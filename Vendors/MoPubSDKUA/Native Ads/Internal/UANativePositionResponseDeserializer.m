//
//  UANativePositionResponseDeserializer.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UANativePositionResponseDeserializer.h"
#import "UAClientAdPositioning.h"
#import "NSJSONSerialization+UAAdditions.h"

static NSString * const UANativePositionResponseDeserializationErrorDomain = @"com.mopub.iossdk.position.deserialization";
static NSString * const UANativePositionResponseFixedPositionsKey = @"fixed";
static NSString * const UANativePositionResponseSectionKey = @"section";
static NSString * const UANativePositionResponsePositionKey = @"position";
static NSString * const UANativePositionResponseRepeatingKey = @"repeating";
static NSString * const UANativePositionResponseIntervalKey = @"interval";
static NSInteger const UAMinRepeatingInterval = 2;
static NSInteger const UAMaxRepeatingInterval = 1 << 16;

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UANativePositionResponseDeserializer

+ (instancetype)deserializer
{
    return [[[self class] alloc] init];
}

- (UAClientAdPositioning *)clientPositioningForData:(NSData *)data error:(NSError **)error
{
    UAClientAdPositioning *positioning = [UAClientAdPositioning positioning];

    if (!data || [data length] == 0) {
        [self safeAssignError:error code:UANativePositionResponseDataIsEmpty description:@"Positioning cannot be created from nil or empty data."];
        return [UAClientAdPositioning positioning];
    }

    NSError *deserializationError = nil;
    NSDictionary *positionDictionary = [NSJSONSerialization mp_JSONObjectWithData:data options:0 clearNullObjects:YES error:&deserializationError];

    if (deserializationError) {
        [self safeAssignError:error code:UANativePositionResponseIsNotValidJSON description:@"Failed to deserialize JSON." underlyingError:deserializationError];
        return [UAClientAdPositioning positioning];
    }

    NSError *fixedPositionsError = nil;
    NSArray *fixedPositions = [self parseFixedPositionsObject:[positionDictionary objectForKey:UANativePositionResponseFixedPositionsKey] error:&fixedPositionsError];

    if (fixedPositionsError) {
        if (error) {
            *error = fixedPositionsError;
        }
        return [UAClientAdPositioning positioning];
    }

    NSError *repeatingIntervalError = nil;
    NSInteger repeatingInterval = [self parseRepeatingIntervalObject:[positionDictionary objectForKey:UANativePositionResponseRepeatingKey] error:&repeatingIntervalError];

    if (repeatingIntervalError) {
        if (error) {
            *error = repeatingIntervalError;
        }
        return [UAClientAdPositioning positioning];
    }

    if ([fixedPositions count] == 0 && repeatingInterval <= 0) {
        [self safeAssignError:error code:UANativePositionResponseJSONHasInvalidPositionData description:@"Positioning object must have either fixed positions or a repeating interval."];
        return [UAClientAdPositioning positioning];
    }

    [fixedPositions enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [positioning addFixedIndexPath:indexPath];
    }];
    [positioning enableRepeatingPositionsWithInterval:repeatingInterval];
    return positioning;
}

#pragma mark - Parsing and validation

- (NSArray *)parseFixedPositionsObject:(id)positionsObject error:(NSError **)error
{
    NSMutableArray *parsedPositions = [NSMutableArray array];

    if (positionsObject && ![positionsObject isKindOfClass:[NSArray class]]) {
        [self safeAssignError:error code:UANativePositionResponseJSONHasInvalidPositionData description:[NSString stringWithFormat:@"Expected object for key \"%@\" to be an array. Actual: %@", UANativePositionResponseFixedPositionsKey, positionsObject]];
        return nil;
    }

    __block NSError *fixedPositionError = nil;
    [positionsObject enumerateObjectsUsingBlock:^(id positionObj, NSUInteger idx, BOOL *stop) {
        if (![self validatePositionObject:positionObj error:&fixedPositionError]) {
            *stop = YES;
            return;
        }

        NSInteger section = [self integerFromDictionary:positionObj forKey:UANativePositionResponseSectionKey defaultValue:0];
        NSInteger position = [self integerFromDictionary:positionObj forKey:UANativePositionResponsePositionKey defaultValue:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:section];
        [parsedPositions addObject:indexPath];
    }];

    if (fixedPositionError) {
        if (error) {
            *error = fixedPositionError;
        }
        return nil;
    }

    return parsedPositions;
}

- (NSInteger)parseRepeatingIntervalObject:(id)repeatingIntervalObject error:(NSError **)error
{
    if (!repeatingIntervalObject) {
        return 0;
    }

    NSError *repeatingIntervalError = nil;
    if (![self validateRepeatingIntervalObject:repeatingIntervalObject error:&repeatingIntervalError]) {
        if (error) {
            *error = repeatingIntervalError;
        }
        return 0;
    }

    return [self integerFromDictionary:repeatingIntervalObject forKey:UANativePositionResponseIntervalKey defaultValue:0];
}

- (BOOL)validatePositionObject:(id)positionObject error:(NSError **)error
{
    if (![positionObject isKindOfClass:[NSDictionary class]]) {
        [self safeAssignError:error code:UANativePositionResponseJSONHasInvalidPositionData description:[NSString stringWithFormat:@"Position object is not a dictionary: %@.", positionObject]];
        return NO;
    }

    // Section number is not required. If it's present, we have to check that it's non-negative;
    // if it isn't there, we assign a section number of 0.
     NSInteger section = [positionObject objectForKey:UANativePositionResponseSectionKey] ? [self integerFromDictionary:positionObject forKey:UANativePositionResponseSectionKey defaultValue:-1] : 0;
    if (section < 0) {
        [self safeAssignError:error code:UANativePositionResponseJSONHasInvalidPositionData description:[NSString stringWithFormat:@"Position object has an invalid \"%@\" value or is not a positive number: %ld.", UANativePositionResponseSectionKey, (long)section]];
        return NO;
    }

    // Unlike section, position is required. It also must be a non-negative number.
    NSInteger position = [self integerFromDictionary:positionObject forKey:UANativePositionResponsePositionKey defaultValue:-1];
    if (position < 0) {
        [self safeAssignError:error code:UANativePositionResponseJSONHasInvalidPositionData description:[NSString stringWithFormat:@"Position object has an invalid \"%@\" value or is not a positive number: %ld.", UANativePositionResponsePositionKey, (long)position]];
        return NO;
    }

    return YES;
}

- (BOOL)validateRepeatingIntervalObject:(id)repeatingIntervalObject error:(NSError **)error
{
    if (![repeatingIntervalObject isKindOfClass:[NSDictionary class]]) {
        [self safeAssignError:error code:UANativePositionResponseJSONHasInvalidPositionData description:[NSString stringWithFormat:@"Repeating interval object is not a dictionary: %@.", repeatingIntervalObject]];
        return NO;
    }

    // The object must contain a value between UAMinRepeatingInterval and UAMaxRepeatingInterval.
    NSInteger interval = [self integerFromDictionary:repeatingIntervalObject forKey:UANativePositionResponseIntervalKey defaultValue:0];
    if (interval < UAMinRepeatingInterval || interval > UAMaxRepeatingInterval) {
        [self safeAssignError:error code:UANativePositionResponseJSONHasInvalidPositionData description:[NSString stringWithFormat:@"\"%@\" value in repeating interval object needs to be between %ld and %ld: %ld.", UANativePositionResponseIntervalKey, (long)UAMinRepeatingInterval, (long)UAMaxRepeatingInterval, (long)interval]];
        return NO;
    }

    return YES;
}

#pragma mark - Dictionary helpers

/**
 * Returns an `NSInteger` value associated with a certain key in a dictionary, or a specified
 * default value if the key is not associated with a valid integer representation.
 *
 * Valid integer representations include `NSNumber` objects and `NSString` objects that
 * consist only of integer or sign characters.
 *
 * @param dictionary A dictionary containing keys and values.
 * @param key The key for which to return an integer value.
 * @param defaultValue A value that should be returned if `key` is not associated with an object
 * that contains an integer representation.
 *
 * @return The integer value associated with `key`, or `defaultValue` if the object is not an
 * `NSNumber` or an `NSString` representing an integer.
 */
- (NSInteger)integerFromDictionary:(NSDictionary *)dictionary forKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    static NSCharacterSet *nonIntegerCharacterSet;

    id object = [dictionary objectForKey:key];

    if ([object isKindOfClass:[NSNumber class]]) {
        return [object integerValue];
    } else if ([object isKindOfClass:[NSString class]]) {
        if (!nonIntegerCharacterSet) {
            nonIntegerCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789-"] invertedSet];
        }

        // If the string consists of all digits, we'll call -integerValue. Otherwise, return the
        // default value.
        if ([object rangeOfCharacterFromSet:nonIntegerCharacterSet].location == NSNotFound) {
            return [object integerValue];
        } else {
            return defaultValue;
        }
    } else {
        return defaultValue;
    }
}

#pragma mark - Error helpers

- (void)safeAssignError:(NSError **)error code:(UANativePositionResponseDeserializationErrorCode)code userInfo:(NSDictionary *)userInfo
{
    if (error) {
        *error = [self deserializationErrorWithCode:code userInfo:userInfo];
    }
}

- (void)safeAssignError:(NSError **)error code:(UANativePositionResponseDeserializationErrorCode)code description:(NSString *)description
{
    [self safeAssignError:error code:code description:description underlyingError:nil];
}

- (void)safeAssignError:(NSError **)error code:(UANativePositionResponseDeserializationErrorCode)code description:(NSString *)description underlyingError:(NSError *)underlyingError
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

    if (description) {
        [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    }

    if (underlyingError) {
        [userInfo setObject:underlyingError forKey:NSUnderlyingErrorKey];
    }

    [self safeAssignError:error code:code userInfo:userInfo];
}

- (NSError *)deserializationErrorWithCode:(UANativePositionResponseDeserializationErrorCode)code userInfo:(NSDictionary *)userInfo
{
    return [NSError errorWithDomain:UANativePositionResponseDeserializationErrorDomain
                               code:code
                           userInfo:userInfo];
}

@end
