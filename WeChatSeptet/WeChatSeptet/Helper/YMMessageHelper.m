//
//  YMMessageHelper.m
//  WeChatExtension
//
//  Created by MustangYM on 2019/1/22.
//  Copyright © 2019 MustangYM. All rights reserved.
//

#import "YMMessageHelper.h"
#import <objc/runtime.h>
#import "XMLReader.h"

@implementation YMMessageHelper
+ (MessageData *)getMessageData:(AddMsg *)addMsg
{
    if (!addMsg) {
        return nil;
    }
    MessageService *msgService = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
    return [msgService GetMsgData:addMsg.fromUserName.string svrId:addMsg.newMsgId];
}

+ (WCContactData *)getContactData:(AddMsg *)addMsg
{
    if (!addMsg) {
        return nil;
    }
    MMSessionMgr *sessionMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MMSessionMgr")];
    
    if (LargerOrEqualVersion(@"2.3.26")) {
        return [sessionMgr getSessionContact:addMsg.fromUserName.string];
    }

    return [sessionMgr getContact:addMsg.fromUserName.string];
}

+ (void)addLocalWarningMsg:(NSString *)msg fromUsr:(NSString *)fromUsr
{
    if (!msg || !fromUsr) {
        return;
    }
    MessageService *msgService = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
    NSString *newMsgContent = msg;
    MessageData *newMsgData = ({
        MessageData *msg = [[objc_getClass("MessageData") alloc] initWithMsgType:0x2710];
        [msg setFromUsrName:fromUsr];
        [msg setToUsrName:fromUsr];
        [msg setMsgStatus:4];
        [msg setMsgContent:newMsgContent];
        [msg setMsgCreateTime:[[NSDate date] timeIntervalSince1970]];
        msg;
    });
    
    [msgService AddLocalMsg:fromUsr msgData:newMsgData];
    
}
@end
