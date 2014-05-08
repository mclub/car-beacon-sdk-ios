//
//  CarBeacon SDK
//
//  Created by Shawn Chain on 14-3-12.
//  Copyright (c) 2014 Shawn Chain. All rights reserved.
//
//  shawn.chain@gmail.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

/*
 * Base data object
 */
@interface JLCBData : NSObject

@end

/*
 * OBD data object, base class
 */
@interface JLCBOBDData : JLCBData

@end

/*
 * Engine data object
 */
@interface JLCBEngineData : JLCBOBDData

@property(readonly) float rpm;
@property(readonly) float engineLoad;
@property(readonly) float coolantTemperature;

@property(readonly) float vehicleSpeed;

@property(readonly) float throttlePosition;
@property(readonly) float engineRuntime;

@end

/*
 * Fuel data
 */
@interface JLCBFuelData : JLCBOBDData

@property(readonly) float fuelLevel;
@property(readonly) float vehicleSpeed;
@property(readonly) float distanceSinceLastMIL;
@property(readonly) float estimatedFuelRate;
@property(readonly) float fuelRate;

+(float) calculateEstimatedFuelRate:(float) speed maf:(float)maf rat:(float)rat  fuelLevel:(float)fuelLevel;
@end

/*
 * DeviceInfo
 *@discussion read from the firmware, standard GATT service.
 */
@interface JLCBDeviceInfo : JLCBData

@property(readonly) NSString *systemId;
@property(readonly) NSString *modelNumber;
@property(readonly) NSString *serialNumber;
@property(readonly) NSString *firmwareRev;
@property(readonly) NSString *hardwareRev;
@property(readonly) NSString *softwareRev;
@property(readonly) NSString *manufacturerName;

@property(readonly) NSString *firmwareFileName;

@end



/*
 * Base data handle block
 */
typedef void (^JLCBDataHandler)(JLCBData* dataObject);

/*
 * Engine data handle block
 */
typedef void (^JLCBEngineDataHandler)(JLCBEngineData* engineData);

/*
 * Fuel data handle block
 */
typedef void (^JLCBFuelDataHandler)(JLCBFuelData* fuelData);

/*
 * DeviceInfo data handle block
 */
typedef void (^JLCBDeviceInfoHandler)(JLCBDeviceInfo* deviceInfo);


/*
 * JLCBDataUpdateFrequency
 *
 * @discussion 
 * To save enerty and avoid excessive access to the CAN bus, please choose the FAST or NORMAL frequency.
 * SLOW mode will update every 15s, NORMAL will be 5s, FAST will be 1s.
 * The BEST mode is used for real time data monitoring
 *
 */
typedef enum{
    JLCBDataUpdateFrequency_BEST = 0,   // crazy
    JLCBDataUpdateFrequency_FAST,       // about every 1s
    JLCBDataUpdateFrequency_NORMAL,     // about every 5s
    JLCBDataUpdateFrequency_SLOW        // about every 15s
} JLCBDataUpdateFrequency;

/*
 * error code
 */
extern NSString *kJLCBErrorDomain;
extern int const kJLCBErrorCodeTimeout;
extern int const kJLCBErrorCodeUserCancel;
extern int const kJLCBErrorCodeServiceNotFound;
extern int const kJLCBErrorCodePowerOff;
