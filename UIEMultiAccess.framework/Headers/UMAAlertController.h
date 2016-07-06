//
//  UMAAlertController.h
//  UIE MultiAccess
//
//  Created by hkoide on 6/18/15.
//  Copyright (c) 2015 UIEvolution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIEMultiAccess/UMAFocusManager.h>

typedef NS_ENUM(NSInteger, UMAAlertActionStyle) {
  UMAAlertActionStyleDefault = 0,
  UMAAlertActionStyleCancel,
  UMAAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, UMAAlertControllerStyle) {
  UMAAlertControllerStyleAlert = 0,
  UMAAlertControllerStyleActionSheet,
};


/**
 * This class emulates UIAlertAction.
 */
@interface UMAAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title style:(UMAAlertActionStyle)style handler:(void (^)(UMAAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UMAAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end


/**
 * UIAlertController compatible class supporting second screen and touch / focus management.
 * Specification is compatible with UIAlertController, except followings.
 *
 * - Can be used for iOS7 or later
 * - Should be presented by using presentAlertController method defined in UIViewController category (UMAAlertController)
 * - No textFields property for alert-style
 * - If controller has 2 actions for alert-style, they will be displayed vertically
 * - If controller has cancel-style action, it will not be displayed separately
 * - Popover presentation will not be used for iPad
 * - Height of title / message label is limited for view size, and does not scroll
 */
@interface UMAAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UMAAlertControllerStyle)preferredStyle;

- (void)addAction:(UMAAlertAction *)action;
@property (nonatomic, readonly) NSArray *actions;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, readonly) UMAAlertControllerStyle preferredStyle;


/**
 * Focus manager used in alert / action sheet, default is nil.
 */
@property (weak) UMAFocusManager *focusManager;

@end


/**
 * UIViewController additional category for presenting UMAAlertController.
 */
@interface UIViewController (UMAAlertController)

/**
 * This function should be used for presenting UMAAlertController.
 *
 * @param alertController    UMAAlertController instance
 * @param flag    animation flag
 * @param completion    completion callback
 */
- (void)presentAlertController:(UMAAlertController *)alertController animated:(BOOL)flag completion:(void (^)(void))completion;

@end
