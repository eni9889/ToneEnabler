//
//  UATableViewCellImpressionTracker.m
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UATableViewCellImpressionTracker.h"

@interface UATableViewCellImpressionTracker ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<UATableViewCellImpressionTrackerDelegate> delegate;
@property (nonatomic, strong) NSTimer *timer;

@end

#define UATableViewCellImpressionTrackerTimeInterval 0.25

@implementation UATableViewCellImpressionTracker

- (id)initWithTableView:(UITableView *)tableView delegate:(id<UATableViewCellImpressionTrackerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _tableView = tableView;
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [_timer invalidate];
}

- (void)startTracking
{
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:UATableViewCellImpressionTrackerTimeInterval target:self selector:@selector(tick:) userInfo:nil repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTracking
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Internal

- (void)tick:(NSTimer *)timer
{
    NSMutableArray *indexPathsForVisibleRows = [[self.tableView indexPathsForVisibleRows] mutableCopy];
    NSUInteger rowCount = [indexPathsForVisibleRows count];

    // For our purposes, "visible" means that more than half of the cell is on-screen.
    // Filter -indexPathsForVisibleRows to fit this definition.
    if (rowCount > 1) {
        NSIndexPath *firstVisibleRow = [indexPathsForVisibleRows objectAtIndex:0];
        if (![self isMajorityOfCellAtIndexPathVisible:firstVisibleRow]) {
            [indexPathsForVisibleRows removeObjectAtIndex:0];
        }

        NSIndexPath *lastVisibleRow = [indexPathsForVisibleRows lastObject];
        if (![self isMajorityOfCellAtIndexPathVisible:lastVisibleRow]) {
            [indexPathsForVisibleRows removeLastObject];
        }
    }

    if ([indexPathsForVisibleRows count]) {
        [self.delegate tracker:self didDetectVisibleRowsAtIndexPaths:[NSArray arrayWithArray:indexPathsForVisibleRows]];
    }
}

- (BOOL)isMajorityOfCellAtIndexPathVisible:(NSIndexPath *)indexPath
{
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    CGPoint cellRectMidY = CGPointMake(0, CGRectGetMidY(cellRect));
    return CGRectContainsPoint(self.tableView.bounds, cellRectMidY);
}

@end
