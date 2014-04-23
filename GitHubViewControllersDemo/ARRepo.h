//
//  ARRepo.h
//  GithubClient
//
//  Created by Anton Rivera on 4/20/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARRepo : NSObject

- (id)initWithJSON:(NSDictionary *)json;

@property (nonatomic, strong) NSURL *html_url;
@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) UIImage *authorAvatar;
@property (nonatomic, strong) NSData *htmlCache;

@end
