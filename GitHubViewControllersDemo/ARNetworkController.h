//
//  ARNetworkController.h
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/22/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARNetworkController : NSObject

- (void)requestOAuthAccessWithCompletion:(void (^)())completionBlock;
- (void)handleOAuthCallbackWithURL:(NSURL *)url;
- (void)getReposForCurrentUser:(void(^)(NSMutableArray *repos))completionBlock;
- (void)getUsersForQuery:(NSString *)query withCompletion:(void(^)(NSMutableArray *array))completionBlock;
- (void)getReposForQuery: (NSString *)query withCompletion:(void(^)(NSMutableArray *array))completionBlock;
- (BOOL)checkForUserToken;

@end
