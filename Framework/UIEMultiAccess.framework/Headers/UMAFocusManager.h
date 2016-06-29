//
//  UMAFocusManager.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 10/6/13.
//  Copyright (c) 2013 UIEvolution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMAFocusManager;

/**
 * The delegate for handling events UI element gets active or inactive.
 */
@protocol UMAFocusManagerDelegate <NSObject>
@optional

/**
 * The delegate for handling the event that UI element becomes focused.
 *
 * @param manager    A focus manager
 * @param newView    A view that takes the focus
 * @param oldView    A view that lost the focus
 */
- (void)focusManager:(UMAFocusManager *)manager didFocusChange:(UIView *)newView oldView:(UIView *)oldView;

/**
 * The delegate for handling the the event that UI element gets selected.
 *
 * @param manager    A focus manager
 * @param element    A view that gets selected
 */
- (void)focusManager:(UMAFocusManager *)manager didSelectElement:(UIView *)element;

@end

// The type of the direction that can take focus
typedef NS_ENUM(NSInteger, UMAFocusDirection) {
    kUMAFocusBackward,
    kUMAFocusForward,
    kUMAFocusLeft,
    kUMAFocusRight,
    kUMAFocusUp,
    kUMAFocusDown,
};

/**
 * This class provides a clevar focus management.
 */
@interface UMAFocusManager : NSObject

@property (nonatomic, weak) UIWindow *window; // target window
@property (nonatomic) BOOL wrapping; // Determine whether wrap focus at the end, YES by default.
@property (nonatomic, readonly) NSInteger focusIndex;
@property (nonatomic, readonly) UIView *focusedView;
@property (weak, nonatomic) id<UMAFocusManagerDelegate> delegate;

/*!
 * @discussion Returns focus border visibility.
 *             Default to YES.
 */
@property (nonatomic, getter=isHidden) BOOL hidden;

/**
 * Set visibility for the boder rendered upon focused view, YES by default.
 *
 * @deprecated  Please use hidden property instead.
 */
@property (nonatomic) BOOL showsFocusBorder DEPRECATED_ATTRIBUTE;

/**
 * Instantiate focus manager with specified window.
 *
 * @param window    A window object
 * @return A new instance
 */
- (instancetype)initWithWindow:(UIWindow *)window;

/**
 * Give focus to the view specified as the parameter.
 * This API resets current focus and state.
 *
 * @param view   A root view that managed by the focus manager
 */
- (void)setFocusRootView:(UIView *)view;

/**
 * Give focus to a specific view.
 * The view must belong view hierarchy under specified root.
 *
 * @param   view   A view taking focus
 * @return  Return YES if succeed, otherwise NO
 */
- (BOOL)requestFocus:(UIView *)view;

/**
 * Push current focus state in order to restore it later.
 */
- (void)pushState;

/**
 * Removes current focus state and restoring the previous state.
 */
- (void)popState;

/**
 * Lock focus at the current position, just ignore an input event.
 */
- (void)lock;

/**
 * Unlock focus the lock state.
 */
- (void)unlock;

/**
 * Move forward focus from the current position.
 *
 * @param   steps   An offset from current position
 * @return  YES if it's successfully moved, otherwise NO
 */
- (BOOL)moveFocus:(NSInteger)steps;

/**
 * Move focus to the direction.
 *
 * @param steps     An offset from current position
 * @param direction UMAperFocusDirection
 */
- (BOOL)moveFocus:(NSUInteger)steps direction:(UMAFocusDirection)direction;

/**
 * Send the particular events to the selected view.
 *
 * @param events
 */
- (void)sendUIControlEventToFocusedView:(UIControlEvents)events;

@end

/**
 * The protocol defines methods to operate behavior of UIView
 */
@interface UMAFocusManager(UIViewFocusExtension)

/**
 * Set whether this view can receive this focus
 *
 * @param target  A view to set focusable
 * @param flag    Whether the view is focusable
 */
- (void)setFocusable:(UIView *)target value:(BOOL)value;

/**
 * Set the target view of origin to use when the next focus is direction.
 *
 * @param next    A view that takes next focus
 * @param origin  A view to be set focus movement
 * @param direction
 */
- (void)setNextFocus:(UIView *)next origin:(UIView *)origin direction:(UMAFocusDirection)direction;

@end
