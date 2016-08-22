//
//  STTableViewCell.m
//  General
//
//  Created by Lutz Vogelsang on 28.06.12.
//  Copyright (c) 2012 Stollmann E+V GmbH. All rights reserved.
//

#import "STTableViewCell.h"


@implementation STTableViewCell

@synthesize payload = _payload;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
