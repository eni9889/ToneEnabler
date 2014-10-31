//
//  UAAdDestinationDisplayAgent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAAdDestinationDisplayAgent.h"
#import "UIViewController+UAAdditions.h"
#import "UACoreInstanceProvider.h"
#import "UALastResortDelegate.h"
#import "NSURL+UAAdditions.h"

@interface UAAdDestinationDisplayAgent ()

@property (nonatomic, strong) UAURLResolver *resolver;
@property (nonatomic, strong) UAProgressOverlayView *overlayView;
@property (nonatomic, assign) BOOL isLoadingDestination;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= UA_IOS_6_0
@property (nonatomic, strong) SKStoreProductViewController *storeKitController;
#endif

@property (nonatomic, strong) UAAdBrowserController *browserController;
@property (nonatomic, strong) UATelephoneConfirmationController *telephoneConfirmationController;

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL;
- (void)hideOverlay;
- (void)hideModalAndNotifyDelegate;
- (void)dismissAllModalContent;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UAAdDestinationDisplayAgent

@synthesize delegate = _delegate;
@synthesize resolver = _resolver;
@synthesize isLoadingDestination = _isLoadingDestination;

+ (UAAdDestinationDisplayAgent *)agentWithDelegate:(id<UAAdDestinationDisplayAgentDelegate>)delegate
{
    UAAdDestinationDisplayAgent *agent = [[UAAdDestinationDisplayAgent alloc] init];
    agent.delegate = delegate;
    agent.resolver = [[UACoreInstanceProvider sharedProvider] buildUAURLResolver];
    agent.overlayView = [[UAProgressOverlayView alloc] initWithDelegate:agent];
    return agent;
}

- (void)dealloc
{
    [self dismissAllModalContent];

    self.overlayView.delegate = nil;
    self.resolver.delegate = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= UA_IOS_6_0
    // XXX: If this display agent is deallocated while a StoreKit controller is still on-screen,
    // nil-ing out the controller's delegate would leave us with no way to dismiss the controller
    // in the future. Therefore, we change the controller's delegate to a singleton object which
    // implements SKStoreProductViewControllerDelegate and is always around.
    self.storeKitController.delegate = [UALastResortDelegate sharedDelegate];
#endif
    self.browserController.delegate = nil;

}

- (void)dismissAllModalContent
{
    [self.overlayView hide];
}

- (void)displayDestinationForURL:(NSURL *)URL
{
    if (self.isLoadingDestination) return;
    self.isLoadingDestination = YES;

    [self.delegate displayAgentWillPresentModal];
    [self.overlayView show];

    [self.resolver startResolvingWithURL:URL delegate:self];
}

- (void)cancel
{
    if (self.isLoadingDestination) {
        self.isLoadingDestination = NO;
        [self.resolver cancel];
        [self hideOverlay];
        [self.delegate displayAgentDidDismissModal];
    }
}

#pragma mark - <UAURLResolverDelegate>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL
{
    [self hideOverlay];

    self.browserController = [[UAAdBrowserController alloc] initWithURL:URL
                                                              HTMLString:HTMLString
                                                                delegate:self];
    self.browserController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[self.delegate viewControllerForPresentingModalView] mp_presentModalViewController:self.browserController
                                                                               animated:UA_ANIMATED];
}

- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL
{
    if ([UAStoreKitProvider deviceHasStoreKit]) {
        [self presentStoreKitControllerWithItemIdentifier:parameter fallbackURL:URL];
    } else {
        [self openURLInApplication:URL];
    }
}

- (void)openURLInApplication:(NSURL *)URL
{
    [self hideOverlay];

    if ([URL mp_hasTelephoneScheme] || [URL mp_hasTelephonePromptScheme]) {
        [self interceptTelephoneURL:URL];
    } else {
        [self.delegate displayAgentWillLeaveApplication];
        [[UIApplication sharedApplication] openURL:URL];
        self.isLoadingDestination = NO;
    }
}

- (void)interceptTelephoneURL:(NSURL *)URL
{
    __weak UAAdDestinationDisplayAgent *weakSelf = self;
    self.telephoneConfirmationController = [[UATelephoneConfirmationController alloc] initWithURL:URL clickHandler:^(NSURL *targetTelephoneURL, BOOL confirmed) {
        UAAdDestinationDisplayAgent *strongSelf = weakSelf;
        if (strongSelf) {
            if (confirmed) {
                [strongSelf.delegate displayAgentWillLeaveApplication];
                [[UIApplication sharedApplication] openURL:targetTelephoneURL];
            }
            strongSelf.isLoadingDestination = NO;
            [strongSelf.delegate displayAgentDidDismissModal];
        }
    }];

    [self.telephoneConfirmationController show];
}

- (void)failedToResolveURLWithError:(NSError *)error
{
    self.isLoadingDestination = NO;
    [self hideOverlay];
    [self.delegate displayAgentDidDismissModal];
}

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= UA_IOS_6_0
    self.storeKitController = [UAStoreKitProvider buildController];
    self.storeKitController.delegate = self;

    NSDictionary *parameters = [NSDictionary dictionaryWithObject:identifier
                                                           forKey:SKStoreProductParameterITunesItemIdentifier];
    [self.storeKitController loadProductWithParameters:parameters completionBlock:nil];

    [self hideOverlay];
    [[self.delegate viewControllerForPresentingModalView] mp_presentModalViewController:self.storeKitController
                                                                               animated:UA_ANIMATED];
#endif
}

#pragma mark - <UASKStoreProductViewControllerDelegate>
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    self.isLoadingDestination = NO;
    [self hideModalAndNotifyDelegate];
}

#pragma mark - <UAAdBrowserControllerDelegate>
- (void)dismissBrowserController:(UAAdBrowserController *)browserController animated:(BOOL)animated
{
    self.isLoadingDestination = NO;
    [self hideModalAndNotifyDelegate];
}

#pragma mark - <UAProgressOverlayViewDelegate>
- (void)overlayCancelButtonPressed
{
    [self cancel];
}

#pragma mark - Convenience Methods
- (void)hideModalAndNotifyDelegate
{
    [[self.delegate viewControllerForPresentingModalView] mp_dismissModalViewControllerAnimated:UA_ANIMATED];
    [self.delegate displayAgentDidDismissModal];
}

- (void)hideOverlay
{
    [self.overlayView hide];
}

@end
