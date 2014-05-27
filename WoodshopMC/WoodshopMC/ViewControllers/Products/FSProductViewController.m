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
    FSProductCell *curCell;
}
@end

@implementation FSProductViewController
@synthesize isEditing = _isEditing;
@synthesize tblProducts, viewTopAdd, txtAdd;
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
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Product Screen";
    
    [self initTable];
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
    
    if ([curCell.curProduct.productName isEqualToString:cell.txtProductName.text])
    {
        //
    }
    else
    {
#if CHECK_PRODUCT_DUPLICATE
        if ([[DataManager sharedInstance] isExistSameProduct:cell.txtProductName.text] )
        {
            [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Product '%@' is already exist", cell.txtProductName.text]];
            return NO;
        }
#endif
        [curCell.curProduct setProductName:cell.txtProductName.text];
        
        [[DataManager sharedInstance] updateProductToDatabase:curCell.curProduct];
    }
//    [curProduct clear];
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblProducts setFrame:CGRectMake(tblProducts.frame.origin.x, tblProducts.frame.origin.y + trasnfromHeight, tblProducts.frame.size.width, tblProducts.frame.size.height)];
        }];
    }
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
}


- (void)didDetail:(id)sender
{
    [CommonMethods playTapSound];
    
    //FSProductCell *cell = (FSProductCell *)sender;
    //FSProduct *product = cell.curProduct;
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

- (IBAction)onAdd:(id)sender
{
    [CommonMethods playTapSound];
    
    if (txtAdd.text == nil || [txtAdd.text isEqualToString:@""]) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please input product name to add!"];
        return;
    }
    
#if CHECK_PRODUCT_DUPLICATE
    if ([[DataManager sharedInstance] isExistSameProduct:self.txtAdd.text] )
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Product '%@' is already exist", self.txtAdd.text]];
        return;
    }
#endif
    
    FSProduct *product = [[FSProduct alloc] init];
    product.productName = txtAdd.text;
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
    
    [self initTable];
}

@end
