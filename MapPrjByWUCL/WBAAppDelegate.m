//
//  WBAAppDelegate.m
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-10.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import "WBAAppDelegate.h"
#import "LoadViewController.h"

@implementation WBAAppDelegate
@synthesize viewController;
@synthesize mapView,identifyFlag,NETWORKABLE;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    initConfig();
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
 
    self.viewController = [[LoadViewController alloc] initWithNibName:@"LoadViewController"bundle:nil];
    
    // warning: addSubView doesn't work on iOS6
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        [self.window addSubview: viewController.view];
    }
    else
    {
        [self.window setRootViewController:viewController];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

void initConfig()
{
	NSUserDefaults *defal = [NSUserDefaults standardUserDefaults];
	NSString *tmp = [defal stringForKey:@"WebServiceServiceIP"];
    NSLog(@"%@",tmp);
	if (nil==tmp) {
		NSString *settingBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
		NSLog(@"%@",settingBundle);
        
		NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingBundle stringByAppendingPathComponent:@"Root.plist"]];
		
		NSArray *preference = [settings objectForKey:@"PreferenceSpecifiers"];
		NSLog(@"%d",preference.count);
        
		NSMutableDictionary *defaultToRegister = [[NSMutableDictionary alloc]initWithCapacity:[preference count]];
		
		for(NSDictionary *prefSpecification in preference)
		{
			NSString *key = [prefSpecification objectForKey:@"Key"];
            NSLog(@"%@",key);
			if(key)
			{
				[defaultToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
			}
		}
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultToRegister];
		
		[defaultToRegister release];
        
	}
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
    // Saves changes in the application's managed object context before the application terminates.
}
@end
