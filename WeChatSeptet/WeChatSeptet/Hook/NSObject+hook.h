//
//  NSObject+hook.h
//  WeChatShelby
//
//  Created by MustangYM on 2020/5/21.
//  Copyright © 2020 WeChatShelby. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (hook)
+ (void)hookWeChat;
@end

NS_ASSUME_NONNULL_END
