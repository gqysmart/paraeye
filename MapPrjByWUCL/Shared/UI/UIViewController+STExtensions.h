//
//  UIViewController+STExtensions.h
//  General
//
//  Created by Lutz Vogelsang on 01.07.12.
//  Copyright (c) 2012 Stollmann E+V GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (STExtensions)

- (void)showAlert:(NSString *)title withMessage:(NSString *)message;
- (void)showErrorAlert:(NSString *)message;
- (void)performBlockOnMainThread:(void(^)())block;

@end
