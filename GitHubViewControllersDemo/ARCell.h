//
//  ARCell.h
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/24/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *repoNameLabel;

@end
