//
//  FSLocSelCell.m
//  FloorSmart
//
//  Created by Donald Pae on 3/11/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSLocSelCell.h"

@implementation FSLocSelCell

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

- (void)setLocData:(id)locData
{
    _locData = locData;
    if (!self.delegate)
        return;
    
    [self.lblName setText:[self.delegate getLocName:self]];
}

#pragma mark - Actions

- (IBAction)onBtnAdd:(id)sender
{
    if (!self.delegate)
        return;
    
    [self.delegate onAddSelLoc:self];
}

@end
