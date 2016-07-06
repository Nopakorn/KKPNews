//
//  UMAKeyboardController.h
//  UIEMultiAccess
//
//  Created by Madhu on 7/24/14.
//  Copyright (c) 2014 UIEvolution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UMAKeyboardController;

/*!
 * @class UMAKeyboardControllerDelegate
 *
 * @discussion The delegate type for handling qwerty keybord events.
 */
@protocol UMAKeyboardControllerDelegate <NSObject>
@optional

/*!
 * @method umaKeyboard:didFinishEditing
 *
 * @param controller    A keyboard view controller
 * @param text          A text to input
 */
- (void)umaKeyboard:(UMAKeyboardController *)controller didFinishEditing:(NSString *)text;

/**
 * Invoked when Enter button is clicked.
 *
 * @param controller    A keybord View
 * @param text          An text in the input field.
 *
 * @deprecated          Use umaKeyboard:didFinishEditing instead.
 */
- (void)UMAKeyboardController:(UMAKeyboardController *)controller didFinishEditing:(NSString *)text DEPRECATED_ATTRIBUTE;
@end

/*!
 * @discussion A view controller to represent QWERTY keyboard.
 */
@interface UMAKeyboardController : UIViewController

/*!
 * @property delegate for keyboard view controller.
 */
@property (weak) id<UMAKeyboardControllerDelegate> delegate;

/*!
 * @property defaultText
 * @discussion Default text is shown on the text view.
 */
@property (nonatomic, copy) NSString *defaultText;

/**
 * Sets the input language for Keyboard.
 *
 * @param lang    language  Ex: en, ja
 *
 * @return return true if language is enabled in system other wise false;
 */
- (BOOL)setLanguage :(NSString*)lang;

/**
 *  Set the textView for entering text.
 *
 * @param textView   input textview
 *
 */
- (void) setTextView:(UITextView*)textView;

@end
