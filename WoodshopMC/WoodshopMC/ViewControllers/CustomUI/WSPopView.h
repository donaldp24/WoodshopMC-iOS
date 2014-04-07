//
//  FSPopView.h
//  FloorSmart
//
//  Created by Lydia on 12/24/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPopView : UIView <UITableViewDelegate>

@property (nonatomic, assign) IBOutlet UIView *view;

@property (nonatomic, assign) IBOutlet UITableView *tblContent;
@property (nonatomic, strong) NSArray *arrContents;
@property (nonatomic) NSInteger selectedNum;

@property (nonatomic, strong) id delegate;

@end
