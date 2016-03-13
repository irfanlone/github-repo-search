//
//  KeychainManager.m
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/14/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import "KeychainManager.h"
#import "UICKeychainStore.h"

@implementation KeychainManager

+ (void)saveAccessTokenToKeyChain:(NSString*)token forKey:(NSString*)key {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.example.github-token"];
    NSError *error;
    [keychain setString:token forKey:key error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
}

+ (void)removeKeyChainForKey:(NSString*)key {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.example.github-token"];
    NSError *error;
    [keychain removeItemForKey:key error:&error];
    if (error) {
        NSLog(@"Error in removing keychain value : %@",error.localizedDescription);
    }
}

+ (NSString*)valueForKey:(NSString*)key {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.example.github-token"];
    NSError *error;
    NSString *token = [keychain stringForKey:key error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return nil;
    }
    return token;
}

@end
