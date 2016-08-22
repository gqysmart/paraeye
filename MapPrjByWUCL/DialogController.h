//
//  DialogController.h
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-15.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogController : UIViewController
- (IBAction)btnClose:(UIButton *)sender;

@property (nonatomic, strong) IBOutlet UITextView *info;
@end
