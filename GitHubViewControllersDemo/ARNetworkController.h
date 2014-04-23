//
//  ARNetworkController.h
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/22/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARNetworkProtocol.h"

@interface ARNetworkController : NSObject

@property (nonatomic, strong) NSMutableArray *reposArray;
@property (nonatomic, unsafe_unretained) id<ARNetworkProtocol> delegate;

- (void)requestOAuthAccess;
- (void)handleOAuthCallbackWithURL:(NSURL *)url;
- (void)retrieveReposForCurrentUser;

@end
