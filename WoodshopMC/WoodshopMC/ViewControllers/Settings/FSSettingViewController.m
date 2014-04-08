//
//  FSSettingViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSSettingViewController.h"
#import "Global.h"

@interface FSSettingViewController ()

@end

@implementation FSSettingViewController
@synthesize btntempC, btntempF, btnareaFT, btnareaM, btndateEU, btndateUS;
@synthesize viewUS, viewEuro, lblEuro, lblUS;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [btntempF setSelected:_globalData.settingTemp];
    [btntempC setSelected:!_globalData.settingTemp];
    [btnareaFT setSelected:_globalData.settingArea];
    [btnareaM setSelected:!_globalData.settingArea];
    [btndateUS setSelected:[_globalData.settingDateFormat isEqualToString:US_DATEFORMAT]];
    [btndateEU setSelected:![_globalData.settingDateFormat isEqualToString:US_DATEFORMAT]];
    [viewUS setBackgroundColor:[_globalData.settingDateFormat isEqualToString:US_DATEFORMAT] ? [UIColor colorWithRed:193.0f/255.0f green:182.0f/255.0f blue:169.0f/255.0f alpha:1.0f] : [UIColor colorWithRed:164.0f/255.0f green:149.0f/255.0f blue:130.0f/255.0f alpha:1.0f]];
    [viewEuro setBackgroundColor:![_globalData.settingDateFormat isEqualToString:US_DATEFORMAT] ? [UIColor colorWithRed:193.0f/255.0f green:182.0f/255.0f blue:169.0f/255.0f alpha:1.0f] : [UIColor colorWithRed:164.0f/255.0f green:149.0f/255.0f blue:130.0f/255.0f alpha:1.0f]];
    
    NSDate *curDate = [NSDate date];
    [lblUS setText:[CommonMethods date2str:curDate withFormat:US_DATEFORMAT]];
    [lblEuro setText:[CommonMethods date2str:curDate withFormat:EU_DATEFORMAT]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTempF:(id)sender
{
    [btntempC setSelected:NO];
    [btntempF setSelected:YES];
    _globalData.settingTemp = YES;
}

- (IBAction)onTempC:(id)sender
{
    [btntempF setSelected:NO];
    [btntempC setSelected:YES];
    _globalData.settingTemp = NO;
}

- (IBAction)onAreaFT:(id)sender
{
    [btnareaM setSelected:NO];
    [btnareaFT setSelected:YES];
    _globalData.settingArea = YES;
}

- (IBAction)onAreaM:(id)sender
{
    [btnareaFT setSelected:NO];
    [btnareaM setSelected:YES];
    _globalData.settingArea = NO;
}

- (IBAction)onDateUS:(id)sender
{
    [btndateEU setSelected:NO];
    [btndateUS setSelected:YES];
    [viewEuro setBackgroundColor:[UIColor colorWithRed:164.0f/255.0f green:149.0f/255.0f blue:130.0f/255.0f alpha:1.0f]];
    [viewUS setBackgroundColor:[UIColor colorWithRed:193.0f/255.0f green:182.0f/255.0f blue:169.0f/255.0f alpha:1.0f]];
    _globalData.settingDateFormat = US_DATEFORMAT;
}

- (IBAction)onDateEU:(id)sender
{
    [btndateUS setSelected:NO];
    [btndateEU setSelected:YES];
    [viewUS setBackgroundColor:[UIColor colorWithRed:164.0f/255.0f green:149.0f/255.0f blue:130.0f/255.0f alpha:1.0f]];
    [viewEuro setBackgroundColor:[UIColor colorWithRed:193.0f/255.0f green:182.0f/255.0f blue:169.0f/255.0f alpha:1.0f]];
    _globalData.settingDateFormat = EU_DATEFORMAT;
}

@end
