//
//  StatisticsCell.h
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-2.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticsCell : UITableViewCell





@property (nonatomic, strong) IBOutlet UITextField *layername;
@property (nonatomic, strong) IBOutlet UITextField *attname;
@property (nonatomic, strong) IBOutlet UITextField *lengthvalue;
@property (nonatomic, strong) IBOutlet UITextField *numvalue;
-(void)setTextName:(NSString *)value;
@end
