//
//  LoadViewController.m
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-11.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import "LoadViewController.h"
#import "MainViewController.h"
#import "DialogController.h"
#import "SimplePingHelper.h"
#import "WBAAppDelegate.h"

@interface LoadViewController ()

@end

@implementation LoadViewController
@synthesize usernameText, userpsdText, SYStitle,Loading,activityIndicatorView;
int movementDistance = 0;
bool IsUp = NO;
bool IsChange = YES;
DialogController *dia;
WBAAppDelegate *appDelegate;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self  ArcgisTokenRegister];///arcgis授权
    Loading.hidden=true;
    userpsdText.secureTextEntry=YES;
    appDelegate=[[UIApplication sharedApplication] delegate];
}
-(void)ArcgisTokenRegister
{
    NSError *error;
    NSString *clientID=@"ZqOeDBdmfdAXowFw";
    [AGSRuntimeEnvironment setClientID:clientID error:&error];
    if(error)
    {
        //id错误
        NSLog(@"Error using client ID:%@",@"s");
    }
}

-(IBAction)btnLoadBtnClick:(id)sender
{
    [usernameText resignFirstResponder];
    [userpsdText resignFirstResponder];
    
    if ([usernameText.text isEqualToString:@"admin"] && [userpsdText.text isEqualToString:@"admin"])
    {
        //        [activityIndicatorView startAnimating];
        //        Loading.hidden=false;
        NSUserDefaults *defal = [NSUserDefaults standardUserDefaults];
        NSString *WebIP = [defal stringForKey:@"WebServiceServiceIP"];
        
//    if ( [WebIP isEqualToString:@"192.168.200.18"] ) {
            [SimplePingHelper ping:WebIP target:self sel:@selector(pingResult:)];
//        }
//        else
//        {
//            ///12.17屏蔽在线模式
//            //
//            appDelegate.NETWORKABLE=false;
//            MainViewController *mapviewcontroller=[[MainViewController alloc] init];
//            [self.view addSubview:mapviewcontroller.view];
//        }
        
    
        
    }
    else {
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=@"用户名或密码错误!";
        [self.view addSubview:dia.view];
        
    }
    
    usernameText.text=@"";
    userpsdText.text=@"";
}




-(void)pingResult:(NSNumber*)success
{

    if (success.boolValue) {
        appDelegate.NETWORKABLE=true;
        NSLog(@"SUCCESS");
        
    } else {
        appDelegate.NETWORKABLE=false;
        NSLog(@"FAILURE");
    }
    //gqy test1
    //appDelegate.NETWORKABLE=true;

    //gqy test1 end
   
    MainViewController *mapviewcontroller=[[MainViewController alloc] init];
    [self.view addSubview:mapviewcontroller.view];//gqy 这里导致loadview持续留在内存
}





-(IBAction) slideFrameUp;
{
    IsChange = YES;
    IsUp = YES;
    [self slideFrame:IsUp];
}

- (BOOL) shouldAutorotate
{
    return YES;
}

-(void) slideFrame:(BOOL) up
{
    if (!IsChange) {
        return;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationLandscapeLeft)
        movementDistance = -180;
    else
        movementDistance = 180;
    
    const float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, movement, 0);
    [UIView commitAnimations];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(IBAction) slideFrameDown;
{
    IsUp = NO;
    [self slideFrame:IsUp];
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    IsChange = NO;
    [usernameText resignFirstResponder];
    [userpsdText resignFirstResponder];
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        NSLog(@"UIInterfaceOrientationPortrait");
    } else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        NSLog(@"UIInterfaceOrientationLandscapeLeft");
    } else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        NSLog(@"UIInterfaceOrientationLandscapeRight");
    }
    else
        NSLog(@"else");
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







@end
