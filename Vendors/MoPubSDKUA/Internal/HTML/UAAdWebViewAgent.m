//
//  UAAdWebViewAgent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAAdWebViewAgent.h"
#import "UAAdConfiguration.h"
#import "UAGlobal.h"
#import "UALogging.h"
#import "UAAdDestinationDisplayAgent.h"
#import "NSURL+UAAdditions.h"
#import "UIWebView+UAAdditions.h"
#import "UAAdWebView.h"
#import "UAInstanceProvider.h"
#import "UACoreInstanceProvider.h"
#import "UAUserInteractionGestureRecognizer.h"
#import "NSJSONSerialization+UAAdditions.h"
#import "NSURL+UAAdditions.h"
#import "UAInternalUtils.h"

#ifndef NSFoundationVersionNumber_iOS_6_1
#define NSFoundationVersionNumber_iOS_6_1 993.00
#endif

#define UAOffscreenWebViewNeedsRenderingWorkaround() (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)

NSString * const kMoPubURLScheme = @"mopub";
NSString * const kMoPubCloseHost = @"close";
NSString * const kMoPubFinishLoadHost = @"finishLoad";
NSString * const kMoPubFailLoadHost = @"failLoad";
NSString * const kMoPubCustomHost = @"custom";

@interface UAAdWebViewAgent () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UAAdConfiguration *configuration;
@property (nonatomic, strong) UAAdDestinationDisplayAgent *destinationDisplayAgent;
@property (nonatomic, assign) BOOL shouldHandleRequests;
@property (nonatomic, strong) id<UAAdAlertManagerProtocol> adAlertManager;
@property (nonatomic, assign) BOOL userInteractedWithWebView;
@property (nonatomic, strong) UAUserInteractionGestureRecognizer *userInteractionRecognizer;

- (void)performActionForMoPubSpecificURL:(NSURL *)URL;
- (BOOL)shouldIntercept:(NSURL *)URL navigationType:(UIWebViewNavigationType)navigationType;
- (void)interceptURL:(NSURL *)URL;
- (void)handleMoPubCustomURL:(NSURL *)URL;

@end

@implementation UAAdWebViewAgent

@synthesize configuration = _configuration;
@synthesize delegate = _delegate;
@synthesize destinationDisplayAgent = _destinationDisplayAgent;
@synthesize customMethodDelegate = _customMethodDelegate;
@synthesize shouldHandleRequests = _shouldHandleRequests;
@synthesize view = _view;
@synthesize adAlertManager = _adAlertManager;
@synthesize userInteractedWithWebView = _userInteractedWithWebView;
@synthesize userInteractionRecognizer = _userInteractionRecognizer;

- (id)initWithAdWebViewFrame:(CGRect)frame delegate:(id<UAAdWebViewAgentDelegate>)delegate customMethodDelegate:(id)customMethodDelegate;
{
    self = [super init];
    if (self) {
        self.view = [[UAInstanceProvider sharedProvider] buildUAAdWebViewWithFrame:frame delegate:self];
        self.destinationDisplayAgent = [[UACoreInstanceProvider sharedProvider] buildUAAdDestinationDisplayAgentWithDelegate:self];
        self.delegate = delegate;
        self.customMethodDelegate = customMethodDelegate;
        self.shouldHandleRequests = YES;
        self.adAlertManager = [[UACoreInstanceProvider sharedProvider] buildUAAdAlertManagerWithDelegate:self];

        self.userInteractionRecognizer = [[UAUserInteractionGestureRecognizer alloc] initWithTarget:self action:@selector(handleInteraction:)];
        self.userInteractionRecognizer.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:self.userInteractionRecognizer];
        self.userInteractionRecognizer.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.userInteractionRecognizer.delegate = nil;
    [self.userInteractionRecognizer removeTarget:self action:nil];
    self.adAlertManager.targetAdView = nil;
    self.adAlertManager.delegate = nil;
    [self.destinationDisplayAgent cancel];
    [self.destinationDisplayAgent setDelegate:nil];
    self.view.delegate = nil;
}

- (void)handleInteraction:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.userInteractedWithWebView = YES;
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
    return YES;
}

#pragma mark - <UAAdAlertManagerDelegate>

- (UIViewController *)viewControllerForPresentingMailVC
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adAlertManagerDidTriggerAlert:(UAAdAlertManager *)manager
{
    [self.adAlertManager processAdAlertOnce];
}

#pragma mark - Public

- (void)loadConfiguration:(UAAdConfiguration *)configuration
{
    self.configuration = configuration;

    // Ignore server configuration size for interstitials. At this point our web view
    // is sized correctly for the device's screen. Currently the server sends down values for a 3.5in
    // screen, and they do not size correctly on a 4in screen.
    if (configuration.adType != UAAdTypeInterstitial) {
        if ([configuration hasPreferredSize]) {
            CGRect frame = self.view.frame;
            frame.size.width = configuration.preferredSize.width;
            frame.size.height = configuration.preferredSize.height;
            self.view.frame = frame;
        }
    }

    // excuse interstitials from user tapped check since it's already a takeover experience
    // and certain videos may delay tap gesture recognition
    if (configuration.adType == UAAdTypeInterstitial) {
        self.userInteractedWithWebView = YES;
    }

    [self.view mp_setScrollable:configuration.scrollable];
    [self.view disableJavaScriptDialogs];
    [self.view loadHTMLString:[configuration adResponseHTMLString] baseURL:nil];

    [self initAdAlertManager];
}

- (void)invokeJavaScriptForEvent:(UAAdWebViewEvent)event
{
    switch (event) {
        case UAAdWebViewEventAdDidAppear:
            [self.view stringByEvaluatingJavaScriptFromString:@"webviewDidAppear();"];
            break;
        case UAAdWebViewEventAdDidDisappear:
            [self.view stringByEvaluatingJavaScriptFromString:@"webviewDidClose();"];
            break;
        default:
            break;
    }
}

- (void)disableRequestHandling
{
    self.shouldHandleRequests = NO;
    [self.destinationDisplayAgent cancel];
}

- (void)enableRequestHandling
{
    self.shouldHandleRequests = YES;
}

#pragma mark - <UAAdDestinationDisplayAgentDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)displayAgentWillPresentModal
{
    [self.delegate adActionWillBegin:self.view];
}

- (void)displayAgentWillLeaveApplication
{
    [self.delegate adActionWillLeaveApplication:self.view];
}

- (void)displayAgentDidDismissModal
{
    [self.delegate adActionDidFinish:self.view];
}

#pragma mark - <UIWebViewDelegate>

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if (!self.shouldHandleRequests) {
        return NO;
    }

    NSURL *URL = [request URL];
    if ([[URL scheme] isEqualToString:kMoPubURLScheme]) {
        [self performActionForMoPubSpecificURL:URL];
        return NO;
    } else if ([self shouldIntercept:URL navigationType:navigationType]) {
        [self interceptURL:URL];
        return NO;
    } else {
        // don't handle any deep links without user interaction
        return self.userInteractedWithWebView || [URL mp_isSafeForLoadingWithoutUserAction];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view disableJavaScriptDialogs];
}

#pragma mark - MoPub-specific URL handlers
- (void)performActionForMoPubSpecificURL:(NSURL *)URL
{
    UALogDebug(@"UAAdWebView - loading MoPub URL: %@", URL);
    NSString *host = [URL host];
    if ([host isEqualToString:kMoPubCloseHost]) {
        [self.delegate adDidClose:self.view];
    } else if ([host isEqualToString:kMoPubFinishLoadHost]) {
        [self.delegate adDidFinishLoadingAd:self.view];
    } else if ([host isEqualToString:kMoPubFailLoadHost]) {
        [self.delegate adDidFailToLoadAd:self.view];
    } else if ([host isEqualToString:kMoPubCustomHost]) {
        [self handleMoPubCustomURL:URL];
    } else {
        UALogWarn(@"UAAdWebView - unsupported MoPub URL: %@", [URL absoluteString]);
    }
}

- (void)handleMoPubCustomURL:(NSURL *)URL
{
    NSDictionary *queryParameters = [URL mp_queryAsDictionary];
    NSString *selectorName = [queryParameters objectForKey:@"fnc"];
    NSString *oneArgumentSelectorName = [selectorName stringByAppendingString:@":"];
    SEL zeroArgumentSelector = NSSelectorFromString(selectorName);
    SEL oneArgumentSelector = NSSelectorFromString(oneArgumentSelectorName);

    if ([self.customMethodDelegate respondsToSelector:zeroArgumentSelector]) {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
            [self.customMethodDelegate performSelector:zeroArgumentSelector withObject:nil]
        );
    } else if ([self.customMethodDelegate respondsToSelector:oneArgumentSelector]) {
        NSData *data = [[queryParameters objectForKey:@"data"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDictionary = nil;
        if (data) {
            dataDictionary = [NSJSONSerialization mp_JSONObjectWithData:data options:NSJSONReadingMutableContainers clearNullObjects:YES error:nil];
        }

        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
            [self.customMethodDelegate performSelector:oneArgumentSelector withObject:dataDictionary]
        );
    } else {
        UALogError(@"Custom method delegate does not implement custom selectors %@ or %@.",
                   selectorName, oneArgumentSelectorName);
    }
}

#pragma mark - URL Interception
- (BOOL)shouldIntercept:(NSURL *)URL navigationType:(UIWebViewNavigationType)navigationType
{
    if ([URL mp_hasTelephoneScheme] || [URL mp_hasTelephonePromptScheme]) {
        return YES;
    } else if (!(self.configuration.shouldInterceptLinks)) {
        return NO;
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return YES;
    } else if (navigationType == UIWebViewNavigationTypeOther) {
        return [[URL absoluteString] hasPrefix:[self.configuration clickDetectionURLPrefix]];
    } else {
        return NO;
    }
}

- (void)interceptURL:(NSURL *)URL
{
    NSURL *redirectedURL = URL;
    if (self.configuration.clickTrackingURL) {
        NSString *path = [NSString stringWithFormat:@"%@&r=%@",
                          self.configuration.clickTrackingURL.absoluteString,
                          [[URL absoluteString] URLEncodedString]];
        redirectedURL = [NSURL URLWithString:path];
    }

    [self.destinationDisplayAgent displayDestinationForURL:redirectedURL];
}

#pragma mark - Utility

- (void)initAdAlertManager
{
    self.adAlertManager.adConfiguration = self.configuration;
    self.adAlertManager.adUnitId = [self.delegate adUnitId];
    self.adAlertManager.targetAdView = self.view;
    self.adAlertManager.location = [self.delegate location];
    [self.adAlertManager beginMonitoringAlerts];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    [self forceRedraw];
}

- (void)forceRedraw
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    int angle = -1;
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait: angle = 0; break;
        case UIInterfaceOrientationLandscapeLeft: angle = 90; break;
        case UIInterfaceOrientationLandscapeRight: angle = -90; break;
        case UIInterfaceOrientationPortraitUpsideDown: angle = 180; break;
        default: break;
    }

    if (angle == -1) return;

    // UIWebView doesn't seem to fire the 'orientationchange' event upon rotation, so we do it here.
    NSString *orientationEventScript = [NSString stringWithFormat:
                                        @"window.__defineGetter__('orientation',function(){return %d;});"
                                        @"(function(){ var evt = document.createEvent('Events');"
                                        @"evt.initEvent('orientationchange',true,true);window.dispatchEvent(evt);})();",
                                        angle];
    [self.view stringByEvaluatingJavaScriptFromString:orientationEventScript];

    // XXX: If the UIWebView is rotated off-screen (which may happen with interstitials), its
    // content may render off-center upon display. We compensate by setting the viewport meta tag's
    // 'width' attribute to be the size of the webview.
    NSString *viewportUpdateScript = [NSString stringWithFormat:
                                      @"document.querySelector('meta[name=viewport]')"
                                      @".setAttribute('content', 'width=%f;', false);",
                                      self.view.frame.size.width];
    [self.view stringByEvaluatingJavaScriptFromString:viewportUpdateScript];

    // XXX: In iOS 7, off-screen UIWebViews will fail to render certain image creatives.
    // Specifically, creatives that only contain an <img> tag whose src attribute uses a 302
    // redirect will not be rendered at all. One workaround is to temporarily change the web view's
    // internal contentInset property; this seems to force the web view to re-draw.
    if (UAOffscreenWebViewNeedsRenderingWorkaround()) {
        if ([self.view respondsToSelector:@selector(scrollView)]) {
            UIScrollView *scrollView = self.view.scrollView;
            UIEdgeInsets originalInsets = scrollView.contentInset;
            UIEdgeInsets newInsets = UIEdgeInsetsMake(originalInsets.top + 1,
                                                      originalInsets.left,
                                                      originalInsets.bottom,
                                                      originalInsets.right);
            scrollView.contentInset = newInsets;
            scrollView.contentInset = originalInsets;
        }
    }
}

@end
