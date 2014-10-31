//
//  UAAdAlertManager.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UAGlobal.h"

@class CLLocation;
@protocol UAAdAlertManagerDelegate;

@class UAAdConfiguration;

@interface UAAdAlertManager : NSObject <UAAdAlertManagerProtocol>

@end

@protocol UAAdAlertManagerDelegate <NSObject>

@required
- (UIViewController *)viewControllerForPresentingMailVC;
- (void)adAlertManagerDidTriggerAlert:(UAAdAlertManager *)manager;

@optional
- (void)adAlertManagerDidProcessAlert:(UAAdAlertManager *)manager;

@end