//
//  Transport.h
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/14/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransportResponseObject : NSObject

@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSHTTPURLResponse *response;
@property (strong, nonatomic) NSError *error;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error NS_DESIGNATED_INITIALIZER;

@end



@interface Transport : NSObject

- (void)getDataAtUrl:(NSURL *)url completionBlock:(void (^)(BOOL success, TransportResponseObject *responseObject))completionBlock;

@end
