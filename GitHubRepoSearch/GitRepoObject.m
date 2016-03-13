//
//  GitRepoObject.m
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/10/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import "GitRepoObject.h"

@implementation GitRepoObject

- (instancetype)initWithTitle:(NSString *)title description:(NSString *)description language:(NSString *)language ownerName:(NSString *)name ownerAvatar:(NSString *)avatar lastUpdateTimeStamp:(NSString *)timeStamp url:(NSString *)url {
    if (self = [super init]) {
        _title = title;
        _respositoryLanguage = language;
        _repositoryDescription = description;
        _ownerName = name;
        _ownerAvatar = avatar;
        _lastUpdateTimeStamp = timeStamp;
        _url = url;
    }
    return self;
}

@end
