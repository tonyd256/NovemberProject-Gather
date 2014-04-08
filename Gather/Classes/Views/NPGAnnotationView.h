//
//  NPGAnnotationView.h
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import <MapKit/MapKit.h>

@class NPGGroup;

@interface NPGAnnotationView : MKAnnotationView

- (void)configureWithAnnotation:(id<MKAnnotation>)annotation;
- (void)setImageTintColor:(UIColor *)color;

@end
