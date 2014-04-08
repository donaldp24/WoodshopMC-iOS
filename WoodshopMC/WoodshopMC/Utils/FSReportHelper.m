//
//  FSReportHelper.m
//  FloorSmart
//


#import "FSReportHelper.h"
#import "DataManager.h"
#import "Global.h"
#import "CommonMethods.h"
#import "GlobalData.h"

#define STR(string) (string) ? (string) : @""

static NSString * const kLabelKey = @"label";
static NSString * const kDescriptionKey = @"description";
static NSString * const kNewLineKey = @"newLineSeparator";
static NSString * const kFontSizeKey = @"fontSize";

static NSString * const kDateKey = @"date";
static NSString * const kReadingsKey = @"readings";
static NSString * const kLocProductKey = @"locProduct";
static NSString * const kLocationKey = @"location";
static NSString * const kDateReadingsKey = @"datereadings";
static NSString * const kLocLocProductKey = @"loclocProduct";

static CGFloat const kHeaderHeight = 110.f;
static CGFloat const kSubtitleHeight = 120.f;
static CGFloat const kDateHeight = 50.f;
static CGFloat const kRowHeight = 40.0f;
static CGFloat const kStatisticHeight = 40.f;
static CGFloat const kGap = 10.f;

@interface NSMutableString (Placeholder)

- (void)appendString:(NSString *)aString placeholder:(NSString*)aPlaceholder;

@end

@implementation NSMutableString (Placeholder)

- (void)appendString:(NSString *)aString placeholder:(NSString *)aPlaceholder {
    NSString *stringToAdd = aPlaceholder;

    if (aString) {
        stringToAdd = aString;
    }
    [self appendString:stringToAdd];
}

@end

#define kPadding 25
static int countData;

static NSString * const kEmptyPlaceholder = @"EMPTY";

@interface FSReportHelper() {
    CGSize pageSize;
}

@property(nonatomic, retain) NSMutableArray *fsReportArray;
@property(nonatomic, retain) FSJob *job;

@end

@implementation FSReportHelper


- (id)init {
    self = [super init];
    if (self) {
        //
    }
    return self;
}

-(NSString *)getStringFromDate:(NSDate *)date {

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss"];
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    return stringFromDate;
}

- (void)fillReportData:(FSJob *)job {
    
    NSMutableArray *arrayLoc = [[DataManager sharedInstance] getLocations:job.jobID containDefault:YES];
    
    for (int i = 0; i < [arrayLoc count]; i++) {
        FSLocation *loc = [arrayLoc objectAtIndex:i];
        NSMutableArray *arrayLocProduct = [[DataManager sharedInstance] getLocProducts:loc searchField:@"" containDefault:YES];
        
        NSMutableArray *arrayLocProductDates = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < [arrayLocProduct count]; j++) {
            FSLocProduct *locProduct = [arrayLocProduct objectAtIndex:j];
            NSMutableArray *arrayDates = [[DataManager sharedInstance] getAllReadingDates:locProduct.locProductID];
            
            NSMutableArray *arrayDateReadings = [[NSMutableArray alloc] init];
            for (int k = 0; k < [arrayDates count]; k++)
            {
                NSDate *date = [arrayDates objectAtIndex:k];
                NSMutableArray *arrayReadings = [[DataManager sharedInstance] getReadings:locProduct.locProductID withDate:date];
                
                [arrayDateReadings addObject:@{kDateKey: date, kReadingsKey: arrayReadings}];
            }
            
            
            if ([arrayDateReadings count] > 0)
            {
                [arrayLocProductDates addObject:@{kLocProductKey: locProduct, kDateReadingsKey: arrayDateReadings}];
            }
        }
        if ([arrayLocProductDates count] > 0)
        {
            if (self.fsReportArray == nil)
                self.fsReportArray = [[NSMutableArray alloc] init];
            [self.fsReportArray addObject:@{kLocationKey: loc, kLocLocProductKey: arrayLocProductDates}];
        }
    }
}

- (CGRect)drawLabel:(NSString*)label
            details:(NSString*)details
             origin:(CGPoint)origin
           fontSize:(CGFloat)fontSize
   newLineSeparator:(BOOL)newLineSeparator
{

    UIFont *labelFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *detailsFont = [UIFont systemFontOfSize:fontSize];

    CGSize labelSize = [label sizeWithFont:labelFont constrainedToSize:CGSizeMake(700, 300)];

    CGRect labelFrame = {origin, labelSize};

    CGSize detailsSize = [details sizeWithFont:detailsFont constrainedToSize:CGSizeMake(300, 100)];

    CGRect detailsFrame = {{0, 0}, detailsSize};
    CGRect totalFrame = {origin, {0, 0}};

    if (newLineSeparator) {
        detailsFrame.origin.x = origin.x;
        detailsFrame.origin.y = origin.y + labelSize.height + 10;

        totalFrame.size.width = MAX(labelSize.width, detailsSize.width);
        totalFrame.size.height = labelSize.height + detailsSize.height + 10;
    }
    else {
        detailsFrame.origin.x = origin.x + labelSize.width + 10;
        detailsFrame.origin.y = origin.y;

        totalFrame.size.width = labelSize.width + detailsSize.width + 10;
        totalFrame.size.height = MAX(labelSize.height, detailsSize.height);
    }

    [self drawText:label withFrame:labelFrame withFont:labelFont];
    [self drawText:details withFrame:detailsFrame withFont:detailsFont];

    return totalFrame;
}

- (void)renderFirstPage:(FSJob *)aJob dateStr:(NSString *)dateStr {

    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    [self drawImage];

    CGRect previousRect = {{kBorderInset + kMarginInset+50, kBorderInset + kMarginInset + 150.0}, {0, 0}};

    NSArray *strings = @[
                         @{kLabelKey: @"Job Name:",                   kDescriptionKey: STR(self.job.jobName),                               kFontSizeKey: @24.f},
                         @{kLabelKey: @"Date:",              kDescriptionKey: STR(dateStr),                                 kFontSizeKey: @24.f}
                         ];

    for (NSDictionary *row in strings) {
        previousRect =[self drawLabel:row[kLabelKey]
                              details:row[kDescriptionKey]
                               origin:CGPointMake(previousRect.origin.x, previousRect.size.height + previousRect.origin.y + 10)
                             fontSize:[row[kFontSizeKey] floatValue]
                     newLineSeparator:[row[kNewLineKey] boolValue]];
    }

    if (YES) {
        [self drawLogoImage];
        [self drawTextWithLeftAllignment:@"Certified By Wagner Meters"
                               withFrame:CGRectMake(kBorderInset + kMarginInset+150, kBorderInset + kMarginInset + 850.0,400 , 80)
                                withFont:[UIFont systemFontOfSize:24.0f]];
    }
}

- (void)renderHeader:(FSJob *)job loc:(FSLocation *)loc {
    
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    NSString *strHeader = [NSString stringWithFormat:@"Job: %@ \t\t Location: %@", job.jobName, loc.locName];
    CGFloat width = [CommonMethods widthOfString:strHeader withFont:font] + 20;
    
    [self drawText:strHeader
         withFrame:CGRectMake(50, 60, width, 20)
          withFont:font];
    
    
    
    CGPoint from = CGPointMake(40, 90);
    CGPoint to = CGPointMake(pageSize.width - 80, 90);
    
    [self drawLineFromPoint:from toPoint:to];
}

- (void) renderFooter:(NSInteger) currentPage {
    [self drawPageNumber:currentPage];
}

- (void) renderSubtitle:(CGFloat)ypos loc:(FSLocation *)loc locProduct:(FSLocProduct *)locProduct {
    
    
    ypos += 30;
    
    UIFont *font = [UIFont systemFontOfSize:22.0f];
    NSString *strHeader = [NSString stringWithFormat:@"Location: %@", loc.locName];
    CGFloat width = [CommonMethods widthOfString:strHeader withFont:font] + 20;
    
    [self drawText:strHeader
         withFrame:CGRectMake(60, ypos, width, 20)
          withFont:font];
    
    ypos += 30;

    strHeader = [NSString stringWithFormat:@"Product: %@", locProduct.locProductName];
    width = [CommonMethods widthOfString:strHeader withFont:font] + 20;
    [self drawText:strHeader
         withFrame:CGRectMake(60, ypos, width, 30)
          withFont:font];
    if ([locProduct.locProductName isEqualToString:FMD_DEFAULT_PRODUCTNAME])
    {
        int xpos = 60 + width;
        strHeader = [NSString stringWithFormat:@"(%@)", [FSProduct getDisplayProductType:locProduct.locProductType]];
        font = [UIFont systemFontOfSize:22.0f];
        width = [CommonMethods widthOfString:strHeader withFont:font] + 20;
        [self drawText:strHeader
             withFrame:CGRectMake(xpos, ypos, width, 30)
              withFont:font];
    }
    
    ypos += 30;
    
    font = [UIFont italicSystemFontOfSize:22.0f];
    GlobalData *globalData = [GlobalData sharedData];
    if (globalData.settingArea == YES) //feet
        strHeader = [NSString stringWithFormat:@"Coverage: %.1f square feet", locProduct.locProductCoverage];
    else
    {
        strHeader = [NSString stringWithFormat:@"Coverage: %.1f square meter", [GlobalData sqft2sqm:locProduct.locProductCoverage]];
    }
    width = [CommonMethods widthOfString:strHeader withFont:font] + 20;
    [self drawText:strHeader
         withFrame:CGRectMake(60, ypos, width, 30)
          withFont:font];
    
}

- (void) renderDate:(CGFloat)ypos date:(NSDate *)date {
    
    GlobalData *globalData = [GlobalData sharedData];
    
    UIFont *font = [UIFont systemFontOfSize:18.0f];
    NSString *strDate = [NSString stringWithFormat:@"Date: %@", [CommonMethods date2str:date withFormat:globalData.settingDateFormat]];

    CGFloat width = [CommonMethods widthOfString:strDate withFont:font] + 20;
    
    [self drawText:strDate
         withFrame:CGRectMake(80, ypos + 10, width, 30)
          withFont:font];
    
    ypos += 25;
}

- (BOOL) isInPage:(CGFloat)ypos {
    if (ypos >= A4PAPER_HEIGHT_IN_PORTRATE-120)
        return NO;
    return YES;
}

- (CGFloat) heightRemains:(CGFloat)ypos {
    return A4PAPER_HEIGHT_IN_PORTRATE-120-ypos;
}

- (void) renderStatistics:(CGFloat)ypos arrayReadings:(NSMutableArray *)arrayReadings {
    
    CGFloat xOrigin = 100;
    CGFloat yOrigin = ypos;
    // draw statistics
    
    UIFont *font = [UIFont systemFontOfSize:18.0f];
    CGFloat mcavg = [FSReading getMCAvg:arrayReadings];
    CGFloat rhavg = [FSReading getRHAvg:arrayReadings];
    CGFloat tempavg = [FSReading getTempAvg:arrayReadings];
    CGFloat emcavg = [FSReading getEmcAvg:arrayReadings];
    
    NSString *strStatistic = [NSString stringWithFormat:@"MC Avg: %.1f%%;\t\tRH Avg: %d%%;\t\tTemp Avg: %dC;\t\tEMC Avg:%.1f%%", mcavg / 10.f, ROUND(rhavg), ROUND(tempavg), emcavg];
    
    CGFloat width = [CommonMethods widthOfString:strStatistic withFont:font] + 20;
    
    [self drawText:strStatistic
         withFrame:CGRectMake(xOrigin, yOrigin, width, 30)
          withFont:font];
    
    ypos += 25;
}


- (void) renderRows:(CGFloat)ypos data:(NSMutableArray *)data startIndex:(long)startIndex count:(long)count {
    
    CGFloat xOrigin = 100;
    CGFloat yOrigin = ypos;
    CGFloat columnWidth = 150;
    int numberOfColumns = 6;
    
    // table header
    [self drawTableAt:CGPointMake(xOrigin, yOrigin)
        withRowHeight:kRowHeight
       andColumnWidth:columnWidth
          andRowCount:1
       andColumnCount:numberOfColumns];
    
    NSArray *labels = @[@"No",
                        @"MC (%)",
                        @"RH (%)",
                        @"Temp (C)",
                        @"EMC (%)",
                        @"Time"
                        ];
    
    for (int i = 0; i < [labels count]; i++) {
        [self drawText:labels[i]
             withFrame:CGRectMake(xOrigin + 20 + columnWidth * i,
                                  yOrigin + 10,
                                  columnWidth - 40,
                                  80)
              withFont:[UIFont boldSystemFontOfSize:18.0f]];
    }
    
    yOrigin += kRowHeight;
    
    
    [self drawTableAt:CGPointMake(xOrigin, yOrigin)
        withRowHeight:kRowHeight
       andColumnWidth:columnWidth
          andRowCount:(int)count
       andColumnCount:numberOfColumns];
    
    for (int i = (int)startIndex; i < (int)startIndex + count; i++) {
        UIFont *textFont = [UIFont systemFontOfSize:14.0f];
        
        FSReading *reading = [data objectAtIndex:i];
        
        // No.
        int column = 0;
        [self drawText:[NSString stringWithFormat:@"%d", (int)i + 1]
             withFrame:CGRectMake(xOrigin + 10 + (columnWidth * column),
                                  yOrigin + 10 + (kRowHeight * (i - startIndex)),
                                  columnWidth - 20,
                                  30)
              withFont:textFont
           placeholder:kEmptyPlaceholder];
        
        // MC(%)
        column++;
        [self drawText:[NSString stringWithFormat:@"%.1f", reading.readMC / 10.f]
             withFrame:CGRectMake(xOrigin + 10 + (columnWidth * column),
                                  yOrigin + 10 + (kRowHeight * (i - startIndex)),
                                  columnWidth - 20,
                                  30)
              withFont:textFont
           placeholder:kEmptyPlaceholder];
        
        // RH(%)
        column++;
        [self drawText:[NSString stringWithFormat:@"%d", ROUND(reading.readConvRH)]
             withFrame:CGRectMake(xOrigin + 10 + (columnWidth * column),
                                  yOrigin + 10 + (kRowHeight * (i - startIndex)),
                                  columnWidth - 20,
                                  30)
              withFont:textFont
           placeholder:kEmptyPlaceholder];
        
        // Temp(C)
        column++;
        [self drawText:[NSString stringWithFormat:@"%d", ROUND(reading.readConvTemp)]
             withFrame:CGRectMake(xOrigin + 10 + (columnWidth * column),
                                  yOrigin + 10 + (kRowHeight * (i - startIndex)),
                                  columnWidth - 20,
                                  30)
              withFont:textFont
           placeholder:kEmptyPlaceholder];
        
        // Emc
        column++;
        [self drawText:[NSString stringWithFormat:@"%.1f", [reading getEmcValue]]
             withFrame:CGRectMake(xOrigin + 10 + (columnWidth * column),
                                  yOrigin + 10 + (kRowHeight * (i - startIndex)),
                                  columnWidth - 20,
                                  30)
              withFont:textFont
           placeholder:kEmptyPlaceholder];
        
        // Time
        column++;
        [self drawText:[CommonMethods date2str:reading.readTimestamp withFormat:@"HH:mm"]
             withFrame:CGRectMake(xOrigin + 10 + (columnWidth * column),
                                  yOrigin + 10 + (kRowHeight * (i - startIndex)),
                                  columnWidth - 20,
                                  30)
              withFont:textFont
           placeholder:kEmptyPlaceholder];
    }
}

- (NSString *)createReportForJob:(FSJob *)aJob {

    NSDate * aDate = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.pdf", aJob.jobName, [CommonMethods date2str:aDate withFormat:@"MM_dd_HH_mm"]];
    NSString * fullPDFPath = [[CommonMethods getDocumentDirectory] stringByAppendingPathComponent:fileName];

    NSString *dateStr = [NSString stringWithFormat:@"%@",[self getStringFromDate:[NSDate date]]];

    // fill report data
    [self fillReportData:aJob];
    
    if ([self.fsReportArray count] == 0) {
        return nil;
    }
    
    // Opent the PDF context
    pageSize = CGSizeMake(A4PAPER_WIDTH_IN_PORTRATE, A4PAPER_HEIGHT_IN_PORTRATE);
    UIGraphicsBeginPDFContextToFile(fullPDFPath, CGRectZero, nil);
    
    NSInteger currentPage = 0;
    
    CGFloat yPos = 0.0;
    
    // render first page
    [self renderFirstPage:aJob dateStr:dateStr];
    [self drawPageNumber:currentPage++ + 1];
    
    // render contents page
    BOOL isStart = YES;
    
    for (int i = 0; i < [self.fsReportArray count]; i++) {
        
        NSDictionary *dic = [self.fsReportArray objectAtIndex:i];
        FSLocation *loc = [dic objectForKey:kLocationKey];
        NSMutableArray *arrayLocProducts = [dic objectForKey:kLocLocProductKey];
        
        if (isStart == YES) {
            
            // draw header.
            [self renderHeader:aJob loc:loc];
            isStart = NO;
            yPos = kHeaderHeight;
        }
        
        for (int j = 0; j < [arrayLocProducts count]; j++) {
            NSDictionary *dic1 = [arrayLocProducts objectAtIndex:j];
            FSLocProduct *locProduct = (FSLocProduct *)[dic1 objectForKey:kLocProductKey];
            NSMutableArray *arrayLocProductsDates = [dic1 objectForKey:kDateReadingsKey];
            
            // page break and render header
            if ([self isInPage:yPos + kSubtitleHeight] == NO) {
                [self drawPageNumber:currentPage++ + 1];
                
                [self renderHeader:aJob loc:loc];
                yPos = kHeaderHeight;
            }
            
            // draw subtitle
            [self renderSubtitle:yPos loc:loc locProduct:locProduct];
            yPos += kSubtitleHeight;
            
            // draw parameters of product
            //

            
            for (int k = 0; k < [arrayLocProductsDates count]; k++) {
                NSDictionary *dic2 = [arrayLocProductsDates objectAtIndex:k];
                NSDate *date = (NSDate *)[dic2 objectForKey:kDateKey];
                NSMutableArray *arrayReadings = [dic2 objectForKey:kReadingsKey];
                
                yPos += kGap;
                
                // page break and render header
                if ([self isInPage:yPos + kDateHeight] == NO) {
                    [self drawPageNumber:currentPage++ + 1];
                    
                    [self renderHeader:aJob loc:loc];
                    yPos = kHeaderHeight;
                }
                
                // draw date
                [self renderDate:yPos date:date];
                yPos += kDateHeight;
                
                // draw statistics
                [self renderStatistics:yPos arrayReadings:arrayReadings];
                yPos += kStatisticHeight;
                
                
                int m = 0;
                int count = (int)[arrayReadings count];
                isStart = NO;
                while (m < count) {
                    
                    if (isStart == YES)
                    {
                        [self drawPageNumber:currentPage++ + 1];
                        
                        [self renderHeader:aJob loc:loc];
                        yPos = kHeaderHeight;
                        
                        isStart = NO;
                    }
                    
                    CGFloat remains = [self heightRemains:yPos];
                    int remainRows = remains / kRowHeight - 1;
                    
                    
                    if (remainRows <= count - m) {
                        isStart = YES;
                    }
                    
                    if (remainRows <= 0)
                        continue;
                    
                    if (remainRows > count - m)
                        remainRows = count - m;
                    
                    [self renderRows:yPos data:arrayReadings startIndex:m count:remainRows];
                    yPos += (remainRows + 1) * kRowHeight;
                    m += remainRows;
                }
            }
        }
    }
    
    if (yPos > kHeaderHeight)
        [self drawPageNumber:currentPage++ + 1];
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();

    NSNumber *fileSize = [self getFileSizeWithFilePath:fullPDFPath];
    

    [[self delegate] didFinishGeneratingReport];
    
    return fullPDFPath;
}

-(NSString *) generateReportForJob:(FSJob *) aJob {

    if (aJob == nil)
        return nil;

    if (self.fsReportArray) {
        [self.fsReportArray removeAllObjects];
        countData = 0;
    }
    self.job = aJob;

    return [self createReportForJob:self.job];
}

-(NSNumber*)getFileSizeWithFilePath:(NSString*)filePath {

    NSNumber *fileSizeNumber = nil;
	NSError *attributesError = nil;
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&attributesError];
	fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    return fileSizeNumber;
}

- (void) drawBorder {

    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    UIColor *borderColor = [UIColor brownColor];

    CGRect rectFrame = CGRectMake(kBorderInset, kBorderInset, pageSize.width-kBorderInset*2, pageSize.height-kBorderInset*2);

    CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
    CGContextSetLineWidth(currentContext, kBorderWidth);
    CGContextStrokeRect(currentContext, rectFrame);
}

- (void)drawPageNumber:(NSInteger)pageNumber {

    NSString* pageNumberString = [NSString stringWithFormat:@"Page %d", pageNumber];
    UIFont* theFont = [UIFont systemFontOfSize:16];

    CGSize pageNumberStringSize = [pageNumberString sizeWithFont:theFont
                                               constrainedToSize:pageSize
                                                   lineBreakMode:NSLineBreakByWordWrapping];

    CGRect stringRenderingRect = CGRectMake(kBorderInset,
                                            pageSize.height - 80.0,
                                            pageSize.width - 2*kBorderInset,
                                            pageNumberStringSize.height);

    [pageNumberString drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
}

- (void) drawText:(NSString*)textToDraw
        withFrame:(CGRect)renderingRect
         withFont:(UIFont*)font
{

    [self drawText:textToDraw
         withFrame:renderingRect
          withFont:font
       placeholder:@""];
}

- (void) drawText:(NSString*)textToDraw
        withFrame:(CGRect)renderingRect
         withFont:(UIFont*)font
      placeholder:(NSString*)placeholder
{

    if (textToDraw == nil) {
        textToDraw = placeholder;
    }
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);

    [textToDraw drawInRect:renderingRect
                  withFont:font
             lineBreakMode:NSLineBreakByWordWrapping
                 alignment:NSTextAlignmentCenter];

}

- (void) drawTextWithLeftAllignment:(NSString*)textToDraw withFrame:(CGRect)renderingRect withFont:(UIFont*)font {

    if (textToDraw == nil) {
        textToDraw = @"";
    }
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);

    [textToDraw drawInRect:renderingRect
                  withFont:font
             lineBreakMode:NSLineBreakByWordWrapping
                 alignment:NSTextAlignmentLeft];

}

- (void) drawLine {

    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, kLineWidth);

    CGContextSetStrokeColorWithColor(currentContext, [UIColor blueColor].CGColor);

    CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset, kMarginInset + kBorderInset + 40.0);
    CGPoint endPoint = CGPointMake(pageSize.width - 2*kMarginInset -2*kBorderInset, kMarginInset + kBorderInset + 40.0);

    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);

    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
}

- (void) drawImage {

    //UIImage * demoImage = [UIImage imageNamed:@"wagner_pdf_image.png"];
    UIImage * demoImage = [UIImage imageNamed:@"ReportLogo"];
    [demoImage drawInRect:CGRectMake( (pageSize.width - demoImage.size.width - 50), 40, demoImage.size.width, demoImage.size.height)];
}

- (void) drawLogoImage {

    UIImage * demoImage = [UIImage imageNamed:@"wagner_pdf_logo.png"];
    //UIImage * demoImage = [UIImage imageNamed:@"ReportLogo"];
    [demoImage drawInRect:CGRectMake(demoImage.size.width*3, kBorderInset + kMarginInset + 810.0, demoImage.size.width, demoImage.size.height)];
}

-(void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to {

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);

    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.2, 0.2, 0.2, 0.3};
    CGColorRef color = CGColorCreate(colorspace, components);

    CGContextSetStrokeColorWithColor(context, color);

    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);

    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);

}

-(void)drawTableAt:(CGPoint)origin
     withRowHeight:(int)rowHeight
    andColumnWidth:(int)columnWidth
       andRowCount:(int)numberOfRows
    andColumnCount:(int)numberOfColumns

{
    for (int i = 0; i <= numberOfRows; i++) {

        int newOrigin = origin.y + (rowHeight*i);

        CGPoint from = CGPointMake(origin.x, newOrigin);
        CGPoint to = CGPointMake(origin.x + (numberOfColumns*columnWidth), newOrigin);

        [self drawLineFromPoint:from toPoint:to];
    }

    for (int i = 0; i <= numberOfColumns; i++) {

        int newOrigin = origin.x + (columnWidth*i);

        CGPoint from = CGPointMake(newOrigin, origin.y);
        CGPoint to = CGPointMake(newOrigin, origin.y +(numberOfRows*rowHeight));

        [self drawLineFromPoint:from toPoint:to];
    }
}

@end
