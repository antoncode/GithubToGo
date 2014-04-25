//
//  ARRepo.m
//  GithubClient
//
//  Created by Anton Rivera on 4/20/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARRepo.h"

@implementation ARRepo

- (instancetype)initWithName:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        self.name = [dictionary objectForKey:@"name"];
        self.html_url = [dictionary objectForKey:@"html_url"];
    }
    return self;
}
@end
