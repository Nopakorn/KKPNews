//
//  UMAApplication
//  UIE MultiAccess / KKP
//
//  Created by Rakuto Furutani on 9/19/13.
//  Copyright (c) 2013 UIEvolution Inc. All rights reserved.
//

#import <UIKit/UIResponder.h>
#import <Foundation/Foundation.h>

@class UIImage;
@class UIScreen;
@class UIViewController;
@class UIApplication;
@class UMAApplication;
@class UMAFocusManager;
@class UMAHIDManager;
@class UMAInputDevice;
@protocol UMAFocusManagerDelegate;

/*!
 * Observer API
 *
 * Mainly observer based APIs declared below would be used to catch events in UMA application lifecycle from
 * other than singleton UIApplicationObject in your application. Since that allows to assign only one instance
 * implemented UMAApplicationDelegate, it is bit hard to handle this kind of event in multiple place.
 * However, there is no such limitation about observer based APIs, your application can use it anywhere.
 */
extern NSString *const UMAInputDeviceKey;
extern NSString *const UMAScreenKey;

/**
 * A notification that is notified when HID device connected to the phone.
 * By using UMAInputDeviceKey, an application takes the HID device.
 *
 * e.g.) [[notification userInfo] objectForKey:UMAInputDeviceKey]
 */
extern NSString *const UMAInputDeviceConnectedNotification;

/**
 * A notification that is notified when HID device disconnected to the phone.
 * By using UMAInputDeviceKey, an application takes the HID device.
 *
 * e.g.) [[notification userInfo] objectForKey:UMAInputDeviceKey]
 */
extern NSString *const UMAInputDeviceDisconnectedNotification;

/*!
 * @discussion  A notification that is notified when second screen is connected to the phone.
 *              By using UMAScreenKey, an application takes the screen object.
 *
 *              Screen information can be taken by UMAScreenKey only when display is connected with HDMI or AirPlay.
 *              e.g.) [[notification] objectForKey:UMAScreenKey]
 *
 * @note        Notified only when secondary display mode used.
 */
extern NSString *const UMAScreenConnectedNotification;

/*!
 * @discussion  A notification that is notified when second screen is disconnected to the phone.
 *              By using UMAScreenKey, an application takes the screen object.
 *
 *              Screen information can be taken by UMAScreenKey only when display is connected with HDMI or AirPlay.
 *              e.g.) [[notification] objectForKey:UMAScreenKey]
 *
 * @note        Notified only when secondary display mode used.
 */
extern NSString *const UMAScreenDisconnectedNotification;

/*!
 * @abstract    The central delegate for UMA application.
 *
 * @discussion  The UMAApplicationDelegate protocol declares methods that are usually implemented by the delegate
 *              of singleton UIApplicationObject in your application. These methods provides you with information about
 *              variety of events regarding UMA appliation activity.
 */
@protocol UMAApplicationDelegate <NSObject>

/*!
 * @method uma:requestRootViewController
 *
 * @discussion Invoked when the library request app a view controller of you app that will be shown on the connected screen.
 *
 * @param application   The instance of UMA Application
 * @param screen        A variable represents the connected screen
 *
 * @return              A view controller that will be shown on the connected screen.
 */
- (UIViewController *)uma:(UMAApplication *)application requestRootViewController:(UIScreen *)screen;

@optional

/*!
 * @discussion Invoked when the library request app default view that will be shown on the connected screen.
 *
 * @param application   The instance of UMA Application
 * @param screen        A variable represents the connected screen
 * @return              A view controller that will be shown on the connected screen.
 */
- (UIViewController *)uma:(UMAApplication *)application requestSplashViewController:(UIScreen *)screen;

/**
 * Invoked when the application has started discovery for a remote input device.
 * 
 * @param application   The instance of UMA Application
 * @param manager       The instance of remote input device manager
 */
- (void)uma:(UMAApplication *)application willStartInputDeviceDiscovery:(UMAHIDManager *)manager;

/**
 * Invoked when the application has stopped discovery for a remote input device.
 * 
 * @param application   The instance of UMA Application
 * @param manager       The instance of remote input device manager
 */
- (void)uma:(UMAApplication *)application didStopInputDeviceDiscovery:(UMAHIDManager *)manager;

/**
 * Invoked when the discovery for a remote input device failed.
 *
 * @param application   The instance of UMA Application
 * @param manager       The instance of remote input device manager
 */
- (void)uma:(UMAApplication *)application didFailInputDeviceDiscovery:(UMAHIDManager *)manager error:(NSError *)error;

/**
 * Invoked when the new remote input device found.
 *
 * @param application   The instance of UMA Application
 * @param device        The instance which represents an remote input device
 */
- (void)uma:(UMAApplication *)application didDiscoverInputDevice:(UMAInputDevice *)device;

/**
 * Invoked when the new remote input device has connected to the phone.
 *
 * @param application   The instance of UMA Application
 * @param device        The instance which represents an remote input device
 */
- (void)uma:(UMAApplication *)application didConnectInputDevice:(UMAInputDevice *)device;

/**
 * Invoked when the the remote input device has disconnected to the phone.
 *
 * @param application   The instance of UMA Application
 * @param device        The instance which represents an remote input device
 */
- (void)uma:(UMAApplication *)application didDisconnectInputDevice:(UMAInputDevice *)device;

/**
 * Invoked when the secondary screen has connected to the phone.
 *
 * @param screen        The screen connected to the phone
 */
- (void)uma:(UMAApplication *)application didConnectScreen:(UIScreen *)screen;

/**
 * Invoked when the secondary screen has disconnected.
 *
 * @param screen        The screen disconnected to the phone
 */
- (void)uma:(UMAApplication *)application didDisconnectScreen:(UIScreen *)screen;

@end

/*!
 * @enum UMAResult
 *
 * @discussion The type of error code used by UMA Library
 */
typedef NS_ENUM(NSInteger, UMAResult) {
    UMA_SUCCESS = 0,
    UMA_INVALID_STATE = -1,
    UMA_ERROR,
    UMA_REQUEST_FAILED,
};

/*!
 * @enum        UMALogLevel
 *
 * @discussion  The log levels specify how much verbose logs should be printed into the log file.
 */
typedef NS_ENUM(NSInteger, UMALogLevel) {
    kUMALogLevelError,
    kUMALogLevelWarn,
    kUMALogLevelInfo,
    kUMALogLevelDebug,
    kUMALogLevelVerbose,
};

/**
 * The type of state represents BLE device discovery
 */
typedef NS_ENUM(NSInteger, UMADeviceScanState) {
    UMA_DEVICE_SCAN_STATE_INITIAL = 0,
    UMA_DEVICE_SCAN_STATE_SCANNING,
    UMA_DEVICE_SCAN_STATE_STOPPED,
    UMA_DEVICE_SCAN_STATE_FAILED
};

/*!
 * @enum Style of the status bar shown on the second screen
 */
typedef NS_ENUM(NSInteger, UMAStatusBarStyle) {
    kUMAStatusBarStyleNone    = 0, // Default
    kUMAStatusBarStyleBlack,
    kUMAStatusBarStyleWhite,
};

/*!
 * @enum Options to specify how view to project on the second screen adjusts second screen size.
 */
typedef NS_OPTIONS(NSInteger, UMAVideoScaleMode) {
    kUMAVideoScaleModeCrop = 0,// to defaut
    kUMAVideoScaleModeAspectFit ,
};

/*!
 * @enum        UMADisplayType
 *
 * @discussion  Type of second display, following types are supoprted.
 *              kUMADisplayHDMI:    A display connected with HDMI, or AirPlay.
 */
typedef NS_OPTIONS(NSInteger, UMADisplayType) {
    kUMADisplayHDMI,
};

/*!
 * @abstract    Type to represent UMA application mode.
 *
 * @discussion
 */
typedef NS_ENUM(NSInteger, UMAAppMode) {
    kUMAAppModeIdle = 0,    // Application in idle.
    kUMAAppModeVideoOut,    // External display mode, HDMI or Air Play.
};

/*!
 * @interface   UMAApplication
 *
 * @discussion  Represents top-level singleton object to manage UMA application displayed on the second screen.
 *              This class manages application status and various system level settings. In general,
 *              this class is instantiated in the application delegate class.
 *
 *              The root view controller will be retrieved via {@link UMAApplicationDelegate:uma:requestRootViewController}
 *              in specified delegate. An application is responsible for providing a valid root view controller object.
 *
 * @seealso     {@link UMAApplicationDelegate}
 */
@interface UMAApplication : NSObject

/*!
 * @abstract    This represents UMA application mode that currently running.
 *
 * @discussion  When application changes application mode with property, or internally changed due to events such as
 *              USB connection lost, appication mode is notified to connected HU.
 */
@property (nonatomic) UMAAppMode appMode;

/*!
 * @abstract    The delegate that will receive UMA App events.
 */
@property (weak, nonatomic) id<UMAApplicationDelegate> delegate;

/*!
 * @property    logLevel
 * @discussion  Specify how verbose logs should be printed into the log file.
 */
@property (nonatomic) UMALogLevel logLevel;

/*!
 * @property    deviceScanTimeout
 * @discussion  The timeout of scanning remote input devices.
 */
@property (nonatomic) NSTimeInterval deviceScanTimeout;

/*!
 * @discussion  The state of scanning remote input devices.
 */
@property (nonatomic, readonly) UMADeviceScanState scanState;

/*!
 * @abstract    The main window for second display.
 */
@property (nonatomic) UIWindow *window;

/*!
 * @discussion  The boolean flag to keep screen awake, YES by default.
 */
@property (nonatomic) BOOL keepAwake;

/*!
 * @discussion  The property that indicates whether automatically start the application on remote screen
 *              when second display connected to the phone. YES by default.
 */
@property (nonatomic) BOOL autoStart;

/*!
 * @discussion  A style of the status bar shown on the second screen.
 *              By default, UIEMultiAccess does not show any status bar on the second screen.
 */
@property (nonatomic) UMAStatusBarStyle statusBarStyle;

/*!
 * @discussion  The property determines whether enable or disable sound effect.
 *              This property is set NO by default.
 */
@property (nonatomic, getter = isBeepSoundEnabled) BOOL beepSoundEnabled;

/*!
 * @abstract Type of second display.
 */
@property (nonatomic) UMADisplayType displayType;

/*!
 * @abstract Options to specify how view to project on the second screen adjusts second screen size.
 */
@property (nonatomic) UMAVideoScaleMode videoScaleMode;

/*!
 * @property apiKeys
 *
 * @discussion  This propery only needs to be set if your app allows to control by HID device.
 */
@property (nonatomic) NSMutableArray *apiKeys;

//
// Voice Feedback provides feedback with Text to Speech when view item gets focus.
//

/*!
 * @abstract    Enabling voice-over-ish feature, which speaks item when a view got focus.
 * @discussion  This property is set NO by default.
 */
@property (nonatomic, getter = isVoiceOverEnabled) BOOL voiceOverEnabled;

/*!
 * @abstract Speech pitch for voice over feature, 1.2f used as default.
 */
@property (nonatomic) float speechPitch;

/*!
 * @abstract The speech rate for voice over, set 0.15f by default.
 */
@property (nonatomic) float speechRate;

/*!
 * @abstract  The speech volume for voice over, set 0.8f by default.
 */
@property (nonatomic) float speechVolume;

/*!
 * @discussion Get the singleton instance
 *
 * @return UMAApplication
 */
+ (instancetype)sharedApplication;

/*!
 * @method isBeepSoundEnabled
 *
 * @discussion Returns whether it plays beep sound when HID input event received.
 *
 * @return  YES if beep sound enabled, otherwise NO.
 */
- (BOOL)isBeepSoundEnabled;

/*!
 * Set up the library, your application has to call this method in your application delegate.
 */
- (void)setup;

/*!
 * @method      startProjection
 *
 * @discussion  Initialize multiple service to start UMA application on the connected HU.
 *
 * @return      UMA_SUCCESS if it is successful, otherwise negative value.
 */
- (UMAResult)startProjection;

/*!
 * @deprecated  Use {@link startProjection} instead.
 */
- (UMAResult)start DEPRECATED_ATTRIBUTE;

/*!
 * @method      stop
 *
 * @discussion  Stop an application on remote screen.
 *
 * @result      UMA_SUCCESS if success, otherwise not zero.
 */
- (UMAResult)stop;

/*!
 * @method      isStarted
 * 
 * @discussion  Return whether the application already started or not.
 * 
 * @return      YES if it had already started, otherwise NO.
 */
- (BOOL)isStarted;

/*!
 * @method      isSecondScreenAvailable
 *
 * @discussion  Return whether the secondary screen had already connected or not.
 *
 * @return      YES if the secondary screen had already connected, otherwise NO.
 */
- (BOOL)isSecondScreenAvailable;

/*!
 * @method requestFocusManager
 *
 * @discussion Obtain the shared focus manager.
 *
 * @result An isntance of focus manger
 */
- (UMAFocusManager *)requestFocusManager;

/**
 * Obtain the focus manager with the delegate specified as a parameter
 *
 * @param  delegate  The delegate
 * @result An instance of focus manager
 */
- (UMAFocusManager *)requestFocusManagerWithDelegate:(id<UMAFocusManagerDelegate>)delegate;

/**
 * Obtain the focus manager for main display
 *
 * @param  delegate  The delegate
 * @result An instance of focus manager
 */
- (UMAFocusManager *)requestFocusManagerForMainScreenWithDelegate:(id<UMAFocusManagerDelegate>)delegate;

/*!
 * @method requestHIDManager
 *
 * @discussion Obtain the shared HID manager.
 *
 * @result An isntance of HID manger
*/
- (UMAHIDManager *)requestHIDManager;

/**
 * Push view controller to the stack so that it can recieve event from HID device.
 *
 * @param controller    A view controller that receives an event from HID device.
 */
- (void)addViewController:(UIViewController *)controller;

/**
 * Remove view controller from the stack, once it removed from the stack, it never recieves an event from HID device.
 *
 * @param controller    A view controller that will be removed from the stack.
 */
- (void)removeViewController:(UIViewController *)controller;

/**
 * Set the custom URL scheme that represents the launcher application.
 *
 * @param uri
 */
- (void)setLauncherApplicationURI:(NSString *)uri;

/**
 * To make sure the launcher app can launch your application, you have to call this 
 * in AppDelegate's <code>application:openURL:sourceApplication:annotation</code>.
 *
 * @param url   An URL to be passed when an app is launched by another.
 * @return YES if an app is launched by l
 */
- (BOOL)handleOpenURL:(NSURL *)url;

/**
 * Get the url to launch an application.
 * 
 * @param scheme    An application scheme to specify app to be launched
 * @param query     A URL encoded query string to be passed to URL as parameter.
 * @return          An application URL
 */
- (NSURL *)appURL:(NSString *)scheme query:(NSString *)query;

/**
 * Request the launch of the application.
 *
 * @param scheme    An application scheme to specify app to be launched
 * @param query     A URL encoded query string to be passed to URL as parameter.
 * @return          YES if an application is launched, otherwise NO.
 */
- (BOOL)launchAppWithURL:(NSString *)scheme query:(NSString *)query;

@end
