//
//  NPGEditGroupViewController.m
//  Gather
//
//  Created by Tony DiPasquale on 3/30/14.
//  Copyright (c) 2014 tstormlabs. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "NPGEditGroupViewController.h"
#import "NPGGroup.h"
#import "NPGDateFormatterFactory.h"
#import "NSDate+Additions.h"
#import "NPGGroupType.h"
#import "NPGAPIClient.h"

@interface NPGEditGroupViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *typePicker;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIImageView *typeImage;

@property (nonatomic) NSString *selectedType;

@end

@implementation NPGEditGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.timePicker.date = [NSDate tomorrowWithHour:6 minute:0];
    self.selectedType = @"run";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    MKCoordinateRegion region = [self.mapView regionThatFits:MKCoordinateRegionMake(self.coordinate, MKCoordinateSpanMake(0.002, 0.002))];
    self.mapView.region = region;
}

#pragma mark - Actions

- (IBAction)typeChanged
{
    switch (self.typePicker.selectedSegmentIndex) {
        case 0:
            self.selectedType = @"run";
            break;

        case 1:
            self.selectedType = @"bike";
            break;

        case 2:
            self.selectedType = @"car";
            break;

        default:
            break;
    }

    self.typeImage.image = [NPGGroupType imageWithGroupType:self.selectedType];
}

- (IBAction)save
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.timePicker.date];
    NSDate *time = [NSDate tomorrowWithHour:components.hour minute:components.minute];

    double lat = [[NSString stringWithFormat:@"%.6f", self.mapView.centerCoordinate.latitude] doubleValue];
    double lng = [[NSString stringWithFormat:@"%.6f", self.mapView.centerCoordinate.longitude] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lng);

    [NPGAPIClient createGroupWithType:self.selectedType time:time coordinate:coordinate completionHandler:^(NPGGroup *group) {
        if (!group) {
            return [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was an error creating your group." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }

        [self.delegate editGroupViewControllerDidSaveGroup:group];
    }];
}

- (IBAction)cancel
{
    [self.delegate editGroupViewControllerDidCancel];
}

@end
