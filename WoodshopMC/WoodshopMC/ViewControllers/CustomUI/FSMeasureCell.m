//
//  FSMeasureCell.m
//  FloorSmart
//
//  Created by Lydia on 1/6/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSMeasureCell.h"
#import "Global.h"

@implementation FSMeasureCell
@synthesize btnDel, lblEMC, lblMC, lblRH, lblTemperature, lblTime;
@synthesize delegate;
@synthesize curReading = _curReading;

+ (FSMeasureCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"FSMeasureCell" owner:nil options:nil];
    FSMeasureCell *cell = [array objectAtIndex:0];
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)setCurReading:(FSReading *)curReading
{
    _curReading = curReading;
    NSDate *curReadDate = curReading.readTimestamp;
    [lblTime setText:[NSString stringWithFormat:@"%@hrs", [CommonMethods date2str:curReadDate withFormat:@"HH:mm"]]];
    [lblMC setText:[NSString stringWithFormat:@"%@", [curReading getDisplayRealMCValue]]];
    
    // EMC
    [lblEMC setText:[NSString stringWithFormat:@"%.1f", [curReading getEmcValue]]];
    
    // RH, is rounded whole unit
    [lblRH setText:[NSString stringWithFormat:@"%d", ROUND(curReading.readConvRH)]];
    GlobalData *globalData = [GlobalData sharedData];
    
    // Temperature
    CGFloat temp = curReading.readConvTemp;
    if (globalData.settingTemp == YES) //f
        temp = [FSReading getFTemperature:temp];
    [lblTemperature setText:[NSString stringWithFormat:@"%d", ROUND(temp)]];
    
}

#pragma mark - Action
- (IBAction)onDel:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didDelete:)])
    {
        [self.delegate performSelector:@selector(didDelete:) withObject:self];
    }
}

@end
