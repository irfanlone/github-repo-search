//
//  GitRepoObject.h
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/10/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitRepoObject : NSObject

@property (nonatomic, strong) NSNumber * identifier;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * repositoryDescription;
@property (nonatomic, strong) NSString * respositoryLanguage;
@property (nonatomic, strong) NSString * ownerName;
@property (nonatomic, strong) NSString * ownerAvatar;
@property (nonatomic, strong) NSString * lastUpdateTimeStamp;
@property (nonatomic, strong) NSString * url;

@end
