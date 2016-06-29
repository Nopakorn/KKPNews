//
//  UMAServiceManager.h
//  UIEMultiAccess
//
//  Created by Rakuto Furutani on 11/7/14.
//  Copyright (c) 2014 UIEvolution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class UMAServiceManager
 *
 * @discussion  Service Manager enables dynamic discovery of network services on IP network.
 *              UMA enabled application internally launches multiple servers, which information 
 *              is notified with mDNS/DNS-SD methodology.
 */
@interface UMAServiceManager : NSObject

/*!
 * @method sharedInstance
 *
 * @return Returns the singleton instance of UMA service manager.
 */
+ (instancetype)sharedInstance;

/*!
 * @method startAdvertising
 *
 * @discussion Publishing the UMA related network services, advertising service is stopped in specified
 *             timeout second. Application should specify timeout since advertising is battery consuming
 *             operation.
 *
 * @param timeout   Timeout in secound, if 0 it never stops.
 * @return          YES if it is succesfful, otherwise NO.
 *
 * @note Need to be called from main thread or NSRunLoop enabled thread.
 */
- (BOOL)startAdvertisingWithTimeout:(NSTimeInterval)timeout;

/*!
 * @method stopAdvertising
 *
 * @discussion Stops advertising process if it's running now.
 *
 * @return          YES if it is succesfful, otherwise NO.
 */
- (BOOL)stopAdvertising;

@end