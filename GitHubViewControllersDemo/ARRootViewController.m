//
//  ARRootViewController.m
//  githubdemo
//
//  Created by Anton Rivera on 4/21/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARRootViewController.h"
#import "ARReposViewController.h"
#import "ARUsersViewController.h"
#import "ARSearchViewController.h"

@interface ARRootViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, ARBurgerProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayOfViewControllers;
@property (nonatomic, strong) UIViewController *topViewController;
@property (nonatomic, strong) UITapGestureRecognizer *tapToClose;
@property (nonatomic) BOOL menuIsOpen;

@end

@implementation ARRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.userInteractionEnabled = NO;

    [self setUpChildViewControllers];
    [self setUpDrag];
}

- (void)setUpChildViewControllers
{
    ARReposViewController *repoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"repos"];
    repoViewController.title = @"My Repos";
    repoViewController.delegate = self;
    
    ARUsersViewController *usersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"users"];
    usersViewController.title = @"Folowing";
    usersViewController.delegate = self;
    
    ARSearchViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
    searchViewController.title = @"Search";
    usersViewController.delegate = self;
    
    _arrayOfViewControllers = @[repoViewController, usersViewController, searchViewController];
    
    _topViewController = _arrayOfViewControllers[0];
    
    [self addChildViewController:_topViewController];
    // repoViewController.view.frame = self.view.frame; // Take up whole screen, not needed because instantiated in storyboard
    [self.view addSubview:_topViewController.view];
    [_topViewController didMoveToParentViewController:self];
}

- (void)setUpDrag
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    
    panRecognizer.minimumNumberOfTouches = 1;   // # of fingers needed to Pan, default is 1
    panRecognizer.maximumNumberOfTouches = 1;
    
    panRecognizer.delegate = self;
    
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)movePanel:(id)sender
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
    
//    [[[pan view] layer] removeAllAnimations];     // Clears all animations before gesture starts
    
    CGPoint translatedPoint = [pan translationInView:self.view];
//    CGPoint velocity = [pan velocityInView:self.view];
//    NSLog(@"translation: %@", NSStringFromCGPoint(translatedPoint));    // Amount moved
//    NSLog(@"velocity: %@", NSStringFromCGPoint(velocity));      // Speed of geture
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        if (translatedPoint.x > 0) {
            _topViewController.view.center = CGPointMake(_topViewController.view.center.x + translatedPoint.x, _topViewController.view.center.y);     // Panning on x axis only
            
            [pan setTranslation:CGPointZero inView:self.view];    // resets
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (_topViewController.view.frame.origin.x > self.view.frame.size.width / 3) {    // if slide is more than 1/3 of screen
            [self openMenu];
        } else {
            [UIView animateWithDuration:.4 animations:^{
                _topViewController.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
}

#pragma mark - Helper methods

- (void)closeMenu:(id)sender
{
    [UIView animateWithDuration:.5 animations:^{
        _topViewController.view.frame = self.view.frame;
    } completion:^(BOOL finished) {
        [_topViewController.view removeGestureRecognizer:_tapToClose];
        _menuIsOpen = NO;
    }];
}

- (void)openMenu
{
    [UIView animateWithDuration:.4 animations:^{
        _topViewController.view.frame = CGRectMake(self.view.frame.size.width * 0.75, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            _tapToClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu:)];
            [_topViewController.view addGestureRecognizer:_tapToClose];
            _menuIsOpen = YES;
            _tableView.userInteractionEnabled = YES;
        }
    }];
}

-(void)switchToViewControllerAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView animateWithDuration:.2 animations:^{
        _topViewController.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        CGRect offScreen = _topViewController.view.frame;
        
        [_topViewController.view removeFromSuperview];
        [_topViewController removeFromParentViewController];
        
        _topViewController = _arrayOfViewControllers[indexPath.row];
        [self addChildViewController:_topViewController];
        _topViewController.view.frame = offScreen;
        
        [self.view addSubview:_topViewController.view];
        
        [_topViewController didMoveToParentViewController:self];  // recalls viewdidload, etc.
        
        [self closeMenu:nil];
    }];
}

- (void) handleBurgerPress
{
    if (_menuIsOpen) {
        [self closeMenu:nil];
    } else {
        [self openMenu];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayOfViewControllers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.arrayOfViewControllers[indexPath.row] title];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self switchToViewControllerAtIndexPath:(indexPath)];
}

@end
















