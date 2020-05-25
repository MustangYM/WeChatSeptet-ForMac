//
//  YMWeChatConfig.m
//  WeChatShelby
//
//  Created by MustangYM on 2020/5/21.
//  Copyright © 2020 WeChatShelby. All rights reserved.
//

#import "YMWeChatConfig.h"

@implementation YMWeChatConfig
@dynamic preventRevokeEnable;
@dynamic preventSelfRevokeEnable;
@dynamic preventAsyncRevokeToPhone;
@dynamic preventAsyncRevokeSignal;
@dynamic preventAsyncRevokeChatRoom;
@dynamic autoAuthEnable;
@dynamic darkMode;
@dynamic blackMode;
@dynamic pinkMode;
@dynamic groupMultiColorMode;
@dynamic isThemeLoaded;
@dynamic launchFromNew;

@dynamic autoLoginEnable;

+ (instancetype)sharedConfig
{
    static YMWeChatConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [YMWeChatConfig standardUserDefaults];
    });
    return config;
}

- (NSString *)languageSetting:(NSString *)chinese english:(NSString *)english
{
    if ([YMWeChatConfig sharedConfig].languageType == PluginLanguageTypeZH) {
        return chinese;
    }
    return english;
}

- (PluginLanguageType)languageType
{
    NSArray *languages = [NSLocale preferredLanguages];
    PluginLanguageType type = PluginLanguageTypeEN;;
    if (languages.count > 0) {
        NSString *language = languages.firstObject;
        if ([language hasPrefix:@"zh"]) {
            type = PluginLanguageTypeZH;
        }
    }
    return type;
}

- (BOOL)usingTheme {
    return self.darkMode || self.blackMode || self.pinkMode;
}

- (BOOL)usingDarkTheme {
    return self.darkMode || self.blackMode;
}

- (NSColor *)mainTextColor {
    if (![self usingTheme]) {
        return kDefaultTextColor;
    }
    return self.darkMode ? kDarkModeTextColor : (self.blackMode ? kBlackModeTextColor : kPinkModeTextColor);
}

- (NSColor *)mainBackgroundColor {
    if (![self usingTheme]) {
        return NSColor.clearColor;
    }
    return self.darkMode ? kDarkBacgroundColor : (self.blackMode ? kBlackBackgroundColor : kPinkBacgroundColor);
}

- (NSColor *)mainIgnoredTextColor {
    if (![self usingTheme]) {
        return kDefaultIgnoredTextColor;
    }
    return self.darkMode ? kDarkModeIgnoredTextColor : (self.blackMode ? kBlackModeIgnoredTextColor : kPinkModeIgnoredTextColor);
}

- (NSColor *)mainIgnoredBackgroundColor {
    if (![self usingTheme]) {
        return kDefaultIgnoredBackgroundColor;
    }
    return self.darkMode ? kDarkModeIgnoredBackgroundColor : (self.blackMode ? kBlackModeIgnoredBackgroundColor : kPinkModeIgnoredBackgroundColor);
}

- (NSColor *)mainSeperatorColor {
    return self.darkMode ? kRGBColor(147, 148, 248, 0.2) : (self.blackMode ? kRGBColor(128,128,128, 0.5) : kRGBColor(147, 148, 248, 0.2));
}

- (NSColor *)mainScrollerColor {
    return self.darkMode ? kRGBColor(33, 48, 64, 1.0) : (self.blackMode ? kRGBColor(128,128,128, 0.5) : NSColor.clearColor);
}

- (NSColor *)mainDividerColor {
    return self.darkMode ? kRGBColor(71, 69, 112, 0.5) : (self.blackMode ? kRGBColor(128,128,128, 0.7) : kRGBColor(71, 69, 112, 0.5));
}

- (NSColor *)mainChatCellBackgroundColor {
    return self.darkMode ? kRGBColor(33, 48, 64, 1.0) : (self.blackMode ? kRGBColor(38, 38, 38, 1.0) : nil);
}


#pragma mark - 撤回的消息集合
- (NSMutableSet *)revokeMsgSet
{
    if (!_revokeMsgSet) {
        _revokeMsgSet = [NSMutableSet set];
    }
    return _revokeMsgSet;
}
@end
