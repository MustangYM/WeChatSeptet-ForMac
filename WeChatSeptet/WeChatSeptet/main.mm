//
//  main.c
//  WeChatExtension
//
//  Created by WeChatExtension on 2017/4/19.
//  Copyright © 2017年 WeChatExtension. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+hook.h"
#import "NSObject+ThemeHook.h"

static void __attribute__((constructor)) initialize(void) {
    [NSObject hookWeChat];
    [NSObject hookTheme];
}
