//
//  NPGAnnotationView.m
//  Gather
//
//  Created by Tony DiPasquale on 3/10/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGAnnotationView.h"
#import "NPGGroup.h"
#import "NPGGroupType.h"
#import "NPGAppSession.h"

@interface NPGAnnotationView ()

@property (nonatomic) UIButton *joinButton;
@property (nonatomic) UIButton *leaveButton;

@end

@implementation NPGAnnotationView

- (instancetype)initWithAnnotation:(NPGGroup *)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.image = [NPGGroupType imageWithGroupType:annotation.type];

    self.enabled = YES;
    self.canShowCallout = YES;
    [self configureCalloutAccessoryView];
    [self addObserver:self forKeyPath:@"annotation.people" options:0 context:NULL];

    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"annotation.people"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self configureCalloutAccessoryView];
}

#pragma mark - Private Methods

- (void)configureCalloutAccessoryView
{
    NPGGroup *group = (NPGGroup *)self.annotation;

    if (group.people.count) {// == [[NPGAppSession sharedAppSession] currentGroup]) {
        self.rightCalloutAccessoryView = self.leaveButton;
    } else {
        self.rightCalloutAccessoryView = self.joinButton;
    }
}

- (UIButton *)joinButton
{
    if (_joinButton) return _joinButton;

    _joinButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _joinButton.frame = CGRectMake(0, 0, 55, 45);
    [_joinButton setTitle:@"Join" forState:UIControlStateNormal];
    _joinButton.titleLabel.font = [UIFont systemFontOfSize:18];
    _joinButton.tintColor = [UIColor whiteColor];
    _joinButton.backgroundColor = [UIColor actionTintColor];
    return _joinButton;
}

- (UIButton *)leaveButton
{
    if (_leaveButton) return _leaveButton;

    _leaveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _leaveButton.frame = CGRectMake(0, 0, 65, 45);
    [_leaveButton setTitle:@"Leave" forState:UIControlStateNormal];
    _leaveButton.titleLabel.font = [UIFont systemFontOfSize:18];
    _leaveButton.tintColor = [UIColor whiteColor];
    _leaveButton.backgroundColor = [UIColor negativeTintColor];
    return _leaveButton;
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

#pragma mark - Public Methods

- (void)configureWithAnnotation:(NPGGroup *)annotation
{
    self.annotation = annotation;
    self.image = [NPGGroupType imageWithGroupType:annotation.type];
    [self configureCalloutAccessoryView];
}

- (void)setImageTintColor:(UIColor *)color
{
    self.image = [self.image tintWithColor:color];
}

@end
