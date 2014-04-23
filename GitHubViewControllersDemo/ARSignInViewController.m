//
//  ARSignInViewController.m
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/23/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARSignInViewController.h"
#import "ARNetworkController.h"
#import "ARAppDelegate.h"

@interface ARSignInViewController ()

@property (weak,nonatomic) ARNetworkController *networkController;
@property (weak,nonatomic) ARAppDelegate *appDelegate;

@end

@implementation ARSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.networkController = self.appDelegate.networkController;
    
    if ([self.networkController checkForUserToken])
    {
        
        [self performSegueWithIdentifier:@"goToMenu" sender:self];
    }
    // Do any additional setup after loading the view.
}
- (IBAction)signIn:(id)sender {
    
    [self.networkController requestOAuthAccessWithCompletion:^{
        [self performSegueWithIdentifier:@"goToMenu" sender:self];
    }];
    
}


@end
