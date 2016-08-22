//
//  calloutCell.h
//  NJSZGX（new）
//
//  Created by JSJM on 15-8-31.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface calloutCell : UITableViewCell




@property (nonatomic, strong) IBOutlet UITextField *fieldname;
@property (nonatomic, strong) IBOutlet UITextField *valuename;
-(void)setTextName:(NSString *)value;
@end
