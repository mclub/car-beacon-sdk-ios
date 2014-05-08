//
//  CRBDemoAppDelegate.m
//  CarBeaconDemo
//
//  Created by Shawn Chain on 14-3-12.
//  Copyright (c) 2014年 JoyLabs. All rights reserved.
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


#import "CRBDemoAppDelegate.h"
#import "CRBDemoMainViewController.h"

#import <CarBeaconSDK/JLCarBeaconSDK.h>


@implementation CRBDemoAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

typedef unsigned char uint8;

void merge_sort(uint8 *list, uint8 length){
	uint8 i, left_min, left_max, right_min, right_max, next;
	uint8 *tmp = (uint8*)malloc(sizeof(uint8) * length);
	if (tmp == NULL){
		fputs("Error: out of memory\n", stderr);
		abort();
	}
	for (i = 1; i < length; i *= 2){
		for (left_min = 0; left_min < length - i; left_min = right_max){
			right_min = left_max = left_min + i;
			right_max = left_max + i;
			if (right_max > length)
				right_max = length;
			next = 0;
			while (left_min < left_max && right_min < right_max)
				tmp[next++] = list[left_min] > list[right_min] ? list[right_min++] : list[left_min++];
			while (left_min < left_max)
				list[--right_min] = list[--left_max];
			while (next > 0)
				list[--right_min] = tmp[--next];
		}
    }
	free(tmp);
}


void bubble_sort(uint8 *list, uint8 length){
    for (uint8 i = 0; i < length; i++) {
        for (uint8 j = length - 1; j > i; j--) {
            if (list[j] < list[j-1]) {
                uint8 tmp = list[j-1];
                list[j-1] =  list[j];
                list[j] = tmp;
            }
        }
    }
}

#define osal_mem_alloc(x) malloc(x)
#define osal_mem_free(x) free(x)

void sort_and_merge(uint8 *list1, uint8 length1, uint8 *list2, uint8 length2, uint8 *merged, uint8 *mergedLength){
    bubble_sort(list1,length1);
    bubble_sort(list2,length2);
    
    int i, j, k;

    i = j = k = 0;
    while(i<length1 && j < length2){
        // remove duplicated in one list, assume lists are sorted
        while(i < length1 - 1 && list1[i] == list1[i+1]){
            i++;
        }
        while(j < length2 - 1 && list2[j] == list2[j+1]){
            j++;
        }
        // compare and merge to another
        if(list1[i] < list2[j]){
            merged[k++] = list1[i++];
        }else if(list1[i] > list2[j]){
            merged[k++] = list2[j++];
        }else{
            merged[k++] = list1[i++];
            j++;
        }
    }
    while(i < length1){
        while(i < length1 - 1 && list1[i] == list1[i+1]){
            i++;
        }
        merged[k++] =  list1[i++];
        
    }
    while(j < length2){
        while(j < length2 - 1 && list2[j] == list2[j+1]){
            j++;
        }
        merged[k++] = list2[j++];
    }
    
    *mergedLength = k;
    
}

void print_list(uint8 *list, uint8 length){
    for(int i = 0;i < length;i++){
        printf("%d,",*(list + i));
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    JLCarBeaconSDK *sdk = [[JLCarBeaconSDK alloc] init];
//    NSLog(@"%@",sdk);
    /*
    uint8 list1[] = {1,2,2,2};
    uint8 list2[] = {1};
    
    uint8 len1 = sizeof(list1) / sizeof(list1[0]);
    uint8 len2 = sizeof(list2) / sizeof(list2[0]);
    bubble_sort(list1,len1);
    merge_sort(list2,len2);
    print_list(list1,len1);
    print_list(list2,len2);
    
    uint8 *merged = (uint8*)osal_mem_alloc(len1 + len2);
    uint8 mergedLen = 0;
    sort_and_merge(list1,len1,list2,len2,merged,&mergedLen);
    
    print_list(merged,mergedLen);
    osal_mem_free(merged);
    */
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    CRBDemoMainViewController *main = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        main = [[[CRBDemoMainViewController alloc] initWithNibName:@"CRBDemoMainViewController_iPad" bundle:nil] autorelease];
    }else{
        main = [[[CRBDemoMainViewController alloc] initWithNibName:@"CRBDemoMainViewController" bundle:nil] autorelease];        
    }
    UINavigationController *navi = [[[UINavigationController alloc] initWithRootViewController:main] autorelease];
    self.window.rootViewController = navi;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
