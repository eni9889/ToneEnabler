//
//  UALastResortDelegate.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UALastResortDelegate.h"
#import "UAGlobal.h"
#import "UIViewController+UAAdditions.h"

@class MFMailComposeViewController;

@implementation UALastResortDelegate

+ (id)sharedDelegate
{
    static UALastResortDelegate *lastResortDelegate;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        lastResortDelegate = [[self alloc] init];
    });
    return lastResortDelegate;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(NSInteger)result error:(NSError*)error
{
    [(UIViewController *)controller mp_dismissModalViewControllerAnimated:UA_ANIMATED];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController mp_dismissModalViewControllerAnimated:UA_ANIMATED];
}
#endif

@end
