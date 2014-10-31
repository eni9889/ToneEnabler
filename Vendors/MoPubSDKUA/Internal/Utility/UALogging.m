//
//  UALogging.m
//  MoPub
//
//  Created by Andrew He on 2/10/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "UALogging.h"
#import "UAIdentityProvider.h"

NSString * const kUAClearErrorLogFormatWithAdUnitID = @"No ads found for ad unit: %@";

static UALogLevel UALOG_LEVEL = UALogLevelInfo;

UALogLevel UALogGetLevel()
{
    return UALOG_LEVEL;
}

void UALogSetLevel(UALogLevel level)
{
    UALOG_LEVEL = level;
}

void _UALog(NSString *format, va_list args)
{
    static NSString *sIdentifier;
    static NSString *sObfuscatedIdentifier;

    if (!sIdentifier) {
        sIdentifier = [[UAIdentityProvider identifier] copy];
    }

    if (!sObfuscatedIdentifier) {
        sObfuscatedIdentifier = [[UAIdentityProvider obfuscatedIdentifier] copy];
    }

    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];

    // Replace identifier with a obfuscated version when logging.
    logString = [logString stringByReplacingOccurrencesOfString:sIdentifier withString:sObfuscatedIdentifier];

    NSLog(@"%@", logString);
}

void _UALogTrace(NSString *format, ...)
{
    if (UALOG_LEVEL <= UALogLevelTrace)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _UALog(format, args);
        va_end(args);
    }
}

void _UALogDebug(NSString *format, ...)
{
    if (UALOG_LEVEL <= UALogLevelDebug)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _UALog(format, args);
        va_end(args);
    }
}

void _UALogWarn(NSString *format, ...)
{
    if (UALOG_LEVEL <= UALogLevelWarn)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _UALog(format, args);
        va_end(args);
    }
}

void _UALogInfo(NSString *format, ...)
{
    if (UALOG_LEVEL <= UALogLevelInfo)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _UALog(format, args);
        va_end(args);
    }
}

void _UALogError(NSString *format, ...)
{
    if (UALOG_LEVEL <= UALogLevelError)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _UALog(format, args);
        va_end(args);
    }
}

void _UALogFatal(NSString *format, ...)
{
    if (UALOG_LEVEL <= UALogLevelFatal)
    {
        format = [NSString stringWithFormat:@"MOPUB: %@", format];
        va_list args;
        va_start(args, format);
        _UALog(format, args);
        va_end(args);
    }
}
