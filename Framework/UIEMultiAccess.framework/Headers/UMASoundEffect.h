//
//  UMASoundEffect.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 12/12/13.
//  Copyright (c) 2013 UIEvolution Inc. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

/* Type of sound effects */
typedef NS_ENUM(NSInteger, UMASoundEffectType) {
    kUMASoundEffectDefault,
};

/**
 * This class provides to control sound effects.
 */
@interface UMASoundEffect : NSObject

/**
 * Get the singleton instance
 *
 * @return UMASoundEffect     An instance
 */
+ (instancetype)sharedInstance;

/**
 * Ring specific sound effect
 *
 * @return BOOL YES if it is successuflly played, otherwise NO
 */
- (BOOL)play:(UMASoundEffectType)type;

/**
 * Stop the sound effect.
 *
 * @return BOOL YES if it is successuflly stopped, otherwise NO
 */
- (BOOL)stop;

@end
