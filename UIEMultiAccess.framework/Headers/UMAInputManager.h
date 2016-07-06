//
//  UMAInputManager.h
//  UIEMultiAccess
//
//  Created by Madhu on 4/29/15.
//  Copyright (c) 2015 UIEvolution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, UMAInputMethod) {
    kUMAInputMethodKeyBoardQwerty,
    kUMAInputMethodKeyBoardRotary,
    kUMAInputMethodKeyBoardHUNativeSoft, // Can not be used on this build
    kUMAInputMethodVoice,
};
typedef NS_ENUM(NSInteger, UMAInputLanguage) {
    kUMAInputLanguageEnglish,
    kUMAInputLanguageChinese,
    kUMAInputLanguageJapanese,
    kUMAInputLanguageSpanish,
};

/*!
 * @class UMAInputManagerDelegate
 *
 * @discussion The delegate type for handling Input manger.
 */
@class UMAInputManager;
@protocol UMAInputManagerDelegate <NSObject>
@required

/*!
 * @method umaInputManager:didInputFinish:result:
 *
 * @param manager       Input Manager
 *
 * @param textview      TextView of Application
 *
 * @param text          A text to input
 */
- (void)umaInputManager:(UMAInputManager *)manager didInputFinish:(UITextView*)textview result:(NSString *)text;

/*!
 * @method umaInputManager:didInputError:errorCode:errorMsg:
 *
 * @param manager       Input Manager
 *
 * @param textview      TextView of Application
 *
 * @param errorCode     Error code
 *
 * @param errorMsg      Error Message
 */
- (void)umaInputManager:(UMAInputManager *)manager didInputError:(UITextView*)textview errorCode:(NSUInteger)code errorMsg:(NSString *)errormsg;

@end

@interface UMAInputManager : NSObject
/*!
 * @property delegate for Input Manager.
 */
@property (weak) id<UMAInputManagerDelegate> delegate;
/*!
 * @property inputLang  input Language. by default it is system language.
 */
@property (nonatomic) UMAInputLanguage inputLang;

/*!
 * @property textViewTitle  Title for TextView. it is mainly used in case of kUMAInputMethodKeyBoardHUNativeSoft type. other cases this value ignored.
 */
@property (nonatomic) NSString* textViewTitle;

/*!
 * @method initWithTextView
 *
 * @discussion  Intialize input manager with input Method.
 *
 * @param textView   TextView of application
 *
 * @param method     input Method
 *
 * @return the UMAInputManager instance.
 */

-(instancetype)initWithTextView:(UITextView *)textView inputMethod : (UMAInputMethod) method;

/*!
 * @method becomeFirstResponder
 *
 * @discussion  It will launch the keyboard
 *
 */

- (BOOL)becomeFirstResponder;

/*!
 * @method resignFirstResponder
 *
 *  @discussion .
 */

- (BOOL)resignFirstResponder;

@end
