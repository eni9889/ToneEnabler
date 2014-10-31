//
//  UAInterstitialViewController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UAInterstitialViewController.h"

#import "UAGlobal.h"
#import "UALogging.h"
#import "UIViewController+UAAdditions.h"

static const CGFloat kCloseButtonPadding = 6.0;
static NSString * const kCloseButtonXImageName = @"MPCloseButtonX.png";

@interface UAInterstitialViewController ()

@property (nonatomic, assign) BOOL applicationHasStatusBar;
@property (nonatomic, assign) BOOL isOnViewControllerStack;

- (void)setCloseButtonImageWithImageNamed:(NSString *)imageName;
- (void)setCloseButtonStyle:(UAInterstitialCloseButtonStyle)style;
- (void)closeButtonPressed;
- (void)dismissInterstitialAnimated:(BOOL)animated;
- (void)setApplicationStatusBarHidden:(BOOL)hidden;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UAInterstitialViewController

@synthesize closeButton = _closeButton;
@synthesize closeButtonStyle = _closeButtonStyle;
@synthesize orientationType = _orientationType;
@synthesize applicationHasStatusBar = _applicationHasStatusBar;
@synthesize isOnViewControllerStack = _isOnViewControllerStack;
@synthesize delegate = _delegate;


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.isOnViewControllerStack) {
        self.isOnViewControllerStack = YES;
        [self didPresentInterstitial];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // When the interstitial is dismissed, we want to
    // -viewDidDisappear: is called 1) when the interstitial is dismissed and 2) when a modal view
    // controller is presented atop the interstitial (e.g. the ad browser).

    if (![self mp_presentedViewController]) {
        self.isOnViewControllerStack = NO;
        //self.view.alpha = 0.0;
    }
}

#pragma mark - Public

- (void)presentInterstitialFromViewController:(UIViewController *)controller
{
    if (_isOnViewControllerStack) {
        UALogWarn(@"Cannot present an interstitial that is already on-screen.");
        return;
    }

    [self willPresentInterstitial];

    self.applicationHasStatusBar = !([UIApplication sharedApplication].isStatusBarHidden);
    [self setApplicationStatusBarHidden:YES];

    [self layoutCloseButton];
    [controller mp_presentModalViewController:self animated:UA_ANIMATED];
}

- (void)willPresentInterstitial
{

}

- (void)didPresentInterstitial
{

}

- (void)willDismissInterstitial
{

}

- (void)didDismissInterstitial
{

}

- (BOOL)shouldDisplayCloseButton
{
    return YES;
}

#pragma mark - Close Button

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleBottomMargin;

        UIImage *closeButtonImage = [UIImage imageNamed:kCloseButtonXImageName];
        [_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
        [_closeButton sizeToFit];

        [_closeButton addTarget:self
                         action:@selector(closeButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
        _closeButton.accessibilityLabel = @"Close Interstitial Ad";
    }

    return _closeButton;
}

- (void)layoutCloseButton
{
    CGFloat originX = self.view.bounds.size.width - kCloseButtonPadding -
    self.closeButton.bounds.size.width;
    self.closeButton.frame = CGRectMake(originX,
                                        kCloseButtonPadding,
                                        self.closeButton.bounds.size.width,
                                        self.closeButton.bounds.size.height);
    [self setCloseButtonStyle:self.closeButtonStyle];
    [self.view addSubview:self.closeButton];
    [self.view bringSubviewToFront:self.closeButton];
}

- (void)setCloseButtonImageWithImageNamed:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    [self.closeButton setImage:image forState:UIControlStateNormal];
    [self.closeButton sizeToFit];
}

- (void)setCloseButtonStyle:(UAInterstitialCloseButtonStyle)style
{
    _closeButtonStyle = style;
    switch (style) {
        case UAInterstitialCloseButtonStyleAlwaysVisible:
            self.closeButton.hidden = NO;
            break;
        case UAInterstitialCloseButtonStyleAlwaysHidden:
            self.closeButton.hidden = YES;
            break;
        case UAInterstitialCloseButtonStyleAdControlled:
            self.closeButton.hidden = ![self shouldDisplayCloseButton];
            break;
        default:
            self.closeButton.hidden = NO;
            break;
    }
}

- (void)closeButtonPressed
{
    [self dismissInterstitialAnimated:YES];
}

- (void)dismissInterstitialAnimated:(BOOL)animated
{
    [self setApplicationStatusBarHidden:!self.applicationHasStatusBar];

    [self willDismissInterstitial];

    UIViewController *presentingViewController = [self mp_presentingViewController];
    // TODO: Is this check necessary?
    if ([presentingViewController mp_presentedViewController] == self) {
        [presentingViewController mp_dismissModalViewControllerAnimated:UA_ANIMATED];
    }

    [self didDismissInterstitial];
}

#pragma mark - Hidding status bar (pre-iOS 7)

- (void)setApplicationStatusBarHidden:(BOOL)hidden
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= UA_IOS_3_2
    if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
        // Hiding the status bar should use a fade effect.
        // Displaying the status bar should use no animation.
        UIStatusBarAnimation animation = hidden ?
        UIStatusBarAnimationFade : UIStatusBarAnimationNone;
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
        return;
    }
#endif

    [[UIApplication sharedApplication] setStatusBarHidden:hidden];
}

#pragma mark - Hidding status bar (iOS 7 and above)

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Autorotation (iOS 6.0 and above)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= UA_IOS_6_0
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger applicationSupportedOrientations =
    [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:UAKeyWindow()];
    NSUInteger interstitialSupportedOrientations = applicationSupportedOrientations;
    NSString *orientationDescription = @"any";

    // Using the _orientationType, narrow down the supported interface orientations.

    if (_orientationType == UAInterstitialOrientationTypePortrait) {
        interstitialSupportedOrientations &=
        (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
        orientationDescription = @"portrait";
    }
    else if (_orientationType == UAInterstitialOrientationTypeLandscape) {
        interstitialSupportedOrientations &= UIInterfaceOrientationMaskLandscape;
        orientationDescription = @"landscape";
    }

    // If the application does not support any of the orientations given by _orientationType,
    // just return the application's supported orientations.

    if (!interstitialSupportedOrientations) {
        UALogError(@"Your application does not support this interstitial's desired orientation "
                   @"(%@).", orientationDescription);
        return applicationSupportedOrientations;
    }
    else {
        return interstitialSupportedOrientations;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    NSUInteger supportedInterfaceOrientations = [self supportedInterfaceOrientations];
    UIInterfaceOrientation currentInterfaceOrientation = UAInterfaceOrientation();
    NSUInteger currentInterfaceOrientationMask = (1 << currentInterfaceOrientation);

    // First, try to display the interstitial using the current interface orientation. If the
    // current interface orientation is unsupported, just use any of the supported orientations.

    if (supportedInterfaceOrientations & currentInterfaceOrientationMask) {
        return currentInterfaceOrientation;
    }
    else if (supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
        return UIInterfaceOrientationPortrait;
    }
    else if (supportedInterfaceOrientations & UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown;
    }
    else if (supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    else {
        return UIInterfaceOrientationLandscapeRight;
    }
}
#endif

#pragma mark - Autorotation (before iOS 6.0)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (_orientationType == UAInterstitialOrientationTypePortrait)
        return (interfaceOrientation == UIInterfaceOrientationPortrait ||
                interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    else if (_orientationType == UAInterstitialOrientationTypeLandscape)
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    else return YES;
}

@end
