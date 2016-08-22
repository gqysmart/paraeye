//
//  SimplePingHelper.h
//  NJSZGXnewA
//
//  Created by 陈川 on 15/10/27.
//  Copyright © 2015年 吴成亮. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SimplePing.h"

@interface SimplePingHelper : NSObject <SimplePingDelegate>

+ (void)ping:(NSString*)address target:(id)target sel:(SEL)sel;

@end