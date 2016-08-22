//
//  calloutCell.m
//  NJSZGX（new）
//
//  Created by JSJM on 15-8-31.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import "calloutCell.h"

@implementation calloutCell

@synthesize valuename,fieldname;
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
    NSString *valueStr=[@" " stringByAppendingString: [[value componentsSeparatedByString:@":"]objectAtIndex:1]];
    NSString *fieldStr=[@" " stringByAppendingString: [[value componentsSeparatedByString:@":"]objectAtIndex:0]];
    fieldname.text=fieldStr;

    if([fieldStr isEqualToString:@" 埋设类型"])
    {
        if ([valueStr isEqualToString:@" 0"]) {
            valuename.text=@"直埋";
        }
        else if([valueStr isEqualToString:@" 1"]) {
            valuename.text=@"矩形管沟";
        }
        else if([valueStr isEqualToString:@" 2"]) {
            valuename.text=@"拱形管沟";
        }
        else if([valueStr isEqualToString:@" 3"]) {
            valuename.text=@"管块";
        }
        else if([valueStr isEqualToString:@" 4"]) {
            valuename.text=@"管埋";
        }
        else if([valueStr isEqualToString:@" 5"]) {
            valuename.text=@"架空";
        }
        else if([valueStr isEqualToString:@" 6"]) {
            valuename.text=@"井内连线";
        }
        else if([valueStr isEqualToString:@" 7"]) {
            valuename.text=@"顶管";
        }
        else
        {
            valuename.text=@"";
        }
        
    }
    else
    {
    valuename.text=valueStr;
      }
  

}



@end
