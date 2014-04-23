//
//  ARNetworkProtocol.h
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/22/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ARNetworkProtocol <NSObject>

- (void)finishedNetworkDownload:(NSMutableArray *)reposArray;

@end
