//
//  YMMenuManager.h
//  WeChatSeptet
//
//  Created by MustangYM on 2020/5/25.
//  Copyright © 2020 WeChatSeptet. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMMenuManager : NSObject
+ (instancetype)shareInstance;
- (void)initAssistantMenuItems;
@end

NS_ASSUME_NONNULL_END
