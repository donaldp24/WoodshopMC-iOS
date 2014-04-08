//
//  FSPopContentController.m
//  FloorSmart
//
//  Created by Lydia on 12/24/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSPopContentController.h"

@interface FSPopContentController ()
{
    UITableView *tblContent;
}
@end

@implementation FSPopContentController
@synthesize arrButtonString = _arrButtonString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithArrButtonString:(NSArray *)arrButtons
{
    self = [super init];
    if (self) {
        _arrButtonString = arrButtons;
        tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 140, 30 * [arrButtons count])];
        [self initLayout];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)initLayout
{
    tblContent.delegate = self;
    [tblContent setBackgroundColor:[UIColor clearColor]];
    [tblContent setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view setFrame:[tblContent frame]];
    [self.view addSubview:tblContent];
    [tblContent reloadData];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrButtonString count];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tblContent dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] init];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setText:[_arrButtonString objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
