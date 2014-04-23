//
//  ARReposDetailViewController.m
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/22/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARReposDetailViewController.h"

@interface ARReposDetailViewController ()

@end

@implementation ARReposDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
}

- (void)configureView
{
    //    if (self.html_url) {
    //        if (!_repo.htmlCache) {
    //            NSData *cacheData = [NSData dataWithContentsOfURL:_html_url];
    //            _repo.htmlCache = cacheData;
    //            [self configureView];
    //        } else {
    //            [_repoWebView loadData:_repo.htmlCache MIMEType:nil textEncodingName:nil baseURL:nil];
    //        }
    //    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.html_url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:604800];
    [_repoWebView loadRequest:urlRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

@end
