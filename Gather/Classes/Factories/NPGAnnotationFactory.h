//
//  NPGAnnotationFactory.h
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

@class NPGAnnotation;
@class NPGGroup;

@interface NPGAnnotationFactory : NSObject

+ (NPGAnnotation *)annotationWithGroup:(NPGGroup *)group;

@end
