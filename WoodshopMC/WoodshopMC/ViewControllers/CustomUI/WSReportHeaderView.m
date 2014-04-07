//
//  FSReportHeaderView.m
//  FloorSmart
//
//  Created by Donald Pae on 3/22/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSReportHeaderView.h"
#import "FSProduct.h"
#import "CommonMethods.h"
#import "GlobalData.h"

@implementation FSReportHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id) reportHeaderView : (FSLocation *)loc locProduct:(FSLocProduct *)locProuct
{
    
    NSArray *arrayViews = [[NSBundle mainBundle] loadNibNamed:@"FSReportHeaderView" owner:self options:nil];
    if ([arrayViews count] == 0)
        return nil;
    
    FSReportHeaderView *view = [arrayViews objectAtIndex:0];
    view.loc = loc;
    view.locProduct = locProuct;
    
    view.lblLocation.text = loc.locName;
    view.lblProduct.text = locProuct.locProductName;
    view.lblProductType.text = [FSProduct getDisplayProductType:locProuct.locProductType];
    
    
    GlobalData *globalData = [GlobalData sharedData];
    
    float convCoverage = locProuct.locProductCoverage;
    if (globalData.settingArea == YES) //ft
    {
        view.lblUnitFt.hidden = NO;
        view.lblUnitM.hidden = YES;
    }
    else
    {
        view.lblUnitFt.hidden = YES;
        view.lblUnitM.hidden = NO;
        convCoverage = [GlobalData sqft2sqm:locProuct.locProductCoverage];
    }
    NSString *strCoverage = [NSString stringWithFormat:@"%.2f", convCoverage];
    view.lblCoverage.text = strCoverage;
    CGFloat szWidth = [CommonMethods widthOfString:strCoverage withFont:view.lblCoverage.font];
    CGRect frame = view.viewUnit.frame;
    frame.origin.x = view.lblCoverage.frame.origin.x + szWidth + 10;
    view.viewUnit.frame = frame;
    
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (CGFloat) getViewHeight
{
    return 117.0f;
}

@end
