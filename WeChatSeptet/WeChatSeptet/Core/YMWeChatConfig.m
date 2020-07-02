//
//  YMWeChatConfig.m
//  WeChatShelby
//
//  Created by MustangYM on 2020/5/21.
//  Copyright © 2020 WeChatShelby. All rights reserved.
//

#import "YMWeChatConfig.h"

static NSString * const kTKWeChatResourcesPath = @"/Applications/WeChat.app/Contents/MacOS/WeChatSeptet.framework/Resources/";

static NSString * const kThemModeDark = @"kThemModeDark";
static NSString * const kThemModeBlack = @"kThemModeBlack";
static NSString * const kThemModePink = @"kThemModePink";

@interface YMWeChatConfig ()
@property (nonatomic, copy) NSString *themeModePath;
@end

@implementation YMWeChatConfig
@dynamic preventRevokeEnable;
@dynamic preventSelfRevokeEnable;
@dynamic preventAsyncRevokeToPhone;
@dynamic preventAsyncRevokeSignal;
@dynamic preventAsyncRevokeChatRoom;
@dynamic autoAuthEnable;
//@dynamic darkMode;
//@dynamic blackMode;
//@dynamic pinkMode;
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
    return self.cacheDarkMode || self.cacheBlackMode || self.cachePinkMode;
}

- (BOOL)usingDarkTheme {
    return self.currentThemeMode == PluginThemeModeBlack || self.currentThemeMode == PluginThemeModeDark;
}

- (NSColor *)mainTextColor {
    if (![self usingTheme]) {
        return kDefaultTextColor;
    }
    return self.currentThemeMode == PluginThemeModeDark ? kDarkModeTextColor : (self.currentThemeMode == PluginThemeModeBlack ? kBlackModeTextColor : kPinkModeTextColor);
}

- (NSColor *)mainBackgroundColor {
    if (![self usingTheme]) {
        return NSColor.clearColor;
    }
    return self.currentThemeMode == PluginThemeModeDark ? kDarkBacgroundColor : (self.currentThemeMode == PluginThemeModeBlack ? kBlackBackgroundColor : kPinkBacgroundColor);
}

- (NSColor *)mainIgnoredTextColor {
    if (![self usingTheme]) {
        return kDefaultIgnoredTextColor;
    }
    return self.currentThemeMode == PluginThemeModeDark ? kDarkModeIgnoredTextColor : (self.currentThemeMode == PluginThemeModeBlack ? kBlackModeIgnoredTextColor : kPinkModeIgnoredTextColor);
}

- (NSColor *)mainIgnoredBackgroundColor {
    if (![self usingTheme]) {
        return kDefaultIgnoredBackgroundColor;
    }
    return self.currentThemeMode == PluginThemeModeDark ? kDarkModeIgnoredBackgroundColor : (self.currentThemeMode == PluginThemeModeBlack ? kBlackModeIgnoredBackgroundColor : kPinkModeIgnoredBackgroundColor);
}

- (NSColor *)mainSeperatorColor {
    return self.currentThemeMode == PluginThemeModeDark ? kRGBColor(147, 148, 248, 0.2) : (self.currentThemeMode == PluginThemeModeBlack ? kRGBColor(128,128,128, 0.5) : kRGBColor(147, 148, 248, 0.2));
}

- (NSColor *)mainScrollerColor {
    return self.currentThemeMode == PluginThemeModeDark ? kRGBColor(33, 48, 64, 1.0) : (self.currentThemeMode == PluginThemeModeBlack ? kRGBColor(128,128,128, 0.5) : NSColor.clearColor);
}

- (NSColor *)mainDividerColor {
    return self.currentThemeMode == PluginThemeModeDark ? kRGBColor(71, 69, 112, 0.5) : (self.currentThemeMode == PluginThemeModeBlack ? kRGBColor(128,128,128, 0.7) : kRGBColor(71, 69, 112, 0.5));
}

- (NSColor *)mainChatCellBackgroundColor {
    return self.currentThemeMode == PluginThemeModeDark ? kRGBColor(33, 48, 64, 1.0) : (self.currentThemeMode == PluginThemeModeBlack ? kRGBColor(38, 38, 38, 1.0) : nil);
}


#pragma mark - 撤回的消息集合
- (NSMutableSet *)revokeMsgSet
{
    if (!_revokeMsgSet) {
        _revokeMsgSet = [NSMutableSet set];
    }
    return _revokeMsgSet;
}

#pragma mark - ThemeMode
- (void)initializeModelConfig
{
    NSArray *themes = [self getThemeModes];
    NSString *modeKey = [themes lastObject];
    
    if ([modeKey isEqualToString:kThemModeDark]) {
        self.currentThemeMode = PluginThemeModeDark;
    } else if ([modeKey isEqualToString:kThemModeBlack]) {
        self.currentThemeMode = PluginThemeModeBlack;
    } else if ([modeKey isEqualToString:kThemModePink]) {
        self.currentThemeMode = PluginThemeModePink;
    }
}

- (void)saveThemeModes:(PluginThemeMode)mode
{
    NSString *themeModeKey = nil;
    switch (mode) {
        case PluginThemeModeDark:
            themeModeKey = kThemModeDark;
            break;
            
        case PluginThemeModeBlack:
            themeModeKey = kThemModeBlack;
            break;
            
        case PluginThemeModePink:
            themeModeKey = kThemModePink;
            break;
    }
    
    if (!themeModeKey) {
        return;
    }
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:[self getThemeModes]];
    [temp addObject:themeModeKey];
    
    [temp writeToFile:self.themeModePath atomically:YES];
}

- (NSArray *)getThemeModes
{
    NSArray *arr = [NSArray arrayWithContentsOfFile:self.themeModePath];
    return arr;
}

- (NSString *)themeModePath
{
    if (!_themeModePath) {
        _themeModePath = [self getSandboxFilePathWithPlistName:@"themeMode.plist"];
    }
    return _themeModePath;
}

- (BOOL)cacheDarkMode
{
    NSArray *themes = [self getThemeModes];
    if (themes.count == 0) {
        return NO;
    }
    NSString *modeKey = [themes lastObject];
    return [modeKey isEqualToString:kThemModeDark];
}

- (BOOL)cacheBlackMode
{
    NSArray *themes = [self getThemeModes];
    if (themes.count == 0) {
        return NO;
    }
    NSString *modeKey = [themes lastObject];
    return [modeKey isEqualToString:kThemModeBlack];
}

- (BOOL)cachePinkMode
{
    NSArray *themes = [self getThemeModes];
    if (themes.count == 0) {
        return NO;
    }
    NSString *modeKey = [themes lastObject];
    return [modeKey isEqualToString:kThemModePink];
}

#pragma mark - SandBoxFilePath
- (NSString *)getSandboxFilePathWithPlistName:(NSString *)plistName
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *currentUserName = [objc_getClass("CUtility") GetCurrentUserName];
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *wechatPluginDirectory = [documentDirectory stringByAppendingFormat:@"/WeChatSeptet/%@/",currentUserName];
    NSString *plistFilePath = [wechatPluginDirectory stringByAppendingPathComponent:plistName];
    if ([manager fileExistsAtPath:plistFilePath]) {
        return plistFilePath;
    }
    
    [manager createDirectoryAtPath:wechatPluginDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *resourcesFilePath = [kTKWeChatResourcesPath stringByAppendingString:plistName];
    if (![manager fileExistsAtPath:resourcesFilePath]) {
        return plistFilePath;
    }
    
    NSError *error = nil;
    [manager copyItemAtPath:resourcesFilePath toPath:plistFilePath error:&error];
    if (!error) {
        return plistFilePath;
    }
    return resourcesFilePath;
}
@end
