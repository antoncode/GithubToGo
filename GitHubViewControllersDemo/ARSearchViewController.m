//
//  ARSearchViewController.m
//  githubdemo
//
//  Created by Anton Rivera on 4/21/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARSearchViewController.h"
#import "ARSearchDetailViewController.h"
#import "ARRepo.h"

@interface ARSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *repos;

@end

@implementation ARSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self getReposForQuery:@"iOS"];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self getReposForQuery:searchBar.text];
}

- (void)getReposForQuery:(NSString *)query
{
    NSOperationQueue *downloadQueue = [NSOperationQueue new];
    [downloadQueue addOperationWithBlock:^{
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
        
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        
        [mainQueue addOperationWithBlock:^{
            _repos = tempRepos;
            [self.tableView reloadData];
        }];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _repos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepoCell" forIndexPath:indexPath];
    
    ARRepo *repo = _repos[indexPath.row];
    cell.textLabel.text = repo.name;
    cell.imageView.image = repo.authorAvatar;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARRepo *repo = _repos[indexPath.row];
    _searchDetailViewController.repo = repo;
    
    
}

- (IBAction)burgerPressed:(id)sender
{
    [self.delegate handleBurgerPress];
}



@end
