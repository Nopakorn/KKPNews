//
//  UMAHIDManager.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 9/28/13.
//  Copyright (c) 2013 UIEvolution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMAInputDevice.h"

typedef NS_ENUM(NSInteger, UMADiscoveryStopReason) {
    kUMADiscoveryDone         = 0, // Intentionally stops by the app
    kUMADiscoveryStarted,          // Discovery started
    kUMADiscoveryTimeout,          // Timeout occurred
    kUMADiscoveryFailed,           // Discovery failed with some reason
    kUMADiscoveryDiscovered,       // Device discovered
};

typedef NS_ENUM(NSInteger, UMAConnectedResult) {
    kUMAConnectedSuccess      = 0, // Successfully connected
    kUMAConnectedFailed,           // Connection failed with some reason
    kUMAConnectedTimeout,          // Timeout occurred
};

typedef NS_ENUM(NSInteger, UMADisconnectedResult) {
    kUMADisconnectedSuccess      = 0, // Successfully connected
    kUMADisconnectedFailed,           // Disconnection failed with some reason
};

typedef void (^UMAHIDManagerCallback) (UMAInputDevice *device, NSError *error);

@class UMAHIDManager;
@protocol UMARemoteInputDelegate;

/**
 * The type of delegate for handling the events of a HID device, one of main purpose of the delegate
 * is to catch the event HID device itself such as discovery, connection and disconnection.
 * Handling an input event issued by a HID device is not a target of this delegate.
 */
@protocol UMAHIDManagerDelegate<NSObject>
@optional

/**
 * Invoked when new HID device is just discovered.
 * 
 * @param manager  An input device manager
 * @param device   A device discovered by the manager.
 */
- (void)uma:(UMAHIDManager *)manager didDiscoverDevice:(UMAInputDevice *)device;

/**
 * Invoked when BLE scanning started to discover HID device.
 *
 * @param manager       An input device manager
 * @param stopReason    A device that just found.
 */
- (void)uma:(UMAHIDManager *)manager didStopDiscovery:(NSInteger)stopReason;

/**
 * Invoked when an input device manager has connected to certain HID device.
 *
 * @param manager  An input device manager
 * @param device   A device that is just connected.
 */
- (void)uma:(UMAHIDManager *)manager didConnectDevice:(UMAInputDevice *)device;

/**
 * Invoked when connecting to certain HID device failed.
 *
 * @param manaegr  An input device manager
 * @param device   A device the manager tried to connect
 * @param error    An error with detail
 */
- (void)uma:(UMAHIDManager *)manager didFailToConnectDevice:(UMAInputDevice *)device error:(NSError *)error;

/**
 * Invoked when an input device manager has disconnected to the device.
 *
 * @param manager  An input device manager
 * @param device   A device disconnected to the phone
 */
- (void)uma:(UMAHIDManager *)manager didDisconnectDevice:(UMAInputDevice *)device;

@end

/**
 * The class implements HID over GATT Service.
 *
 * @seealso HIDS_SPEC_V10.pdf
 */
@interface UMAHIDManager : NSObject

/**
 * The delegate of HID service manager
 */
@property (nonatomic, weak) id<UMAHIDManagerDelegate> delegate;
@property (nonatomic, copy) UMAHIDManagerCallback discoveryCallback;
@property (nonatomic, copy) UMAHIDManagerCallback connectionCallback;
@property (nonatomic, copy) UMAHIDManagerCallback disconnectionCallback;
@property (nonatomic) NSInteger discoveryTimeout;
@property (nonatomic) NSInteger discoveryInterval;
@property (nonatomic) NSInteger connectionTimeout;
@property (nonatomic) NSString *discoveringDeviceName;

/**
 * Enable BLE HID Device manual connection mode.
 * This property is set NO by default.
 */
@property (nonatomic, getter = isManualConnection) BOOL manualConnection;

/**
 * Instantiate a remote input device manager
 *
 * @param       delegate  The delegate that will receive remote input events
 * @return      An object to be instantiated
 */
- (instancetype)initWithDelegate:(id<UMAHIDManagerDelegate>)delegate;

/**
 * Enable Manual Connection with parameters
 *
 * @param       discoveryTimeout
 * @param       connectionTimeout
 */
- (void)enableManualConnectionWithDiscoveryTimeout:(NSTimeInterval)discoveryTimeout
                             WithConnectionTimeout:(NSTimeInterval)connectionTimeout;
/**
 * Enable Auto Connection with parameters
 *
 * @param       discoveryTimeout
 * @param       discoveryInterval
 * @param       connectionTimeout
 */
- (void)enableAutoConnectionWithDiscoveryTimeout:(NSTimeInterval)discoveryTimeout
                            WithDiscoveryInterval:(NSTimeInterval)discoveryInterval
                           WithConnectionTimeout:(NSTimeInterval)connectionTimeout;

/**
 * Start discovering HID Devices.
 *
 * @result      YES if succefully requested, NO if already discovering.
 */
- (BOOL)startDiscoverWithDeviceName:(NSString *)deviceName;

/**
 * Stop discovering of HID Device.
 *
 * @result      YES if it successfully cancelled, No if already stopped.
 */
- (BOOL)stopDiscoverDevice;

/**
 * Make a connection to the device which is connected last time, the process will be asynchronously.
 * This method supports BLE HID device only.
 *
 * @result      YES if succefully requested, NO if the last connected device does not saved.
 */
- (BOOL)connectLastConnectedDevice;

/**
 * Make a connection to particular device, the process will be executed asynchronously.
 *
 * @param       inputDevice   A HID device to be connected
 * @return      YES if successfully initiated, No if already connected or the devices is not appropriate.
 */
- (BOOL)connectDevice:(UMAInputDevice *)inputDevice;

/**
 * Make a connection to particular device, the process will be executed asynchronously.
 *
 * @param       UUID   A UUDI of a HID device to be connected
 * @return      YES if successfully initiated, No if already connected or the devices is not appropriate.
 */
- (BOOL)connectDeviceWithUUID:(NSUUID *)uuid;

/**
 * Disconnect from the device, disconnection will be executed asynchronously.
 *
 * @param       device      A HID device to be disconnected
 * @param       completion  A callback for result of disconnection.
 * @return      YES if successfully initiated, No if already disconnected or the device is not appropriate.
 */
- (BOOL)disconnectDevice:(UMAInputDevice *)inputDevice;

/**
 * Clear the preference which saves the UUID of a last connected device.
 * This method supports BLE HID device only.
 */
- (void)clearLastConnectedDeviceMemory;

/**
 * Obtain the last connected device UUID.
 * This method supports BLE HID device only.
 */
- (NSUUID*)obtainLastConnectedDeviceUUID;

/**
 * Retrieve connected HID device with specified type.
 *
 * @return      The list of HID devices
 */
- (NSArray *)retrieveConnectedDevices:(UMAInputDeviceType)type;

/**
 * Get whether BLE device scan has started or not.
 *
 * @result      YES if it's in scanning, otherwise NO
 */
- (BOOL)isScanning;

/**
 * Add HID Device name.
 *
 * @result      YES if succefully added the device, NO is already added.
 */
- (BOOL)addDeviceName:(NSString *)deviceName;

@end

/**
 * The input device emulator could be useful for application development in the case without real HID device.
 * The emulator works as TCP server to handle a command received from remote TCP client such as telnet.
 */
@interface UMAHIDManager (HIDReportHostEmulator)

/**
 * Start an emulator server with specified port
 *
 * @param   port The port number to be bounded
 * @return  YES if successfull, otherwise NO
 */
- (BOOL)startEmulatorWithPort:(short)port;

/**
 * Stop the emulator server with specified port
 *
 * @param   port    The port number to be bounded
 * @return  YES if successfull, otherwise NO
 */
- (BOOL)stopEmulator;

@end