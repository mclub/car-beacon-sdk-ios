//
//  CRBDemoScanTableViewController.m
//  CarBeaconDemo
//
//  Created by Shawn Chain on 14-4-25.
//  Copyright (c) 2014年 JoyLabs. All rights reserved.
//

#import "CRBDemoScanViewController.h"
#import <CarBeaconSDK/JLCarBeaconSDK.h>

@interface CRBDemoScanViewController ()

@property(nonatomic,strong) NSMutableArray *foundDevices;
@property(nonatomic,strong) JLCBDeviceManager *deviceManager;
@end

@implementation CRBDemoScanViewController

- (id)init{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self = [super initWithNibName:@"CRBDemoScanViewController_iPad" bundle:nil];
    }else{
        self = [super initWithNibName:@"CRBDemoScanViewController" bundle:nil];
    }
    
    if(self){
        // custom initialization;
        self.foundDevices = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"查找设备";
    
    self.deviceManager = [[[JLCBDeviceManager alloc] init] autorelease];
    [self.deviceManager startScanDevices:^(JLCBDevice *device) {
        if(device){
            [self.foundDevices addObject:device];
            [self.tableView reloadData];
        }else{
            // null device return means scan complete
            [self.deviceManager stopScanDevices];
        }
    } scanTimeoutSeconds:@30 /*by default will be 30s*/];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.deviceManager stopScanDevices];
}

-(void)dealloc{
    self.deviceManager = nil;
    self.foundDevices = nil;
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.foundDevices.count > 0 ?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.foundDevices.count;
}


#define DEVICE_CELL_ID @"deviceTableCell"
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= self.foundDevices.count){
        return nil;
    }


    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DEVICE_CELL_ID] autorelease];
    
    // Configure the cell...
    JLCBDevice *d = ((JLCBDevice*)[self.foundDevices objectAtIndex:indexPath.row]);
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%.0f)",d.name,d.rssi.floatValue];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= self.foundDevices.count){
        return;
    }
    
    JLCBDevice *d = ((JLCBDevice*)[self.foundDevices objectAtIndex:indexPath.row]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JLCBDevice_Found" object:d userInfo:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
