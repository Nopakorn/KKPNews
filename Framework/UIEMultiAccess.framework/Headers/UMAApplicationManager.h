//
//  UMAApplicationManager.h
//  UIEMultiAccess
//
//  Created by swatanabe on 9/26/14.
//  Copyright (c) 2014 UIEvolution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UMAAppDiscoveryDelegate <NSObject>
/*!
 * Delegate method, which gets called after application manager discovered successfully.
 * @param   appInfo: contains the array of UMAApplicationInfo object.
 */
- (void)didDiscoverySucceed:(NSArray *)appInfo;

/*!
 * Delegate method, which gets called if application manager failed to discover the app catalog.
 * @param   reason: error code
 * @param   withMessage: error message.
 */
- (void)didDiscoveryFail:(int)reason withMessage:(NSString *)message;
@end

@protocol UMAAppCatalogAdapter <NSObject>
@required
/*!
 * This method starts discovering application catalog.
 * @param       UMAAppDiscoveryDelegate: callback interface.
 * @return      id of the task, which can be used for cancelRequest for canceling.
 */
- (int)startApplicationDiscovery:(NSDictionary *)param withCallback:(id<UMAAppDiscoveryDelegate>) callback;

/*!
 * This method cancels the request for discovering application catalog.
 * @param   id of the task, which is the return value of startApplicationDiscovery.
 */
- (void)cancelRequest:(int)request;
@end

@interface UMAApplicationManager : NSObject

/*!
 * Initialize the instance and setup Application Catalog Adapter.
 * The adapter can be varied on vendor's spec.
 * @return   instance of UMAApplicationManager.
 */
- (id)initWithAppCatalogAdapter:(id<UMAAppCatalogAdapter>) adapter;

/*!
 * This method starts discovering application catalog.
 * @param       UMAAppDiscoveryDelegate: callback interface.
 * @return   id of the task, which can be used for cancelRequest for canceling.
 */
- (int)startApplicationDiscovery:(NSDictionary *)param withCallback:(id<UMAAppDiscoveryDelegate>) callback;

/*!
 * This method cancels the request for discovering application catalog.
 * @param   id of the task, which is the return value of startApplicationDiscovery.
 */
- (void)cancelRequest:(int)request;

@end

