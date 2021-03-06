//
//  NPGGroup.h
//  Gather
//
//  Created by Tony DiPasquale on 3/29/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface NPGGroup : NSObject <MKAnnotation>

@property (nonatomic) NSString *objectID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSString *type;
@property (nonatomic) NSDate *time;
@property (nonatomic) NSArray *people;

@end
