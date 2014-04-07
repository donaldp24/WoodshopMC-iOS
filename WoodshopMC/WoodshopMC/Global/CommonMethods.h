//
//  CommonMethods.h
//  Chat24Seven
//
//  Created by Lydia on 12/23/13
//

#import <Foundation/Foundation.h>

#ifndef ROUND
#define ROUND(a) ((int)(a + 0.5))
#endif

@interface CommonMethods : NSObject {

}

+ (void)showAlertUsingTitle:(NSString *)titleString andMessage:(NSString *)messageString;
+ (UIView *) addLoadingViewWithTitle:(NSString *)title
					 andDescription:(NSString *)description;
+ (NSNumber *)getCurrentUserID;
+ (NSString *)getVersionNumber;
+ (void) changeUserImage:(NSDictionary *)responseDictionary;
+ (NSString *)getUserImage;
+ (void) showLoadingView:(UIView *) toView title:(NSString *) title andDescription:(NSString *)desc;
+ (void) removeLoadingView:(UIView *) myView;
+ (NSString *)convertToXMLEntities:(NSString *)myString;

+ (BOOL)checkEmail:(UITextField *)checkText;
+ (BOOL)checkBlankField:(NSArray *)txtArray titles:(NSArray *)titleArray;

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

+ (NSString *)date2str:(NSDate *)convertDate withFormat:(NSString *)formatString;
+ (NSDate *)str2date:(NSString *)dateString withFormat:(NSString *)formatString;

+ (NSComparisonResult) compareOnlyDate:(NSDate *)date1 date2:(NSDate *)date2;

+ (CGFloat)widthOfString:(NSString *)string withFont:(id)font;

+ (NSString *)getDocumentDirectory;
+ (void)playTapSound;

@end
