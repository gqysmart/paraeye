//
//  UIViewController+STExtensions.m
//  General
//
//  Created by Lutz Vogelsang on 01.07.12.
//  Copyright (c) 2012 Stollmann E+V GmbH. All rights reserved.
//

#import "UIViewController+STExtensions.h"



@implementation UIViewController (STExtensions)


#pragma mark - public

- (void)showAlert:(NSString *)title withMessage: (NSString *) message
{
	UIAlertView * alertView = [[UIAlertView alloc] initWithTitle: title message: message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alertView show];
}


- (void)showErrorAlert:(NSString *)message
{
	[self showAlert: @"Error" withMessage: message];
}



- (void)performBlockOnMainThread:(void(^)())block
{
	[self performSelector:@selector(executeBlock:) onThread:[NSThread mainThread] withObject:block waitUntilDone:NO];
}





#pragma mark - internal

- (void)executeBlock:(void(^)())block
{
	block();
}



@end
