//
//  FirstScreenViewController.h
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/15/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"
#import "Reachability.h"

@interface FirstScreenViewController : UIViewController<UIAlertViewDelegate>
{
    UIAlertController *alert;
    Reachability *internetReachable;
    Reachability *hostReachable;
}

@property (strong, nonatomic) Youtube *youtube;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spinnerBtmConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *ipadImageScreen;
@end
