//
//  FSArchiveCell.m
//  FloorSmart
//
//  Created by Lydia on 12/24/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSArchiveCell.h"

@implementation FSArchiveCell
@synthesize lblJob, btnDetail;
@synthesize delegate;
@synthesize curJob = _curJob;

+ (FSArchiveCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"FSArchiveCell" owner:nil options:nil];
    FSArchiveCell *cell = [array objectAtIndex:0];
    
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

    // Configure the view for the selected state
}

- (void)setCurJob:(FSJob *)curJob
{
    _curJob = curJob;
    [lblJob setText:[curJob jobName]];
}

- (IBAction)onUnarchive:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didUnarchive:)])
    {
        [self.delegate performSelector:@selector(didUnarchive:) withObject:self];
    }
}

- (IBAction)onDelete:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didDelete:)])
    {
        [self.delegate performSelector:@selector(didDelete:) withObject:self];
    }
}

- (IBAction)onDetail:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didDetail:)])
    {
        [self.delegate performSelector:@selector(didDetail:) withObject:self];
    }
}

@end
