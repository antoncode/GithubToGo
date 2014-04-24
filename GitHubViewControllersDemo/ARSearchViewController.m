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

@interface ARSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) ARAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (weak, nonatomic) ARNetworkController *networkController;

@end

@implementation ARSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _searchArray = [NSMutableArray new];
    
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.networkController = self.appDelegate.networkController;
    
    _networkController.query = @"iOS";
    [_networkController getReposForQuery:^(NSMutableArray *array) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _searchArray = array;
            [self.tableView reloadData];
        }];
    }];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _networkController.query = searchBar.text;
    
    [_networkController getReposForQuery:^(NSMutableArray *array) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _searchArray = array;
            [self.tableView reloadData];
        }];
    }];
     
    [searchBar resignFirstResponder];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ARRepo *repo = _searchArray[indexPath.row];
    cell.textLabel.text = repo.name;
    cell.imageView.image = repo.userAvatar;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_tableView reloadData];
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
        ARRepo *repo = [_searchArray objectAtIndex:indexPath.row];
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


















