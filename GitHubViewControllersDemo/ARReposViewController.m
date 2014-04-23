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
#import "ARReposDetailViewController.h"
#import "ARNetworkProtocol.h"

@interface ARReposViewController () <UITableViewDelegate, UITableViewDataSource, ARNetworkProtocol>

@property (nonatomic, weak) ARAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *reposViewArray;

@end

@implementation ARReposViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.appDelegate = (ARAppDelegate *)[UIApplication sharedApplication].delegate;
    self.networkController = self.appDelegate.networkController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_networkController retrieveReposForCurrentUser];
    
    self.networkController.delegate = self;
}

- (IBAction)burgerPressed:(id)sender
{
    [self.delegate handleBurgerPress];
}

#pragma mark - Table View delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _reposViewArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ARRepo *repo = _reposViewArray[indexPath.row];
    cell.textLabel.text = repo.name;
    //    cell.imageView.image = repo.authorAvatar;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRepo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ARRepo *repo = [_reposViewArray objectAtIndex:indexPath.row];
        ARReposDetailViewController *rdvc = (ARReposDetailViewController *)segue.destinationViewController;
                
        rdvc.html_url = repo.html_url;
    }
}

- (void)finishedNetworkDownload:(NSMutableArray *)reposArray;
{
    _reposViewArray = reposArray;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}


@end
