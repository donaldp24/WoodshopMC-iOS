//
//  FSJobCell.m
//  FloorSmart
//
//  Created by Lydia on 12/24/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSJobCell.h"
#import "FSJobViewController.h"

@implementation FSJobCell
@synthesize viewEdit, viewEditing, txtJobName, lblJobName, btnDetail;
@synthesize curJob = _curJob;
@synthesize delegate;

+ (FSJobCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"FSJobCell" owner:nil options:nil];
    FSJobCell *cell = [array objectAtIndex:0];
    
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
}

- (void)setCurJob:(FSJob *)curJob
{
    _curJob = curJob;
    [lblJobName setText:[curJob jobName]];
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //[self onOK:nil];
    return YES;
}

#pragma mark - Actions
- (IBAction)onEdit:(id)sender
{
    FSJobViewController *superController = (FSJobViewController *)self.delegate;
    if ([superController isEditing]) {
        return;
    }
    if([self.delegate respondsToSelector:@selector(didEdit:)])
    {
        [self.delegate performSelector:@selector(didEdit:) withObject:self];
    }
    if([self.delegate respondsToSelector:@selector(onJobEditStarted:)])
    {
        [self.delegate performSelector:@selector(onJobEditStarted:) withObject:txtJobName];
    }
    
    [superController setIsEditing:YES];
    [txtJobName setText:lblJobName.text];
    [viewEdit setHidden:YES];
    [viewEditing setHidden:NO];
    [lblJobName setHidden:YES];
    //[btnDetail setHidden:YES];
    [txtJobName setHidden:NO];
    [txtJobName becomeFirstResponder];
}

- (IBAction)onArchive:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didArchive:)])
    {
        [self.delegate performSelector:@selector(didArchive:) withObject:self];
    }
}

- (IBAction)onOK:(id)sender
{
    BOOL ret = YES;
    ret = [self.delegate didOK:self];
    if (ret == YES)
    {
        FSJobViewController *superController = (FSJobViewController *)self.delegate;
        [superController setIsEditing:NO];
        [txtJobName resignFirstResponder];
        [txtJobName setHidden:YES];
        [lblJobName setText:[txtJobName text]];
        [txtJobName setText:@""];
        [lblJobName setHidden:NO];
        //[btnDetail setHidden:NO];
        [viewEditing setHidden:YES];
        [viewEdit setHidden:NO];
    }
}

- (IBAction)onCancel:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didCancel:)])
    {
        [self.delegate performSelector:@selector(didCancel:) withObject:self];
    }
    if([self.delegate respondsToSelector:@selector(onJobEditFinished:)])
    {
        [self.delegate performSelector:@selector(onJobEditFinished:) withObject:txtJobName];
    }
    FSJobViewController *superController = (FSJobViewController *)self.delegate;
    [superController setIsEditing:NO];
    [txtJobName resignFirstResponder];
    [txtJobName setHidden:YES];
    [txtJobName setText:@""];
    [lblJobName setHidden:NO];
    //[btnDetail setHidden:NO];
    [viewEditing setHidden:YES];
    [viewEdit setHidden:NO];
}

- (IBAction)onDetail:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didDetail:)])
    {
        [self.delegate performSelector:@selector(didDetail:) withObject:self];
    }
}

@end
