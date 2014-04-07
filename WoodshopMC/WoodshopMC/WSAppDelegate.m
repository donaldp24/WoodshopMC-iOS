//
//  WSAppDelegate.m
//  WoodshopMC
//
//  Created by Donald Pae on 4/7/14.
//  Copyright (c) 2014 damy. All rights reserved.
//

#import "WSAppDelegate.h"
#import "Global.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation WSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
#ifdef TESTFLIGHT_ENABLED
    [TestFlight takeOff:@"61967d35-dba9-49ca-8dcd-412bf6f1339e"];
#endif
    
    [[GlobalData sharedData] loadInitData];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [WSMainViewController sharedController];
    [self.window setRootViewController:self.viewController];
    [self.window makeKeyAndVisible];
    
    AudioSessionInitialize (NULL, NULL, NULL, NULL);
    //UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;
    //AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (sessionCategory), &sessionCategory);
    AudioSessionSetActive (true);
    
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