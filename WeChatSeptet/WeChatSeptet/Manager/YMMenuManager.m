//
//  YMMenuManager.m
//  WeChatSeptet
//
//  Created by MustangYM on 2020/5/25.
//  Copyright © 2020 WeChatSeptet. All rights reserved.
//

#import "YMMenuManager.h"
#import "NSMenu+Action.h"
#import "NSMenuItem+Action.h"
#import "TKAboutWindowController.h"
#import <objc/runtime.h>
#import "NSWindowController+Action.h"

@implementation YMMenuManager
+ (instancetype)shareInstance
{
    static id share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (void)initAssistantMenuItems
{
    NSMenuItem *preventRevokeItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"开启消息防撤回", @"Revoke")
                                                           action:@selector(onPreventRevoke:)
                                                           target:self
                                                    keyEquivalent:@"T"
                                                            state:[[YMWeChatConfig sharedConfig] preventRevokeEnable]];
    if ([[YMWeChatConfig sharedConfig] preventRevokeEnable]) {
        NSMenuItem *preventSelfRevokeItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"拦截自己撤回的消息", @"Revoke Self")
                                                                   action:@selector(onPreventSelfRevoke:)
                                                                   target:self
                                                            keyEquivalent:@""
                                                                    state:[[YMWeChatConfig sharedConfig] preventSelfRevokeEnable]];
        
        NSMenuItem *preventAsyncRevokeItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"防撤回同步到手机", @"Revoke Sync To Phone")
                                                                    action:@selector(onPreventAsyncRevokeToPhone:)
                                                                    target:self
                                                             keyEquivalent:@""
                                                                     state:[[YMWeChatConfig sharedConfig] preventAsyncRevokeToPhone]];
        
        if ([[YMWeChatConfig sharedConfig] preventAsyncRevokeToPhone]) {
            NSMenuItem *asyncRevokeSignalItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"同步单聊", @"Sync Single Chat")
                                                                       action:@selector(onAsyncRevokeSignal:)
                                                                       target:self
                                                                keyEquivalent:@""
                                                                        state:[[YMWeChatConfig sharedConfig] preventAsyncRevokeSignal]];
            NSMenuItem *asyncRevokeChatRoomItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"同步群聊", @"Sync Group Chat")
                                                                         action:@selector(onAsyncRevokeChatRoom:)
                                                                         target:self
                                                                  keyEquivalent:@""
                                                                          state:[[YMWeChatConfig sharedConfig] preventAsyncRevokeChatRoom]];
            NSMenu *subAsyncMenu = [[NSMenu alloc] initWithTitle:@""];
            [subAsyncMenu addItems:@[asyncRevokeSignalItem, asyncRevokeChatRoomItem]];
            preventAsyncRevokeItem.submenu = subAsyncMenu;
        }
        
        
        NSMenu *subPreventMenu = [[NSMenu alloc] initWithTitle:YMLanguage(@"开启消息防撤回", @"Revoke")];
        [subPreventMenu addItems:@[preventSelfRevokeItem, preventAsyncRevokeItem]];
        preventRevokeItem.submenu = subPreventMenu;
    }
       
    
    #pragma mark - 主题
    NSMenuItem *backGroundItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"主题模式", @"Themes")
                                                           action:nil
                                                           target:self
                                                    keyEquivalent:@""
                                                            state:YMWeChatConfig.sharedConfig.usingTheme];
    
    NSMenuItem *darkModeItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"黑夜模式", @"Dark Mode")
                                                      action:@selector(onChangeDarkMode:)
                                                      target:self
                                               keyEquivalent:@""
                                                       state:[YMWeChatConfig sharedConfig].cacheDarkMode];
    
    NSMenuItem *blackModeItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"深邃模式", @"Black Mode")
                                                       action:@selector(onChangeBlackMode:)
                                                       target:self
                                                keyEquivalent:@""
                                                        state:YMWeChatConfig.sharedConfig.cacheBlackMode];
    
    NSMenuItem *pinkColorItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"少女模式", @"Pink Mode")
                                                       action:@selector(onChangePinkModel:)
                                                       target:self
                                                keyEquivalent:@""
                                                        state:[YMWeChatConfig sharedConfig].cachePinkMode];
    
    NSMenu *subBackgroundMenu = [[NSMenu alloc] initWithTitle:@""];
    [subBackgroundMenu addItems:@[darkModeItem, blackModeItem, pinkColorItem]];
    backGroundItem.submenu = subBackgroundMenu;
    
    NSMenuItem *newWeChatItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"多开", @"About")
                                                         action:@selector(onNewWeChat:)
                                                         target:self
                                                  keyEquivalent:@""
                                                          state:0];
    
    NSMenuItem *aboutPluginItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"关于", @"About")
                                                          action:@selector(onAboutPluginControl:)
                                                          target:self
                                                   keyEquivalent:@""
                                                           state:0];
    
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:YMLanguage(@"小助手简版", @"Assistant")];
    [subMenu addItems:@[
        preventRevokeItem,
        backGroundItem,
        newWeChatItem,
        aboutPluginItem
    ]];
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setSubmenu:subMenu];
    menuItem.target = self;
    [[[NSApplication sharedApplication] mainMenu] addItem:menuItem];
}

static char kAboutWindowControllerKey;             //  关于窗口的关联 key
- (void)onAboutPluginControl:(NSMenuItem *)item
{
    WeChat *wechat = [objc_getClass("WeChat") sharedInstance];
    TKAboutWindowController *aboutControlWC = objc_getAssociatedObject(wechat, &kAboutWindowControllerKey);
    if (!aboutControlWC) {
        aboutControlWC = [[TKAboutWindowController alloc] initWithWindowNibName:@"TKAboutWindowController"];
        objc_setAssociatedObject(wechat, &kAboutWindowControllerKey, aboutControlWC, OBJC_ASSOCIATION_RETAIN);
    }
    [aboutControlWC show];
}

/**
 菜单栏-微信小助手-消息防撤回-拦截自己消息 设置
 
 @param item 消息防撤回的item
 */
- (void)onPreventSelfRevoke:(NSMenuItem *)item
{
    item.state = !item.state;
    [[YMWeChatConfig sharedConfig] setPreventSelfRevokeEnable:item.state];
}

- (void)onPreventAsyncRevokeToPhone:(NSMenuItem *)item
{
    item.state = !item.state;
    [[YMWeChatConfig sharedConfig] setPreventAsyncRevokeToPhone:item.state];
    [[YMWeChatConfig sharedConfig] setPreventAsyncRevokeSignal:item.state];
    [[YMWeChatConfig sharedConfig] setPreventAsyncRevokeChatRoom:item.state];
    if (item.state) {
        NSMenuItem *asyncRevokeSignalItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"同步单聊", @"Sync Single Chat")
                                                                   action:@selector(onAsyncRevokeSignal:)
                                                                   target:self
                                                            keyEquivalent:@""
                                                                    state:[[YMWeChatConfig sharedConfig] preventAsyncRevokeSignal]];
        NSMenuItem *asyncRevokeChatRoomItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"同步群聊", @"Sync Group Chat")
                                                                     action:@selector(onAsyncRevokeChatRoom:)
                                                                     target:self
                                                              keyEquivalent:@""
                                                                      state:[[YMWeChatConfig sharedConfig] preventAsyncRevokeChatRoom]];
        NSMenu *subAsyncMenu = [[NSMenu alloc] initWithTitle:@""];
        [subAsyncMenu addItems:@[asyncRevokeSignalItem, asyncRevokeChatRoomItem]];
        item.submenu = subAsyncMenu;
    } else {
        item.submenu = nil;
    }
}

- (void)onAsyncRevokeSignal:(NSMenuItem *)item
{
    item.state = !item.state;
    [[YMWeChatConfig sharedConfig] setPreventAsyncRevokeSignal:item.state];
}

- (void)onAsyncRevokeChatRoom:(NSMenuItem *)item
{
    item.state = !item.state;
    [[YMWeChatConfig sharedConfig] setPreventAsyncRevokeChatRoom:item.state];
}

- (void)onChangeBlackMode:(NSMenuItem *)item
{
    item.state = !item.state;
    NSString *msg = nil;
    if (item.state) {
        msg = YMLanguage(@"打开深邃模式, 重启生效!",@"Turn on BLACK MODE and restart to take effect!");
    } else {
        msg = YMLanguage(@"关闭深邃模式, 重启生效!",@"Turn off BLACK MODE and restart to take effect!");
    }
    NSAlert *alert = [NSAlert alertWithMessageText:YMLanguage(@"警告", @"WARNING")
                                     defaultButton:YMLanguage(@"取消", @"cancel")                       alternateButton:YMLanguage(@"确定重启",@"restart")
                                       otherButton:nil                              informativeTextWithFormat:@"%@", msg];
    NSUInteger action = [alert runModal];
    
    if (action == NSAlertAlternateReturn) {
        __weak __typeof (self) wself = self;
        [[YMWeChatConfig sharedConfig] saveThemeModes:PluginThemeModeBlack];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[NSApplication sharedApplication] terminate:wself];
            });
        });
    }  else if (action == NSAlertDefaultReturn) {
        item.state = !item.state;
    }
   
}
- (void)onChangeDarkMode:(NSMenuItem *)item
{
    item.state = !item.state;
    NSString *msg = nil;
    if (item.state) {
        msg = YMLanguage(@"打开黑夜模式, 重启生效!",@"Turn on dark mode and restart to take effect!");
    } else {
        msg = YMLanguage(@"关闭黑夜模式, 重启生效!",@"Turn off dark mode and restart to take effect!");
    }
    NSAlert *alert = [NSAlert alertWithMessageText:YMLanguage(@"警告", @"WARNING")
                                     defaultButton:YMLanguage(@"取消", @"cancel")                       alternateButton:YMLanguage(@"确定重启",@"restart")
                                       otherButton:nil                              informativeTextWithFormat:@"%@", msg];
    NSUInteger action = [alert runModal];
    if (action == NSAlertAlternateReturn) {
        __weak __typeof (self) wself = self;
        [[YMWeChatConfig sharedConfig] saveThemeModes:PluginThemeModeDark];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[NSApplication sharedApplication] terminate:wself];
            });
        });
    }  else if (action == NSAlertDefaultReturn) {
        item.state = !item.state;
    }
   
}

- (void)onChangePinkModel:(NSMenuItem *)item
{
    item.state = !item.state;
    NSString *msg = nil;
    if (item.state) {
        msg = YMLanguage(@"打开少女模式, 重启生效!",@"Turn on Pink mode and restart to take effect!");
    } else {
        msg = YMLanguage(@"关闭少女模式, 重启生效!",@"Turn off Pink mode and restart to take effect!");
    }
    NSAlert *alert = [NSAlert alertWithMessageText:YMLanguage(@"警告", @"WARNING")
                                     defaultButton:YMLanguage(@"取消", @"cancel")                       alternateButton:YMLanguage(@"确定重启",@"restart")
                                       otherButton:nil                              informativeTextWithFormat:@"%@", msg];
    NSUInteger action = [alert runModal];
    if (action == NSAlertAlternateReturn) {
        __weak __typeof (self) wself = self;
        [[YMWeChatConfig sharedConfig] saveThemeModes:PluginThemeModePink];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[NSApplication sharedApplication] terminate:wself];
            });
        });
    }  else if (action == NSAlertDefaultReturn) {
        item.state = !item.state;
    }
    
}

- (void)onPreventRevoke:(NSMenuItem *)item
{
    item.state = !item.state;
    [[YMWeChatConfig sharedConfig] setPreventRevokeEnable:item.state];
    if (item.state) {
        NSMenuItem *preventSelfRevokeItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"拦截自己撤回消息", @"Revoke Self")
                                                                   action:@selector(onPreventSelfRevoke:)
                                                                   target:self
                                                            keyEquivalent:@""
                                                                    state:[[YMWeChatConfig sharedConfig] preventSelfRevokeEnable]];
        
        NSMenuItem *preventAsyncRevokeItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"防撤回同步到手机", @"Revoke Sync To Phone")
                                                                    action:@selector(onPreventAsyncRevokeToPhone:)
                                                                    target:self
                                                             keyEquivalent:@""
                                                                     state:[[YMWeChatConfig sharedConfig] preventAsyncRevokeToPhone]];
        
        if (preventAsyncRevokeItem.state) {
            NSMenuItem *asyncRevokeSignalItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"同步单聊", @"Sync Single Chat")
                                                                       action:@selector(onAsyncRevokeSignal:)
                                                                       target:self
                                                                keyEquivalent:@""
                                                                        state:[[YMWeChatConfig sharedConfig] preventAsyncRevokeSignal]];
            NSMenuItem *asyncRevokeChatRoomItem = [NSMenuItem menuItemWithTitle:YMLanguage(@"同步群聊", @"Sync Group Chat")
                                                                         action:@selector(onAsyncRevokeChatRoom:)
                                                                         target:self
                                                                  keyEquivalent:@""
                                                                          state:[[YMWeChatConfig sharedConfig] preventAsyncRevokeChatRoom]];
            NSMenu *subAsyncMenu = [[NSMenu alloc] initWithTitle:@""];
            [subAsyncMenu addItems:@[asyncRevokeSignalItem, asyncRevokeChatRoomItem]];
            preventAsyncRevokeItem.submenu = subAsyncMenu;
        } else {
            preventAsyncRevokeItem.submenu = nil;
        }
        
        NSMenu *subPreventMenu = [[NSMenu alloc] initWithTitle:YMLanguage(@"开启消息防撤回", @"Revoke")];
        [subPreventMenu addItems:@[preventSelfRevokeItem, preventAsyncRevokeItem]];
        item.submenu = subPreventMenu;
    } else {
        item.submenu = nil;
    }
    
}

- (void)onNewWeChat:(NSMenuItem *)item
{
     [self executeShellCommand:@"open -n /Applications/WeChat.app"];
}

- (NSString *)executeShellCommand:(NSString *)cmd
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-c", cmd]];
    NSPipe *errorPipe = [NSPipe pipe];
    [task setStandardError:errorPipe];
    NSFileHandle *file = [errorPipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
