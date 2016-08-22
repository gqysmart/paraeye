//
//  WBAAppDelegate.h
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-10.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadViewController.h"
#import <ArcGIS/ArcGIS.h>

@interface WBAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property bool identifyFlag;
@property bool NETWORKABLE;
@property bool BLUETOOTHABLE;//蓝牙是否已经成功订阅
@property (nonatomic,retain)  LoadViewController *viewController;
@end
