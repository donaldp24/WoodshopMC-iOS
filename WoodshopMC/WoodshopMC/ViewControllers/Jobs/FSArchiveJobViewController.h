//
//  FSArchiveJobViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/24/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSJobViewController.h"

@interface FSArchiveJobViewController : UIViewController <UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet UITableView *tblArchives;
@property (nonatomic, assign) IBOutlet UITextField *txtTop;

@property (nonatomic, assign) IBOutlet UIView *delete_alertview;
@property (nonatomic, assign) IBOutlet UIImageView *imgAlertBack;
@property (nonatomic, assign) IBOutlet UILabel *lblNoResult;
@property (nonatomic, assign) id<FSJobSelectDelegate> jobSelectDelegate;
@property (nonatomic) int mode;

- (IBAction)onSearch:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onDelete_OK:(id)sender;
- (IBAction)onDelete_Cancel:(id)sender;
- (IBAction)onTopChanged:(id)sender;
- (IBAction)onBtnCancel:(id)sender;

@end
