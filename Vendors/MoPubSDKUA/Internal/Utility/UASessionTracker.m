//
//  UASessionTracker.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UASessionTracker.h"
#import "UAConstants.h"
#import "UAIdentityProvider.h"
#import "UAGlobal.h"
#import "UACoreInstanceProvider.h"

@implementation UASessionTracker

+ (void)load
{
    if (SESSION_TRACKING_ENABLED) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackEvent)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackEvent)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
}

+ (void)trackEvent
{
    [NSURLConnection connectionWithRequest:[[UACoreInstanceProvider sharedProvider] buildConfiguredURLRequestWithURL:[self URL]]
                                  delegate:nil];
}

+ (NSURL *)URL
{
    NSString *path = [NSString stringWithFormat:@"http://%@/m/open?v=%@&udid=%@&id=%@&av=%@&st=1",
                      HOSTNAME,
                      UA_SERVER_VERSION,
                      [UAIdentityProvider identifier],
                      [[[NSBundle mainBundle] bundleIdentifier] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                      ];

    return [NSURL URLWithString:path];
}

@end
