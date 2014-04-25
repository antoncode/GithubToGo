//
//  ARRepo.h
//  GithubClient
//
//  Created by Anton Rivera on 4/20/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARRepo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *html_url;

- (instancetype)initWithName:(NSDictionary *)dictionary;

@end
