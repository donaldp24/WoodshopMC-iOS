//
//  FSMainViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSMainViewController.h"
#import "FSRecordViewController.h"
#import "GlobalData.h"
#import "Global.h"
#import "CommonMethods.h"

@interface FSMainViewController ()

@end

@implementation FSMainViewController
@synthesize viewForTabbar, btnHome, btnReports;

const int scanDelay = 5;

+ (FSMainViewController *) sharedController
{
    __strong static FSMainViewController *sharedController = nil;
	static dispatch_once_t onceToken;
    
	dispatch_once(&onceToken, ^{
        sharedController = [[[NSBundle mainBundle] loadNibNamed:@"FSMainViewController" owner:nil options:nil] objectAtIndex:0];
	});
    
    return sharedController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tabBar] addSubview:viewForTabbar];
    [viewForTabbar setFrame:CGRectMake(0, 0, viewForTabbar.frame.size.width, viewForTabbar.frame.size.height)];
    
    [self setSelected:1];
    [btnHome setSelected:YES];
    
    /* start scanning */
    _scanManager = [[ScanManager alloc] init];
    [_scanManager setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setSelected:(NSInteger)index
{
    if(index != [self selectedIndex] + 1)
    {
        [self setSelectedIndex:index - 1];
        return ;
    }
}

- (void)clearSelected
{
    for (int i=1; i<6; i++) {
        UIView *v = [viewForTabbar viewWithTag:i];
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            [btn setSelected:NO];
        }
    }
}

- (void)selectItem:(UIButton *)btnItem
{
    [self clearSelected];
    [btnItem setSelected:YES];
    [self setSelected:btnItem.tag];
}

- (IBAction)onTabItem:(id)sender
{
    [CommonMethods playTapSound];
    
    UIButton *tabItem = (UIButton *)sender;
    [self clearSelected];
    [tabItem setSelected:YES];
    
    if (tabItem.tag == 3) {
        [self setSelected:1];
    } else {
        [self setSelected:tabItem.tag];
    }
    //[self setSelected:tabItem.tag];
}


#pragma mark - Bluetooth Management Helper Functions


- (void)scanManagerDidStartScanning:(ScanManager *)scanManager {
    
#ifdef TESTFLIGHT_ENABLED
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"FloorSmart:scanForPeripheralsWithServices"]];
    NSLog(@"FloorSmart:scanPeripheralsWithServices");
#endif
}

- (void)scanManager:(ScanManager *)scanManager didFindSensor:(NSDictionary *)sensorData {
    
    SEL aSelector = NSSelectorFromString(@"startScan");
    [self.scanManager stopScan];
    
    //[self.scanManager performSelector:aSelector withObject:nil afterDelay:scanDelay];
    [self.scanManager performSelector:aSelector withObject:nil afterDelay:0.1];
    NSLog(@"FloorSmart:scanManager.didFindSensor");
    
    GlobalData *globalData = [GlobalData sharedData];
    if (globalData.isSaved == NO)
        return;
    
    [self onTabItem:(id)self.btnRecord];
    
    FSRecordViewController *recordVC = nil;
    UINavigationController *NC = [self.viewControllers objectAtIndex:4];
    if (NC) {
        recordVC = NC.viewControllers.firstObject;
        if (recordVC)
        {
            [recordVC saveNewData:[self readingFromData:sensorData]];
            [recordVC showReadingView];
        }
    }
}

- (void)scanManager:(ScanManager *)scanManager didFindThirdPackage:(NSData *)thirdData
{
    SEL aSelector = NSSelectorFromString(@"startScan");
    [self.scanManager stopScan];
    //[self.scanManager performSelector:aSelector withObject:nil afterDelay:scanDelay];
    [self.scanManager performSelector:aSelector withObject:nil afterDelay:scanDelay];
    NSLog(@"FloorSmart:scanManager.didFindThirdPackage");
    
}


- (BOOL)isSameAsBefore:(NSDictionary *)beforeData withData:(NSDictionary *)sensorData
{
    if (beforeData == nil)
    {
        if (sensorData == nil)
            return YES;
        else
            return NO;
    }
    else if (sensorData == nil)
        return NO;
    
    FSReading *readingBefore = [self readingFromData:beforeData];
    FSReading *readingNew = [self readingFromData:sensorData];
    if (readingBefore.readMC == readingNew.readMC &&
        readingBefore.readMaterial == readingNew.readMaterial &&
        readingBefore.readGravity == readingNew.readGravity &&
        readingBefore.readDepth == readingNew.readDepth &&
        readingBefore.readBattery == readingNew.readBattery &&
        readingBefore.readTemp == readingNew.readTemp &&
        readingBefore.readRH == readingBefore.readRH)
        return YES;
    return NO;
}

- (FSReading *)readingFromData:(NSDictionary *)data
{
    FSReading *reading = [[FSReading alloc] init];
    reading.readID = 0;
    
    reading.readLocProductID = 0;
    
    reading.readTimestamp = [CommonMethods str2date:[data objectForKey:kSensorDataReadingTimestampKey] withFormat:DATETIME_FORMAT];
    reading.readUuid = [data objectForKey:kSensorDataUuidKey];
    reading.readRH = (long)[[data objectForKey:kSensorDataRHKey] intValue];
    reading.readConvRH = (double)[[data objectForKey:kSensorDataConvRHKey] floatValue];
    reading.readTemp = (long)[[data objectForKey:kSensorDataTemperatureKey] intValue];
    reading.readConvTemp = (double)[[data objectForKey:kSensorDataConvTempKey] floatValue];
    reading.readBattery = (long)[[data objectForKey:kSensorDataBatteryKey] intValue];
    reading.readDepth = (long)[[data objectForKey:kSensorDataDepthKey] intValue];
    reading.readGravity = (long)[[data objectForKey:kSensorDataGravityKey] intValue];
    reading.readMaterial = (long)[[data objectForKey:kSensorDataMaterialKey] intValue];
    reading.readMC = (long)[[data objectForKey:kSensorDataMCKey] intValue];
    return reading;
}

@end
