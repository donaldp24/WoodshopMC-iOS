//
//  FSReportHelper.h
//  FloorSmart


#import <Foundation/Foundation.h>
#import "DataManager.h"

#define kBorderInset            20.0
#define kBorderWidth            1.0
#define kMarginInset            10.0
#define kLineWidth              1.0

#define A4PAPER_WIDTH_IN_PORTRATE  1240.0f
#define A4PAPER_HEIGHT_IN_PORTRATE   1753.0f

#define FS_REPORT_VALUE_SEPARATOR @";+;"

@class FSJob;

@protocol FSReportHelperDelegate <NSObject>

- (void) didFinishGeneratingReport;

@end



@interface FSReportHelper : NSObject

@property (nonatomic, assign) id<FSReportHelperDelegate> delegate;

-(NSString *) generateReportForJob:(FSJob *) aJob;

@end
