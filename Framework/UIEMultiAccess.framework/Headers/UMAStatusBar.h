//
//  UMAStatusBar.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 12/1/13.
//  Copyright (c) 2013 UIEvolution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMAApplication.h" // For UMAStatusBarStyle

/**
 * A status bar shown on the second screen.
 */
@interface UMAStatusBar : UIView

@property (nonatomic) UMAStatusBarStyle style;
@property (nonatomic, weak) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *batteryLevelIcon;
@property (nonatomic, weak) IBOutlet UIImageView *signalLevelIcon;
@property (nonatomic, weak) IBOutlet UIImageView *bluetoothStatusIcon;
@property (nonatomic, weak) IBOutlet UIImageView *gpsStatusIcon;

/**
 * Instantiates the status bar view by the specified style.
 *
 * @param UMAStatusBarStyle   A style of the status bar
 * @return instancetype         A view of status bar
 */
+ (instancetype)viewWithStyle:(UMAStatusBarStyle)style;

@end
