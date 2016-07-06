//
//  DNApplicationManager.h
//  UIEMultiAccess
//
//  Created by swatanabe on 9/26/14.
//  Copyright (c) 2014 UIEvolution Inc. All rights reserved.
//

#import "UMAApplicationManager.h"

@protocol CheckAppIdDelegate <NSObject>
/*!
 * Delegate method, which gets called after checking app id successfully.
 * @param   result: checking result. YES: app ID is correct, NO: app ID is incorrect.
 */
- (void)didCheckingSucceed:(BOOL)result;

/*!
 * Delegate method, which gets called if application manager failed to check an app ID.
 * @param   reason: error code
 * @param   withMessage: error message.
 */
- (void)didCheckingFail:(int)reason withMessage:(NSString *)message;
@end

@interface DNApplicationManager : UMAApplicationManager
/*!
 * Initialize instance of Application Manager and setup App Catalog Adapter.
 * @param       UMAAppCatalogAdapter
 * @return      instance of UMAApplicationManager.
 */
- (id)initWithAppCatalogAdapter:(id<UMAAppCatalogAdapter>) adapter;

/*!
 * This method starts discovering application catalog.
 * @param       UMAAppDiscoveryDelegate: callback interface.
 * @return      id of the task, which can be used for cancelRequest for canceling.
 */
- (int)checkAppID:(NSString *)appID withCallback:(id<CheckAppIdDelegate>)callback;

@end
