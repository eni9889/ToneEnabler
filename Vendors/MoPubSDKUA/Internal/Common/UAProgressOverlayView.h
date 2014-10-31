//
//  UAProgressOverlayView.h
//  MoPub
//
//  Created by Andrew He on 7/18/12.
//  Copyright 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UAProgressOverlayViewDelegate;

@interface UAProgressOverlayView : UIView {
    id<UAProgressOverlayViewDelegate> __weak _delegate;
    UIView *_outerContainer;
    UIView *_innerContainer;
    UIActivityIndicatorView *_activityIndicator;
    UIButton *_closeButton;
    CGPoint _closeButtonPortraitCenter;
}

@property (nonatomic, weak) id<UAProgressOverlayViewDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;

- (id)initWithDelegate:(id<UAProgressOverlayViewDelegate>)delegate;
- (void)show;
- (void)hide;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol UAProgressOverlayViewDelegate <NSObject>

@optional
- (void)overlayCancelButtonPressed;
- (void)overlayDidAppear;

@end
