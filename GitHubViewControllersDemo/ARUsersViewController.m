//
//  ARUsersViewController.m
//  githubdemo
//
//  Created by Anton Rivera on 4/21/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARUsersViewController.h"
#import "ARRepo.h"
#import "ARWebViewController.h"

@interface ARUsersViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *usersArray;

@end

@implementation ARUsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _usersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ARRepo *repo = _usersArray[indexPath.row];
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
        ARRepo *repo = [_usersArray objectAtIndex:indexPath.row];
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
