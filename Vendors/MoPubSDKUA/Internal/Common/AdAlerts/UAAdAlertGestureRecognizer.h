//
//  UAAdAlertGestureRecognizer.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const kUAAdAlertGestureMaxAllowedYAxisMovement;

typedef enum
{
    UAAdAlertGestureRecognizerState_ZigRight1,
    UAAdAlertGestureRecognizerState_ZagLeft2,
    UAAdAlertGestureRecognizerState_Recognized
} UAAdAlertGestureRecognizerState;

@interface UAAdAlertGestureRecognizer : UIGestureRecognizer

// default is 4
@property (nonatomic, assign) NSInteger numZigZagsForRecognition;

// default is 100
@property (nonatomic, assign) CGFloat minTrackedDistanceForZigZag;

@property (nonatomic, readonly) UAAdAlertGestureRecognizerState currentAlertGestureState;
@property (nonatomic, readonly) CGPoint inflectionPoint;
@property (nonatomic, readonly) BOOL thresholdReached;
@property (nonatomic, readonly) NSInteger curNumZigZags;

@end
