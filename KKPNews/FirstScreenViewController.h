//
//  FirstScreenViewController.h
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/15/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"

@interface FirstScreenViewController : UIViewController<UIAlertViewDelegate>


@property (strong, nonatomic) Youtube *youtube;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
