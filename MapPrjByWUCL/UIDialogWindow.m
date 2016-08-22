//
//  UIDialogWindow.m
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-15.
//  Copyright (c) 2015年 吴成亮. All rights reserved.
//

#import "UIDialogWindow.h"

@implementation UIDialogWindow
@synthesize info,s;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert;
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/





- (IBAction)btnClose:(UIButton *)sender {
    [self removeFromSuperview ];
    [self release];
}


-(void)show
{
    [self makeKeyAndVisible];
 
}
@end
