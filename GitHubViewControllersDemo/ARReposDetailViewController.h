//
//  ARReposDetailViewController.h
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/22/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARRepo.h"

@interface ARReposDetailViewController : UIViewController

@property (nonatomic, strong) ARRepo *repo;
@property (weak, nonatomic) IBOutlet UIWebView *repoWebView;
@property (nonatomic, strong) NSString *html_url;

@end
