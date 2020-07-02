//
//  NSObject+hook.m
//  WeChatShelby
//
//  Created by MustangYM on 2020/5/21.
//  Copyright © 2020 WeChatShelby. All rights reserved.
//

#import "NSObject+hook.h"
#import "YMSwizzledHelper.h"
#import <AppKit/AppKit.h>
#import "YMDeviceHelper.h"
#import "fishhook.h"
#import<CommonCrypto/CommonDigest.h>
#import "YMWeChatConfig.h"
#import "WeChatSeptet.h"
#import "YMMessageManager.h"
#import "YMMenuManager.h"
#import "NSButton+Action.h"
#import "YMThemeManager.h"

@implementation NSObject (hook)
+ (void)hookWeChat
{
    if (LargerOrEqualVersion(@"2.3.29")) {
        hookMethod(objc_getClass("MessageService"), @selector(FFToNameFavChatZZ:sessionMsgList:), [self class], @selector(hook_FFToNameFavChatZZ:sessionMsgList:));
        
    } else {
        SEL revokeMsgMethod = LargerOrEqualVersion(@"2.3.22") ? @selector(FFToNameFavChatZZ:) : @selector(onRevokeMsg:);
        hookMethod(objc_getClass("MessageService"), revokeMsgMethod, [self class], @selector(hook_onRevokeMsg:));
    }
    
    hookMethod(objc_getClass("MMLoginOneClickViewController"), @selector(viewWillAppear), [self class], @selector(hook_viewWillAppear));
    
    hookMethod(objc_getClass("WeChat"), @selector(applicationDidFinishLaunching:), [self class], @selector(hook_applicationDidFinishLaunching:));

    //多开
    SEL hasWechatInstanceMethod = LargerOrEqualVersion(@"2.3.22") ? @selector(FFSvrChatInfoMsgWithImgZZ) : @selector(HasWechatInstance);
    hookClassMethod(objc_getClass("CUtility"), hasWechatInstanceMethod, [self class], @selector(hook_HasWechatInstance));
    hookClassMethod(objc_getClass("NSRunningApplication"), @selector(runningApplicationsWithBundleIdentifier:), [self class], @selector(hook_runningApplicationsWithBundleIdentifier:));
    
    rebind_symbols((struct rebinding[2]) {
        { "NSSearchPathForDirectoriesInDomains", swizzled_NSSearchPathForDirectoriesInDomains, (void *)&original_NSSearchPathForDirectoriesInDomains },
        { "NSHomeDirectory", swizzled_NSHomeDirectory, (void *)&original_NSHomeDirectory }
    }, 2);

}

- (void)hook_viewWillAppear {
    [self hook_viewWillAppear];
    
    WeChat *wechat = [objc_getClass("WeChat") sharedInstance];
    MMLoginOneClickViewController *loginVC = wechat.mainWindowController.loginViewController.oneClickViewController;
    if (![self.className isEqualToString:@"MMLoginOneClickViewController"]) {
        return;
    } else {
        if (YMWeChatConfig.sharedConfig.usingTheme) {
            [[YMThemeManager shareInstance] changeTheme:loginVC.view];
        }
    }
    
}

- (void)hook_applicationDidFinishLaunching:(id)arg1 {
    [[YMMenuManager shareInstance] initAssistantMenuItems];
    [self hook_applicationDidFinishLaunching:arg1];
}

- (void)hook_FFToNameFavChatZZ:(id)msgData sessionMsgList:(id)arg2
{
    if (![[YMWeChatConfig sharedConfig] preventRevokeEnable]) {
        [self hook_FFToNameFavChatZZ:msgData sessionMsgList:arg2];
        return;
    }
    id msg = msgData;
    if ([msgData isKindOfClass:objc_getClass("MessageData")]) {
        msg = [msgData valueForKey:@"msgContent"];
    }
    
    if ([msg rangeOfString:@"<sysmsg"].length <= 0) return;
    
    [self _doParseRevokeMsg:msg msgData:msgData arg1:nil arg2:arg2 arg3:nil];
}

- (void)hook_onRevokeMsg:(id)msgData {
    if (![[YMWeChatConfig sharedConfig] preventRevokeEnable]) {
        [self hook_onRevokeMsg:msgData];
        return;
    }
    id msg = msgData;
    if ([msgData isKindOfClass:objc_getClass("MessageData")]) {
        msg = [msgData valueForKey:@"msgContent"];
    }
    
    if ([msg rangeOfString:@"<sysmsg"].length <= 0) return;
    
    [self _doParseRevokeMsg:msg msgData:msgData arg1:nil arg2:nil arg3:nil];
}

- (void)_doParseRevokeMsg:(NSString *)msg msgData:(id)msgData arg1:(id)arg1 arg2:(id)arg2 arg3:(id)arg3
{
    //      转换群聊的 msg
    NSString *msgContent = [msg substringFromIndex:[msg rangeOfString:@"<sysmsg"].location];
    
    //      xml 转 dict
    XMLDictionaryParser *xmlParser = [objc_getClass("XMLDictionaryParser") sharedInstance];
    NSDictionary *msgDict = [xmlParser dictionaryWithString:msgContent];
    
    if (msgDict && msgDict[@"revokemsg"]) {
        NSString *newmsgid = msgDict[@"revokemsg"][@"newmsgid"];
        NSString *session =  msgDict[@"revokemsg"][@"session"];
        msgDict = nil;
        
        NSMutableSet *revokeMsgSet = [[YMWeChatConfig sharedConfig] revokeMsgSet];
        //      该消息已进行过防撤回处理
        if ([revokeMsgSet containsObject:newmsgid] || !newmsgid) {
            return;
        }
        [revokeMsgSet addObject:newmsgid];
        
        //      获取原始的撤回提示消息
        MessageService *msgService = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
        MessageData *revokeMsgData = [msgService GetMsgData:session svrId:[newmsgid integerValue]];
        
        [[YMMessageManager shareManager] asyncRevokeMessage:revokeMsgData];
        
        if ([revokeMsgData isSendFromSelf] && ![[YMWeChatConfig sharedConfig] preventSelfRevokeEnable]) {
            
            if (LargerOrEqualVersion(@"2.3.29")) {
                [self hook_FFToNameFavChatZZ:msgData sessionMsgList:arg2];
            } else {
                [self hook_onRevokeMsg:msgData];
            }
            return;
        }
        NSString *msgContent = [[YMMessageManager shareManager] getMessageContentWithData:revokeMsgData];
        NSString *newMsgContent = [NSString stringWithFormat:@"%@ \n%@",YMLanguage(@"拦截到一条撤回消息: ", @"Intercepted a message revoke: "), msgContent];
        MessageData *newMsgData = ({
            MessageData *msg = [[objc_getClass("MessageData") alloc] initWithMsgType:0x2710];
            [msg setFromUsrName:revokeMsgData.toUsrName];
            [msg setToUsrName:revokeMsgData.fromUsrName];
            [msg setMsgStatus:4];
            [msg setMsgContent:newMsgContent];
            [msg setMsgCreateTime:[revokeMsgData msgCreateTime]];
            //   [msg setMesLocalID:[revokeMsgData mesLocalID]];
            
            msg;
        });
        
        [msgService AddLocalMsg:session msgData:newMsgData];
    }
}

#pragma mark - 多开
+ (BOOL)hook_HasWechatInstance {
    return NO;
}

+ (NSArray *)hook_runningApplicationsWithBundleIdentifier:(id)arg1 {
    return @[];
}

#pragma mark - 替换 NSSearchPathForDirectoriesInDomains & NSHomeDirectory
static NSArray<NSString *> *(*original_NSSearchPathForDirectoriesInDomains)(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);

NSArray<NSString *> *swizzled_NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde) {
    NSMutableArray<NSString *> *paths = [original_NSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde) mutableCopy];
    NSString *sandBoxPath = [NSString stringWithFormat:@"%@/Library/Containers/com.tencent.xinWeChat/Data",original_NSHomeDirectory()];
    
    [paths enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [filePath rangeOfString:original_NSHomeDirectory()];
        if (range.length > 0) {
            NSMutableString *newFilePath = [filePath mutableCopy];
            [newFilePath replaceCharactersInRange:range withString:sandBoxPath];
            paths[idx] = newFilePath;
        }
    }];
    
    return paths;
}

static NSString *(*original_NSHomeDirectory)(void);

NSString *swizzled_NSHomeDirectory(void) {
    return [NSString stringWithFormat:@"%@/Library/Containers/com.tencent.xinWeChat/Data",original_NSHomeDirectory()];
}

@end
