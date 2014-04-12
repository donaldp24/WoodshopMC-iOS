//
//  FSLocProductViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPopView.h"
#import "FSProduct.h"
#import "FSLocation.h"
#import "FSProductCell.h"

@protocol FSLocProductSelectDelegate <NSObject>

- (void)locationAdded:(FSLocation *)loc;
- (void)productSelected:(FSProduct *)product;
- (void)locProductSelected:(FSLocProduct *)locProduct;

@end

@interface FSLocProductViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FSProductCellDelegate>

@property (nonatomic) BOOL isEditing;

@property (nonatomic, assign) IBOutlet UITableView *tblProducts;

@property (nonatomic, assign) IBOutlet UIView *viewTopAdd;
@property (nonatomic, assign) IBOutlet UIView *viewTopSearch;
@property (nonatomic, assign) IBOutlet UITextField *txtAdd;
@property (nonatomic, assign) IBOutlet UITextField *txtSearch;

@property (nonatomic, assign) IBOutlet UISwitch *switchShowMain;
@property (nonatomic, assign) IBOutlet UILabel *lblNoResult;
@property (nonatomic, assign) IBOutlet UILabel *lblJobLocName;

@property (nonatomic, assign) IBOutlet UIView *delete_alertview;

@property (nonatomic, retain) id<FSLocProductSelectDelegate> locProductSelectDelegate;

@property (nonatomic, retain) FSLocation *curLoc;

- (IBAction)onDelete_OK:(id)sender;
- (IBAction)onDelete_Cancel:(id)sender;


- (IBAction)onAdd:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onSearch:(id)sender;
- (IBAction)onSearchCancel:(id)sender;

@end
