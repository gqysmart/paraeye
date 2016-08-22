//
//  StatisticsCell.m
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-2.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import "StatisticsCell.h"

@implementation StatisticsCell
@synthesize layername,lengthvalue,attname,numvalue;
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
    layername.text= [@" " stringByAppendingString: [[value componentsSeparatedByString:@"|"]objectAtIndex:0]];
     attname.text= [@" " stringByAppendingString: [[value componentsSeparatedByString:@"|"]objectAtIndex:3]];
    

    
    lengthvalue.text= [@" " stringByAppendingString: [NSString stringWithFormat:@"%.3f",
                                                      [[[value componentsSeparatedByString:@"|"]objectAtIndex:2] doubleValue ]]];
    numvalue.text= [@" " stringByAppendingString: [[value componentsSeparatedByString:@"|"]objectAtIndex:1]];
    
}


@end
