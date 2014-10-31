//
//  UAServerAdPositioning.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UAAdPositioning.h"

/**
 * The `UAServerAdPositioning` class is a model that allows you to control the positions where
 * native advertisements should appear within a stream. A server positioning object works in
 * conjunction with an ad placer, telling the ad placer that it should retrieve positioning
 * information from the MoPub ad server.
 *
 * Unlike `UAClientAdPositioning`, which represents hard-coded positioning information, a server
 * positioning object offers you the benefit of modifying your ad positions via the MoPub website,
 * without rebuilding your application.
 */

@interface UAServerAdPositioning : UAAdPositioning

/** @name Creating a Server Positioning Object */

/**
 * Creates and returns a server positioning object.
 *
 * When an ad placer is set to use server positioning, it will ask the MoPub ad server for the
 * positions where ads should be inserted into a given stream. These positioning values are
 * configurable on the MoPub website.
 *
 * @return The newly created positioning object.
 *
 * @see UAClientAdPositioning
 */
+ (instancetype)positioning;

@end
