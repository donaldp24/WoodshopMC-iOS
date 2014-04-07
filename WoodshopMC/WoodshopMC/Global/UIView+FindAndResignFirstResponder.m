//
//  UIView+FindAndResignFirstResponder.m
//  iPadRally
//
//  Created by Lydia on 12/23/13
//  Copyright (c) 2013 Jonas. All rights reserved.
//

@implementation UIView (FindAndResignFirstResponder)

- (BOOL)findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}

@end