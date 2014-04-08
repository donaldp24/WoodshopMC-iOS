//
//  FSRecordViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSRecordViewController.h"
#import "FSJobViewController.h"
#import "Defines.h"
#import "CommonMethods.h"
#import "DataManager.h"
#import "GlobalData.h"
#import "FSCurReadingsViewController.h"
#import "FSMainViewController.h"

#import "EmulatorReadingParser.h"
#import "SensorReadingParser.h"
#import "Global.h"

@interface FSRecordViewController () {
    CGFloat trasnfromHeight;
    
    NSMutableArray *arrayJobs;
}

@end

@implementation FSRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        trasnfromHeight = 0.0f;
    }
    return self;
}

- (void)initMember
{
    defaultLocation = [[FSLocation alloc] init];
    defaultLocation.locID = 0;
    defaultLocation.locJobID = 0;
    defaultLocation.locName = FMD_DEFAULT_LOCATIONNAME;
    
    /*
    defaultProduct = [[FSLocProduct alloc] init];
    defaultProduct.locProductID = 0;
    defaultProduct.locProductLocID = 0;
    defaultProduct.locProductName = @DEFAULT_PRODUCTNAME;
    defaultProduct.locProductType = FSProductTypeFinished;
    defaultProduct.locProductCoverage = 0.0;
     */
    
    defaultProduct = [[FSProduct alloc] init];
    defaultProduct.productID = 0;
    defaultProduct.productName = FMD_DEFAULT_PRODUCTNAME;
    defaultProduct.productType = FSProductTypeFinished;
    defaultProduct.productDeleted = 0.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initMember];
    
    trasnfromHeight = 0.0f;
    
    readingVC = nil;
    
    GlobalData *globalData = [GlobalData sharedData];
    if (globalData.isSaved == YES)
    {
        selectedJob = [[DataManager sharedInstance] getJobFromID:globalData.selectedJobID];
        selectedLocation = [[DataManager sharedInstance] getLocationFromID:globalData.selectedLocID];
        selectedProduct = nil;
        selectedLocProduct = [[DataManager sharedInstance] getLocProductWithID:globalData.selectedLocProductID];
        
        if (selectedJob == nil
            || selectedLocation == nil
            || selectedLocProduct == nil)
        {
            NSLog(@"global data : jobid(%ld - %ld), locid(%ld - %ld), locproductid(%ld - %ld) ", globalData.selectedJobID, (selectedJob == nil ? 0 : selectedJob.jobID), globalData.selectedLocID, (selectedLocation == nil ? 0 : selectedLocation.locID), globalData.selectedLocProductID, (selectedLocProduct == nil ? 0 : selectedLocProduct.locProductID));
        }
        else
        {
            NSLog(@"global data : jobid(%ld - %@), locid(%ld - %@), locproductid(%ld - %@) ", selectedJob.jobID, selectedJob.jobName, selectedLocation.locID, selectedLocation.locName, selectedLocProduct.locProductID, selectedLocProduct.locProductName);
        }
        
        [self setLabelSelected:self.lblJob text:selectedJob.jobName];
        [self setLabelSelected:self.lblLocation text:selectedLocation.locName];
        [self setLabelSelected:self.lblProduct text:selectedLocProduct.locProductName];
        
        if (globalData.settingArea == YES) //ft
        {
            self.txtCoverage.text = [NSString stringWithFormat:@"%.2f", selectedLocProduct.locProductCoverage];
        }
        else
        {
            self.txtCoverage.text = [NSString stringWithFormat:@"%.2f", [GlobalData sqft2sqm:selectedLocProduct.locProductCoverage]];
        }
        
        if ([selectedLocation.locName isEqualToString:FMD_DEFAULT_LOCATIONNAME])
        {
            [self setLabelNotSelected:self.lblLocation];
        }
        if ([selectedLocProduct.locProductName isEqualToString:FMD_DEFAULT_PRODUCTNAME])
        {
            [self setLabelNotSelected:self.lblProduct];
        }
        
        self.btnSave.enabled = NO;
        self.btnCancel.enabled = YES;
        //self.btnSummary.enabled = YES;
        self.txtCoverage.enabled = NO;
    }
    else
    {
        selectedJob = nil;
        selectedLocation = nil;
        selectedProduct = nil;
        selectedLocProduct = nil;
        
        [self setLabelNotSelected:self.lblJob];
        [self setLabelNotSelected:self.lblLocation];
        [self setLabelNotSelected:self.lblProduct];
        self.txtCoverage.text = @"";
        
        self.btnSave.enabled = YES;
        self.btnCancel.enabled = NO;
        //self.btnSummary.enabled = NO;
        self.txtCoverage.enabled = YES;
    }
    
    if (globalData.settingArea == YES) //ft
    {
        self.lblUnitFt.hidden = NO;
        self.lblUnitM.hidden = YES;
        
        isPrevSqureFoot = YES;
    }
    else
    {
        self.lblUnitFt.hidden = YES;
        self.lblUnitM.hidden = NO;
        
        isPrevSqureFoot = NO;
    }
    
    curTextField = nil;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    readingVC = nil;
    GlobalData *globalData = [GlobalData sharedData];
    
    BOOL isKeeped = YES;
    if (selectedJob)
    {
        FSJob *orgJob = selectedJob;
        selectedJob = [[DataManager sharedInstance] getJobFromID:selectedJob.jobID];
        if (selectedJob == nil)
        {
            isKeeped = NO;
            selectedLocation = nil;
            selectedLocProduct = nil;
            selectedProduct = nil;
            NSLog(@"don't keep - job : %ld, %@", orgJob.jobID, orgJob.jobName);
        }
        else
        {
            [self setLabelSelected:self.lblJob text:[NSString stringWithFormat:@"%@", selectedJob.jobName]];
        }
    }

    if (selectedLocation)
    {
        FSLocation *orgLoc = selectedLocation;
        selectedLocation = [[DataManager sharedInstance] getLocationFromID:selectedLocation.locID];
        if (selectedLocation == nil)
        {
            isKeeped = NO;
            selectedProduct = nil;
            selectedLocProduct = nil;
            NSLog(@"don't keep - loc : %ld, %@", orgLoc.locID, orgLoc.locName);
        }
        else
        {
            [self setLabelSelected:self.lblLocation text:[NSString stringWithFormat:@"%@", selectedLocation.locName]];
        }
    }
    
    if (selectedProduct)
    {
        FSProduct *orgProduct = selectedProduct;
        selectedProduct = [[DataManager sharedInstance] getProductFromID:selectedProduct.productID];
        if (selectedProduct == nil) {
            isKeeped = NO;
            NSLog(@"don't keep - product : %ld, %@", orgProduct.productID, orgProduct.productName);
        }
        else
        {
            [self setLabelSelected:self.lblProduct text:[NSString stringWithFormat:@"%@", selectedProduct.productName]];
        }
    }
    
    if (selectedLocProduct)
    {
        FSLocProduct *orgLocProduct = selectedLocProduct;
        selectedLocProduct = [[DataManager sharedInstance] getLocProductWithID:selectedLocProduct.locProductID];
        if (selectedLocProduct == nil) {
            isKeeped = NO;
            NSLog(@"don't keep - locproduct : %ld, %@", orgLocProduct.locProductID, orgLocProduct.locProductName);
        }
        else
        {
            [self setLabelSelected:self.lblProduct text:[NSString stringWithFormat:@"%@", selectedLocProduct.locProductName]];
        }
    }
    
    if (isKeeped == NO)
    {
        GlobalData *globalData = [GlobalData sharedData];
        if (globalData.isSaved)
        {
            [globalData resetSavedData];
            self.btnCancel.enabled = NO;
            self.btnSave.enabled = YES;
            //self.btnSummary.enabled = NO;
        }
        
        if (selectedJob == nil) {
            [self setLabelNotSelected:self.lblJob];
            [self setLabelNotSelected:self.lblLocation];
            [self setLabelNotSelected:self.lblProduct];

            self.txtCoverage.text = @"";
            selectedLocation = nil;
            selectedLocProduct = nil;
            selectedProduct = nil;
        }
        else
        {
            [self setLabelNotSelected:self.lblLocation];
            [self setLabelNotSelected:self.lblProduct];
            
            if (selectedLocation == nil)
            {
                selectedLocation = [[DataManager sharedInstance] getDefaultLocationOfJob:selectedJob.jobID];
                selectedLocProduct = nil;
                selectedProduct = nil;
            }
            
            if (selectedLocation != nil)
            {
                if (selectedLocProduct == nil && selectedProduct == nil)
                    selectedLocProduct = [[DataManager sharedInstance] getDefaultLocProductOfLocation:selectedLocation];
                
                if ([selectedLocation.locName isEqualToString:FMD_DEFAULT_LOCATIONNAME])
                    [self setLabelNotSelected:self.lblLocation];
                else
                    [self setLabelSelected:self.lblLocation text:selectedLocation.locName];
            }
            
            if (selectedLocProduct != nil)
            {
                if ([selectedLocProduct.locProductName isEqualToString:FMD_DEFAULT_PRODUCTNAME])
                    [self setLabelNotSelected:self.lblProduct];
                else
                    [self setLabelSelected:self.lblProduct text:selectedLocProduct.locProductName];
            }
        }
    }
    
    self.btnSummary.enabled = YES;
    
    // set txtcoverage
    CGFloat coverage = [self.txtCoverage.text floatValue];
    // have to convert unit
    if (isPrevSqureFoot == globalData.settingArea)
        coverage = coverage;
    else
    {
        if (globalData.settingArea == YES)
        {
            coverage = [GlobalData sqm2sqft:coverage];
            isPrevSqureFoot = YES;
        }
        else
        {
            coverage = [GlobalData sqft2sqm:coverage];
            isPrevSqureFoot = NO;
        }
    }
    
    if (globalData.settingArea == YES)
    {
        self.lblUnitFt.hidden = NO;
        self.lblUnitM.hidden = YES;
    }
    else
    {
        self.lblUnitFt.hidden = YES;
        self.lblUnitM.hidden = NO;
    }
    self.txtCoverage.text = [NSString stringWithFormat:@"%.2f", coverage];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
    
    
    arrayJobs = [[DataManager sharedInstance] getJobs:0 searchField:@""];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)BeginEditing:(UITextField *)sender
{
    curTextField = sender;
    
}

- (IBAction)EndEditing:(UITextField *)sender
{
    

    curTextField = nil;
    [sender resignFirstResponder];
}

- (IBAction)onBgClicked:(id)sender
{
    if (curTextField != nil)
    {
        
        [curTextField resignFirstResponder];
        curTextField = nil;
    }
}


#pragma mark - Actions
- (IBAction)onSelJob:(id)sender
{
    [CommonMethods playTapSound];
    
    if ([self isSelectable] == NO)
    {
        [self showAlertForNotSelectable];
        return;
    }
    FSJobViewController *vc = [[FSJobViewController alloc] initWithNibName:@"FSJobViewController" bundle:nil];
    vc.mode = MODE_RECORD;
    vc.jobSelectDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSelLocation:(id)sender
{
    
    [CommonMethods playTapSound];
    
    if ([self isSelectable] == NO)
    {
        [self showAlertForNotSelectable];
        return;
    }
    
    if (selectedJob == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a job"];
        return;
    }
    
    FSLocationsViewController *vc = [[FSLocationsViewController alloc] initWithNibName:@"FSLocationsViewController" bundle:nil];
    vc.mode = MODE_RECORD;
    vc.curJob = selectedJob;
    vc.locationSelectDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSelProduct:(id)sender
{
    
    [CommonMethods playTapSound];
    
    if ([self isSelectable] == NO)
    {
        [self showAlertForNotSelectable];
        return;
    }
    
    if (selectedJob == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a job"];
        return;
    }
    
    FSLocProductViewController *vc = [[FSLocProductViewController alloc] initWithNibName:@"FSLocProductViewController" bundle:nil];
    if (selectedLocation == nil)
        vc.curLoc = defaultLocation;
    else
        vc.curLoc = selectedLocation;
    vc.locProductSelectDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onJobClick:(id)sender
{
    [self.txtCoverage resignFirstResponder];
    
    NSMutableArray *arrayData = [[DataManager sharedInstance] getJobs:0 searchField:@""];
    if (arrayData.count <= 0)
    {
        [self onSelJob:nil];
        return;
    }
    
    [CommonMethods playTapSound];
    
    if ([self isSelectable] == NO)
    {
        [self showAlertForNotSelectable];
        return;
    }
    
    
    jobSelector = [[FSSelectViewController alloc] initWithParent:@"FSSelectViewController" bundle:nil parent:self mode:MODE_SELECT_JOB parentNode:nil];
    if (selectedJob != nil)
        [jobSelector setCurSelected:selectedJob];
    
    [self.view addSubview:jobSelector.view]; [self.view bringSubviewToFront:jobSelector.view];
    /*
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveLinear animations:^ { [self.view addSubview:jobSelector.view]; [self.view bringSubviewToFront:jobSelector.view]; } completion:nil];
     */

}

- (IBAction)onLocationClick:(id)sender
{
    [self.txtCoverage resignFirstResponder];
    
    if (selectedJob == nil)
    {
        [self onSelLocation:nil];
        return;
    }
    
    //NSMutableArray *arrayData = [[DataManager sharedInstance] getLocations:selectedJob.jobID];
    NSMutableArray *arrayData = [[DataManager sharedInstance] getAllDistinctLocations];
    if (arrayData.count <= 0)
    {
        [self onSelLocation:nil];
        return;
    }
    
    [CommonMethods playTapSound];
    
    if ([self isSelectable] == NO)
    {
        [self showAlertForNotSelectable];
        return;
    }
    
    if (selectedJob == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a job"];
        return;
    }
    
    jobSelector = [[FSSelectViewController alloc] initWithParent:@"FSSelectViewController" bundle:nil parent:self mode:MODE_SELECT_LOCATION parentNode:selectedJob];
    if (selectedLocation != nil)
        [jobSelector setCurSelected:selectedLocation];
    
    [self.view addSubview:jobSelector.view]; [self.view bringSubviewToFront:jobSelector.view];
    /*
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveLinear animations:^ { [self.view addSubview:jobSelector.view]; [self.view bringSubviewToFront:jobSelector.view]; } completion:nil];
     */

}

- (IBAction)onProductClick:(id)sender
{
    [self.txtCoverage resignFirstResponder];
    
    FSLocation *loc = nil;
    if (selectedLocation == nil)
        loc = defaultLocation;
    else
        loc = selectedLocation;
    
    if (loc == nil)
    {
        [self onSelProduct:nil];
        return;
    }
    
    //NSMutableArray *arrayData = [[DataManager sharedInstance] getLocProducts:loc searchField:@""];
    NSMutableArray *arrayData = [[DataManager sharedInstance] getProducts:@""];
    if (arrayData.count <= 0)
    {
        [self onSelProduct:nil];
        return;
    }
    
    [CommonMethods playTapSound];
    
    if ([self isSelectable] == NO)
    {
        [self showAlertForNotSelectable];
        return;
    }
    
    if (selectedJob == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a job"];
        return;
    }
    
    
    jobSelector = [[FSSelectViewController alloc] initWithParent:@"FSSelectViewController" bundle:nil parent:self mode:MODE_SELECT_PRODUCT parentNode:loc];
    if (selectedLocProduct != nil)
        [jobSelector setCurSelected:selectedLocProduct];
    
    [self.view addSubview:jobSelector.view]; [self.view bringSubviewToFront:jobSelector.view];
    /*
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveLinear animations:^ { [self.view addSubview:jobSelector.view]; [self.view bringSubviewToFront:jobSelector.view]; } completion:nil];
     */
}

- (void)showSummary
{
    self.btnSummary.hidden = NO;
}

- (void)hideSummary
{
    self.btnSummary.hidden = YES;
}

#pragma mark - Job Select Delegate
- (void)jobSelected:(FSJob *)job
{
    
    [self.lblHintJob setHidden:YES];
    
    if (selectedJob.jobID == job.jobID)
        return;
    
    selectedJob = job;
    selectedLocation = nil;
    selectedProduct = nil;
    selectedLocProduct = nil;
    
    [self setLabelSelected:self.lblJob text:job.jobName];
   
    [self setLabelNotSelected:self.lblLocation];
    [self setLabelNotSelected:self.lblProduct];

    
    
    selectedLocation = [[DataManager sharedInstance] getDefaultLocationOfJob:job.jobID];
    if (selectedLocation != nil)
    {
        //selectedLocProduct = [[DataManager sharedInstance] getDefaultLocProductOfLocation:selectedLocation];
        [self locationSelected:selectedLocation];
    }
    else
    {
        /*
        defaultLocation.locID = 0;
        defaultLocation.locName = FMD_DEFAULT_LOCATIONNAME;
        defaultLocation.locJobID = selectedJob.jobID;
        
        int retId = [[DataManager sharedInstance] addLocationToDatabase:defaultLocation];
        defaultLocation = [[DataManager sharedInstance] getLocationFromID:retId];
        
        [self locationSelected:selectedLocation];
         */
    }
    
    defaultLocation.locJobID = job.jobID;
    
    
    
}

#pragma mark - Location Select Delegate
- (void)locationSelected:(FSLocation *)loc
{
    [self.lblHintLocation setHidden:YES];
    
    if (selectedLocation.locID == loc.locID)
        return;
    
    selectedLocation = loc;
    
    [self setLabelSelected:self.lblLocation text:loc.locName];
    
    [self setLabelNotSelected:self.lblProduct];
    
    selectedProduct = nil;
    selectedLocProduct = [[DataManager sharedInstance] getDefaultLocProductOfLocation:selectedLocation];
    if (selectedLocProduct != nil)
    {
        [self locProductSelected:selectedLocProduct];
    }
    
}

#pragma mark - LocProduct Select Delegate
- (void)locationAdded:(FSLocation *)loc
{
    selectedLocation = loc;
    
    [self setLabelSelected:self.lblLocation text:loc.locName];
    
    [self setLabelNotSelected:self.lblProduct];
    
    selectedProduct = nil;
    selectedLocProduct = [[DataManager sharedInstance] getDefaultLocProductOfLocation:selectedLocation];
    if (selectedLocProduct != nil)
    {
        [self locProductSelected:selectedLocProduct];
    }
    
}


- (void)productSelected:(FSProduct *)product
{
    [self.lblHintProduct setHidden:YES];
    
    if (selectedProduct.productID == product.productID)
        return;
    
    FSLocProduct *locProduct = [[DataManager sharedInstance] getLocProductWithProduct:product locID:selectedLocation.locID];
    if (locProduct != nil)
    {
        selectedProduct = nil;
        [self locProductSelected:locProduct];
    }
    else
    {
        selectedProduct = product;
        selectedLocProduct = nil;
        [self setLabelSelected:self.lblProduct text:selectedProduct.productName];
    }
    
    
}

- (void)locProductSelected:(FSLocProduct *)locProduct
{
    [self.lblHintProduct setHidden:YES];
    
    if (selectedLocProduct.locProductID == locProduct.locProductID)
        return;
    
    selectedLocProduct = locProduct;
    selectedProduct = nil;
    
    [self setLabelSelected:self.lblProduct text:selectedLocProduct.locProductName];
    
    float coverage = selectedLocProduct.locProductCoverage;
    GlobalData *globalData = [GlobalData sharedData];
    
    if (globalData.settingArea == YES) //ft
        coverage = coverage;
    else
        coverage = [GlobalData sqft2sqm:coverage];
    [self.txtCoverage setText:[NSString stringWithFormat:@"%.2f", coverage]];
    
}

#pragma mark - Actions
- (IBAction)onSaveClicked:(id)sender
{
    [CommonMethods playTapSound];
    
    if (curTextField != nil)
    {
        [curTextField resignFirstResponder];
    }
    
    if (selectedJob == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a job"];
        return;
    }
    
    GlobalData *globalData = [GlobalData sharedData];
    
    float coverage = [self.txtCoverage.text floatValue];
    if (globalData.settingArea == YES) //ft
        coverage = coverage;
    else
        coverage = [GlobalData sqm2sqft:coverage];
    
    if (selectedLocation == nil)
    {
        // add default location to this job
        defaultLocation.locJobID = selectedJob.jobID;
        defaultLocation.locName = FMD_DEFAULT_LOCATIONNAME;
        int loc_id = [[DataManager sharedInstance] addLocationToDatabase:defaultLocation];
        selectedLocation = [[DataManager sharedInstance] getLocationFromID:loc_id];
    }
    
    if (selectedLocation == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a location"];
        return;
    }
    
    if (selectedLocProduct) {
        selectedLocProduct.locProductCoverage = coverage;
        [[DataManager sharedInstance] updateLocProductToDatabase:selectedLocProduct];
    }
    else
    if (selectedProduct)
    {
        FSLocProduct *locProduct = [[DataManager sharedInstance] getLocProductWithProduct:selectedProduct locID:selectedLocation.locID];
        if (locProduct)
        {
            selectedLocProduct = locProduct;
            selectedLocProduct.locProductCoverage = coverage;
            [[DataManager sharedInstance] updateLocProductToDatabase:selectedLocProduct];
        }
        else
        {
            // add this selected product to locproduct list for the specific location
            int locproduct_id = [[DataManager sharedInstance] addLocProductToDatabaseWithProduct:selectedProduct locID:(long)selectedLocation.locID coverage:coverage];
            selectedLocProduct = [[DataManager sharedInstance] getLocProductWithID:locproduct_id];
        }
    }
    else
    {
        // add default product for specific location
        FSLocProduct *locProduct = [[FSLocProduct alloc] init];
        locProduct.locProductLocID = selectedLocation.locID;
        locProduct.locProductName = FMD_DEFAULT_PRODUCTNAME;
        locProduct.locProductType = FSProductTypeFinished;
        locProduct.locProductCoverage = coverage;
        locProduct.locProductID = [[DataManager sharedInstance] addLocProductToDatabase:locProduct];
        
        selectedLocProduct = [[DataManager sharedInstance] getLocProductWithID:locProduct.locProductID];
    }
    
    if (selectedLocProduct == nil)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please select a product"];
        return;
    }
    
    self.txtCoverage.enabled = NO;
    
    
    
    [[GlobalData sharedData] setSavedData:selectedJob.jobID selectedLocID:selectedLocation.locID selectedLocProductID:selectedLocProduct.locProductID];
    
    //self.btnSummary.enabled = YES;
    self.btnCancel.enabled = YES;
    self.btnSave.enabled = NO;
    
    FSMainViewController *mainController = [FSMainViewController sharedController];
    [mainController.scanManager stopScan];
    [mainController.scanManager performSelector:@selector(startScan) withObject:nil afterDelay:2];
    
}

- (IBAction)onCancelClicked:(id)sender
{
    [CommonMethods playTapSound];
    
    if (curTextField != nil)
        [curTextField resignFirstResponder];
    
    [[GlobalData sharedData] resetSavedData];
    
    //self.btnSummary.enabled = NO;
    self.btnCancel.enabled = NO;
    self.btnSave.enabled = YES;
    
    self.txtCoverage.enabled = YES;
    
}

- (IBAction)onSummaryClicked:(id)sender
{
    [CommonMethods playTapSound];
    
    if (curTextField != nil)
        [curTextField resignFirstResponder];
    
    if (readingVC == nil)
    {
        readingVC = [[FSCurReadingsViewController alloc] initWithNibName:@"FSCurReadingsViewController" bundle:nil];
        [readingVC setCurLocProduct:selectedLocProduct];
        [self.navigationController pushViewController:readingVC animated:YES];
    }
    
}

- (BOOL)isSelectable
{
    GlobalData *globalData = [GlobalData sharedData];
    if (globalData.isSaved == YES)
        return NO;
    return YES;
}

- (void)showAlertForNotSelectable
{
    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Cannot change selection, \n Please press 'Cancel' button to stop recording first!"];
}

- (void)saveNewData:(NSDictionary *)data
{
    if (selectedLocProduct == nil)
        return;
    FSReading *reading = [[FSReading alloc] init];
    reading.readID = 0;
    reading.readLocProductID = selectedLocProduct.locProductID;
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
    [[DataManager sharedInstance] addReadingToDatabase:reading];
}

- (void)showReadingView
{
    [self performSelectorOnMainThread:@selector(navigateToReadingVC) withObject:nil waitUntilDone:NO];
}

- (void)navigateToReadingVC
{
    if (readingVC == nil)
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        if (curTextField != nil)
            [curTextField resignFirstResponder];
        
        if (selectedLocProduct == nil)
            return;
        
        readingVC = [[FSCurReadingsViewController alloc] initWithNibName:@"FSCurReadingsViewController" bundle:nil];
        [readingVC setCurLocProduct:selectedLocProduct];
        [self.navigationController pushViewController:readingVC animated:YES];
    }
    else
    {
        [readingVC initDateTable];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (curTextField == self.txtCoverage)
    {
        self.btnBg.hidden = NO;
        CGRect selectedCellFrame = self.txtCoverage.frame;
        if (selectedCellFrame.origin.y + 40 >= [[UIScreen mainScreen] bounds].size.height - KEYBOARD_HEIGHT /* 216 */) {
            trasnfromHeight = selectedCellFrame.origin.y + 40 - [[UIScreen mainScreen] bounds].size.height + KEYBOARD_HEIGHT;
            [UIView animateWithDuration:0.1f animations:^{
                [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - trasnfromHeight, self.view.frame.size.width, self.view.frame.size.height)];
            }];
        } else {
            trasnfromHeight = 0;
        }
        
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.btnBg.hidden = YES;
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + trasnfromHeight, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }
    
    trasnfromHeight = 0.0f;
    
    curTextField = nil;
}

- (void)setLabelNotSelected:(UILabel *)label
{
    [label setText:@"Not selected..."];
    [label setTextColor:[UIColor colorWithRed:168/255.0 green:168/255.0 blue:168/255.0 alpha:1.0]];
    [label setFont:[UIFont italicSystemFontOfSize:14.0]];
}
- (void)setLabelSelected:(UILabel *)label text:(NSString *)text
{
    [label setText:text];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont boldSystemFontOfSize:16.0]];
}


@end
