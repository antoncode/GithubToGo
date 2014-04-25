//
//  ARSearchViewController.m
//  githubdemo
//
//  Created by Anton Rivera on 4/21/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARSearchViewController.h"
#import "ARAppDelegate.h"
#import "ARRepo.h"
#import "ARWebViewController.h"
#import "ARNetworkController.h"
#import "ARUser.h"

@interface ARSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) ARAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *repoSearchArray;
@property (weak, nonatomic) ARNetworkController *networkController;
@property (nonatomic, strong) NSOperationQueue *imageQueue;


@end

@implementation ARSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    _searchBar.delegate = self;
    
    _repoSearchArray = [NSMutableArray new];
    
    _appDelegate = [UIApplication sharedApplication].delegate;
    _networkController = _appDelegate.networkController;
    
    [_networkController getReposForQuery:@"iOS" withCompletion:^(NSMutableArray *array) {
        _repoSearchArray = array;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_tableView reloadData];
        }];
    }];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [_networkController getReposForQuery:searchBar.text withCompletion:^(NSMutableArray *array) {
        _repoSearchArray = array;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_tableView reloadData];
        }];
    }];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _repoSearchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ARRepo *repo = _repoSearchArray[indexPath.row];
    cell.textLabel.text = repo.name;
    
//    if (user.avatarImage)
//    {
//        cell.imageView.image = user.avatarImage;
//    } else {
//        [user downloadAvatarOnQueue:_imageQueue withCompletionBlock:^{
//            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//        }];
//    }    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [tableView reloadData];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWebView"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ARRepo *repo = [_repoSearchArray objectAtIndex:indexPath.row];
        ARWebViewController *wvc = (ARWebViewController *)segue.destinationViewController;
        
        wvc.html_url = repo.html_url;
    }
}

# pragma mark - Other

- (IBAction)burgerPressed:(id)sender
{
    [self.delegate handleBurgerPress];
}

@end


















