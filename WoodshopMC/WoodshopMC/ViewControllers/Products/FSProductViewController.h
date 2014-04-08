//
//  FSProductViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPopView.h"
#import "FSProduct.h"
#import "FSProductCell.h"

@protocol FSProductSelectDelegate <NSObject>

- (void)productSelected:(FSProduct *)product;

@end

@interface FSProductViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FSProductCellDelegate>

@property (nonatomic) BOOL isEditing;

@property (nonatomic, assign) IBOutlet UITableView *tblProducts;

@property (nonatomic, assign) IBOutlet UIView *viewTopAdd;
@property (nonatomic, assign) IBOutlet UIView *viewTopSearch;
@property (nonatomic, assign) IBOutlet UITextField *txtAdd;
@property (nonatomic, assign) IBOutlet UITextField *txtSearch;
@property (nonatomic, assign) IBOutlet UIView *viewSelectType;
@property (nonatomic, assign) IBOutlet UILabel *lblSelectType;
@property (nonatomic, assign) IBOutlet UIButton *btnFinished;
@property (nonatomic, assign) IBOutlet UIButton *btnSubfloor;
@property (nonatomic, assign) IBOutlet UILabel *lblNoResult;

@property (nonatomic, assign) IBOutlet UIView *delete_alertview;

@property (nonatomic, retain) id<FSProductSelectDelegate> productSelectDelegate;

- (IBAction)onDelete_OK:(id)sender;
- (IBAction)onDelete_Cancel:(id)sender;
- (IBAction)onSelectType:(id)sender;
- (IBAction)onSelectFinished:(id)sender;
- (IBAction)onSelectSubfloor:(id)sender;

- (IBAction)onAdd:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onSearch:(id)sender;
- (IBAction)onSearchCancel:(id)sender;

@end
