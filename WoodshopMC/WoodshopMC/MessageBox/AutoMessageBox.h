//
//  AutoMessageBox.h
//  Showhand
//
//  Created by Lion User on 01/02/2013.
//  Copyright (c) 2013 AppDevCenter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoMessageBox : UIViewController{
    IBOutlet UITextView *textView;
    NSAttributedString *strMsg;
}


+ (void)AutoMsgInView:(UIView *)parentView withText:(NSAttributedString *)text;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil text:(NSAttributedString *)text;
@end
