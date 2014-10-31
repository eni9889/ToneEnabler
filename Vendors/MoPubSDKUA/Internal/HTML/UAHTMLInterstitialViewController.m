//
//  UAHTMLInterstitialViewController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UAHTMLInterstitialViewController.h"
#import "UAAdWebView.h"
#import "UAAdDestinationDisplayAgent.h"
#import "UAInstanceProvider.h"

@interface UAHTMLInterstitialViewController ()

@property (nonatomic, strong) UAAdWebView *backingView;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UAHTMLInterstitialViewController

@synthesize delegate = _delegate;
@synthesize backingViewAgent = _backingViewAgent;
@synthesize customMethodDelegate = _customMethodDelegate;
@synthesize backingView = _backingView;

- (void)dealloc
{
    self.backingViewAgent.delegate = nil;
    self.backingViewAgent.customMethodDelegate = nil;

    self.backingView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.backingViewAgent = [[UAInstanceProvider sharedProvider] buildUAAdWebViewAgentWithAdWebViewFrame:self.view.bounds
                                                                                                delegate:self
                                                                                    customMethodDelegate:self.customMethodDelegate];
    self.backingView = self.backingViewAgent.view;
    self.backingView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backingView];
}

#pragma mark - Public

- (void)loadConfiguration:(UAAdConfiguration *)configuration
{
    [self view];
    [self.backingViewAgent loadConfiguration:configuration];
}

- (void)willPresentInterstitial
{
    self.backingView.alpha = 0.0;
    [self.delegate interstitialWillAppear:self];
}

- (void)didPresentInterstitial
{
    [self.backingViewAgent enableRequestHandling];
    [self.backingViewAgent invokeJavaScriptForEvent:UAAdWebViewEventAdDidAppear];

    // XXX: In certain cases, UIWebView's content appears off-center due to rotation / auto-
    // resizing while off-screen. -forceRedraw corrects this issue, but there is always a brief
    // instant when the old content is visible. We mask this using a short fade animation.
    [self.backingViewAgent forceRedraw];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.backingView.alpha = 1.0;
    [UIView commitAnimations];

    [self.delegate interstitialDidAppear:self];
}

- (void)willDismissInterstitial
{
    [self.backingViewAgent disableRequestHandling];
    [self.delegate interstitialWillDisappear:self];
}

- (void)didDismissInterstitial
{
    [self.backingViewAgent invokeJavaScriptForEvent:UAAdWebViewEventAdDidDisappear];
    [self.delegate interstitialDidDisappear:self];
}

#pragma mark - Autorotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.backingViewAgent rotateToOrientation:self.interfaceOrientation];
}

#pragma mark - UAAdWebViewAgentDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adDidFinishLoadingAd:(UAAdWebView *)ad
{
    [self.delegate interstitialDidLoadAd:self];
}

- (void)adDidFailToLoadAd:(UAAdWebView *)ad
{
    [self.delegate interstitialDidFailToLoadAd:self];
}

- (void)adActionWillBegin:(UAAdWebView *)ad
{
    [self.delegate interstitialDidReceiveTapEvent:self];
}

- (void)adActionWillLeaveApplication:(UAAdWebView *)ad
{
    [self.delegate interstitialWillLeaveApplication:self];
    [self dismissInterstitialAnimated:NO];
}

- (void)adActionDidFinish:(UAAdWebView *)ad
{
    //NOOP: the landing page is going away, but not the interstitial.
}

- (void)adDidClose:(UAAdWebView *)ad
{
    //NOOP: the ad is going away, but not the interstitial.
}

@end
