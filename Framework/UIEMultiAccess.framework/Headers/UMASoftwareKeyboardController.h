//
//  UMASoftwareKeyboardController.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 5/8/14.
//  Copyright (c) 2014 UIEvolution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIEMultiAccess/UIEMultiAccess.h>

@class UMASoftwareKeyboardController;

/**
 * Type of language.
 */
typedef enum {
    UMA_SKB_LANGUAGE_ENGLISH = 0,
    UMA_SKB_LANGUAGE_JAPANESE,
    UMA_SKB_LANGUAGE_CHINESE
} UMASoftwareKeyboardLanguage;

/**
 * The delegate type for handling software keybord events.
 */
@protocol UMASoftwareKeyboardControllerDelegate <NSObject>
@optional

/**
 * Invoked when OK button is clicked.
 *
 * @param controller    A keybord controller
 * @param text          An text in the input field.
 */
- (void)umaKeyboard:(UMASoftwareKeyboardController *)controller didEndEditing:(NSString *)text;

@end

/**
 * A view controller to represent software keyboard.
 */
@interface UMASoftwareKeyboardController : UIViewController

@property (nonatomic) NSString *defaultText; // A default text in the input field.
@property (weak) id<UMASoftwareKeyboardControllerDelegate> delegate;

/**
 * Initialize keyboard view controller by default settings.
 *
 * @return A keyboard view controller
 */
- (instancetype)init;
- (instancetype)initWithLanguage:(UMASoftwareKeyboardLanguage)language;
- (instancetype)initWithFocusManager:(UMAFocusManager *)focusManager;
- (instancetype)initWithFocusManager:(UMAFocusManager *)focusManager language:(UMASoftwareKeyboardLanguage)language;

@end
