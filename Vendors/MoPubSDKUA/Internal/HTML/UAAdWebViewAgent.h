//
//  UAAdWebViewAgent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAAdDestinationDisplayAgent.h"

enum {
    UAAdWebViewEventAdDidAppear     = 0,
    UAAdWebViewEventAdDidDisappear  = 1
};
typedef NSUInteger UAAdWebViewEvent;

@protocol UAAdWebViewAgentDelegate;

@class UAAdConfiguration;
@class UAAdWebView;
@class CLLocation;

@interface UAAdWebViewAgent : NSObject <UIWebViewDelegate, UAAdDestinationDisplayAgentDelegate>

@property (nonatomic, weak) id customMethodDelegate;
@property (nonatomic, strong) UAAdWebView *view;
@property (nonatomic, weak) id<UAAdWebViewAgentDelegate> delegate;

- (id)initWithAdWebViewFrame:(CGRect)frame delegate:(id<UAAdWebViewAgentDelegate>)delegate customMethodDelegate:(id)customMethodDelegate;
- (void)loadConfiguration:(UAAdConfiguration *)configuration;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)invokeJavaScriptForEvent:(UAAdWebViewEvent)event;
- (void)forceRedraw;

- (void)enableRequestHandling;
- (void)disableRequestHandling;

@end

@class UAAdWebView;

@protocol UAAdWebViewAgentDelegate <NSObject>

- (NSString *)adUnitId;
- (CLLocation *)location;
- (UIViewController *)viewControllerForPresentingModalView;
- (void)adDidClose:(UAAdWebView *)ad;
- (void)adDidFinishLoadingAd:(UAAdWebView *)ad;
- (void)adDidFailToLoadAd:(UAAdWebView *)ad;
- (void)adActionWillBegin:(UAAdWebView *)ad;
- (void)adActionWillLeaveApplication:(UAAdWebView *)ad;
- (void)adActionDidFinish:(UAAdWebView *)ad;

@end
