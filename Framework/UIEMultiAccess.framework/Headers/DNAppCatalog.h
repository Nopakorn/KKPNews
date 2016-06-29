//
//  DNAppCatalog.h
//  UIEMultiAccess
//
//  Created by swatanabe on 9/26/14.
//  Copyright (c) 2014 UIEvolution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMAApplicationManager.h"
#import "DNApplicationManager.h"

@interface DNAppCatalog : NSObject <UMAAppCatalogAdapter>
/*!
 * This method starts discovering application catalog.
 * @param       UMAAppDiscoveryDelegate: callback interface.
 * @return      id of the task, which can be used for cancelRequest for canceling.
 */
- (int)startApplicationDiscovery:(NSDictionary *)param withCallback:(id<UMAAppDiscoveryDelegate>) callback;

/*!
 * This method starts discovering application catalog.
 * @param       UMAAppDiscoveryDelegate: callback interface.
 * @return      id of the task, which can be used for cancelRequest for canceling.
 */
- (int)checkAppID:(NSString *)appID withCallback:(id<CheckAppIdDelegate>)callback;

/*!
 * This method cancels the request for discovering application catalog.
 * @param   id of the task, which is the return value of startApplicationDiscovery.
 */
- (void)cancelRequest:(int)request;

@end
