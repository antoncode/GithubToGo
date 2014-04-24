//
//  ARNetworkController.h
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/22/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARNetworkController : NSObject

@property (nonatomic, strong) NSMutableArray *reposArray;
@property (nonatomic, strong) NSString *query;

- (void)requestOAuthAccessWithCompletion:(void (^)())completionBlock;
- (void)handleOAuthCallbackWithURL:(NSURL *)url;
- (void)retrieveReposForCurrentUser:(void(^)(NSMutableArray *repos))completionBlock;
- (BOOL)checkForUserToken;
- (void)getReposForQuery:(void(^)(NSMutableArray *array))completionBlock;

@end
