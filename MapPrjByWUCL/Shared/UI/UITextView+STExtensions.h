//
//  UITextView+STExtensions.h
//  General
//
//  Created by Lutz Vogelsang on 01.07.12.
//  Copyright (c) 2012 Stollmann E+V GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (STExtensions)

- (void)setTextKeepingFont:(NSString *)text;
- (void)appendText:(NSString *)text limitingLengthTo:(NSUInteger)maxLength;

@end
