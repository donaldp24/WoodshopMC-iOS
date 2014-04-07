//
//  XIBTableViewCell.h
//  BodyWear
//
//  Created by RyuCJ on 8/28/13.
//  Copyright (c) 2013 damytech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XIBTableViewCell : UITableViewCell {
    NSString *strIdentifier;
}

+ (XIBTableViewCell *)cellFromNibNamed:(NSString *)nibName;

- (void)setIdentifier:(NSString *)identifier;
    
@end
