//
//  UITextView+STExtensions.m
//  General
//
//  Created by Lutz Vogelsang on 01.07.12.
//  Copyright (c) 2012 Stollmann E+V GmbH. All rights reserved.
//

#import "UITextView+STExtensions.h"


@implementation UITextView (STExtensions)


- (void)setTextKeepingFont:(NSString *)text
{
	BOOL selectable = self.selectable;
	if (!selectable)
		self.selectable = YES;
	self.text = text;
	if (!selectable)
		self.selectable = NO;
}


- (void)appendText:(NSString *)text limitingLengthTo:(NSUInteger)maxLength
{
	// concatenate data
	text = [self.text stringByAppendingString:text];
	
	// limit text length
	if (text.length > maxLength + 3)
	{
		text = [text substringFromIndex:text.length - (maxLength + 3)];
		text = [@"..." stringByAppendingString:text];
	}
	
	// display text
	[self setTextKeepingFont:text];
	[self scrollRangeToVisible:NSMakeRange([self.text length], 0)];
}


@end












