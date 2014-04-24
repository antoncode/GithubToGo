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
    
    [self getReposForQuery:@"iOS"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self getReposForQuery:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)getReposForQuery:(NSString *)query
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("com.Rivera.Anton.downloadQueue", NULL);
    dispatch_async(downloadQueue, ^{
        NSString *searchURLString = [NSString stringWithFormat:@"https://api.github.com/search/repositories?q=%@", query];
        NSURL *searchURL = [NSURL URLWithString:searchURLString];
        NSData *searchData = [NSData dataWithContentsOfURL:searchURL];
        NSDictionary *searchDict = [NSJSONSerialization JSONObjectWithData:searchData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
        
        NSMutableArray *tempRepos = [NSMutableArray new];
        
        for (NSDictionary *repo in [searchDict objectForKey:@"items"]) {
            ARRepo *downloadedRepo = [[ARRepo alloc] initWithJSON:repo];
            [tempRepos addObject:downloadedRepo];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _searchArray = tempRepos;
            [self.tableView reloadData];
        });
    });
    
//    NSOperationQueue *downloadQueue = [NSOperationQueue new];
//    [downloadQueue addOperationWithBlock:^{
//        NSString *searchURLString = [NSString stringWithFormat:@"https://api.github.com/search/repositories?q=%@", query];
//        NSURL *searchURL = [NSURL URLWithString:searchURLString];
//        NSData *searchData = [NSData dataWithContentsOfURL:searchURL];
//        NSDictionary *searchDict = [NSJSONSerialization JSONObjectWithData:searchData
//                                                                   options:NSJSONReadingMutableContainers
//                                                                     error:nil];
//        
//        NSMutableArray *tempRepos = [NSMutableArray new];
//        
//        for (NSDictionary *repo in [searchDict objectForKey:@"items"]) {
//            ARRepo *downloadedRepo = [[ARRepo alloc] initWithJSON:repo];
//            [tempRepos addObject:downloadedRepo];
//        }
//        
//        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
//        [mainQueue addOperationWithBlock:^{
//            _repos = tempRepos;
//            [self.tableView reloadData];
//        }];
//    }];
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


















