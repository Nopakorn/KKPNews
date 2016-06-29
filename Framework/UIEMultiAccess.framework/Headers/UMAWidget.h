//
//  UMAWidget.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 12/1/13.
//  Copyright (c) 2013 UIEvolution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * The base class of UMA widget.
 */
@interface UMAWidget : UIView

/**
 * Become first responder in the parent view
 */
- (BOOL)becomeFirstResponder;

/**
 * Returns whether it's a first responder in the parent view
 *
 * @return BOOL     YES if it's first responder, otherwise NO
 */
- (BOOL)isFirstResponder;

/**
 * Relinquish its status as first responder in the parent view
 */
- (BOOL)resignFirstResponder;

@end
