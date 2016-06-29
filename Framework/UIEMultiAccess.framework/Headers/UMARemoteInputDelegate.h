//
//  UMARemoteInputDelegate.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 10/8/13.
//  Copyright (c) 2013 UIEvolution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMAInputDevice.h"
#import "UMAWidget.h"

@class UMASpeechRecognizer;
@class UMAEvent;

/**
 * The delegate defines callbacks handling the events input from the remote input device.
 */
@protocol UMARemoteInputDelegate <NSObject>
@optional

/**
 * The callback for handling dial event
 *
 * @param distance      The relative offset from the current position
 * @param direction     kUMARotateClockwise or kUMARotateAntiClockwise
 * @result          YES if your application handles the event and wants to stop event propagation.
 *                  If you app returns NO, UMA library handles event according to default behavior specified 
 *                  in the library.
 */
- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction;

/**
 * The callback for handling the event to translate cursor
 *
 * @param distanceX     The relative offset from the current position along the x-axis
 * @param distanceY     The relative offset from the current position along the y-axis
 * @result          YES if your application handles the event and wants to stop event propagation.
 *                  If you app returns NO, UMA library handles event according to default behavior specified
 *                  in the library.
 */
- (BOOL)umaDidTranslateWithDistance:(NSInteger)distanceX distanceY:(NSInteger)distanceY;

/**
 * The callback for handling the event represents button pressed
 *
 * @param button    A type of button pressed down
 * @result          YES if your application handles the event and wants to stop event propagation.
 *                  If you app returns NO, UMA library handles event according to default behavior specified
 *                  in the library.
 */
- (BOOL)umaDidPressDownButton:(UMAInputButtonType)button;

/**
 * The callback for handling the event represents button pressed up
 *
 * @param button    A type of button pressed up
 * @result          YES if your application handles the event and wants to stop event propagation.
 *                  If you app returns NO, UMA library handles event according to default behavior specified
 *                  in the library.
 */
- (BOOL)umaDidPressUpButton:(UMAInputButtonType)button;

/**
 * The callback invoked when long press event has been detected.
 *
 * This method is deprecated. Use umaDidLongPressButton:state: instead.
 *
 * @param button    A type of button long pressed
 */
- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button DEPRECATED_ATTRIBUTE;

/**
 * The callback invoked when long press event has been detected.
 *
 * @param button    A type of button long pressed
 * @param state     A state of gesture
 */
- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button state:(UMAInputGestureRecognizerState)state;

/**
 * The callback invoked when double click gesture is detected.
 *
 * @param button    A type of button double clicked
 */
- (BOOL)umaDidDoubleClickButton:(UMAInputButtonType)button;

/**
 * The callback invoked when accelerometer update is received.
 *
 * @param acceleration  The acceleration data measured by the accelerometer
 */
- (void)umaDidAccelerometerUpdate:(UMAAcceleration)acceleration;

/**
 * The callback invoked when one or more finger touch in remote display is detected.
 *
 * @param touches   A set of UMATouch instance that represent the touches for the starting phase of the event represented by event.
 * @param event     An object representing the event to which the touches belong.
 */
- (void)umaTouchesBegan:(NSSet *)touches withEvent:(UMAEvent *)event;

/**
 * The callback invoked when one or more finters associated with an event morve within a screen of connected display.
 *
 * @param touches   A set of UMATouch instance that represent the touches for the starting phase of the event represented by event.
 * @param event     An object representing the event to which the touches belong.
 */
- (void)umaTouchesMoved:(NSSet *)touches withEvent:(UMAEvent *)event;

/**
 * The callback invoked when one or more fingeres are raised from a screen of connected display.
 *
 * @param touches   A set of UMATouch instance that represent the touches for the starting phase of the event represented by event.
 * @param event     An object representing the event to which the touches belong.
 */
- (void)umaTouchesEnded:(NSSet *)touches withEvent:(UMAEvent *)event;

/**
 * The callback invoked when a motion event has been cancelled.
 *
 * @param touches   A set of UMATouch instance that represent the touches for the starting phase of the event represented by event.
 * @param event An object representing the event to which the touches belong.
 */
- (void)umaTouchesCancelled:(NSSet *)touches withEvent:(UMAEvent *)event;

@end

// Mixin delegate handling HID events
@interface UIResponder() <UMARemoteInputDelegate>
@end

// Mixin delegate handling HID events
@interface UMAWidget() <UMARemoteInputDelegate>
@end