//
//  AutoMessageBox.m
//  Showhand
//
//  Created by Lion User on 01/02/2013.
//  Copyright (c) 2013 AppDevCenter. All rights reserved.
//

#import "AutoMessageBox.h"

@interface AutoMessageBox ()

@end

@implementation AutoMessageBox

// Set visibility duration
static const CGFloat kDuration = 8;


// Static toastview queue variable
static NSMutableArray *toasts;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

+ (void)AutoMsgInView:(UIView *)parentView withText:(NSAttributedString *)text{
    // Add new instance to queue
    AutoMessageBox *viewCtrl = [[AutoMessageBox alloc] initWithNibName:@"AutoMessageBox" bundle:nil text:text];
    
    CGFloat lWidth =  viewCtrl.view.frame.size.width;
    CGFloat lHeight = viewCtrl.view.frame.size.height;
    CGFloat pWidth = parentView.frame.size.width;
    CGFloat pHeight = parentView.frame.size.height;
    
    // Change toastview frame
    viewCtrl.view.frame = CGRectMake((pWidth - lWidth) / 2., (pHeight - lHeight) / 2., lWidth, lHeight);
    viewCtrl.view.alpha = 0.0f;
    
    if (toasts == nil) {
        toasts = [[NSMutableArray alloc] initWithCapacity:1];
        [toasts addObject:viewCtrl];
        [AutoMessageBox nextToastInView:parentView];
    }
    else {
        if (toasts.count <= 0)
            [toasts addObject:viewCtrl];
    }
    
    //[viewCtrl release];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)fadeToastOut {
    
    // Fade in parent view
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction
     
                     animations:^{
                         self.view.alpha = 0.f;
                     }
                     completion:^(BOOL finished){
                         UIView *parentView = self.view.superview;
                         [self.view removeFromSuperview];
                         
                         // Remove current view from array
                         [toasts removeObject:self];
                         if ([toasts count] == 0) {
                            ///[toasts release];
                             toasts = nil;
                         }
                         else
                             [AutoMessageBox nextToastInView:parentView];
                     }];
}


+ (void)nextToastInView:(UIView *)parentView {
    if ([toasts count] > 0) {
        AutoMessageBox *viewCtrl = [toasts objectAtIndex:0];
        
        // Fade into parent view
        [parentView addSubview:viewCtrl.view];
        [UIView animateWithDuration:.5  delay:0 options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             viewCtrl.view.alpha = 1.0;
                         } completion:^(BOOL finished){}];
        
        // Start timer for fade out
        [viewCtrl performSelector:@selector(fadeToastOut) withObject:nil afterDelay:kDuration];
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil text:(NSAttributedString *)text
{
    NSString *szXibName = nibNameOrNil;
//    if ([Common phoneType] == IPAD)
//        szXibName = [NSString stringWithFormat:@"%@_ipad", nibNameOrNil];
	

	self = [super initWithNibName:szXibName bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        strMsg = text;
    }

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.alpha = 0;
    textView.attributedText = strMsg;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
}

#ifdef IOS6

#endif

@end