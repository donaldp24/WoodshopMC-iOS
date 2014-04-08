//
//  FSReportCell.m
//  FloorSmart
//
//  Created by iOS Developer on 2/28/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSReportCell.h"
#import "Global.h"

@implementation FSReportCell
@synthesize lblReadingDate, btnDisclosure;
@synthesize curDate = _curDate;
@synthesize isOpened = _isOpened;
@synthesize delegate;

+ (FSReportCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"FSReportCell" owner:nil options:nil];
    FSReportCell *cell = [array objectAtIndex:0];
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurDate:(NSDate *)curDate
{
    _curDate = curDate;
    _isOpened = NO;
    [lblReadingDate setText:[NSString stringWithFormat:@"Date: %@", [CommonMethods date2str:curDate withFormat:_globalData.settingDateFormat]]];
}

- (void)setIsOpened:(BOOL)isOpened
{
    _isOpened = isOpened;
    [btnDisclosure setImage:[UIImage imageNamed:(!_isOpened) ? @"bt_arrow_down1" : @"bt_arrow_up1"] forState:UIControlStateNormal];
}

- (IBAction)onDisclosre:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didDisclosure:)])
    {
        [self.delegate performSelector:@selector(didDisclosure:) withObject:self];
    }
}

@end
