//
//  FSSelectViewController.m
//  FloorSmart
//
//  Created by Donald Pae on 4/3/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSSelectViewController.h"
#import "DataManager.h"
#import "FSRecordViewController.h"
#import "CommonMethods.h"

@interface FSSelectViewController ()

@end

@implementation FSSelectViewController

- (id) initWithParent : (NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil parent:(id) realParent mode:(int)mode parentNode:(id)parentNode
{

   // NSString *szXibName = [ResourceManager getXibName:nibNameOrNil];
    NSString *szXibName = nibNameOrNil;
    
	self = [super initWithNibName:szXibName bundle:nibBundleOrNil];
    
    _parent = realParent;
    _curRow = 0;
    _mode = mode;
    _parentNode = parentNode;
    
    return self;
}

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
    // Do any additional setup after loading the view from its nib.
    
    CGRect rtBound = [[UIScreen mainScreen] bounds];
    CGRect rtContainer = self.viewContainer.frame;
    
    CGFloat toolbarHeight = 44;
    self.viewContainer.frame = CGRectMake(rtContainer.origin.x, rtBound.size.height - rtContainer.size.height - toolbarHeight, rtContainer.size.width, rtContainer.size.height);
    
    if (_mode == MODE_SELECT_JOB)
    {
        arrayData = [[DataManager sharedInstance] getJobs:0 searchField:@""];
        [self.lblTitle setText:@"Select a Job"];
    }
    else if (_mode == MODE_SELECT_LOCATION)
    {
        //FSJob *job = (FSJob *)_parentNode;
        //arrayData = [[DataManager sharedInstance] getLocations:job.jobID];
        
        
        arrayData = [[DataManager sharedInstance] getAllDistinctLocations];
        [self.lblTitle setText:@"Select a Location"];
    }
    else if (_mode == MODE_SELECT_PRODUCT)
    {
        FSLocation *loc = (FSLocation *)_parentNode;
        //arrayData = [[DataManager sharedInstance] getLocProducts:loc searchField:@""];
        arrayData = [[DataManager sharedInstance] getProducts:@""];
        [self.lblTitle setText:@"Select a Product"];
    }
    FSRecordViewController *p = (FSRecordViewController *)_parent;
    [p hideSummary];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setCurSelected:(id)data
{
    _curSelectedData = data;
}

- (void)reloadData
{

    id data = _curSelectedData;
    if (data == nil)
        return;
    
    
    
    if (data != nil && arrayData.count > 0)
    {
        int i = 0;
        for (id item in arrayData) {
            
            if (_mode == MODE_SELECT_JOB)
            {
                FSJob *job = (FSJob *)item;
                if (job.jobID == ((FSJob *)data).jobID)
                {
                    _curRow = i;
                    //[self.picker selectRow:i inComponent:0 animated:NO];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.tblMain scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                    break;
                }
            }
            else if (_mode == MODE_SELECT_LOCATION)
            {
                FSLocation *loc = (FSLocation *)item;
                if (loc.locID == ((FSLocation *)data).locID)
                {
                    _curRow = i;
                    //[self.picker selectRow:i inComponent:0 animated:NO];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.tblMain scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                    break;
                }
            }
            else if (_mode == MODE_SELECT_JOB)
            {
                FSLocProduct *locProduct = (FSLocProduct *)item;
                if (locProduct.locProductID == ((FSLocProduct *)data).locProductID)
                {
                    _curRow = i;
                    //[self.picker selectRow:i inComponent:0 animated:NO];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.tblMain scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                    break;
                }
            }
            i++;
        }
    }
}

#pragma mark Event handlers

- (IBAction)onCancelClicked:(id)sender {
    [CommonMethods playTapSound];
    
    [self.view removeFromSuperview];
    FSRecordViewController *p = (FSRecordViewController *)_parent;
    [p showSummary];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableString *str = [[NSMutableString alloc] init];
    if (arrayData.count > 0)
    {
        //AddrInfo  *addr = [addrArray objectAtIndex:row];
        
        //[str appendFormat:@"%@ %@ %@ %@", addr.receivername, addr.area1, addr.area2, addr.area3];
        
        if (_mode == MODE_SELECT_JOB)
        {
            FSJob *job = [arrayData objectAtIndex:indexPath.row];
            [str appendFormat:@"%@", job.jobName];
        }
        else if (_mode == MODE_SELECT_LOCATION)
        {
            FSLocation *location = [arrayData objectAtIndex:indexPath.row];
            [str appendFormat:@"%@", location.locName];
        }
        else if (_mode == MODE_SELECT_PRODUCT)
        {
            FSProduct *product = [arrayData objectAtIndex:indexPath.row];
            [str appendFormat:@"%@ (%@)", product.productName, [FSProduct getDisplayProductType:product.productType]];
        }
    }
    UITableViewCell *cell = [self.tblMain dequeueReusableCellWithIdentifier:@"selectcell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectcell"];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    }
    cell.textLabel.text = str;
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CommonMethods playTapSound];
    
    _curRow = indexPath.row;
    
    FSRecordViewController *p = (FSRecordViewController *)_parent;
    if (_curRow < arrayData.count)
    {
        
        if (_mode == MODE_SELECT_JOB)
        {
            FSJob  *job = [arrayData objectAtIndex:_curRow];
            [p jobSelected:job];
            
        }
        else if (_mode == MODE_SELECT_LOCATION)
        {
            FSLocation *loc = [arrayData objectAtIndex:_curRow];
            FSJob *job = (FSJob *)_parentNode;
            
            loc.locJobID = job.jobID;
            FSLocation *existLoc = [[DataManager sharedInstance] getLocation:job.jobID locName:loc.locName];
            
            if (existLoc != nil)
                [p locationSelected:existLoc];
            else
            {
                loc.locID = [[DataManager sharedInstance] addLocationToDatabase:loc];
                [p locationSelected:loc];
            }
            
        }
        else if (_mode == MODE_SELECT_PRODUCT)
        {
            FSProduct *product = [arrayData objectAtIndex:_curRow];
            [p productSelected:product];
            
        }
    }
    
    [self.view removeFromSuperview];
    [p showSummary];

}

@end
