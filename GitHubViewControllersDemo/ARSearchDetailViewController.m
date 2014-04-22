//
//  ARSearchDetailViewController.m
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/21/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARSearchDetailViewController.h"

@interface ARSearchDetailViewController ()

- (void)configureView;

@end

@implementation ARSearchDetailViewController

- (void)setRepo:(id)newRepo
{
    if (_repo != newRepo) {
        _repo = newRepo;
        
        // Update the view.
        [self configureView];
    }
    
//    if (self.masterPopoverController != nil) {
//        [self.masterPopoverController dismissPopoverAnimated:YES];
//    }
    
    NSLog(@"Repo URL: %@", _repo.html_url);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.repo.html_url) {
        if (!self.repo.htmlCache) {
            NSData *cacheData = [NSData dataWithContentsOfURL:_repo.html_url];
            NSString *cacheString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
            _repo.htmlCache = cacheString;
            [self configureView];
        } else {
            [_repoWebView loadHTMLString:_repo.htmlCache baseURL:nil];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}
@end
