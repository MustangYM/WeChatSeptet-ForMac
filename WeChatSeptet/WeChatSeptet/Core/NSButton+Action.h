//
//  NSButton+Action.h
//  WeChatExtension
//
//  Created by WeChatExtension on 2017/9/19.
//  Copyright © 2017年 WeChatExtension. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSButton (Action)

+ (instancetype)ym_buttonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (instancetype)ym_checkboxWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@end
