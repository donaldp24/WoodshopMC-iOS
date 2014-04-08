//
//  FSArchiveCell.h
//  FloorSmart
//
//  Created by Lydia on 12/24/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSJob.h"

@interface FSArchiveCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *lblJob;
@property (nonatomic, assign) IBOutlet UIButton *btnDetail;

@property (nonatomic, strong) FSJob *curJob;

@property (nonatomic, strong) id delegate;

+ (FSArchiveCell *)sharedCell;

- (IBAction)onUnarchive:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onDetail:(id)sender;

@end
