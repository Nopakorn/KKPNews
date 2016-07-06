//
//  UMARotarySwitchDevice.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 2/23/14.
//  Copyright (c) 2014 UIEvolution Inc. All rights reserved.
//

#import "UMAInputDevice.h"

@class UMARotarySwitchDevice;

/**
 * The class representing rotary-switch device.
 */
@interface UMARotarySwitchDevice : UMAInputDevice

/**
 * Request HID Device start to notify accelerometer updates.
 *
 * @return BOOL true if it's successfully initiated, otherwise false.
 */
- (BOOL)startAccelerometerNotification;

/**
 * Request HID Device stop to notify accelerometer updates.
 *
 * @return BOOL true if it's successfully initiated, otherwise false.
 */
- (BOOL)stopAccelerometerNotification;

@end
