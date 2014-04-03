//
//  NPGEditGroupViewController.m
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "NPGEditGroupViewController.h"
#import "NPGGroup.h"
#import "NPGDateFormatterFactory.h"
#import "NSDate+Additions.h"
#import "NPGGroupType.h"

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

    self.mapView.region = MKCoordinateRegionMake(self.group.coordinate, MKCoordinateSpanMake(0.01, 0.01));
    self.timePicker.date = self.group.time;
}

#pragma mark - Actions

- (IBAction)typeChanged
{
    switch (self.typePicker.selectedSegmentIndex) {
        case 0:
            self.group.type = @"run";
            break;

        case 1:
            self.group.type = @"bike";
            break;

        case 2:
            self.group.type = @"car";
            break;

        default:
            break;
    }

    self.typeImage.image = [NPGGroupType imageWithGroupType:self.group.type];
}

- (IBAction)save
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.timePicker.date];
    self.group.time = [NSDate tomorrowWithHour:components.hour minute:components.minute];
    self.group.coordinate = self.mapView.centerCoordinate;

    [self.delegate editGroupViewControllerDidSaveGroup:self.group];
}

- (IBAction)cancel
{
    [self.delegate editGroupViewControllerDidCancel];
}

@end
