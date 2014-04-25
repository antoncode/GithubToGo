//
//  ARUser.h
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/24/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARRepo.h"

@interface ARUser : ARRepo

@property (nonatomic, strong) NSString *avatarURL;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSBlockOperation *imageDownloadOp;

- (instancetype)initWithJSON:(NSDictionary *)dictionary;
- (void)downloadAvatarWithCompletionBlock:(void(^)())completion;
- (void)downloadAvatarOnQueue:(NSOperationQueue *)queue withCompletionBlock:(void(^)())completion;
//- (void)cancelAvatarDownload;

@end
