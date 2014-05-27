//
//  FSLocProductViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSLocProductViewController.h"
#import "FSProductCell.h"
#import "FSLocProductCell.h"
#import "DataManager.h"
#import "Global.h"
#import "FSProduct.h"
#import "Defines.h"

@interface FSLocProductViewController ()
{
    NSMutableArray *arrProdcutList;
    CGFloat trasnfromHeight;
    FSProductCell *curCell;
    FSLocProductCell *curLocCell;
}
@end

@implementation FSLocProductViewController
@synthesize isEditing = _isEditing;
@synthesize tblProducts, viewTopAdd, viewTopSearch, txtAdd, txtSearch;
@synthesize delete_alertview;

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
    
    delete_alertview.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    [delete_alertview setHidden:YES];
    [tblProducts setBackgroundColor:[UIColor clearColor]];
    trasnfromHeight = 0;
    _isEditing = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Loc.Product Screen";
    
    [self initTable];
    
    NSString *jobName = @"";
    NSString *locName = @"";
    // set job.name
    if (self.curLoc != nil)
    {
        if (self.curLoc.locJobID != 0)
        {
            FSJob *job = [[DataManager sharedInstance] getJobFromID:self.curLoc.locJobID];
            if (job)
            {
                jobName = job.jobName;
            }
        }
        locName = self.curLoc.locName;
    }
    
    self.lblJobLocName.text = [NSString stringWithFormat:@"Location : %@.%@", jobName, locName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTable
{
    
    [self initTableArray];
    [tblProducts reloadData];
    self.isEditing = NO;
    if ([arrProdcutList count] == 0)
    {
        [self.lblNoResult setHidden:NO];
        
        if (self.txtAdd.text == nil || [self.txtAdd.text isEqualToString:@""])
        {
            [self.lblNoResult setText:@"No Products"];
        }
        else
        {
            [self.lblNoResult setText:@"Searching..."];
        }
    }
    else
    {
        [self.lblNoResult setHidden:YES];
    }
}

- (void)initTableArray
{
    if (self.switchShowMain.on)
        arrProdcutList = [[DataManager sharedInstance] getProducts:self.txtAdd.text];
    else
        arrProdcutList = [[DataManager sharedInstance] getLocProducts:self.curLoc searchField:self.txtAdd.text];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrProdcutList count];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.switchShowMain.on)
    {
        FSProductCell *cell = [tblProducts dequeueReusableCellWithIdentifier:@"FSLocProductCell"];
        
        if(cell == nil)
        {
            cell = [FSProductCell sharedCell];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setDelegate:self];
        [cell setCurProduct:[arrProdcutList objectAtIndex:indexPath.row]];
        return cell;
    }
    else
    {
        FSLocProductCell *cell = [tblProducts dequeueReusableCellWithIdentifier:@"FSLocProductCell"];
        
        if(cell == nil)
        {
            cell = [FSLocProductCell sharedCell];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setDelegate:self];
        [cell setCurLocProduct:[arrProdcutList objectAtIndex:indexPath.row]];
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - custom
- (void)showAlertAnimation
{
    [UIView animateWithDuration:0.2f animations:^{
        delete_alertview.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.07f animations:^{
            delete_alertview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }completion:nil];
    }];
}

- (void)hideAlertAnimation
{
    [UIView animateWithDuration:0.1f animations:^{
        delete_alertview.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    }completion:^(BOOL finished){
        [delete_alertview setHidden:YES];
    }];
}

#pragma mark - Cell Delegate
- (void)didEdit:(id)cell
{
    [CommonMethods playTapSound];
    
    CGRect selectedCellFrame;
    if (self.switchShowMain.on)
    {
        curCell = cell;
        curLocCell = nil;
        selectedCellFrame = [curCell.superview convertRect:curCell.frame toView:self.view];
    }
    else
    {
        curLocCell = cell;
        curCell = nil;
        selectedCellFrame = [curLocCell.superview convertRect:curLocCell.frame toView:self.view];
    }
    
    
    if (selectedCellFrame.origin.y + 80 >= [[UIScreen mainScreen] bounds].size.height - KEYBOARD_HEIGHT /* 216 */) {
        trasnfromHeight = selectedCellFrame.origin.y + 80 - [[UIScreen mainScreen] bounds].size.height + KEYBOARD_HEIGHT /* 216 */;
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y - trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    } else {
        trasnfromHeight = 0;
    }
    
}

- (void)didDelete:(id)cell
{
    [CommonMethods playTapSound];
    
    if (self.switchShowMain.on)
    {
        curCell = (FSProductCell *)cell;
        curLocCell = nil;
    }
    else
    {
        curCell = nil;
        curLocCell = (FSLocProductCell *)cell;
    }
    [self.view bringSubviewToFront:delete_alertview];
    [delete_alertview setHidden:NO];
    [self showAlertAnimation];
}

- (BOOL)didOK:(id)cell
{
    [CommonMethods playTapSound];
    
    if (self.switchShowMain.on)
    {
        curCell = (FSProductCell *)cell;
        curLocCell = nil;
        
        if ([curCell.curProduct.productName isEqualToString:curCell.txtProductName.text])
        {
            //
        }
        else
        {
#if CHECK_PRODUCT_DUPLICATE
            if ([[DataManager sharedInstance] isExistSameProduct:curCell.txtProductName.text] )
            {
                [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Product '%@' is already exist", curCell.txtProductName.text]];
                return NO;
            }
#endif
            
            [curCell.curProduct setProductName:curCell.txtProductName.text];
            
            [[DataManager sharedInstance] updateProductToDatabase:curCell.curProduct];
        }
    }
    else
    {
        curCell = nil;
        curLocCell = (FSLocProductCell *)cell;
        
#if CHECK_LOCPRODUCT_DUPLICATE
        if ([[DataManager sharedInstance] isExistSameLocProduct:self.curLoc.locID locProductName:curLocCell.txtProductName.text] )
        {
            [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Product '%@' is already exist", curLocCell.txtProductName.text]];
            return NO;
        }
#endif
        
        [curLocCell.curLocProduct setLocProductName:curLocCell.txtProductName.text];
        
        [[DataManager sharedInstance] updateLocProductToDatabase:curLocCell.curLocProduct];
        FSProduct *sameProduct = [[DataManager sharedInstance] getProductWithLocProduct:curLocCell.curLocProduct];
        if (sameProduct == nil)
        {
            sameProduct = [[FSProduct alloc] init];
            sameProduct.productID = 0;
            sameProduct.productName = curLocCell.curLocProduct.locProductName;
            
            [[DataManager sharedInstance] addProductToDatabase:sameProduct];
        }
    }

    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y + trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    }
    return YES;
}

- (void)didCancel:(id)cell
{
    [CommonMethods playTapSound];
    
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y + trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    }
}

- (void)didDetail:(id)sender
{
    [CommonMethods playTapSound];
    
    if (self.switchShowMain.on)
    {
        FSProductCell *cell = (FSProductCell *)sender;
        FSProduct *product = cell.curProduct;
        if (self.locProductSelectDelegate)
            [self.locProductSelectDelegate productSelected:product];
    }
    else
    {
        
        FSLocProductCell *cell = (FSLocProductCell *)sender;
        FSLocProduct *locProduct = cell.curLocProduct;
        if (self.locProductSelectDelegate)
            [self.locProductSelectDelegate locProductSelected:locProduct];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Action

- (IBAction)onDelete_OK:(id)sender
{
    [CommonMethods playTapSound];
    
    if (self.switchShowMain.on)
    {
        [[DataManager sharedInstance] deleteProductFromDatabase:curCell.curProduct];
    }
    else
    {
        // check recording is for this product
        GlobalData *globalData = [GlobalData sharedData];
        if (globalData.isSaved && globalData.selectedLocProductID == curLocCell.curLocProduct.locProductID)
        {
            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Recording is for this Product.\nPlease 'Cancel' recording first to delete this product."];
            return;
        }
        [[DataManager sharedInstance] deleteLocProductFromDatabase:curLocCell.curLocProduct];
    }
        

    [self initTable];
    [self hideAlertAnimation];
}

- (IBAction)onDelete_Cancel:(id)sender
{
    [CommonMethods playTapSound];
    
    [self hideAlertAnimation];
}

- (IBAction)onAdd:(id)sender
{
    [CommonMethods playTapSound];
    
    if (txtAdd.text == nil || [txtAdd.text isEqualToString:@""]) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please input product name to add!"];
        return;
    }
    
    if (self.switchShowMain.on)
    {
#if CHECK_PRODUCT_DUPLICATE
        if ([[DataManager sharedInstance] isExistSameProduct:self.txtAdd.text] )
        {
            [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Product '%@' is already exist", self.txtAdd.text]];
            return;
        }
#endif
    
        
        // add product to main product list
        
        FSProduct *product = [[FSProduct alloc] init];
        product.productName = txtAdd.text;
        
        product.productID = [[DataManager sharedInstance] addProductToDatabase:product];
    }
    else
    {
        // add product for a specific location
        FSLocProduct *locProduct = [[FSLocProduct alloc] init];
        locProduct.locProductID = 0;
        locProduct.locProductLocID = 0;
        locProduct.locProductName = txtAdd.text;
        
        // default location
        if (self.curLoc.locID == 0)
        {
            // adde default location to location table
            int loc_id = [[DataManager sharedInstance] addLocationToDatabase:self.curLoc];
            self.curLoc = [[DataManager sharedInstance] getLocationFromID:loc_id];
            if (self.locProductSelectDelegate)
                [self.locProductSelectDelegate locationAdded:self.curLoc];
        }
        if (self.curLoc != nil)
        {
#if CHECK_LOCPRODUCT_DUPLICATE
            if ([[DataManager sharedInstance] isExistSameLocProduct:self.curLoc.locID locProductName:self.txtAdd.text])
            {
                [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Product '%@' is already exist in this Location", self.txtAdd.text]];
                return;
            }
#endif
            locProduct.locProductLocID = self.curLoc.locID;
            [[DataManager sharedInstance] addLocProductToDatabase:locProduct];
            
            FSProduct *sameProduct = [[DataManager sharedInstance] getProductWithLocProduct:locProduct];
            if (sameProduct == nil)
            {
                sameProduct = [[FSProduct alloc] init];
                sameProduct.productID = 0;
                sameProduct.productName = locProduct.locProductName;
                
                [[DataManager sharedInstance] addProductToDatabase:sameProduct];
            }
        }
    }
    
    [self.txtAdd resignFirstResponder];
    [self.txtAdd setText:@""];
    
    [self initTable];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[arrProdcutList count] - 1 inSection:0];
    
    [tblProducts scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (IBAction)onClose:(id)sender
{
    [CommonMethods playTapSound];
    
    [txtAdd setText:@""];
    [self initTable];
}

- (IBAction)onBack:(id)sender
{
    [CommonMethods playTapSound];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSearch:(id)sender
{
    [self initTable];
}

- (IBAction)onSearchCancel:(id)sender
{
    [CommonMethods playTapSound];
    
    [txtSearch resignFirstResponder];
    [txtSearch setText:@""];
    
    [self initTable];
}

- (IBAction)onSwitch:(id)sender
{
    [CommonMethods playTapSound];
    
    [self initTable];
}

@end
