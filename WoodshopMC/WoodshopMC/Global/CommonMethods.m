//
//  CommonMethods.m
//  Chat24Seven
//
//  Created by Lydia on 12/23/13
//

#import "CommonMethods.h"
#import <QuartzCore/QuartzCore.h>
#import "Global.h"
#import <AudioToolbox/AudioToolbox.h>

static CFURLRef        soundFileURLRef = nil;
static SystemSoundID   soundFileObject;

@implementation CommonMethods

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

+ (void)showAlertUsingTitle:(NSString *)titleString andMessage:(NSString *)messageString {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [alert release];
}

+ (void) showLoadingView:(UIView *) toView title:(NSString *) title andDescription:(NSString *)desc {
  dispatch_async(dispatch_get_main_queue(), ^{
    //some UI methods ej
     UIView *tempView = [CommonMethods addLoadingViewWithTitle:title andDescription:desc];
    [toView addSubview:tempView];
  });
}

+ (void) removeLoadingView:(UIView *) myView {
  
  NSArray *tempArray = [[myView subviews] copy];
  for (UIView*tempView in tempArray) {
    if (tempView.tag == 2000) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [tempView removeFromSuperview];
      });
    }
  }
  [tempArray release];
}

+ (UIView *) addLoadingViewWithTitle:(NSString *)title
					 andDescription:(NSString *)description
{
	UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	backGroundView.backgroundColor = [UIColor clearColor];
	backGroundView.tag = 2000;
	backGroundView.alpha = 0.9;
  
	UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(40, 145, 240, 110)];
	loadingView.backgroundColor = [UIColor blackColor];
	[loadingView.layer setCornerRadius:6.0];
	[loadingView.layer setBorderWidth:2.0];
	[loadingView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
	
	UILabel  *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 200, 30)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = [NSString stringWithFormat:@"%@",title];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:16];
	
	UILabel  *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, 240, 1)];
	lineLabel.backgroundColor = [UIColor lightGrayColor];
  
	UILabel  *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, 30, 200, 60)];
	descriptionLabel.backgroundColor = [UIColor clearColor];
	descriptionLabel.numberOfLines = 3;
	descriptionLabel.text = [NSString stringWithFormat:@"%@",description];
	descriptionLabel.textColor = [UIColor whiteColor];
  
	if ([description length] < 50) {
		descriptionLabel.font = [UIFont systemFontOfSize:15];
		loadingView.frame = CGRectMake(40, 145, 240, 90);
	}
	else {
		descriptionLabel.font = [UIFont systemFontOfSize:13];
		loadingView.frame = CGRectMake(40, 145, 240, 95);
	}
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]
													  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	
	activityIndicatorView.center = CGPointMake(15, 62);
	[activityIndicatorView startAnimating];
  
  [loadingView addSubview:titleLabel];
  [loadingView addSubview:lineLabel];
  [loadingView addSubview:descriptionLabel];
  [loadingView addSubview:activityIndicatorView];
  [backGroundView addSubview:loadingView];
  

  [titleLabel release];
	[lineLabel release];
	[loadingView release];
	[descriptionLabel release];
	[activityIndicatorView release];
  
 	return [backGroundView autorelease];
}

+ (NSNumber *)getCurrentUserID {
 // DEBUGLog(@"Current UserID %d",[[[NSUserDefaults standardUserDefaults] objectForKey:@"ID"] intValue]);
    int userId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ID"] intValue];
    NSNumber *userIDNumber = [NSNumber numberWithInt:userId];
    return userIDNumber;
    
}

+ (NSString *)getVersionNumber {
    NSString * appVersionString = [[NSBundle mainBundle] 
                                   objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSLog(@"app version no. is:%@",appVersionString);
    return appVersionString;
}


+ (void) changeUserImage:(NSDictionary *)responseDictionary{
     
    [[NSUserDefaults standardUserDefaults]setObject:[responseDictionary objectForKey:@"pimage"] forKey:@"userProfileImage"];
}

+ (NSString *)getUserImage{
  NSString *imageString = [[[[NSUserDefaults standardUserDefaults]objectForKey:@"userProfileImage"] retain] autorelease];
    return imageString;
    
}

+ (NSString *)convertToXMLEntities:(NSString *)myString {
    NSMutableString * temp = [myString mutableCopy];
    
    [temp replaceOccurrencesOfString:@"&"
                          withString:@"&amp;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"<"
                          withString:@"&lt;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@">"
                          withString:@"&gt;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"\""
                          withString:@"&quot;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"'"
                          withString:@"&apos;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    
    return temp;
}

+ (BOOL)checkEmail:(UITextField *)checkText
{
    BOOL filter = YES ;
    NSString *filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = filter ? filterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if([emailTest evaluateWithObject:checkText.text] == NO)
    {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Input a valid Email address."];
        return NO ;
    }
    
    return YES ;
}

+ (BOOL)checkBlankField:(NSArray *)txtArray titles:(NSArray *)titleArray
{   
    UITextField *textField = nil;
    NSString *textTitle = nil;
    
    NSInteger nInx = 0;
    NSInteger nCnt = 0;
    
    for(nInx = 0, nCnt = [txtArray count]; nInx<nCnt; nInx++ )
    {
        textField = [txtArray objectAtIndex:nInx];
        textTitle = [titleArray objectAtIndex:nInx];
        
        if([textField.text isEqualToString:@""])
        {
            [CommonMethods showAlertUsingTitle:@"Error" andMessage:[NSString stringWithFormat:@"%@ can't be blank. Please try again.", textTitle]];
            return NO ;
        }
    }
    
    return YES ;
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);

    img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}

+ (NSDate *)str2date:(NSString *)dateString withFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)date2str:(NSDate *)convertDate withFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    
    return [dateFormatter stringFromDate:convertDate];
}

+ (BOOL)isToday:(NSString *)compareDateString withFormat:(NSString *)formatString
{
    NSDate *compareDate = [CommonMethods str2date:compareDateString withFormat:formatString];
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:compareDate];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        return YES;
    }
    return NO;
}

+ (NSComparisonResult)compareOnlyDate:(NSDate *)date1 date2:(NSDate *)date2
{
    NSUInteger dateFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSCalendar *gregorianCalendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *selfComponents = [gregorianCalendar components:dateFlags fromDate:date1];
    NSDate *selfDateOnly = [gregorianCalendar dateFromComponents:selfComponents];
    
    NSDateComponents *otherCompents = [gregorianCalendar components:dateFlags fromDate:date2];
    NSDate *otherDateOnly = [gregorianCalendar dateFromComponents:otherCompents];
    return [selfDateOnly compare:otherDateOnly];
}

+ (CGFloat)widthOfString:(NSString *)string withFont:(id)font
{
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

+ (NSString *)getDocumentDirectory {
    
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return documentsDirectory;
}

+ (void)playTapSound
{
#if true
    /*
    if (soundFileURLRef == nil)
    {
        // Create the URL for the source audio file. The URLForResource:withExtension: method is
        //    new in iOS 4.0.
        NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"tap"
                                                    withExtension: @"aif"];
        
        // Store the URL as a CFURLRef instance
        soundFileURLRef = (CFURLRef) [tapSound retain];
        
        
        // Create a system sound object representing the sound file.
        AudioServicesCreateSystemSoundID (
                                          
                                          soundFileURLRef,
                                          &soundFileObject
                                          );
    }
    
    AudioServicesPlaySystemSound (soundFileObject);
     */
    AudioServicesPlaySystemSound(0x450);
#else
    
    [[UIDevice currentDevice] playInputClick];
#endif
}

@end
