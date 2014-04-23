//
//  ARWebViewController.h
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/23/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARRepo.h"

@interface ARWebViewController : UIViewController

@property (nonatomic, strong) ARRepo *repo;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *html_url;

@end
