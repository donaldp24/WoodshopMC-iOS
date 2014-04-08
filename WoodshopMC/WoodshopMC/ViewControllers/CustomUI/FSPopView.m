//
//  FSPopView.m
//  FloorSmart
//
//  Created by Lydia on 12/24/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSPopView.h"

@implementation FSPopView

@synthesize view;

@synthesize delegate, tblContent;
@synthesize arrContents = _arrContents;
@synthesize selectedNum = _selectedNum;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    [[NSBundle mainBundle] loadNibNamed:@"FSPopView" owner:self options:nil];
    [self addSubview:self.view];
}

- (void)setArrContents:(NSArray *)arrContents
{
    _arrContents = [NSArray arrayWithArray:arrContents];
    [tblContent setContentSize:CGSizeMake(tblContent.frame.size.width, 16*[arrContents count])];
    [tblContent reloadData];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrContents count];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tblContent dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] init];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setText:[_arrContents objectAtIndex:indexPath.row]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Arial" size:10]];
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedNum = indexPath.row;
    
    if([self.delegate respondsToSelector:@selector(didPopUpItem)])
    {
        [self.delegate performSelector:@selector(didPopUpItem) withObject:nil];
    }
}

@end
