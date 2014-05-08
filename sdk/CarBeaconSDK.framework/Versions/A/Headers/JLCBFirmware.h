//
//  CRBOADService.h
//  CarBeaconDemo
//
//  Created by Shawn Chain on 14-3-13.
//  Copyright (c) 2014年 JoyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


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

