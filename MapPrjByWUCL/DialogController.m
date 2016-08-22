//
//  DialogController.m
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-15.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import "DialogController.h"

@interface DialogController ()

@end

@implementation DialogController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnClose:(UIButton *)sender
{
    [self.view removeFromSuperview   ];
}

@end
