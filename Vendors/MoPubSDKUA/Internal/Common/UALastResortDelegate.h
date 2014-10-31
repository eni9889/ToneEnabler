//
//  UALastResortDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface UALastResortDelegate : NSObject
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
<SKStoreProductViewControllerDelegate>
#endif

+ (id)sharedDelegate;

@end
