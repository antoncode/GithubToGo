//
//  ARUsersViewController.m
//  githubdemo
//
//  Created by Anton Rivera on 4/21/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARUsersViewController.h"
#import "ARAppDelegate.h"
#import "ARRepo.h"
#import "ARWebViewController.h"
#import "ARNetworkController.h"
#import "ARUser.h"

@interface ARUsersViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) ARAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *usersSearchArray;
@property (nonatomic, weak) ARNetworkController *networkController;
@property (nonatomic, strong) NSOperationQueue *imageQueue;

@end

@implementation ARUsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    _searchBar.delegate = self;

    _appDelegate = [UIApplication sharedApplication].delegate;
    _networkController = self.appDelegate.networkController;
    
    _imageQueue = [NSOperationQueue new];
    
//    [_networkController getUsersForQuery:@"bob" withCompletion:^(NSMutableArray *array) {
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            _usersSearchArray = array;
//            [_tableView reloadData];
//        }];
//    }];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [_networkController getUsersForQuery:searchBar.text withCompletion:^(NSMutableArray *array) {
        _usersSearchArray = array;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_tableView reloadData];
        }];
    }];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _usersSearchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ARUser *user = _usersSearchArray[indexPath.row];
    cell.textLabel.text = [_usersSearchArray[indexPath.row] name];
    if (user.avatarImage)
    {
        cell.imageView.image = user.avatarImage;
    } else {
        [user downloadAvatarOnQueue:_imageQueue withCompletionBlock:^{
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWebView"]) {
        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
        ARRepo *repo = [_usersSearchArray objectAtIndex:indexPath.row];
        ARWebViewController *sdvc = (ARWebViewController *)segue.destinationViewController;
        
        sdvc.html_url = repo.html_url;
    }
}

#pragma mark - Other

- (IBAction)burgerPressed:(id)sender
{
    [self.delegate handleBurgerPress];
}


@end
