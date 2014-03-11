//
//  NPGAnnotation.h
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

@interface NPGAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSString *imageName;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
