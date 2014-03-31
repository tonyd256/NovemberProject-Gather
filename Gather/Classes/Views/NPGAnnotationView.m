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

    self.image = annotation.baseImage;

    self.enabled = YES;
    self.canShowCallout = YES;
    self.rightCalloutAccessoryView = [self joinButton];

    return self;
}

- (UIButton *)joinButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 55, 45);
    [button setTitle:@"Join" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    button.tintColor = [UIColor whiteColor];
    button.backgroundColor = [UIColor actionTintColor];
    return button;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        [self setImageTintColor:[UIColor actionTintColor]];
    } else {
        [self setImageTintColor:[UIColor blackColor]];
    }
}

- (void)setAnnotation:(NPGAnnotation *)annotation
{
    [super setAnnotation:annotation];
    self.image = annotation.baseImage;
}

- (void)setImageTintColor:(UIColor *)color
{
    self.image = [self.image tintWithColor:color];
}

@end
