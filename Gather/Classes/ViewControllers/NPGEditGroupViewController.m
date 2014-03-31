//
//  NPGEditGroupViewController.m
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import "NPGEditGroupViewController.h"
#import "NPGGroup.h"
#import "NPGDateFormatterFactory.h"

@interface NPGEditGroupViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *typePicker;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIImageView *typeImage;

@end

@implementation NPGEditGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapView.region = MKCoordinateRegionMake(self.group.location, MKCoordinateSpanMake(0.01, 0.01));
    self.timePicker.date = [[NPGDateFormatterFactory timeFormatter] dateFromString:self.group.time];
}

#pragma mark - Actions

- (IBAction)typeChanged
{
    switch (self.typePicker.selectedSegmentIndex) {
        case 0:
            self.group.type = @"run";
            self.typeImage.image = [UIImage imageNamed:@"RunIcon"];
            break;

        case 1:
            self.group.type = @"bike";
            self.typeImage.image = [UIImage imageNamed:@"BikeIcon"];
            break;

        case 2:
            self.group.type = @"car";
            self.typeImage.image = [UIImage imageNamed:@"CarIcon"];
            break;

        default:
            break;
    }
}

- (IBAction)save
{
    self.group.time = [[NPGDateFormatterFactory timeFormatter] stringFromDate:self.timePicker.date];
    self.group.location = self.mapView.centerCoordinate;
    [self.delegate editGroupViewControllerDidFinish];
}

- (IBAction)cancel
{
    [self.delegate editGroupViewControllerDidCancel];
}

@end
