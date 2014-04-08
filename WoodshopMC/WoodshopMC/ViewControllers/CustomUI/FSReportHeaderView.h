//
//  FSReportHeaderView.h
//  FloorSmart
//
//  Created by Donald Pae on 3/22/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface FSReportHeaderView : UIView

@property (nonatomic, retain) IBOutlet UILabel *lblLocation;
@property (nonatomic, retain) IBOutlet UILabel *lblProduct;
@property (nonatomic, retain) IBOutlet UILabel *lblProductType;
@property (nonatomic, retain) IBOutlet UILabel *lblCoverage;
@property (nonatomic, retain) IBOutlet UIView *viewUnit;
@property (nonatomic, retain) IBOutlet UILabel *lblUnitFt;
@property (nonatomic ,retain) IBOutlet UILabel *lblUnitM;

@property (nonatomic, retain) FSLocation *loc;
@property (nonatomic, retain) FSLocProduct *locProduct;

+ (CGFloat)getViewHeight;
+ (id) reportHeaderView : (FSLocation *)loc locProduct:(FSLocProduct *)locProuct;

@end
