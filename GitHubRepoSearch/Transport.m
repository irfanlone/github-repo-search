//
//  Transport.m
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/14/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import "Transport.h"

@implementation TransportResponseObject

- (instancetype)initWithData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error {
    if (self = [super init]) {
        self.data = data;
        self.response = response;
        self.error = error;
    }
    return self;
}

@end


@implementation Transport

- (void)getDataAtUrl:(NSURL *)url completionBlock:(void (^)(BOOL success, TransportResponseObject *responseObject))completionBlock {
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    NSURLSessionDataTask * datatask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        TransportResponseObject *responseObject = [[TransportResponseObject alloc] initWithData:data response:httpResponse error:error];
        NSInteger responseStatusCode = httpResponse.statusCode;
        if(error == nil && (responseStatusCode >= 200 && responseStatusCode <= 299)) {
            completionBlock(YES, responseObject);
        } else {
            completionBlock(NO, nil);
        }
    }];
    [datatask resume];
    [session finishTasksAndInvalidate];
}

@end