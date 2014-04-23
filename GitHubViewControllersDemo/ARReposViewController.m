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

@interface ARReposViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) ARAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *reposArray;

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
    
    [_networkController retrieveReposForCurrentUser:^(NSMutableArray *repos) {
        self.reposArray = repos;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
    }];
}

- (IBAction)burgerPressed:(id)sender
{
    [self.delegate handleBurgerPress];
}

#pragma mark - Table View delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _reposArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ARRepo *repo = _reposArray[indexPath.row];
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
    if ([segue.identifier isEqualToString:@"showWebView"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ARRepo *repo = [_reposArray objectAtIndex:indexPath.row];
        ARWebViewController *wvc = (ARWebViewController *)segue.destinationViewController;
                
        wvc.html_url = repo.url;
    }
}


@end
