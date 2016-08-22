//
//  PointStatisticsCell.m
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-7.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import "PointStatisticsCell.h"

@implementation PointStatisticsCell
@synthesize GDattname,GDTypename,numValue;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setTextName:(NSString *)value
{
    GDTypename.text= [@" " stringByAppendingString: [[value componentsSeparatedByString:@"|"]objectAtIndex:0]];
    GDattname.text= [@" " stringByAppendingString: [[value componentsSeparatedByString:@"|"]objectAtIndex:2]];
    
    
    
   
    numValue.text= [@" " stringByAppendingString: [[value componentsSeparatedByString:@"|"]objectAtIndex:1]];
    
}



@end
