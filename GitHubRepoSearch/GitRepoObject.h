//
//  GitRepoObject.h
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/10/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitRepoObject : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithTitle:(NSString *)title description:(NSString *)description language:(NSString *)language ownerName:(NSString *)name ownerAvatar:(NSString *)avatar lastUpdateTimeStamp:(NSString *)timeStamp url:(NSString *)url NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSString * title;
@property (nonatomic, readonly) NSString * repositoryDescription;
@property (nonatomic, readonly) NSString * respositoryLanguage;
@property (nonatomic, readonly) NSString * ownerName;
@property (nonatomic, readonly) NSString * ownerAvatar;
@property (nonatomic, readonly) NSString * lastUpdateTimeStamp;
@property (nonatomic, readonly) NSString * url;

@end
