//
//  DataManager.m
//  iHelp
//
//  Created by Lydia on 1/14/14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "FMDatabase.h"
#import "Global.h"

static DataManager *sharedManager;

@implementation DataManager

+ (id)sharedInstance
{
    if (!sharedManager) {

        sharedManager = [[DataManager alloc] init];
    }

    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {

        NSString *docsDir;
        NSArray *dirPaths;
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex:0];
        // Build the path to the database file
        databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @DATABASE_FILENAME]];
        
        NSFileManager *filemgr = [NSFileManager defaultManager];
        //[filemgr removeItemAtPath:databasePath error:nil];
        BOOL isDbExist = [filemgr fileExistsAtPath:databasePath];
        _database = [[FMDatabase alloc] initWithPath:databasePath];
        [_database open];
        
        if (isDbExist == NO)
        {
            char *sql_job = "CREATE TABLE tbl_job(job_id INTEGER PRIMARY KEY AUTOINCREMENT, job_name TEXT, job_archived INTEGER, deleted INTEGER);";
            char *sql_location = "CREATE TABLE tbl_location(location_id INTEGER PRIMARY KEY AUTOINCREMENT, location_jobid INTEGER, location_name TEXT, deleted INTEGER);";
            char *sql_product = "CREATE TABLE tbl_product(product_id INTEGER PRIMARY KEY AUTOINCREMENT, product_name TEXT, product_type INTEGER, deleted INTEGER);";
            char *sql_locproduct = "CREATE TABLE tbl_locproduct(locproduct_id INTEGER PRIMARY KEY AUTOINCREMENT, locproduct_locid INTEGER, locproduct_productname TEXT, locproduct_producttype INTEGER, locproduct_coverage DOUBLE, deleted INTEGER);";
            char *sql_reading = "CREATE TABLE tbl_reading(read_id INTEGER PRIMARY KEY AUTOINCREMENT, read_locproductid INTEGER, read_date TEXT, read_uuid TEXT, read_rh INTEGER, read_convrh DOUBLE, read_temp INTEGER, read_convtemp DOUBLE, read_battery INTEGER, read_depth INTEGER, read_gravity INTEGER, read_material INTEGER, read_mc INTEGER, deleted INTEGER);";
            
            BOOL bRet = [_database executeDDL:sql_job];
            bRet = [_database executeDDL:sql_location];
            bRet = [_database executeDDL:sql_product];
            bRet = [_database executeDDL:sql_locproduct];
            bRet = [_database executeDDL:sql_reading];
        }
    }

    return self;
}

#pragma mark - job

- (NSMutableArray *)getAllJobs
{
    NSMutableArray *arrJobList = [[NSMutableArray alloc] init];
    FMResultSet *results = [_database executeQuery:@"SELECT * FROM tbl_job WHERE deleted = 0"];
    while ([results next]) {
        FSJob *job  = [[[FSJob alloc] init] autorelease];
        job.jobID       = [results intForColumn:@"job_id"];
        job.jobName     = [results stringForColumn:@"job_name"];
        job.jobArchived = [results intForColumn:@"job_archived"];
        
        [arrJobList addObject:job];
    }
    return arrJobList;
}


- (NSMutableArray *)getJobs:(long)archiveFlag searchField:(NSString *)searchField
{
    NSMutableArray *arrJobList = [[NSMutableArray alloc] init];
    if (searchField == nil)
        searchField = @"";
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tbl_job WHERE deleted = 0 and job_archived = %ld AND job_name like %@%@%@", (long)archiveFlag, @"'%", searchField, @"%'"];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        FSJob *job  = [[[FSJob alloc] init] autorelease];
        job.jobID       = [results intForColumn:@"job_id"];
        job.jobName     = [results stringForColumn:@"job_name"];
        job.jobArchived = [results intForColumn:@"job_archived"];
        
        [arrJobList addObject:job];
    }
    return arrJobList;
}

- (BOOL)isExistSameJob:(NSString *)jobName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS samecount  FROM tbl_job WHERE deleted = 0 and job_name = '%@'", jobName];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        int count       = [results intForColumn:@"samecount"];
        if (count > 0)
            return YES;
        return NO;
    }
    return NO;
}

- (FSJob *)getJobFromID:(long)jobID
{
    FSJob *job = [[FSJob alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_job WHERE deleted = 0 and job_id = %ld", (long)jobID]];
    while ([results next]) {
        job.jobID = [results intForColumn:@"job_id"];
        job.jobName = [results stringForColumn:@"job_name"];
        job.jobArchived = [results intForColumn:@"job_archived"];
        return job;
    }
    return nil;
}

- (int)addJobToDatabase:(FSJob *)job
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_job (job_archived, job_name, deleted) VALUES (%ld, '%@', 0)",(long)job.jobArchived, job.jobName];
    int retId = 0;
    if ([_database executeUpdate:sql])
    {
        retId = (int)[_database lastInsertRowId];
        return retId;
    }
    return 0;
}

- (void)updateJobToDatabase:(FSJob *)job
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"UPDATE tbl_job SET job_archived = %ld , job_name = '%@' WHERE job_id = %ld", (long)job.jobArchived, job.jobName, job.jobID];
    [_database executeUpdate:sql];
}

- (void)deleteJobFromDatabase:(FSJob *)job
{
    NSString *sql;
    //sql = [NSString stringWithFormat:@"DELETE FROM tbl_job WHERE job_id = %ld", job.jobID];
    sql = [NSString stringWithFormat:@"UPDATE tbl_job SET deleted = 1 WHERE job_id = %ld", job.jobID];
    [_database executeUpdate:sql];
}


#pragma mark - location

- (NSMutableArray *)getLocations:(long)jobID
{
    NSMutableArray *arrLocList = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tbl_location WHERE deleted = 0 and location_jobid  = %ld and location_name != '%@' ", jobID, FMD_DEFAULT_LOCATIONNAME];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        FSLocation *loc  = [[[FSLocation alloc] init] autorelease];
        loc.locID       = [results intForColumn:@"location_id"];
        loc.locJobID    = [results intForColumn:@"location_jobid"];
        loc.locName     = [results stringForColumn:@"location_name"];
        [arrLocList addObject:loc];
    }
    return arrLocList;
}

- (NSMutableArray *)getLocations:(long)jobID containDefault:(BOOL) isContain
{
    NSMutableArray *arrLocList = [[NSMutableArray alloc] init];
    NSString *sql = @"";
    if (isContain)
        sql = [NSString stringWithFormat:@"SELECT * FROM tbl_location WHERE deleted = 0 and location_jobid  = %ld", jobID];
    else
        sql = [NSString stringWithFormat:@"SELECT * FROM tbl_location WHERE deleted = 0 and location_jobid  = %ld and location_name != '%@' ", jobID, FMD_DEFAULT_LOCATIONNAME];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        FSLocation *loc  = [[[FSLocation alloc] init] autorelease];
        loc.locID       = [results intForColumn:@"location_id"];
        loc.locJobID    = [results intForColumn:@"location_jobid"];
        loc.locName     = [results stringForColumn:@"location_name"];
        [arrLocList addObject:loc];
    }
    return arrLocList;
}

- (BOOL)isExistSameLocation:(long)jobID locName:(NSString *)locName
{
    NSString *sql = @"";
    sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS samecount FROM tbl_location WHERE deleted = 0 and location_jobid  = %ld and location_name = '%@'", jobID, locName];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        int count       = [results intForColumn:@"samecount"];
        if (count > 0)
            return YES;
        return NO;
    }
    return NO;
}

- (FSLocation *)getLocation:(long)jobID locName:(NSString *)locName
{
    NSString *sql = @"";
    sql = [NSString stringWithFormat:@"SELECT * FROM tbl_location WHERE deleted = 0 and location_jobid  = %ld and location_name = '%@'", jobID, locName];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        FSLocation *loc  = [[[FSLocation alloc] init] autorelease];
        loc.locID       = [results intForColumn:@"location_id"];
        loc.locJobID    = [results intForColumn:@"location_jobid"];
        loc.locName     = [results stringForColumn:@"location_name"];
        return loc;
    }
    return nil;
}

- (FSLocation *)getLocationFromID:(long)locID
{
    FSLocation *loc = [[FSLocation alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_location WHERE deleted = 0 and location_id = %ld", locID]];
    while ([results next]) {
        loc.locID = [results intForColumn:@"location_id"];
        loc.locJobID = [results intForColumn:@"location_jobid"];
        loc.locName = [results stringForColumn:@"location_name"];
        return loc;
    }
    return nil;
}

- (int)addLocationToDatabase:(FSLocation *)loc
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_location (location_jobid, location_name, deleted) VALUES (%ld, '%@', 0)", loc.locJobID, loc.locName];
    if([_database executeUpdate:sql])
        return (int)[_database lastInsertRowId];
    return 0;
}

- (void)updateLocToDatabase:(FSLocation *)loc
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"UPDATE tbl_location SET location_name = '%@' WHERE location_id = %ld", loc.locName, loc.locID];
    [_database executeUpdate:sql];
}

- (void)deleteLocFromDatabase:(FSLocation *)loc
{
    NSString *sql;
    //sql = [NSString stringWithFormat:@"DELETE FROM tbl_location WHERE location_id = '%@'", loc.locID];
    sql = [NSString stringWithFormat:@"UPDATE tbl_location SET deleted = 1 WHERE location_id = %ld", loc.locID];
    [_database executeUpdate:sql];
}

- (FSLocation *)getDefaultLocationOfJob:(long)jobID
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tbl_location WHERE deleted = 0 and location_jobid  = %ld and location_name = '%@'", jobID, FMD_DEFAULT_LOCATIONNAME];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        FSLocation *loc  = [[[FSLocation alloc] init] autorelease];
        loc.locID       = [results intForColumn:@"location_id"];
        loc.locJobID    = [results intForColumn:@"location_jobid"];
        loc.locName     = [results stringForColumn:@"location_name"];
        return loc;
    }
    return nil;
}

- (NSMutableArray *)getAllDistinctLocations
{
    NSMutableArray *arrayResults = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT(location_name) AS location_name FROM tbl_location WHERE deleted = 0"];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        FSLocation *loc  = [[[FSLocation alloc] init] autorelease];
        loc.locID = 0;
        loc.locJobID = 0;
        loc.locName     = [results stringForColumn:@"location_name"];
        [arrayResults addObject:loc];
    }

    return arrayResults;
}

#pragma mark - product
- (NSMutableArray *)getAllProducts
{
    NSMutableArray *arrProductList = [[NSMutableArray alloc] init];
    FMResultSet *results = [_database executeQuery:@"SELECT * FROM tbl_product WHERE deleted = 0"];
    while ([results next]) {
        
        FSProduct *product  = [[[FSProduct alloc] init] autorelease];
        product.productID = [results intForColumn:@"product_id"];
        product.productName = [results stringForColumn:@"product_name"];
        product.productType = [results intForColumn:@"product_type"];
        product.productDeleted = [results intForColumn:@"deleted"];
        
        [arrProductList addObject:product];
    }
    return arrProductList;
}

- (NSMutableArray *)getProducts:(NSString *)searchField
{
    NSMutableArray *arrProductList = [[NSMutableArray alloc] init];
    if (searchField == nil)
        searchField = @"";
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_product WHERE deleted = 0 and product_name like %@%@%@", @"'%", searchField, @"%'"]];
    while ([results next]) {
        
        FSProduct *product  = [[[FSProduct alloc] init] autorelease];
        product.productID = [results intForColumn:@"product_id"];
        product.productName = [results stringForColumn:@"product_name"];
        product.productType = [results intForColumn:@"product_type"];
        product.productDeleted = [results intForColumn:@"deleted"];
        
        [arrProductList addObject:product];
    }
    return arrProductList;
}

- (BOOL)isExistSameProduct:(NSString *)productName productType:(long)productType
{
    NSString *sql = @"";
    sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS samecount FROM tbl_product WHERE deleted = 0 and product_type = %ld and product_name = '%@'", productType, productName];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        int count       = [results intForColumn:@"samecount"];
        if (count > 0)
            return YES;
        return NO;
    }
    return NO;
}

- (FSProduct *)getProductFromID:(long)procID
{
    FSProduct *product = [[FSProduct alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_product WHERE deleted = 0 AND product_id = %ld", procID]];
    while ([results next]) {
        product.productID = [results intForColumn:@"product_id"];
        product.productName = [results stringForColumn:@"product_name"];
        product.productType = [results intForColumn:@"product_type"];
        product.productDeleted = [results intForColumn:@"deleted"];
        return product;
    }
    return nil;
}

- (int)addProductToDatabase:(FSProduct *)product
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_product (product_name, product_type, deleted) VALUES ('%@', %ld, 0)", product.productName, product.productType];
    if ([_database executeUpdate:sql])
        return (int)[_database lastInsertRowId];
    return 0;
}

- (void)updateProductToDatabase:(FSProduct *)product
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"UPDATE tbl_product SET product_name = '%@', product_type = %ld WHERE product_id = %ld", product.productName, product.productType, product.productID];
    [_database executeUpdate:sql];
}

- (void)deleteProductFromDatabase:(FSProduct *)product
{
    NSString *sql;
    //sql = [NSString stringWithFormat:@"DELETE FROM tbl_product WHERE product_id = '%@'", product.productID];
    sql = [NSString stringWithFormat:@"UPDATE tbl_product SET deleted = 1 WHERE product_id = %ld", product.productID];
    [_database executeUpdate:sql];
}

- (FSProduct *)getProductWithLocProduct:(FSLocProduct *)locProduct
{
    FSProduct *product = [[FSProduct alloc] init];
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_product WHERE deleted = 0 AND product_name = '%@' and product_type = %ld", locProduct.locProductName, locProduct.locProductType]];
    while ([results next]) {
        product.productID = [results intForColumn:@"product_id"];
        product.productName = [results stringForColumn:@"product_name"];
        product.productType = [results intForColumn:@"product_type"];
        product.productDeleted = [results intForColumn:@"deleted"];
        return product;
    }
    return nil;
}

#pragma mark - Products for specific Locations

- (NSMutableArray *)getLocProducts:(FSLocation *)loc searchField:(NSString *)searchField
{
    NSMutableArray *arrLocProductList = [[NSMutableArray alloc] init];
    if (searchField == nil)
        searchField = @"";
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_locproduct WHERE deleted = 0 AND locproduct_locid = %ld AND locproduct_productname like %@%@%@ and locproduct_productname != '%@'", loc.locID, @"'%", searchField, @"%'", FMD_DEFAULT_PRODUCTNAME]];
    while ([results next]) {
        
        FSLocProduct *locProduct  = [[[FSLocProduct alloc] init] autorelease];
        locProduct.locProductID = [results intForColumn:@"locproduct_id"];
        locProduct.locProductLocID = [results intForColumn:@"locproduct_locid"];
        locProduct.locProductName = [results stringForColumn:@"locproduct_productname"];
        locProduct.locProductType = [results intForColumn:@"locproduct_producttype"];
        locProduct.locProductCoverage = [results doubleForColumn:@"locproduct_coverage"];
        
        [arrLocProductList addObject:locProduct];
    }
    return arrLocProductList;
}

- (NSMutableArray *)getLocProducts:(FSLocation *)loc searchField:(NSString *)searchField containDefault:(BOOL) isContain
{
    NSMutableArray *arrLocProductList = [[NSMutableArray alloc] init];
    if (searchField == nil)
        searchField = @"";
    
    NSString *sql = @"";
    if (isContain == YES)
        sql = [NSString stringWithFormat:@"SELECT * FROM tbl_locproduct WHERE deleted = 0 AND locproduct_locid = %ld AND locproduct_productname like %@%@%@", loc.locID, @"'%", searchField, @"%'"];
    else
        sql = [NSString stringWithFormat:@"SELECT * FROM tbl_locproduct WHERE deleted = 0 AND locproduct_locid = %ld AND locproduct_productname like %@%@%@ and locproduct_productname != '%@'", loc.locID, @"'%", searchField, @"%'", FMD_DEFAULT_PRODUCTNAME];
    
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        
        FSLocProduct *locProduct  = [[[FSLocProduct alloc] init] autorelease];
        locProduct.locProductID = [results intForColumn:@"locproduct_id"];
        locProduct.locProductLocID = [results intForColumn:@"locproduct_locid"];
        locProduct.locProductName = [results stringForColumn:@"locproduct_productname"];
        locProduct.locProductType = [results intForColumn:@"locproduct_producttype"];
        locProduct.locProductCoverage = [results doubleForColumn:@"locproduct_coverage"];
        
        [arrLocProductList addObject:locProduct];
    }
    return arrLocProductList;
}

- (BOOL)isExistSameLocProduct:(long)locID locProductName:(NSString *)locProductName locProductType:(long)locProductType
{
    NSString *sql = @"";
    sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS samecount FROM tbl_locproduct WHERE deleted = 0 and locproduct_locid = %ld and locproduct_producttype = %ld and locproduct_productname = '%@'", locID, locProductType, locProductName];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        int count       = [results intForColumn:@"samecount"];
        if (count > 0)
            return YES;
        return NO;
    }
    return NO;
}

- (FSLocProduct *)getLocProductWithID:(long)locProductID
{
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_locproduct WHERE deleted = 0 AND locproduct_id = %ld", locProductID]];
    while ([results next]) {
        
        FSLocProduct *locProduct  = [[[FSLocProduct alloc] init] autorelease];
        locProduct.locProductID = [results intForColumn:@"locproduct_id"];
        locProduct.locProductLocID = [results intForColumn:@"locproduct_locid"];
        locProduct.locProductName = [results stringForColumn:@"locproduct_productname"];
        locProduct.locProductType = [results intForColumn:@"locproduct_producttype"];
        locProduct.locProductCoverage = [results doubleForColumn:@"locproduct_coverage"];
        
        return locProduct;
    }
    return nil;
}

- (FSLocProduct *)getDefaultLocProductOfLocation:(FSLocation *)loc
{
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_locproduct WHERE deleted = 0 AND locproduct_locid = %ld AND locproduct_productname = '%@'", loc.locID, FMD_DEFAULT_PRODUCTNAME]];
    while ([results next]) {
        
        FSLocProduct *locProduct  = [[[FSLocProduct alloc] init] autorelease];
        locProduct.locProductID = [results intForColumn:@"locproduct_id"];
        locProduct.locProductLocID = [results intForColumn:@"locproduct_locid"];
        locProduct.locProductName = [results stringForColumn:@"locproduct_productname"];
        locProduct.locProductType = [results intForColumn:@"locproduct_producttype"];
        locProduct.locProductCoverage = [results doubleForColumn:@"locproduct_coverage"];
        
        return locProduct;
    }
    return nil;
}

- (FSLocProduct *)getLocProductWithProduct:(FSProduct *)product locID:(long)locID
{
    FMResultSet *results = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_locproduct WHERE deleted = 0 AND locproduct_locid = %ld AND locproduct_productname = '%@' AND locproduct_producttype = %ld", locID, product.productName, product.productType]];
    while ([results next]) {
        
        FSLocProduct *locProduct  = [[[FSLocProduct alloc] init] autorelease];
        locProduct.locProductID = [results intForColumn:@"locproduct_id"];
        locProduct.locProductLocID = [results intForColumn:@"locproduct_locid"];
        locProduct.locProductName = [results stringForColumn:@"locproduct_productname"];
        locProduct.locProductType = [results intForColumn:@"locproduct_producttype"];
        locProduct.locProductCoverage = [results doubleForColumn:@"locproduct_coverage"];
        
        return locProduct;
    }
    return nil;
}

- (int)addLocProductToDatabaseWithProduct:(FSProduct *)product locID:(long)locID coverage:(double)coverage
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_locproduct (locproduct_locid, locproduct_productname, locproduct_producttype, locproduct_coverage, deleted) VALUES (%ld, '%@', %ld, %f, 0)", locID, product.productName, product.productType, coverage];
    if ([_database executeUpdate:sql])
        return (int)[_database lastInsertRowId];
    return 0;
}

- (int)addLocProductToDatabase:(FSLocProduct *)locProduct
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_locproduct (locproduct_locid, locproduct_productname, locproduct_producttype, locproduct_coverage, deleted) VALUES (%ld, '%@', %ld, %f, 0)", locProduct.locProductLocID, locProduct.locProductName, locProduct.locProductType, locProduct.locProductCoverage];
    if ([_database executeUpdate:sql])
        return (int)[_database lastInsertRowId];
    return 0;
}

- (BOOL)updateLocProductToDatabase:(FSLocProduct *)locProduct
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"UPDATE tbl_locproduct SET locproduct_locid = %ld, locproduct_productname = '%@', locproduct_producttype = %ld, locproduct_coverage = %f WHERE locproduct_id = %ld", locProduct.locProductLocID, locProduct.locProductName, locProduct.locProductType, locProduct.locProductCoverage, locProduct.locProductID];
    return [_database executeUpdate:sql];
}

- (BOOL)deleteLocProductFromDatabase:(FSLocProduct *)locProduct
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"UPDATE tbl_locproduct SET deleted = 1 WHERE locproduct_id = %ld", locProduct.locProductID];
    return [_database executeUpdate:sql];
}

#pragma mark - Readings
- (NSMutableArray *)getCurReadings:(long)locProductID
{
    /*
     read_locproductid
     read_date
     read_uuid
     read_rh
     read_convrh
     read_temp
     read_convtemp
     read_battery
     read_depth
     read_gravity
     read_material
     read_mc
     deleted
*/
    NSMutableArray *arrReadingsList = [[NSMutableArray alloc] init];
    NSDate *curDate = [NSDate date];
    return [self getReadings:locProductID withDate:curDate];
}

- (NSMutableArray *)getAllReadingDates:(long)locProductID
{
    NSMutableArray *arrDates = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT(SUBSTR(read_date, 1, 10)) as read_date FROM tbl_reading WHERE read_locproductid = %ld ORDER BY read_date ASC", locProductID];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        NSString *strDateOnly = [[results stringForColumn:@"read_date"] substringToIndex:10];
        NSDate *date = [CommonMethods str2date:strDateOnly withFormat:DATE_FORMAT];
        [arrDates addObject:date];
    }
    return arrDates;
}

- (NSMutableArray *)getReadings:(long)locProductID withDate:(NSDate *)date
{
    NSMutableArray *arrReadingsList = [[NSMutableArray alloc] init];
    NSString *strDate = [CommonMethods date2str:date withFormat:DATE_FORMAT];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tbl_reading WHERE deleted = 0 AND  read_locproductid = %ld AND SUBSTR(read_date, 1, 10) = '%@'", locProductID, strDate];
    FMResultSet *results = [_database executeQuery:sql];
    while ([results next]) {
        FSReading *reading = [[FSReading alloc] init];
        reading.readID = [results longForColumn:@"read_id"];
        reading.readLocProductID = [results longForColumn:@"read_locproductid"];
        reading.readTimestamp = [CommonMethods str2date:[results stringForColumn:@"read_date"] withFormat:DATETIME_FORMAT];
        reading.readUuid = [results stringForColumn:@"read_uuid"];
        reading.readRH = [results longForColumn:@"read_rh"];
        reading.readConvRH = [results doubleForColumn:@"read_convrh"];
        reading.readTemp = [results longForColumn:@"read_temp"];
        reading.readConvTemp = [results doubleForColumn:@"read_convtemp"];
        reading.readBattery = [results longForColumn:@"read_battery"];
        reading.readDepth = [results longForColumn:@"read_depth"];
        reading.readGravity = [results longForColumn:@"read_gravity"];
        reading.readMaterial = [results longForColumn:@"read_material"];
        reading.readMC = [results longForColumn:@"read_mc"];
        [arrReadingsList addObject:reading];
    }
    return arrReadingsList;
}

- (NSInteger)getReadingsCount:(long)locProductID
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT count(*) FROM tbl_reading WHERE deleted = 0 AND read_locproductid = %ld", locProductID];
    FMResultSet *results = [_database executeQuery:sql];
    
    while ([results next]) {
        return [results intForColumn:@"count(*)"];
    }
    return 0;
}

- (int)addReadingToDatabase:(FSReading *)reading
{
    /*
     read_locproductid
     read_date
     read_uuid
     read_rh
     read_convrh
     read_temp
     read_convtemp
     read_battery
     read_depth
     read_gravity
     read_material
     read_mc
     deleted
     */
    
    NSString *sql;
    sql = [NSString stringWithFormat:@"INSERT INTO tbl_reading (read_locproductid, read_date, read_uuid, read_rh, read_convrh, read_temp, read_convtemp, read_battery, read_depth, read_gravity, read_material, read_mc, deleted) VALUES (%ld, '%@', '%@', %ld, %f, %ld, %f, %ld, %ld, %ld, %ld, %ld, 0)", reading.readLocProductID, [CommonMethods date2str:reading.readTimestamp withFormat:DATETIME_FORMAT], reading.readUuid, reading.readRH, reading.readConvRH, reading.readTemp, reading.readConvTemp, reading.readBattery, reading.readDepth, reading.readGravity, reading.readMaterial, reading.readMC];
    if ([_database executeUpdate:sql])
        return (int)[_database lastInsertRowId];
    return 0;
}

- (BOOL)updateReadingToDatabase:(FSReading *)reading
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"UPDATE tbl_reading set read_locproductid = %ld, read_date = '%@', read_uuid = '%@', read_rh = %ld, read_convrh = %f, read_temp = %ld, read_convtemp = %f, read_battery = %ld, read_depth = %ld, read_gravity = %ld, read_material = %ld, read_mc = %ld", reading.readLocProductID, [CommonMethods date2str:reading.readTimestamp withFormat:DATETIME_FORMAT], reading.readUuid, reading.readRH, reading.readConvRH, reading.readTemp, reading.readConvTemp, reading.readBattery, reading.readDepth, reading.readGravity, reading.readMaterial, reading.readMC];
    return [_database executeUpdate:sql];
}

- (BOOL)deleteReadingFromDatabase:(FSReading *)reading
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"UPDATE tbl_reading SET deleted = 1 WHERE read_id = %ld", reading.readID];
    return [_database executeUpdate:sql];
}


#pragma mark - life cycle
- (void)dealloc
{
    [_database close];
    [_database release];

    [super dealloc];
}

@end
