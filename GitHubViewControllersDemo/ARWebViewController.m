//
//  ARWebViewController.m
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/23/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARWebViewController.h"

@interface ARWebViewController ()

@end

@implementation ARWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.html_url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:604800];
    [_webView loadRequest:urlRequest];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

@end
