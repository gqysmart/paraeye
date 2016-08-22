//
//  LayerINFOCell.m
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-21.
//  Copyright (c) 2015年 吴成亮. All rights reserved.
//

#import "LayerINFOCell.h"

@implementation LayerINFOCell
@synthesize txtLayer,txtOject;

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
   txtLayer.text= [@" " stringByAppendingString: [[value componentsSeparatedByString:@"$"]objectAtIndex:0]];
    txtOject.text= [@" " stringByAppendingString: [[value componentsSeparatedByString:@"$"]objectAtIndex:1]];
    
    
    
    
}


@end
