//
//  UALogging.h
//  MoPub
//
//  Created by Andrew He on 2/10/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAConstants.h"

extern NSString * const kUAClearErrorLogFormatWithAdUnitID;

// Lower = finer-grained logs.
typedef enum
{
    UALogLevelAll        = 0,
    UALogLevelTrace        = 10,
    UALogLevelDebug        = 20,
    UALogLevelInfo        = 30,
    UALogLevelWarn        = 40,
    UALogLevelError        = 50,
    UALogLevelFatal        = 60,
    UALogLevelOff        = 70
} UALogLevel;

UALogLevel UALogGetLevel(void);
void UALogSetLevel(UALogLevel level);
void _UALogTrace(NSString *format, ...);
void _UALogDebug(NSString *format, ...);
void _UALogInfo(NSString *format, ...);
void _UALogWarn(NSString *format, ...);
void _UALogError(NSString *format, ...);
void _UALogFatal(NSString *format, ...);

#if UA_DEBUG_MODE && !SPECS

#define UALogTrace(...) _UALogTrace(__VA_ARGS__)
#define UALogDebug(...) _UALogDebug(__VA_ARGS__)
#define UALogInfo(...) _UALogInfo(__VA_ARGS__)
#define UALogWarn(...) _UALogWarn(__VA_ARGS__)
#define UALogError(...) _UALogError(__VA_ARGS__)
#define UALogFatal(...) _UALogFatal(__VA_ARGS__)

#else

#define UALogTrace(...) {}
#define UALogDebug(...) {}
#define UALogInfo(...) {}
#define UALogWarn(...) {}
#define UALogError(...) {}
#define UALogFatal(...) {}

#endif
