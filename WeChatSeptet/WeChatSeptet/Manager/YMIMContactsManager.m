//
//  YMIMContactsManager.m
//  WeChatExtension
//
//  Created by MustangYM on 2019/6/28.
//  Copyright © 2019 MustangYM. All rights reserved.
//

#import "YMIMContactsManager.h"
#import "YMMessageHelper.h"
#import "YMWeChatConfig.h"

@implementation YMMonitorChildInfo
- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.usrName = dict[@"usrName"];
        self.group = dict[@"group"];
        self.quitTimestamp = [dict[@"quitTimestamp"] doubleValue];
    }
    return self;
}

- (NSDictionary *)dictionary
{
    return @{@"usrName": self.usrName?:@"",
             @"group": self.group?:@"",
             @"quitTimestamp": @(self.quitTimestamp)};
}

@end

@interface YMIMContactsManager()
@property (nonatomic, strong) NSMutableArray *cachePool;
@end

@implementation YMIMContactsManager

+ (instancetype)shareInstance
{
    static id share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (NSMutableArray *)cachePool
{
    if (!_cachePool) {
        _cachePool = [NSMutableArray array];
    }
    return _cachePool;
}

+ (NSString *)getGroupMemberNickNameFromCache:(NSString *)username
{
    if (!username) {
        return nil;
    }
    ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
    WCContactData *data = [contactStorage getContactCache:username];
    
    return data.m_nsNickName;
}

+ (NSString *)getGroupMemberNickName:(NSString *)username
{
    if (!username) {
        return nil;
    }
    GroupStorage *groupStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("GroupStorage")];
    WCContactData *data = [groupStorage GetGroupMemberContact:username];
    return data.m_nsNickName;
}

+ (NSString *)getWeChatNickName:(NSString *)username
{
    NSArray *arr = [self getAllFriendContacts];
    __block NSString *temp = nil;
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WCContactData *contactData = (WCContactData *)obj;
        if ([contactData.m_nsUsrName isEqualToString:username]) {
            temp = contactData.m_nsNickName;
        }
    }];
    
    return temp;
}

+ (NSArray<WCContactData *> *)getAllFriendContacts
{
    ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
    return [contactStorage GetAllFriendContacts];
}

+ (NSString *)getWeChatAvatar:(NSString *)userName
{
    NSArray *arr = [self getAllFriendContacts];
    __block NSString *temp = nil;
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WCContactData *contactData = (WCContactData *)obj;
        if ([contactData.m_nsUsrName isEqualToString:userName]) {
            temp = contactData.m_nsHeadImgUrl;
        }
    }];
    
    return temp;
}

+ (MMSessionInfo *)getSessionInfo:(NSString *)userName
{
    MMSessionMgr *sessionMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MMSessionMgr")];
    __block MMSessionInfo *info = nil;
    [sessionMgr.m_arrSession enumerateObjectsUsingBlock:^(MMSessionInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.m_nsUserName isEqualToString:userName]) {
            info = obj;
        }
    }];
    return info;
}

@end
