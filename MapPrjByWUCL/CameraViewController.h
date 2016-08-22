//
//  CameraViewController.h
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-8.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "CameraImageHelper.h"
@protocol CameraViewDelegate

@property (nonatomic, retain) IBOutlet UIView *PopView;
@end
@interface CameraViewController : UIViewController
<UIAccelerometerDelegate>
{
    CMMotionManager *moM;
    id<CameraViewDelegate> myCameraViewDelegate;
    UILabel *_label;
    //x轴方向的速度
    UIAccelerationValue _speedX;
    //y轴方向的速度
    UIAccelerationValue _speedY;
 
}
@property(retain,nonatomic) CameraImageHelper *CameraHelper;
@property (nonatomic,assign) id<CameraViewDelegate> myCameraViewDelegate;
@property (nonatomic, strong) IBOutlet UILabel *lb1;
@property (nonatomic, strong) IBOutlet UILabel *lb2;
@property (nonatomic, strong) IBOutlet UILabel *lb3;
@property (nonatomic, strong) IBOutlet UIView *preview;
@end
