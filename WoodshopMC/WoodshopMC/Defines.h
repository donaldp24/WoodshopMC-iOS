//
//  Defines.h
//  BlueToothTest
//
//  Created by konstm on 20/05/2013.
//  Copyright (c) 2013 KTTSoft. All rights reserved.
//

#ifndef BlueToothTest_Defines_h
#define BlueToothTest_Defines_h

//#define BLUETOOTH_SERVICE_UUID           @"00D9797F-04E4-4502-90BC-B01E8071E53B"
//#define BLUETOOTH_CHARACTERISTIC_UUID    @"71D8150E-6755-4E69-8B3D-0CD3C9FF76C0"
#define BLUETOOTH_SERVICE_UUID           @"23DE405A-8493-A2B5-D232-80C32939BE23"
#define BLUETOOTH_CHARACTERISTIC_UUID    @"6C2332B3-2389-D344-3280-A923715BD357"

#define END_OF_DATA @"<EOD>"

#define MODE_JOBMANAGEMENT  0
#define MODE_RECORD         1
#define MODE_REVIEW         2
#define MODE_PRODUCTMANAGEMENT  3

#define CHECK_JOB_DUPLICATE     1
#define CHECK_LOC_DUPLICATE     1
#define CHECK_PRODUCT_DUPLICATE 1
#define CHECK_LOCPRODUCT_DUPLICATE  1

typedef struct AdvertisementPackage{
    UInt32 uuid;//uuid to identify the messages
    UInt16 S1RH;//Sensor 1 RH reading – SHT25A
    UInt16 S1T;//Sensor 1 Temperature reading
    UInt16 SMC;
    UInt8 S2SN[12];//Sensor 2 Serial Number string representation of the 6 bytes in hex
    UInt8 Batt;//batery level
} AdvertisementPackage;

typedef struct AdvertisementDetailPackage{
    UInt32 uuid;//uuid to identify the messages
    UInt16 MAT;//Sensor 1 RH reading – SHT25A
    UInt16 SG;//Sensor 1 Temperature reading
    UInt8 MODE[3];
    UInt8 S2SN[12];//Sensor 2 Serial Number string representation of the 6 bytes in hex
    UInt8 Batt;//batery level
} AdvertisementDetailPackage;

#endif
