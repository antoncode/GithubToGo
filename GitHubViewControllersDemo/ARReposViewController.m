//
//  ARReposViewController.m
//  githubdemo
//
//  Created by Anton Rivera on 4/21/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARReposViewController.h"
#import "ARAppDelegate.h"
#import "ARRepo.h"
#import "ARWebViewController.h"
#import "ARNetworkController.h"

@interface ARReposViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) ARAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *userReposArray;
@property (nonatomic, weak) ARNetworkController *networkController;

@end

@implementation ARReposViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _appDelegate = (ARAppDelegate *)[UIApplication sharedApplication].delegate;
    _networkController = self.appDelegate.networkController;
    
    [_networkController getReposForCurrentUser:^(NSMutableArray *repos) {
        _userReposArray = repos;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_tableView reloadData];
        }];
    }];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userReposArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ARRepo *repo = _userReposArray[indexPath.row];
    cell.textLabel.text = repo.name;
    
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
        ARRepo *repo = [_userReposArray objectAtIndex:indexPath.row];
        ARWebViewController *wvc = (ARWebViewController *)segue.destinationViewController;
                
        wvc.html_url = repo.html_url;
    }
}

#pragma mark - Other

- (IBAction)burgerPressed:(id)sender
{
    [self.delegate handleBurgerPress];
}


@end








