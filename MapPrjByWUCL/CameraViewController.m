//
//  CameraViewController.m
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-8.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import "CameraViewController.h"
#import "LSBGetDegress.h"
#import "CameraImageHelper.h"
@interface CameraViewController ()

@end

@implementation CameraViewController
@synthesize lb1,lb2,lb3,myCameraViewDelegate,CameraHelper,preview;
static const NSTimeInterval accelerometerMin = 0.01;
double px,py;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    
    
    self.view.backgroundColor = [UIColor yellowColor];
    CGRect winRect = [UIScreen mainScreen].applicationFrame;
    //实例化 随加速度方向运动的小方块（label）
    _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _label.center = CGPointMake(winRect.size.width * 0.5, winRect.size.height * 0.5);
    _label.text = @"Droid";
    _label.textAlignment = NSTextAlignmentCenter;
    _label.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_label];
    [_label release];
    moM=[[CMMotionManager alloc]init];
    
    px=  _label.center.x    ;
    py=_label.center.y ;
//    CameraHelper = [[CameraImageHelper alloc]init];
//    
//    // 开始实时取景
//    [CameraHelper startRunning];
//    [CameraHelper embedPreviewInView:preview];
//    [CameraHelper changePreviewOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [CameraHelper changePreviewOrientation:(UIInterfaceOrientation)toInterfaceOrientation];
}

-(void)viewWillAppear:(BOOL)animated
{
}


- (IBAction)btnOpenSensor:(UIButton *)sender {
    //[moM stopAccelerometerUpdates];
   
//    [LSBGetDegress getDegressWithBlock:^( CMAccelerometerData *latestAcc, NSError *error) {
//        
//
//        
//        lb1.text= [NSString stringWithFormat:@"%f",  latestAcc.acceleration.x ];
//        lb2.text= [NSString stringWithFormat:@"%f",  latestAcc.acceleration.y ];
//        lb3.text= [NSString stringWithFormat:@"%f",  latestAcc.acceleration.z ];
//    } M:moM];
    
    
//      [moM stopGyroUpdates];
//    [LSBGetDegress getDegressByGyro:^( CMGyroData *latestGyro, NSError *error)
//     {
//                 lb1.text= [NSString stringWithFormat:@"%f",  latestGyro.rotationRate.x ];
//                 lb2.text= [NSString stringWithFormat:@"%f",  latestGyro.rotationRate.y ];
//                 lb3.text= [NSString stringWithFormat:@"%f",  latestGyro.rotationRate.z ];
//     }M:moM];
   
    
    [moM stopDeviceMotionUpdates];
    [LSBGetDegress getDegressByGravity:^(CMDeviceMotion  *latestDeviceMotion, NSError *error)
    {
        
                         lb1.text= [NSString stringWithFormat:@"%f",  latestDeviceMotion.attitude.roll ];
                         lb2.text= [NSString stringWithFormat:@"%f",  latestDeviceMotion.attitude.yaw ];
                         lb3.text= [NSString stringWithFormat:@"%f",  latestDeviceMotion.attitude.pitch ];
        
        
        
        //_speedX = latestDeviceMotion.attitude.roll*30;
        //y轴方向的速度加上y轴方向获得的加速度
        _speedY =latestDeviceMotion.attitude.roll*30;
        //小方块将要移动到的x轴坐标
        CGFloat posX = px ;
        //小方块将要移动到的y轴坐标
        CGFloat posY = py - _speedY;

        
        //碰到屏幕边缘反弹
        if (posX < 0.0) {
            posX = 0.0;
           
        }else if(posX > self.view.bounds.size.width){
            posX = self.view.bounds.size.width;
           
        }
        if (posY < 0.0) {
            posY = 0.0;
           
        }else if (posY > self.view.bounds.size.height){
            posY = self.view.bounds.size.height;
        }
        
        
        //移动小方块
        _label.center = CGPointMake(posX, posY);
        
        
        
        
    }M:moM];
    
}
- (IBAction)btnCloseSensor:(UIButton *)sender {
    //[moM stopAccelerometerUpdates];
    //[moM stopGyroUpdates];
    [moM stopDeviceMotionUpdates];
}

- (IBAction)btnClose:(UIButton *)sender {
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
