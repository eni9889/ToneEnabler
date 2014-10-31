//
//  UATimer.m
//  MoPub
//
//  Created by Andrew He on 3/8/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "UATimer.h"
#import "UALogging.h"
#import "UAInternalUtils.h"

@interface UATimer ()
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSDate *pauseDate;
@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, assign) NSTimeInterval secondsLeft;
@end

@interface UATimer ()

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@end

@implementation UATimer

@synthesize timeInterval = _timeInterval;
@synthesize timer = _timer;
@synthesize pauseDate = _pauseDate;
@synthesize target = _target;
@synthesize selector = _selector;
@synthesize isPaused = _isPaused;
@synthesize secondsLeft = _secondsLeft;

+ (UATimer *)timerWithTimeInterval:(NSTimeInterval)seconds
                            target:(id)target
                          selector:(SEL)aSelector
                           repeats:(BOOL)repeats
{
    UATimer *timer = [[UATimer alloc] init];
    timer.target = target;
    timer.selector = aSelector;
    timer.timer = [NSTimer timerWithTimeInterval:seconds
                                      target:timer
                                    selector:@selector(timerDidFire)
                                    userInfo:nil
                                     repeats:repeats];
    timer.timeInterval = seconds;
    timer.runLoopMode = NSDefaultRunLoopMode;
    return timer;
}

- (void)dealloc
{
    [self.timer invalidate];
}

- (void)timerDidFire
{
    SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
        [self.target performSelector:self.selector withObject:nil]
    );
}

- (BOOL)isValid
{
    return [self.timer isValid];
}

- (void)invalidate
{
    self.target = nil;
    self.selector = nil;
    [self.timer invalidate];
    self.timer = nil;
}

- (BOOL)isScheduled
{
    if (!self.timer) {
        return NO;
    }
    CFRunLoopRef runLoopRef = [[NSRunLoop currentRunLoop] getCFRunLoop];
    CFArrayRef arrayRef = CFRunLoopCopyAllModes(runLoopRef);
    CFIndex count = CFArrayGetCount(arrayRef);

    for (CFIndex i = 0; i < count; ++i) {
        CFStringRef runLoopMode = CFArrayGetValueAtIndex(arrayRef, i);
        if (CFRunLoopContainsTimer(runLoopRef, (__bridge CFRunLoopTimerRef)self.timer, runLoopMode)) {
            CFRelease(arrayRef);
            return YES;
        }
    }

    CFRelease(arrayRef);
    return NO;
}

- (BOOL)scheduleNow
{
    if (![self.timer isValid])
    {
        UALogDebug(@"Could not schedule invalidated UATimer (%p).", self);
        return NO;
    }

    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:self.runLoopMode];
    return YES;
}

- (BOOL)pause
{
    if (self.isPaused)
    {
        UALogDebug(@"No-op: tried to pause an UATimer (%p) that was already paused.", self);
        return NO;
    }

    if (![self.timer isValid])
    {
        UALogDebug(@"Cannot pause invalidated UATimer (%p).", self);
        return NO;
    }

    if (![self isScheduled])
    {
        UALogDebug(@"No-op: tried to pause an UATimer (%p) that was never scheduled.", self);
        return NO;
    }

    NSDate *fireDate = [self.timer fireDate];
    self.pauseDate = [NSDate date];
    self.secondsLeft = [fireDate timeIntervalSinceDate:self.pauseDate];
    if (self.secondsLeft <= 0)
    {
        UALogWarn(@"An UATimer was somehow paused after it was supposed to fire.");
        self.secondsLeft = 5;
    }
    else UALogDebug(@"Paused UATimer (%p) %.1f seconds left before firing.", self, self.secondsLeft);

    // Pause the timer by setting its fire date far into the future.
    [self.timer setFireDate:[NSDate distantFuture]];
    self.isPaused = YES;

    return YES;
}

- (BOOL)resume
{
    if (![self.timer isValid])
    {
        UALogDebug(@"Cannot resume invalidated UATimer (%p).", self);
        return NO;
    }

    if (!self.isPaused)
    {
        UALogDebug(@"No-op: tried to resume an UATimer (%p) that was never paused.", self);
        return NO;
    }

    UALogDebug(@"Resumed UATimer (%p), should fire in %.1f seconds.", self, self.secondsLeft);

    // Resume the timer.
    NSDate *newFireDate = [NSDate dateWithTimeInterval:self.secondsLeft sinceDate:[NSDate date]];
    [self.timer setFireDate:newFireDate];

    if (![self isScheduled])
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:self.runLoopMode];

    self.isPaused = NO;
    return YES;
}

- (NSTimeInterval)initialTimeInterval
{
    return self.timeInterval;
}

@end

