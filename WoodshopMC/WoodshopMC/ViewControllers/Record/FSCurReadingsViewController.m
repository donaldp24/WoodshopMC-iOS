//
//  FSCurReadingsViewController.m
//  FloorSmart
//
//  Created by Lydia on 1/5/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSCurReadingsViewController.h"
#import "FSMeasureCell.h"
#import "Global.h"
#import "DataManager.h"
#import "FSReading.h"
#import "FSReportCell.h"
#import "CommonMethods.h"
#import "GlobalData.h"
//----
#import "Defines.h"
#import "AutoMessageBox.h"

@interface FSCurReadingsViewController ()

@end

@implementation FSCurReadingsViewController {
    NSMutableArray *arrReadingCounts;
    FSReportCell *selectedCell;
    NSMutableArray *arrOverallReadings;
    NSMutableData *receivedData;
    UIColor *infoColorOrdinal, *infoColorError, *infoColorSubscribed;
}
@synthesize tblDetal;
@synthesize lblLocName, lblProcName, lblJobName;
@synthesize viewOverall, lblOverEMCAVG, lblOverMCAVG, lblOverMCHigh, lblOverMCLow, lblOverRHAVG, lblOverTempAVG;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //-------
        receivedData = [[NSMutableData alloc] init];

        infoColorOrdinal = [UIColor colorWithRed:211.0/255.0 green:163.0/255.0 blue:51.0/255.0 alpha:1.0];
        infoColorError = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:66.0/255.0 alpha:1.0];
        infoColorSubscribed = [UIColor colorWithRed:40.0/255.0 green:181.0/255.0 blue:110.0/255.0 alpha:1.0];
        
        self.isFromRecorded = NO;

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.archive_alertview.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    [self.archive_alertview setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"CurReadings Screen";
    
    GlobalData *globalData = [GlobalData sharedData];
    
    // Title
    if (self.curDate == nil || [CommonMethods compareOnlyDate:self.curDate date2:[NSDate date] ] == NSOrderedSame)
    {
        //self.lblTitle.text = @"Today's Readings";
        self.titleReadings.hidden = YES;
        self.titleTodaysReadings.hidden = NO;
    }
    else
    {
        //self.lblTitle.text = [NSString stringWithFormat:@"Readings (%@)", [CommonMethods date2str:self.curDate withFormat:globalData.settingDateFormat]];
        self.titleReadings.hidden = NO;
        self.titleTodaysReadings.hidden = YES;
    }
    

    
    CGFloat coverage = 0.0;
    
    if (_curLocProduct) {
        FSLocation *loc = [[DataManager sharedInstance] getLocationFromID:self.curLocProduct.locProductLocID];
        if (loc == nil)
            return;
        FSJob *job = [[DataManager sharedInstance] getJobFromID:loc.locJobID];
        if (job == nil)
            return;
        
        NSString *jobName = job.jobName;
        NSString *locName = loc.locName;
        NSString *procName = self.curLocProduct.locProductName;
        
        [lblJobName setText:jobName];
        [lblLocName setText:[NSString stringWithFormat:@"Location: %@", locName]];
        [lblProcName setText:[NSString stringWithFormat:@"Product: %@", procName]];
        
        coverage = self.curLocProduct.locProductCoverage;
        
    }
    else
    {
        [lblJobName setText:@""];
        [lblLocName setText:[NSString stringWithFormat:@"Location: %@", @""]];
        [lblProcName setText:[NSString stringWithFormat:@"Product: %@", @""]];
        
        coverage = 0.0f;
    }
    
    
    float convCoverage = coverage;
    if (globalData.settingArea == YES) //ft
    {
        self.lblFt.hidden = NO;
        self.lblM.hidden = YES;
    }
    else
    {
        self.lblFt.hidden = YES;
        self.lblM.hidden = NO;
        convCoverage = [GlobalData sqft2sqm:coverage];
    }
    
    NSString *strCoverage = [NSString stringWithFormat:@"Coverage: %.2f", convCoverage];
    if (_curLocProduct)
    {
        self.viewUnit.hidden = NO;
    }
    else
    {
        strCoverage = [NSString stringWithFormat:@"Coverage: "];
        self.viewUnit.hidden = YES;
    }
    
    self.lblCoverage.text = strCoverage;
    CGFloat szWidth = [CommonMethods widthOfString:strCoverage withFont:self.lblCoverage.font];
    CGRect frame = self.viewUnit.frame;
    frame.origin.x = self.lblCoverage.frame.origin.x + szWidth + 10;
    self.viewUnit.frame = frame;
    
    [self initDateTable];
    if (self.isFromRecorded) {
        [self scrollToLastRow];
        self.isFromRecorded = NO;
    }
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//------
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWarning
{
    NSString *strTitleFontName = @"HelveticaNeue-Light";
    NSString *strBodyFontName = @"HelveticaNeue";
    CGFloat titleFontSize = 17.0;
    CGFloat bodyFontSize = 13.0;
    UIColor *titleColor = [UIColor colorWithRed:251/255.0 green:181/255.0 blue:46/255.0 alpha:1.0];
    UIColor *bodyColor = [UIColor colorWithRed:251/255.0 green:181/255.0 blue:46/255.0 alpha:1.0];
    
    
    if ([arrOverallReadings count] >= 2)
    {
        FSReading *prevReading = (FSReading *)[arrOverallReadings objectAtIndex:[arrOverallReadings count] - 2];
        FSReading *lastReading = (FSReading *)[arrOverallReadings lastObject];
        
        BOOL isShowMsg = NO;
        NSString *titleText = @"";
        NSString *bodyText = @"";
        if (prevReading.readGravity != lastReading.readGravity && prevReading.readDepth != lastReading.readDepth)
        {
            titleText = @"s.g. and Depth are changed\n";
            bodyText = [NSString stringWithFormat:@" s.g. : %ld => %ld \n depth : %@ => %@", prevReading.readGravity, lastReading.readGravity, [FSReading getDisplayDepth: prevReading.readDepth], [FSReading getDisplayDepth: lastReading.readDepth]];
            
            isShowMsg = YES;
            
        }
        else if (prevReading.readGravity != lastReading.readGravity)
        {
            titleText = @"s.g. is changed\n";
            bodyText = [NSString stringWithFormat:@"\n s.g. : %ld => %ld", prevReading.readGravity, lastReading.readGravity];
            
            
            isShowMsg = YES;
        }
        else if (prevReading.readDepth != lastReading.readDepth)
        {
            titleText = @"Depth is changed\n";
            bodyText = [NSString stringWithFormat:@"\n depth : %@ => %@", [FSReading getDisplayDepth: prevReading.readDepth], [FSReading getDisplayDepth: lastReading.readDepth]];
            
            
            isShowMsg = YES;
        }
        
        if (isShowMsg)
        {
            NSDictionary *titleAttrs = @{NSFontAttributeName:[UIFont fontWithName:strTitleFontName size:titleFontSize], NSForegroundColorAttributeName:titleColor};
            NSDictionary *bodyAttrs = @{NSFontAttributeName:[UIFont fontWithName:strBodyFontName size:bodyFontSize], NSForegroundColorAttributeName:bodyColor};
            
            NSMutableAttributedString *termsText = [[NSMutableAttributedString alloc] initWithString:titleText attributes:titleAttrs];
            NSAttributedString *bodyAttString = [[NSAttributedString alloc] initWithString:bodyText attributes:bodyAttrs];
            
            [termsText appendAttributedString:bodyAttString];
            
            [AutoMessageBox AutoMsgInView:self.view withText:termsText];
        }
    }
    else
    {
        int count = [[DataManager sharedInstance] getReadingsCount:self.curLocProduct.locProductID];
        if (count == 1)
        {
#if false
            titleFontSize = 16.0;
            bodyFontSize = 12.0;
            
            NSString *titleText = @"First reading for this Product!\n";
            NSString *bodyText = @"";
            if (self.curLocProduct.locProductType == FSProductTypeFinished)
            {
                bodyText = [NSString stringWithFormat:@" NWFA Guidelines require 40 readings \n per 1000sqft for finished material"];
            }
            else
            {
                bodyText = [NSString stringWithFormat:@" NWFA Guidelines require 20 readings \n per 1000sqft for subfloor material"];
            }
            
            
            NSDictionary *titleAttrs = @{NSFontAttributeName:[UIFont fontWithName:strTitleFontName size:titleFontSize], NSForegroundColorAttributeName:titleColor};
            NSDictionary *bodyAttrs = @{NSFontAttributeName:[UIFont fontWithName:strBodyFontName size:bodyFontSize], NSForegroundColorAttributeName:bodyColor};
            
            NSMutableAttributedString *termsText = [[NSMutableAttributedString alloc] initWithString:titleText attributes:titleAttrs];
            NSAttributedString *bodyAttString = [[NSAttributedString alloc] initWithString:bodyText attributes:bodyAttrs];
            
            [termsText appendAttributedString:bodyAttString];
            
            [AutoMessageBox AutoMsgInView:self.view withText:termsText];
#endif
        }
    }
}

- (void)initDateTable
{
    if (self.curDate == nil)
        self.curDate = [NSDate date];
    
    if (self.curLocProduct == nil) {
        arrOverallReadings = [[NSMutableArray alloc] init];
        [self setCurData:nil];
        [self setOverallData];
    } else {
        arrOverallReadings = [[DataManager sharedInstance] getReadings:self.curLocProduct.locProductID withDate:self.curDate];
        
        [self setCurData:[arrOverallReadings lastObject]];
        [self setOverallData];
        
    }
}

- (void)scrollToLastRow
{
    if ([arrOverallReadings count] > 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[arrOverallReadings count] - 1 inSection:0];
        [self.tblDetal scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == tblDetal) {
        return 1;
    }
    return [arrReadingCounts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblDetal) {
        return [arrOverallReadings count];
    }
    return 1;
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblDetal) {
        return 40.0f;
    }
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblDetal) {
        FSMeasureCell *cell = [tblDetal dequeueReusableCellWithIdentifier:@"FSMeasureCell"];
        
        if(cell == nil)
        {
            cell = [FSMeasureCell sharedCell];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setDelegate:self];
    
        if (indexPath.row % 2 == 0) {
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:193.0f/255.0f green:182.0f/255.0f blue:169.0f/255.0f alpha:1.0f]];
        } else {
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:164.0f/255.0f green:149.0f/255.0f blue:130.0f/255.0f alpha:1.0f]];
        }
        
        [cell setCurReading:(FSReading *)[arrOverallReadings objectAtIndex:indexPath.row]];
        
        return cell;
    }
    /* //
    FSReportCell *cell = [tblReadingDates dequeueReusableCellWithIdentifier:@"FSReportCell"];
    
    if(cell == nil)
    {
        cell = [FSReportCell sharedCell];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    NSString *strDate = (NSString *)[arrReadingCounts objectAtIndex:indexPath.section];
    [cell setCurDate:[CommonMethods str2date:strDate withFormat:DATE_FORMAT]];
    
    return cell;
     */
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Cell Delegate
- (void)didDisclosure:(FSReportCell *)cell
{
    [CommonMethods playTapSound];
    
    /*
    if (cell.curDate != selectedCell.curDate) {
        if (selectedCell) {
            if (selectedCell.isOpened) {
                selectedCell.isOpened = !selectedCell.isOpened;
            }
        }
        selectedCell = cell;
        [self hideOverall:YES];
        return;
    }
    selectedCell = cell;
    [self setOverallData];
    if (selectedCell.isOpened) {
        [self showOverall];
    } else {
        [self hideOverall:NO];
    }
     */
}

- (void)didDelete:(FSMeasureCell *)cell
{
    
    [CommonMethods playTapSound];
    
    self.curReading = cell.curReading;
    
    [self.view bringSubviewToFront:self.archive_alertview];
    [self.lblCurrReading setText:[NSString stringWithFormat:@"MC:%@%%(%@ hrs)", [cell.curReading getDisplayRealMCValue], [CommonMethods date2str:cell.curReading.readTimestamp withFormat:@"HH:mm"]]];
    [self.archive_alertview setHidden:NO];
    [self showAlertAnimation];
}

- (IBAction)didDeleteOk:(id)sender
{
    
    [CommonMethods playTapSound];
    
    
    if (self.curReading)
        [[DataManager sharedInstance] deleteReadingFromDatabase:self.curReading];
    [self hideAlertAnimation];
    [self initDateTable];
}

- (IBAction)didDeleteCancel:(id)sender
{
    
    [CommonMethods playTapSound];
    
    
    [self hideAlertAnimation];
}

- (void)showAlertAnimation
{
    [UIView animateWithDuration:0.2f animations:^{
        self.archive_alertview.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.07f animations:^{
            self.archive_alertview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }completion:nil];
    }];
}

- (void)hideAlertAnimation
{
    [UIView animateWithDuration:0.1f animations:^{
        self.archive_alertview.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    }completion:^(BOOL finished){
        [self.archive_alertview setHidden:YES];
    }];
}


- (void)setOverallData
{
    /*
    [selectedCell setIsOpened:!selectedCell.isOpened];
    CGRect frame = viewOverall.frame;
    CGRect selectedCellProcViewFrame = [selectedCell.btnDisclosure.superview convertRect:selectedCell.btnDisclosure.frame toView:self.view];
    frame.origin.y = selectedCellProcViewFrame.origin.y + 28.0f;
    [viewOverall setFrame:frame];
     */
    
    //setOverall Items
    if (arrOverallReadings == nil || [arrOverallReadings count] == 0) {

        float mcValue = 0;
        int rh = 0;
        int temp = 0;
        [lblOverMCAVG setText:[NSString stringWithFormat:@"MC Avg: %.1f%@", mcValue, @"%"]];
        [lblOverMCHigh setText:[NSString stringWithFormat:@"MC High: %.1f%@", mcValue, @"%"]];
        [lblOverMCLow setText:[NSString stringWithFormat:@"MC Low: %.1f%@", mcValue, @"%"]];
        [lblOverEMCAVG setText:[NSString stringWithFormat:@"EMC Avg: 0%@", @"%" ]];
        [lblOverRHAVG setText:[NSString stringWithFormat:@"RH Avg: %d%@", (int)rh, @"%"]];
        [lblOverTempAVG setText:[NSString stringWithFormat:@"Temp Avg: %d", (int)temp]];
    }
    else
    {
        CGFloat mcavg = [FSReading getMCAvg:arrOverallReadings];
        CGFloat mchigh = [FSReading getMCMax:arrOverallReadings];
        CGFloat mclow = [FSReading getMCMin:arrOverallReadings];
        CGFloat rhavg = [FSReading getRHAvg:arrOverallReadings];
        CGFloat tempavg = [FSReading getTempAvg:arrOverallReadings];
        CGFloat emcavg = [FSReading getEmcAvg:arrOverallReadings];
        
        GlobalData *globalData = [GlobalData sharedData];
        
        [lblOverMCAVG setText:[NSString stringWithFormat:@"MC Avg: %.1f%@", mcavg, @"%"]];
        [lblOverMCHigh setText:[NSString stringWithFormat:@"MC High: %.1f%@", mchigh, @"%"]];
        [lblOverMCLow setText:[NSString stringWithFormat:@"MC Low: %.1f%@", mclow, @"%"]];
        [lblOverEMCAVG setText:[NSString stringWithFormat:@"EMC Avg: %.1f%@", emcavg, @"%" ]];
        [lblOverRHAVG setText:[NSString stringWithFormat:@"RH Avg: %d%@", ROUND(rhavg), @"%"]];
        
        // temperature
        NSString *tempUnit = [globalData getTempUnit];
        if (globalData.settingTemp == YES) //f
            tempavg = [FSReading getFTemperature:tempavg];
        [lblOverTempAVG setText:[NSString stringWithFormat:@"Temp Avg: %d%@", ROUND(tempavg), tempUnit]];
    }
    [tblDetal reloadData];
}

- (void)showOverall
{
    /*
    CGRect frame = viewOverall.frame;
    frame.size.height = 80.0f;
    [UIView animateWithDuration:0.15f animations:^{
        [viewOverall setFrame:frame];
    }completion:^(BOOL finished){
        [tblReadingDates setScrollEnabled:NO];
    }];
     */
}

- (void)hideOverall:(BOOL)next
{
    /*
    CGRect frame = viewOverall.frame;
    frame.size.height = 0.0f;
    [UIView animateWithDuration:0.15f animations:^{
        [viewOverall setFrame:frame];
    }completion:^(BOOL finished){
        [tblReadingDates setScrollEnabled:YES];
        if (next) {
            [self setOverallData];
            [self showOverall];
        }
    }];
     */
}


#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    [CommonMethods playTapSound];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setCurData:(FSReading *)data
{
    GlobalData *globalData = [GlobalData sharedData];
    if (data != nil)
    {
        self.lblCurrent.text = [NSString stringWithFormat:@"Last Reading : %@ %@", [CommonMethods date2str:data.readTimestamp withFormat:globalData.settingDateFormat], [CommonMethods date2str:data.readTimestamp withFormat:@"HH:mm"]];
        
        // RH, rounded whole unit
        self.lblCurRH.text = [NSString stringWithFormat:@"RH : %d%%", ROUND(data.readConvRH)];
        
        
        // Temperature (F or C)
        NSString *tempUnit = [globalData getTempUnit];
        CGFloat temp = data.readConvTemp;
        if (globalData.settingTemp == YES)
            temp = [FSReading getFTemperature:temp];
        self.lblCurTemp.text = [NSString stringWithFormat:@"Temp : %d%@", ROUND(temp), tempUnit];
        
        // Battery
        self.lblCurBattery.text = [NSString stringWithFormat:@"Battery : %ld%%", data.readBattery];
        self.lblCurDepth.text = [NSString stringWithFormat:@"Depth : %@", [FSReading getDisplayDepth:data.readDepth]];
        self.lblCurMaterial.text = [NSString stringWithFormat:@"Material : %@", [FSReading getDisplayMaterial:data.readMaterial]];
        self.lblCurGravity.text = [NSString stringWithFormat:@"s.g. : %ld", data.readGravity];
        self.lblCurMC.text = [NSString stringWithFormat:@"MC : %@%%", [data getDisplayRealMCValue]];
        
        // Current EMC
        self.lblCurEMC.text = [NSString stringWithFormat:@"EMC : %.1f%%", [data getEmcValue]];
    }
    else
    {
        self.lblCurrent.text = [NSString stringWithFormat:@"Last Reading : %@", [CommonMethods date2str:self.curDate withFormat:globalData.settingDateFormat]];

        self.lblCurRH.text = [NSString stringWithFormat:@"RH :"];
        self.lblCurTemp.text = [NSString stringWithFormat:@"Temp : "];
        self.lblCurBattery.text = [NSString stringWithFormat:@"Battery : "];
        self.lblCurDepth.text = [NSString stringWithFormat:@"Depth : "];
        self.lblCurMaterial.text = [NSString stringWithFormat:@"Material : "];
        self.lblCurGravity.text = [NSString stringWithFormat:@"s.g. : "];
        self.lblCurMC.text = [NSString stringWithFormat:@"MC : "];
        
        self.lblCurEMC.text = [NSString stringWithFormat:@"EMC : "];
    }
}

@end
