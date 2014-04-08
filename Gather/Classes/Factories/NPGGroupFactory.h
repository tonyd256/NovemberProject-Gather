//
//  NPGGroupFactory.h
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import <MapKit/MapKit.h>

@class NPGGroup;

@interface NPGGroupFactory : NSObject

+ (NPGGroup *)createGroupWithLocation:(CLLocationCoordinate2D)location;

@end
