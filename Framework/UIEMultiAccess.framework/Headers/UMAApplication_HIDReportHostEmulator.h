//
//  UMAApplication_HIDReportHostEmulator.h
//  UIE MultiAccess
//
//  Created by Rakuto Furutani on 3/30/14.
//  Copyright (c) 2014 UIEvolution Inc. All rights reserved.
//

#import <UIEMultiAccess/UMAApplication.h>

/**
 * The category that extends app with emulator feature which can be received remote input event over TCP/IP
 * The emulator feature is mainly useful for development purpose without actual remote input device.
 */
@interface UMAApplication(HIDReportHostEmulator)

/**
 * Start a TCP server that emulate remote input event from BLE rotary switch
 *
 * @param port
 * @return YES if succeed, otherwise NO
 */
- (BOOL)startHIDReportHostEmulatorWithPort:(short)port;

/**
 * Start the emulator server
 *
 * @return YES if succeed, otherwise NO
 */
- (BOOL)stopHIDReportHostEmulator;

@end