//
//  ARUser.m
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/24/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARUser.h"

@implementation ARUser

- (instancetype)initWithJSON:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.name = [dictionary objectForKey:@"login"];
        self.html_url = [dictionary objectForKey:@"html_url"];
        self.avatarURL = [dictionary objectForKey:@"avatar_url"];
    }
    return self;
}

- (void)downloadAvatarWithCompletionBlock:(void (^)())completion
{
    [self downloadAvatarOnQueue:[NSOperationQueue new] withCompletionBlock:completion];
}

- (void)downloadAvatarOnQueue:(NSOperationQueue *)queue withCompletionBlock:(void(^)())completion
{
    self.imageDownloadOp = [NSBlockOperation blockOperationWithBlock:^{
        NSData *avatarData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.avatarURL]];
        self.avatarImage = [UIImage imageWithData:avatarData];
        [[NSOperationQueue mainQueue] addOperationWithBlock:completion];
    }];
    
    [queue addOperation:self.imageDownloadOp];
}

//- (void)cancelAvatarDownload
//{
//    if (!self.imageDownloadOp.isExecuting)
//    {
//        [self.imageDownloadOp cancel];
//    }
//}


@end
