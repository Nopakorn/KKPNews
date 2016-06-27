//
//  MainViewController.h
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/13/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
#import "Youtube.h"

@interface MainViewController : UIViewController <YTPlayerViewDelegate, UITableViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource>
{
    UIActivityIndicatorView *spinner;
    NSTimer *hidingView;
}

@property (strong, nonatomic) IBOutlet YTPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UITableView *youtubeTableView;
@property (nonatomic, retain) NSDictionary *playerVars;
@property (strong, nonatomic) Youtube *youtube;
@property (nonatomic, retain) NSMutableArray *imageData;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)buttonPressed:(id)sender;
@property (strong, nonatomic) NSTimer *timerProgress;
@property (nonatomic) NSTimeInterval playerTotalTime;

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

- (IBAction)refeshButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (nonatomic) BOOL regionJp;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btmControlAreaConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heighDateAreaConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightControllerAreaConstraint;

@property (weak, nonatomic) IBOutlet UIView *controllerAreaView;

@property (weak, nonatomic) IBOutlet UIView *dateAreaView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerViewTrailingConstraint;
@end
