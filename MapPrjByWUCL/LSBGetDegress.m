//
//  LSBGetDegress.m
//  DeviceFlatwise
//
//  Created by cc on 14-5-21.
//  Copyright (c) 2014年 lsb. All rights reserved.
//

#import "LSBGetDegress.h"

@implementation LSBGetDegress
+(void)getDegressWithBlock:(void(^)(CMAccelerometerData *latestAcc, NSError *error))aBlcok M:(CMMotionManager *)motionManager
{
    //CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    
    if (!motionManager.accelerometerAvailable) {
        NSLog(@"没有加速计");
    }
     [motionManager startAccelerometerUpdates];
    motionManager.accelerometerUpdateInterval = 0.1; // 告诉manager，更新频率是100Hz
   
    [motionManager startDeviceMotionUpdates];

    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *latestAcc, NSError *error)
     {
       // double a = motionManager.deviceMotion.gravity.x;
        aBlcok(latestAcc,error);
    }];
}


+(void)getDegressByGyro:(void(^)(CMGyroData  *latestGyro, NSError *error))aBlcok M:(CMMotionManager *)motionManager
{
    //CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    
    if (!motionManager.gyroAvailable) {
        NSLog(@"没有加速计");
    }
    [motionManager startGyroUpdates];
    motionManager.GyroUpdateInterval = 0.1; // 告诉manager，更新频率是100Hz
    
    [motionManager startDeviceMotionUpdates];
    
    [motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *latestGyro, NSError *error)
     {
         // double a = motionManager.deviceMotion.gravity.x;
         aBlcok(latestGyro,error);
     }];
}

+(void)getDegressByGravity:(void(^)(CMDeviceMotion  *latestDeviceMotion, NSError *error))aBlcok M:(CMMotionManager *)motionManager
{
    

    //CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    
    if (!motionManager.deviceMotionAvailable) {
        NSLog(@"没有重力仪");
    }
    [motionManager setDeviceMotionUpdateInterval:0.1]; // 告诉manager，更新频率是100Hz
    
    [motionManager startDeviceMotionUpdates];
    
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion  *latestDeviceMotion, NSError *error)
     {
         // double a = motionManager.deviceMotion.gravity.x;
         aBlcok(latestDeviceMotion,error);
     }];
}

@end
