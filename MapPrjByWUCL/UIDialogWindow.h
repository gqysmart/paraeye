//
//  UIDialogWindow.h
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-15.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDialogWindow : UIWindow
- (IBAction)btnClose:(UIButton *)sender;
-(void)show;
@property (nonatomic, strong) IBOutlet UITextView *info;

@property (nonatomic, strong) IBOutlet UIView *s;
@end
