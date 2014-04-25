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
#import "ARCell.h"
#import "ARUser.h"

@interface ARReposViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) ARAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *userReposArray;
@property (nonatomic, weak) ARNetworkController *networkController;
@property (nonatomic, strong) NSOperationQueue *imageQueue;

@end

@implementation ARReposViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    _appDelegate = (ARAppDelegate *)[UIApplication sharedApplication].delegate;
    _networkController = self.appDelegate.networkController;
    
    [_networkController getReposForCurrentUser:^(NSMutableArray *repos) {
        _userReposArray = repos;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_collectionView reloadData];
        }];
    }];
}

#pragma mark - Table View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _userReposArray.count;
}

- (ARCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ARCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.repoNameLabel.text = [_userReposArray [indexPath.row] name];
    cell.backgroundColor = [UIColor whiteColor];
    cell.avatarImageView.image = [UIImage imageNamed:@"default.png"];;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showWebView"]) {
        NSIndexPath *indexPath = [[_collectionView indexPathsForSelectedItems] objectAtIndex:indexPath.row];
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








