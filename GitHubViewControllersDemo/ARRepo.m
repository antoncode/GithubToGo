//
//  ARRepo.m
//  GithubClient
//
//  Created by Anton Rivera on 4/20/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARRepo.h"

@implementation ARRepo

- (id)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        self.name = [json objectForKey:@"name"];
        self.html_url = [NSURL URLWithString:[json objectForKey:@"html_url"]];
        
        NSURL *avatarURL = [NSURL URLWithString:[json[@"owner"] objectForKey:@"avatar_url"]];
        [self downloadImageForURL:avatarURL];
    }
    
    return self;
}

- (void)downloadImageForURL:(NSURL *)url
{
    NSOperationQueue *downloadQueue = [NSOperationQueue new];
    [downloadQueue addOperationWithBlock:^{
        NSData *avatarData = [NSData dataWithContentsOfURL:url];
        self.authorAvatar = [UIImage imageWithData:avatarData];
    }];
}

@end
