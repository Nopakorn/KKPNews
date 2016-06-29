//
//  UMAMiniPlayer.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 12/5/13.
//  Copyright (c) 2013 UIEvolution Inc. All rights reserved.
//

@class UMAWidget;
@class UMAFocusManager;
@class MiniPlayerProgressBar;
@class MiniPlayerVolumeSlider;
@class MPMediaQuery;
@class UMAMiniPlayer;

/* Type of mini player widget */
typedef NS_ENUM(NSInteger, UMAMiniPlayerStyle) {
    kUMAMiniPlayerStyleDefault,
    kUMAMiniPlayerStyle720p,
    kUMAMiniPlayerStyle1080p,
};

/* Mode of mini player widget */
typedef NS_ENUM(NSInteger, UMAMiniPlayerMode) {
    kUMAMiniPlayerModeOperatable, /* default */
    kUMAMiniPlayerModeViewer,
};

// Delegate for events on UMAMiniPlayer
@protocol UMAMiniPlayerDelegate <NSObject>
@optional
- (void)requestDismiss:(UMAMiniPlayer*)miniPlayer;
@end

/**
 * The widget provides a control center to manage multimedia contents such as music.
 */
@interface UMAMiniPlayer : UMAWidget

/**
 * Create a mini player view by specified style.
 *
 * @param UMAMiniPlayerStyle
 */
+ (instancetype)viewWithStyle:(UMAMiniPlayerStyle)style;

/**
 * Displayes a widget that originates from the specifed view
 *
 * @param UIView view   The view from which the widget originates
 */
- (void)showInView:(UIView *)view;

/**
 * Dismiss the widget immediately
 */
- (void)dismiss;

/**
 * Set initial (hidden) position of the widget
 */
- (void)setInitialPosition:(CGPoint)pt;

/**
 * Set dismiss timer of the widget (default is no timer)
 */
- (void)setDismissTimer:(float)duration;

/**
 * Set/get mode of focus behavior (has the focus or not)
 */
- (void)setMode:(UMAMiniPlayerMode)mode;
- (UMAMiniPlayerMode)getMode;

@property (nonatomic, weak) id<UMAMiniPlayerDelegate> delegate;
@property (nonatomic, strong) MPMediaQuery *mediaQuery;
@property (nonatomic, weak) IBOutlet UIImageView *artworkView;
@property (nonatomic, weak) IBOutlet UILabel *songTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UIButton *prevTrackButton;
@property (nonatomic, weak) IBOutlet UIButton *nextTrackButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *volumeViewButton;
@property (nonatomic, weak) IBOutlet UIImageView *volumeDownIcon;
@property (nonatomic, weak) IBOutlet MiniPlayerVolumeSlider *volumeSlider;
@property (nonatomic, weak) IBOutlet MiniPlayerProgressBar *progressBar;

@end
