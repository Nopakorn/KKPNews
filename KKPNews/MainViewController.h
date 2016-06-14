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

@interface MainViewController : UIViewController <YTPlayerViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet YTPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UITableView *youtubeTableView;
@property (nonatomic, retain) NSDictionary *playerVars;
@property (strong, nonatomic) Youtube *youtube;
@property (nonatomic, retain) NSMutableArray *imageData;

@end
