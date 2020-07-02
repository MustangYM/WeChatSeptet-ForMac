//
//  YMWeChatConfig.h
//  WeChatShelby
//
//  Created by MustangYM on 2020/5/21.
//  Copyright © 2020 WeChatShelby. All rights reserved.
//

#import "GVUserDefaults.h"
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PluginLanguageType) {
    PluginLanguageTypeZH,
    PluginLanguageTypeEN
};

typedef NS_ENUM(NSInteger, PluginThemeMode) {
    PluginThemeModeDark,
    PluginThemeModeBlack,
    PluginThemeModePink
};

@interface YMWeChatConfig : GVUserDefaults
@property (nonatomic) BOOL preventRevokeEnable;                 /**<    是否开启防撤回    */
@property (nonatomic) BOOL preventSelfRevokeEnable;             /**<    是否防撤回自己    */
@property (nonatomic) BOOL preventAsyncRevokeToPhone;           /**<    是否将防撤回同步到手机    */
@property (nonatomic) BOOL preventAsyncRevokeSignal;            /**<    只同步单聊    */
@property (nonatomic) BOOL preventAsyncRevokeChatRoom;          /**<    只同步群聊    */
@property (nonatomic) BOOL autoAuthEnable;                      /**<    是否免认证登录    */
@property (nonatomic) BOOL launchFromNew;                       /**<    是否是从 -> 登录新微信 -> 启动*/

@property (nonatomic) BOOL autoLoginEnable;                     /**<    是否自动登录      */

@property (nonatomic) BOOL cacheDarkMode;                            /**<    黑暗模式     */
@property (nonatomic) BOOL cacheBlackMode;                           /**<    深邃模式     */
@property (nonatomic) BOOL cachePinkMode;                            /**<    少女模式     */
@property (nonatomic) BOOL isThemeLoaded;                       /**<    是否有使用过皮肤    */

@property (nonatomic, strong) NSMutableSet *revokeMsgSet;                /**<    撤回的消息集合    */
@property (nonatomic) PluginLanguageType languageType;
@property (nonatomic, assign) PluginThemeMode currentThemeMode;

+ (instancetype)sharedConfig;

- (NSString *)languageSetting:(NSString *)chinese english:(NSString *)english;

- (BOOL)usingTheme;
- (BOOL)usingDarkTheme;

- (NSColor *)mainBackgroundColor;
- (NSColor *)mainTextColor;
- (NSColor *)mainIgnoredBackgroundColor;
- (NSColor *)mainIgnoredTextColor;
- (NSColor *)mainSeperatorColor;
- (NSColor *)mainScrollerColor;
- (NSColor *)mainDividerColor;
- (NSColor *)mainChatCellBackgroundColor;

- (void)initializeModelConfig;
- (void)saveThemeModes:(PluginThemeMode)mode;
@end

NS_ASSUME_NONNULL_END
