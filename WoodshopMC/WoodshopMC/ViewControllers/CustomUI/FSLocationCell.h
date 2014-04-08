//
//  FSCell.h
//  FloorSmart
//
//  Created by Donald Pae on 3/11/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XIBTableViewCell.h"


@protocol FSLocationCellDelegate;

@interface FSLocationCell : XIBTableViewCell <UITextFieldDelegate>

@property (nonatomic, retain) id<FSLocationCellDelegate> delegate;
@property (nonatomic, retain) id data;


@property (nonatomic, assign) IBOutlet UILabel *lblName;
@property (nonatomic, assign) IBOutlet UITextField *txtName;
@property (nonatomic, assign) IBOutlet UIView *viewControl;
@property (nonatomic, assign) IBOutlet UIView *viewEditing;
@property (nonatomic, assign) IBOutlet UIButton *btnBg;
@property (nonatomic, assign) IBOutlet UIButton *btnFirst;
@property (nonatomic, assign) IBOutlet UIButton *btnSecond;

- (IBAction)onBtnEdit:(id)sender;
- (IBAction)onBtnDelete:(id)sender;
- (IBAction)onBtnOk:(id)sender;
- (IBAction)onBtnCancel:(id)sender;
- (IBAction)onBtnBg:(id)sender;

- (void)setData:(id)data;

@end

@protocol FSLocationCellDelegate <NSObject>

@optional
- (void) onEditCell:(id)sender;
- (void) onDeleteCell:(id)sender;
- (BOOL) onEditFinishedOk:(id)sender;
- (void) onEditFinishedCancel:(id)sender;
- (void) onSelectCell:(id)sender;
- (BOOL) isEditing:(id)sender;
- (NSString *) getName:(id)sender;

@end
