//
//  UMAApplicationInfo.h
//  UIEMultiAccess
//
//  Created by swatanabe on 9/26/14.
//  Copyright (c) 2014 UIEvolution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMAApplicationInfo : NSObject

typedef enum {
    PROP_APP_ID = 1,        /*!< The property key for retrieving application ID. */
    PROP_APP_NAME,          /*!< The property key for application name. */
    PROP_APP_VENDOR,        /*!< The property key for application vendor name. */
    PROP_APP_DESCRIPTION,   /*!< The property key for application description. */
    PROP_APP_CATEGORY,      /*!< The property key for application category. */
    PROP_APP_URL,           /*!< The property key for application URL. */
    PROP_APP_SCHEMA,        /*!< The property key for application URL scheme. */
    PROP_APP_ICON_URL,      /*!< The property key for application icon URL. */
    PROP_APP_NEW,           /*!< The property key to inform whether application is new or not. */
    PROP_APP_RECMD,         /*!< The property key to inform whether application is recommend or not. */
    PROP_APP_DATE,          /*!< The property key for update time of the app application. */
    PROP_APP_DEV2,          /*!< The property key for dev2 parameter of application. */
    PROP_APP_DRIVE          /*!< The property key to inform whether application is drive-mode or not. */
} AppInfoEnum;

@property(nonatomic) NSDictionary *properties;

/*!
 * This method returns integer value for the given proeprty.
 * @return      integer value for the given property.
 */
- (int)integerProperty:(AppInfoEnum)prop withDefault:(int)defaultValue;

/*!
 * This method returns string value for the given proeprty.
 * @return      NSString instance for the given property.
 */
- (NSString*) stringProperty:(AppInfoEnum)prop withDefault:(NSString *)defaultValue;

/*!
 * This method returns boolean value for the given proeprty.
 * @return      boolean value for the given property.
 */
- (bool)booleanProperty:(AppInfoEnum)prop withDefault:(bool)defaultValue;

/*!
 * initialize method with key-value pair. You can pass JSON data (as NSDictionary*) here.
 * @return      UMAApplication instance.
 */
- (id)initWithProperties:(NSDictionary *)props;

@end
