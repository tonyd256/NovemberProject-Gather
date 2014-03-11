//
//  NPGAnnotationView.m
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGAnnotationView.h"
#import "NPGAnnotation.h"

@implementation NPGAnnotationView

- (instancetype)initWithAnnotation:(NPGAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.image = [UIImage imageNamed:annotation.imageName];

    return self;
}

- (void)setAnnotation:(NPGAnnotation *)annotation
{
    [super setAnnotation:annotation];
    self.image = [UIImage imageNamed:annotation.imageName];
}

@end
