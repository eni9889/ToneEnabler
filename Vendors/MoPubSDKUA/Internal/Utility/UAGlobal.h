//
//  UAGlobal.h
//  MoPub
//
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef UA_ANIMATED
#define UA_ANIMATED YES
#endif

UIInterfaceOrientation UAInterfaceOrientation(void);
UIWindow *UAKeyWindow(void);
CGFloat UAStatusBarHeight(void);
CGRect UAApplicationFrame(void);
CGRect UAScreenBounds(void);
CGFloat UADeviceScaleFactor(void);
NSDictionary *UADictionaryFromQueryString(NSString *query);
NSString *UASHA1Digest(NSString *string);
BOOL UAViewIsVisible(UIView *view);
BOOL UAViewIntersectsParentWindowWithPercent(UIView *view, CGFloat percentVisible);

////////////////////////////////////////////////////////////////////////////////////////////////////

/*
 * Availability constants.
 */

#define UA_IOS_2_0  20000
#define UA_IOS_2_1  20100
#define UA_IOS_2_2  20200
#define UA_IOS_3_0  30000
#define UA_IOS_3_1  30100
#define UA_IOS_3_2  30200
#define UA_IOS_4_0  40000
#define UA_IOS_4_1  40100
#define UA_IOS_4_2  40200
#define UA_IOS_4_3  40300
#define UA_IOS_5_0  50000
#define UA_IOS_5_1  50100
#define UA_IOS_6_0  60000
#define UA_IOS_7_0  70000

////////////////////////////////////////////////////////////////////////////////////////////////////

enum {
    UAInterstitialCloseButtonStyleAlwaysVisible,
    UAInterstitialCloseButtonStyleAlwaysHidden,
    UAInterstitialCloseButtonStyleAdControlled
};
typedef NSUInteger UAInterstitialCloseButtonStyle;

enum {
    UAInterstitialOrientationTypePortrait,
    UAInterstitialOrientationTypeLandscape,
    UAInterstitialOrientationTypeAll
};
typedef NSUInteger UAInterstitialOrientationType;


////////////////////////////////////////////////////////////////////////////////////////////////////

@interface NSString (UAAdditions)

/*
 * Returns string with reserved/unsafe characters encoded.
 */
- (NSString *)URLEncodedString;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIDevice (UAAdditions)

- (NSString *)hardwareDeviceName;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
// Optional Class Forward Def Protocols
////////////////////////////////////////////////////////////////////////////////////////////////////

@class UAAdConfiguration, CLLocation;

@protocol UAAdAlertManagerProtocol <NSObject>

@property (nonatomic, retain) UAAdConfiguration *adConfiguration;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, assign) UIView *targetAdView;
@property (nonatomic, assign) id delegate;

- (void)beginMonitoringAlerts;
- (void)processAdAlertOnce;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
// Small alert wrapper class to handle telephone protocol prompting
////////////////////////////////////////////////////////////////////////////////////////////////////

@class UATelephoneConfirmationController;

typedef void (^UATelephoneConfirmationControllerClickHandler)(NSURL *targetTelephoneURL, BOOL confirmed);

@interface UATelephoneConfirmationController : NSObject <UIAlertViewDelegate>

- (id)initWithURL:(NSURL *)url clickHandler:(UATelephoneConfirmationControllerClickHandler)clickHandler;
- (void)show;

@end
