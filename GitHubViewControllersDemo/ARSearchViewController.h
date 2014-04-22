//
//  ARSearchViewController.h
//  githubdemo
//
//  Created by Anton Rivera on 4/21/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARBurgerProtocol.h"

@class ARSearchDetailViewController;

@interface ARSearchViewController : UIViewController

@property (nonatomic, unsafe_unretained) id<ARBurgerProtocol> delegate;
@property (nonatomic, strong) ARSearchDetailViewController *searchDetailViewController;

@end
