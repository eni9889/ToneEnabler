//
//  UALastResortDelegate+EventKit.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UALastResortDelegate+EventKit.h"
#import "UAGlobal.h"
#import "UIViewController+UAAdditions.h"


@implementation UALastResortDelegate (EventKit)

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [controller mp_dismissModalViewControllerAnimated:UA_ANIMATED];
}

@end
