//
//  LoadViewController.h
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-11.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITextField *usernameText;
@property (nonatomic, retain) IBOutlet UITextField *userpsdText;
@property (nonatomic, retain) IBOutlet UIImageView *SYStitle;

@property (nonatomic, retain) IBOutlet UIView *Loading;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;

-(IBAction) slideFrameUp;
-(IBAction) slideFrameDown;
-(IBAction)btnLoadBtnClick:(id)sender;
@end
