//
//  FSLocationCell.m
//  FloorSmart
//
//  Created by Donald Pae on 3/11/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSLocationCell.h"

@implementation FSLocationCell

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

- (void)setData:(id)data
{
    _data = data;
    if (!self.delegate)
        return;
    
    [self.lblName setText:[self.delegate getName:self]];
}

#pragma mark - Actions
- (IBAction)onBtnEdit:(id)sender
{
    if (!self.delegate)
        return;
    
    if ([self.delegate isEditing:self]) {
        return;
    }
    
    [self.delegate onEditCell:self];
    
    //[superController setIsEditing:YES];
    [self.viewControl setHidden:YES];
    [self.lblName setHidden:YES];

    [self.viewEditing setHidden:NO];
    [self.txtName setText:self.lblName.text];
    [self.txtName setHidden:NO];
    [self.txtName becomeFirstResponder];
}

- (IBAction)onBtnDelete:(id)sender
{
    if (!self.delegate)
        return;
    [self.delegate onDeleteCell:self];
}

- (IBAction)onBtnOk:(id)sender
{
    if (!self.delegate)
        return;
    
    BOOL ret = [self.delegate onEditFinishedOk:self];
    
    if (ret)
    {
        //[superController setIsEditing:NO];
        
        [self.txtName resignFirstResponder];
        [self.txtName setHidden:YES];
        [self.lblName setText:[self.txtName text]];
        [self.txtName setText:@""];
        [self.lblName setHidden:NO];
        [self.viewEditing setHidden:YES];
        [self.viewControl setHidden:NO];
    }
}

- (IBAction)onBtnCancel:(id)sender
{
    if (!self.delegate)
        return;
    
    [self.delegate onEditFinishedCancel:self];
    
    //FSJobViewController *superController = (FSJobViewController *)self.delegate;
    //[superController setIsEditing:NO];
    
    [self.txtName resignFirstResponder];
    [self.txtName setHidden:YES];
    [self.txtName setText:@""];
    [self.lblName setHidden:NO];
    [self.viewEditing setHidden:YES];
    [self.viewControl setHidden:NO];
}

- (IBAction)onBtnBg:(id)sender
{
    if (!self.delegate)
        return;
    
    [self.delegate onSelectCell:self];
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
