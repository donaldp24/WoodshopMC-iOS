//
//  FSPopContentController.h
//  FloorSmart
//
//  Created by Lydia on 12/24/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPopContentController : UIViewController <UITableViewDelegate>

@property (nonatomic, strong) NSArray *arrButtonString;

- (id)initWithArrButtonString:(NSArray *)arrButtons;

@end
