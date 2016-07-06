//
//  UMAInputDevice.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 9/19/13.
//  Copyright (c) 2013 UIEvolution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UMAInputDevice;
@class UMAHIDManager;

/**
 * The type of a remote input device.
 */
typedef NS_ENUM(NSInteger, UMAInputDeviceType) {
    kUMAInputDeviceRotarySwitch,              // A device having rotary control
    kUMAInputDeviceSteeringSwitch,            // A device that put on a steering.
    kUMAInputDeviceTouchDigitizer,            // A touch panel, it's usually connected display itself.
    kUMAInputDeviceEmulator,                  // A HID Report Host emulator
};

/**
 * The type of rotate direction.
 */
typedef NS_ENUM(NSInteger, UMADialDirection) {
    kUMARotateClockwise,
    kUMARotateAntiClockwise,
};

/**
 * The type of a structure containing 3-axis acceleration values.
 */
typedef struct _UMAAcceleration {
    double x;
    double y;
    double z;
} UMAAcceleration;

/**
 * The type of connection state.
 */
typedef NS_ENUM(NSInteger, UMAInputDeviceState) {
    kUMAInputDeviceStateDisconnected = 0,
    kUMAInputDeviceStateConnecting,
    kUMAInputDeviceStateConnected,
};

/**
 * The type of HID device vendor.
 */
typedef NS_ENUM(NSInteger, UMAInputDeviceVendor) {
    kUMAInputDeviceVendorUnknown = 0,
    kUMAInputDeviceVendorDENSO,
};

/**
 * The type of a button in a HID Device.
 */
typedef NS_ENUM(NSInteger, UMAInputButtonType) {
    kUMAInputButtonTypeMain,      // General button
    kUMAInputButtonTypeBack,      // Back to previous page
    kUMAInputButtonTypeHome,      // Back to home
    kUMAInputButtonTypeVR,        // Start speech recognition
    kUMAInputButtonTypeUp,        // Up
    kUMAInputButtonTypeDown,      // Down
    kUMAInputButtonTypeLeft,      // Left
    kUMAInputButtonTypeRight,     // Right
};

/**
 * The type of key to retrieve values defined in related Characteristics.
 *
 * @see readDeviceProperty
 */
typedef NS_ENUM(NSInteger, UMAInputDeviceProperty) {
    // Human Interface Device
    kUMAInputDeviceManufacturerNameProperty,  // NSString
    kUMAInputDeviceModelNumberProperty,       // NSString
    kUMAInputDeviceSerialNumberProperty,      // NSString
    kUMAInputDeviceHardwareRevisionProperty,  // NSString
    kUMAInputDeviceSoftwareRevisionProperty,  // NSString
    
    // Battery Service
    kUMAInputDeviceBatteryLevel,              // NSNumber
    
    // Generic Access
    kUMAInputDeviceDeviceName,                // NSString
    
    // PnP ID
    kUMAInputDeviceVendorIdSrc,               // NSNumber
    kUMAInputDeviceVendorId,                  // NSNumber
    kUMAInputDeviceProductId,                 // NSNumber
    kUMAInputDeviceProductVersion,            // NSNumber
};

/**
 * The type of the state a gesture recognizer.
 */
typedef NS_ENUM(NSInteger, UMAInputGestureRecognizerState) {
    kUMAInputGestureRecognizerStateBegan,   // Began a continuous gesture
    kUMAInputGestureRecognizerStateEnded,   // Ended a continuous gesture
};

/**
 * A message key to monitor the event GATT property changes.
 *
 * e.g.)
 *   NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
 *   [center addObserver:self selector:@selector(propertyChanged:) name:UMAInputDevicePropertyUpdated object:device];
 *
 *   - (void)propertyChanged:(NSNotification *)notification {
 *       NSInteger propertyId = [[notification userInfo][UMAInputDevicePropertyKey] intValue];
 *       if (propertyId == kUMAInputDeviceBatteryLevel) {
 *           // battery level changed
 *       }
 *   }
 */
extern NSString *const UMAInputDevicePropertyKey;
extern NSString *const UMAInputDevicePropertySet;
extern NSString *const UMAInputDevicePropertyUpdated;

/**
 * The class represents a HID Device and hold information that be taken by GATT request.
 */
@interface UMAInputDevice : NSObject

/**
 * The type of HID device.
 */
@property (nonatomic, readonly) UMAInputDeviceType type;

/**
 * The vendor of the device
 */
@property (nonatomic, readonly) UMAInputDeviceVendor vendor;

/**
 * UUID of the HID device if available.
 */
@property (retain, nonatomic, readonly) NSUUID *identifier;

/**
 * Name of the HID device.
 */
@property (copy, nonatomic, readonly) NSString *name;

/**
 * Connection state of the device.
 */
@property (nonatomic, readonly) UMAInputDeviceState state;

/**
 * Read value of characteristic defined in BLE Device Information service.
 *
 * @param   UMAInputDeviceProperty property
 * @return  Return type depends on peorperty requested with the parameter
 */
- (id)readDeviceProperty:(UMAInputDeviceProperty)property;

@end