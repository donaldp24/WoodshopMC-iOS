//
//  FSProductCell.h
//  FloorSmart
//
//  Created by Lydia on 12/25/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSProduct.h"

@protocol FSProductCellDelegate;

@interface FSProductCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet UILabel *lblProductName;
@property (nonatomic, assign) IBOutlet UITextField *txtProductName;
@property (nonatomic, assign) IBOutlet UILabel *lblProductType;
@property (nonatomic, assign) IBOutlet UIView *viewEditing;
@property (nonatomic, assign) IBOutlet UIView *viewEdit;
@property (nonatomic, assign) IBOutlet UIView *viewEditingProcType;
@property (nonatomic, assign) IBOutlet UILabel *lblEditingProcType;

@property (nonatomic, strong) FSProduct *curProduct;
@property (nonatomic) long curProductType;

@property (nonatomic, strong) id<FSProductCellDelegate> delegate;

+ (FSProductCell *)sharedCell;

- (IBAction)onEdit:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onOK:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onComboProc:(id)sender;
- (IBAction)onBgClick:(id)sender;

@end

@protocol FSProductCellDelegate <NSObject>

- (BOOL)didOK:(id)cell;

@end