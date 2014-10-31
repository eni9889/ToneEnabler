//
//  UATableViewCellImpressionTracker.h
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UATableViewCellImpressionTrackerDelegate;

@interface UATableViewCellImpressionTracker : NSObject

- (id)initWithTableView:(UITableView *)tableView delegate:(id<UATableViewCellImpressionTrackerDelegate>)delegate;
- (void)startTracking;
- (void)stopTracking;

@end

@protocol UATableViewCellImpressionTrackerDelegate <NSObject>

- (void)tracker:(UATableViewCellImpressionTracker *)tracker didDetectVisibleRowsAtIndexPaths:(NSArray *)indexPaths;

@end