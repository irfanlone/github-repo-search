//
//  KeychainManager.h
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/14/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainManager : NSObject

+ (void)saveAccessTokenToKeyChain:(NSString*)token forKey:(NSString*)key;
+ (void)removeKeyChainForKey:(NSString*)key;
+ (NSString*)valueForKey:(NSString*)key;

@end
