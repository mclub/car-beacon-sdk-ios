//
//  CRBOADService.h
//  CarBeaconDemo
//
//  Created by Shawn Chain on 14-3-13.
//  Copyright (c) 2014年 JoyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "JLCBDevice.h"

//////////////////////////////////////////////////////////////////////////
/*
 * FirmwareRelease
 */
@interface JLCBFirmwareReleaseInfo : NSObject

@property(strong,readonly) NSString *version;
@property(strong,readonly) NSDate   *date;
@property(strong,readonly) NSString *notes;

@end

// Error codes
extern NSString *kJLCBFWErrorDomain;
extern int const kJLCBFWErrorCodeNotUpdated;
extern int const kJLCBFWErrorCodeTimeout;
extern int const kJLCBFWErrorCodeUserCancel;
extern int const kJLCBFWErrorCodeNotFound;
extern int const kJLCBFWErrorIllegalState;

// Firmware download/update completion handler
typedef void (^JLCBFirmwareReleaseInfoHandler)(JLCBFirmwareReleaseInfo *releaseInfo, NSError *error);

typedef void (^JLCBFirmwareDownloadProgressHandler)(int bytesDownloaded, int bytesTotal);
typedef void (^JLCBFirmwareDownloadCompletionHandler)(NSData *data, NSError *error);

typedef void (^JLCBFirmwareUpdateProgressHandler)(int bytesSent, int bytesTotal);
typedef void (^JLCBFirmwareUpdateCompletionHandler)(id data, NSError *error);


////////////////////////////////////////////////////////////////////////////////////////
/*
 * CarBeacon Device firmware operations
 */
@interface JLCBDevice(JLCBFirmware)

/*
 * check whether device supports firmware update.
 */
-(BOOL)canUpdateFirmware;

/*
 * update firmware
 */
- (void)updateFirmwareWithImageData:(NSData*)data
                        forceUpdate:(BOOL)forceUpdate
                         fastUpdate:(BOOL)fastUpdate
                  completionHandler:(JLCBFirmwareUpdateCompletionHandler)completionHandler
                    progressHandler:(JLCBFirmwareUpdateProgressHandler)progressHandler;

/*
 * Check firmware update
 * @discussion the callback will be called with an object of JLCBFirmwareReleaseInfo or null if no updates
 */
-(void)checkFirmwareRelease:(JLCBFirmwareReleaseInfoHandler)completionHandler;

/*
 * Download the firmware release
 */
-(void)downloadFirmwareRelease:(JLCBFirmwareReleaseInfo*)release
             completionHandler:(JLCBFirmwareDownloadCompletionHandler)completionHandler
               progressHandler:(JLCBFirmwareDownloadProgressHandler)progressHandler;
@end