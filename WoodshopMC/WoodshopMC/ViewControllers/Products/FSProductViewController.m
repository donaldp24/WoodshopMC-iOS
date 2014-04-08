//
//  FSProductViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSProductViewController.h"
#import "FSProductCell.h"
#import "DataManager.h"
#import "Global.h"
#import "FSProduct.h"
#import "Defines.h"

@interface FSProductViewController ()
{
    NSMutableArray *arrProdcutList;
    CGFloat trasnfromHeight;
    int finishNum;
    FSProductCell *curCell;
    UITableView *tblProcType;
}
@end

@implementation FSProductViewController
@synthesize isEditing = _isEditing;
@synthesize tblProducts, viewTopAdd, viewTopSearch, txtAdd, txtSearch, viewSelectType, lblSelectType, btnFinished, btnSubfloor;
@synthesize delete_alertview;

- (id)init
{
    self = [super init];
    if (self) {
    }
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
    
    //delete_alertview.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    [delete_alertview setHidden:YES];
    [tblProducts setBackgroundColor:[UIColor clearColor]];
    trasnfromHeight = 0;
    _isEditing = NO;
    
    CGRect selectTypeFrame = viewSelectType.frame;
    selectTypeFrame.size.height = 0;
    [viewSelectType setFrame:selectTypeFrame];
    [btnSubfloor setSelected:YES];
    [lblSelectType setText:@"Subfloor"];
    finishNum = FSProductTypeSubfloor;
    
    CGRect frameTable = CGRectMake(0, 0, 90, 0);
    tblProcType = [[UITableView alloc] initWithFrame:frameTable style:UITableViewStylePlain];
    [tblProcType setDataSource:self];
    [tblProcType setDelegate:self];
    [tblProcType setAlpha:0.8f];
    [self.view addSubview:tblProcType];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initTable];
    [tblProcType reloadData];
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
        arrProdcutList = [[DataManager sharedInstance] getProducts:self.txtAdd.text];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == tblProcType) {
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblProcType) {
        return 2;
    }
    return [arrProdcutList count];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblProcType) {
        return 25.0f;
    }
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblProcType) {
        UITableViewCell *cell = [tblProcType dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
        
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellIdentifier"];
        }
        
        [cell.textLabel setTextColor:[UIColor colorWithRed:67.0f/255.0f green:36.0f/255.0f blue:6.0f/255.0f alpha:1.0f]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [cell.textLabel setFrame:cell.frame];
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
        
        if (indexPath.row) {
            [cell.textLabel setText:@"Finished"];
        } else {
            [cell.textLabel setText:@"Subfloor"];
        }
        
        return cell;
    }
    FSProductCell *cell = [tblProducts dequeueReusableCellWithIdentifier:@"FSProductCell"];
    
    if(cell == nil)
    {
        cell = [FSProductCell sharedCell];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    [cell setCurProduct:[arrProdcutList objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblProcType) {
        if (indexPath.row) {
            curCell.curProductType = FSProductTypeFinished;
        } else {
            curCell.curProductType = FSProductTypeSubfloor;
        }

        [curCell.lblEditingProcType setText:[FSProduct getDisplayProductType:curCell.curProductType]];

        [self hideCombo];
    }
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

- (void)showSelectTypeView
{
    [viewSelectType setHidden:NO];
    [UIView animateWithDuration:0.1f animations:^{
        CGRect selectTypeFrame = viewSelectType.frame;
        selectTypeFrame.size.height = 50.0f;
        [viewSelectType setFrame:selectTypeFrame];
    }completion:nil];
}

- (void)hideSelectTypeView
{
    [UIView animateWithDuration:0.1f animations:^{
        CGRect selectTypeFrame = viewSelectType.frame;
        selectTypeFrame.size.height = 0.0f;
        [viewSelectType setFrame:selectTypeFrame];
    }completion:^(BOOL finished){
        [viewSelectType setHidden:YES];
    }];
}

#pragma mark - Cell Delegate
- (void)didEdit:(FSProductCell *)cell
{
    [CommonMethods playTapSound];
    
    curCell = cell;
    CGRect selectedCellFrame = [cell.superview convertRect:cell.frame toView:self.view];
    if (selectedCellFrame.origin.y + 80 >= [[UIScreen mainScreen] bounds].size.height - KEYBOARD_HEIGHT /* 216 */) {
        trasnfromHeight = selectedCellFrame.origin.y + 80 - [[UIScreen mainScreen] bounds].size.height + KEYBOARD_HEIGHT;
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y - trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    } else {
        trasnfromHeight = 0;
    }
    
}

- (void)didDelete:(FSProductCell *)cell
{
    [CommonMethods playTapSound];
    
    curCell = cell;
    [self.view bringSubviewToFront:delete_alertview];
    [delete_alertview setHidden:NO];
    [self showAlertAnimation];
}

- (BOOL)didOK:(FSProductCell *)cell
{
    [CommonMethods playTapSound];
    
    if ([curCell.curProduct.productName isEqualToString:cell.txtProductName.text]
        && curCell.curProduct.productType == curCell.curProductType)
    {
        //
    }
    else
    {
#if CHECK_PRODUCT_DUPLICATE
        if ([[DataManager sharedInstance] isExistSameProduct:cell.txtProductName.text productType:cell.curProductType] )
        {
            [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Product '%@(%@)' is already exist", cell.txtProductName.text, [FSProduct getDisplayProductType:cell.curProductType]]];
            return NO;
        }
#endif
        [curCell.curProduct setProductName:cell.txtProductName.text];
        [curCell.curProduct setProductType:cell.curProductType];
        
        [[DataManager sharedInstance] updateProductToDatabase:curCell.curProduct];
    }
//    [curProduct clear];
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y + trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    }
    [self hideCombo];
    return YES;
}

- (void)didCancel:(FSProductCell *)cell
{
    
    [CommonMethods playTapSound];
    
    
//    [curProduct clear];
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y + trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    }
    [self hideCombo];
}

- (void)didCombo:(FSProductCell *)cell
{
    [CommonMethods playTapSound];
    
    CGRect frame = tblProcType.frame;
    CGRect selectedCellProcViewFrame = [cell.viewEditingProcType.superview convertRect:cell.viewEditingProcType.frame toView:self.view];
    frame.origin.x = selectedCellProcViewFrame.origin.x;
    frame.origin.y = selectedCellProcViewFrame.origin.y + 18.0f;
    [tblProcType setFrame:frame];
    if (frame.size.height == 0.0f) {
        [self showCombo];
    } else {
        [self hideCombo];
    }
}

- (void)showCombo
{
    CGRect frame = tblProcType.frame;
    frame.size.height = 50.0f;
    [UIView animateWithDuration:0.1f animations:^{
        [tblProcType setFrame:frame];
    }completion:^(BOOL finished){
        [tblProducts setScrollEnabled:NO];
    }];
}

- (void)hideCombo
{
    CGRect frame = tblProcType.frame;
    frame.size.height = 0.0f;
    [UIView animateWithDuration:0.1f animations:^{
        [tblProcType setFrame:frame];
    }completion:^(BOOL finished){
        [tblProducts setScrollEnabled:YES];
    }];
}

- (void)didDetail:(id)sender
{
    [CommonMethods playTapSound];
    
    FSProductCell *cell = (FSProductCell *)sender;
    FSProduct *product = cell.curProduct;
}

#pragma mark - Action

- (IBAction)onDelete_OK:(id)sender
{
    [CommonMethods playTapSound];
    
    //curCell.curProduct.productDel = 1;
    [[DataManager sharedInstance] deleteProductFromDatabase:curCell.curProduct];
//    [curProduct clear];
    [self initTable];
    [self hideAlertAnimation];
}

- (IBAction)onDelete_Cancel:(id)sender
{
    [CommonMethods playTapSound];
    
//    [curProduct clear];
    [self hideAlertAnimation];
}

- (IBAction)onSelectType:(id)sender
{
    [CommonMethods playTapSound];
    
    [self.view bringSubviewToFront:viewSelectType];
    [self showSelectTypeView];
}

- (IBAction)onSelectFinished:(id)sender
{
    [CommonMethods playTapSound];
    
    finishNum = FSProductTypeFinished;
    [lblSelectType setText:@"Finished"];
    [btnSubfloor setSelected:NO];
    [btnFinished setSelected:YES];
    [self hideSelectTypeView];
}

- (IBAction)onSelectSubfloor:(id)sender
{
    [CommonMethods playTapSound];
    
    finishNum = FSProductTypeSubfloor;
    [lblSelectType setText:@"Subfloor"];
    [btnSubfloor setSelected:YES];
    [btnFinished setSelected:NO];
    [self hideSelectTypeView];
}

- (IBAction)onAdd:(id)sender
{
    [CommonMethods playTapSound];
    
    if (txtAdd.text == nil || [txtAdd.text isEqualToString:@""]) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please input product name to add!"];
        return;
    }
    
#if CHECK_PRODUCT_DUPLICATE
    if ([[DataManager sharedInstance] isExistSameProduct:self.txtAdd.text productType:finishNum] )
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Product '%@(%@)' is already exist", self.txtAdd.text, [FSProduct getDisplayProductType:finishNum]]];
        return;
    }
#endif
    
    FSProduct *product = [[FSProduct alloc] init];
    product.productName = txtAdd.text;
    product.productType = finishNum;
    product.productID = [[DataManager sharedInstance] addProductToDatabase:product];
    
    
    [self.txtAdd resignFirstResponder];
    [self.txtAdd setText:@""];
    
    [self initTable];
    
    
    if (product.productID == 0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[arrProdcutList count] - 1 inSection:0];
    
    [tblProducts scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (IBAction)onClose:(id)sender
{
    [CommonMethods playTapSound];
    
    [txtAdd setText:@""];
    [self initTable];
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

@end
