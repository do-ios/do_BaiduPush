//
//  do_BaiduPush_SM.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_BaiduPush_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "BPush.h"
#import "doJsonHelper.h"
#import "do_BaiduPush_App.h"
#import "doJsonHelper.h"

@interface do_BaiduPush_SM ()<BPushDelegate,do_BaiduPush_AppDelegate>
@property (nonatomic,strong) doInvokeResult *invokeResult;
@property (nonatomic,copy) NSString *callBackName;
@property (nonatomic,weak) id<doIScriptEngine> scriptEngine;
@end
@implementation do_BaiduPush_SM
#pragma mark -
#pragma mark - 同步异步方法的实现
/*
 1.参数节点
 doJsonNode *_dictParas = [parms objectAtIndex:0];
 a.在节点中，获取对应的参数
 NSString *title = [_dictParas GetOneText:@"title" :@"" ];
 说明：第一个参数为对象名，第二为默认值
 
 2.脚本运行时的引擎
 id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
 
 同步：
 3.同步回调对象(有回调需要添加如下代码)
 doInvokeResult *_invokeResult = [parms objectAtIndex:2];
 回调信息
 如：（回调一个字符串信息）
 [_invokeResult SetResultText:((doUIModule *)_model).UniqueKey];
 异步：
 3.获取回调函数名(异步方法都有回调)
 NSString *_callbackName = [parms objectAtIndex:2];
 在合适的地方进行下面的代码，完成回调
 新建一个回调对象
 doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
 填入对应的信息
 如：（回调一个字符串）
 [_invokeResult SetResultText: @"异步方法完成"];
 [_scritEngine Callback:_callbackName :_invokeResult];
 */
//同步
- (void)startWork:(NSArray *)parms
{
    [BPush setDelegate:self];
    _invokeResult = [parms objectAtIndex:2];
    //自己的代码实现
    do_BaiduPush_App *baiduApp = [do_BaiduPush_App Instance];
    baiduApp.delegate = self;
    [BPush bindChannel];
}
- (void)stopWork:(NSArray *)parms
{
    _invokeResult = [parms objectAtIndex:2];
    //自己的代码实现
    [BPush unbindChannel];
}
//异步
#pragma -mark -
#pragma -mark BPushDelegate代理方法
/**
 * @brief 调用云推送 API 后的回调方法，获取请求返回的数据
 * @param
 *     method - 请求的方法，如bind,set_tags
 *     response - 返回结果字典
 * @return
 *     none
 */

- (void)onMethod:(NSString *)method response:(NSDictionary *)data
{
    _invokeResult = [[doInvokeResult alloc]init:self.UniqueKey];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    if ([method isEqualToString:@"bind"]) {
        [resultDict setValue:[data valueForKey:BPushRequestAppIdKey] forKey:@"appId"];
        [resultDict setValue:[data valueForKey:BPushRequestChannelIdKey] forKey:@"channelId"];
        [resultDict setValue:[data valueForKey:BPushRequestUserIdKey] forKey:@"userId"];
        [resultDict setValue:[data valueForKey:BPushRequestErrorCodeKey] forKey:@"errorCode"];
        NSString *resultStr = [doJsonHelper ExportToText:resultDict :YES];
        [_invokeResult SetResultText:resultStr];
        [self.EventCenter FireEvent:@"bind" :_invokeResult];
        return;
    }
    else if ([method isEqualToString:@"unbind"])
    {
        [resultDict removeAllObjects];
        long errorStr = (long)[data valueForKey:@"errorCode"];
        if (errorStr == 0) {
            [resultDict setValue:@"0" forKey:@"errorCode"];
        }
        else
        {
            [resultDict setValue:[data valueForKey:BPushRequestErrorCodeKey] forKey:@"errorCode"];
        }
        NSString *resultStr = [doJsonHelper ExportToText:resultDict :YES];
        [_invokeResult SetResultText:resultStr];
        [self.EventCenter FireEvent:@"unbind" :_invokeResult];
    }
    
}

- (void)didReceiveNotification:(NSDictionary *)userInfo
{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSString *description = [userInfo objectForKey:@"aps"];
    NSString *customContent;
    NSMutableDictionary *customDict = [NSMutableDictionary dictionary];
    for (NSString *infoKey in userInfo) {
        if (![infoKey isEqualToString:@"aps"]) {
            [customDict setValue:[userInfo valueForKey:infoKey] forKey:infoKey];
        }
    }
    customContent = [doJsonHelper ExportToText:customDict :YES];
    [resultDict setValue:description forKey:@"message"];
    [resultDict setValue:customContent forKey:@"customContent"];
    customContent = [doJsonHelper ExportToText:resultDict :YES];
    [_invokeResult SetResultText:customContent];
    [self.EventCenter FireEvent:@"message" :_invokeResult];
}
- (void)didLaunchFromRemoteNotification:(NSDictionary *)userInfo
{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSDictionary *dicInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *strAppName = [dicInfo objectForKey:@"CFBundleDisplayName"];
    NSString *title = strAppName;
    NSString *description = [userInfo objectForKey:@"aps"];
    NSString *customContent;
    NSMutableDictionary *customDict = [NSMutableDictionary dictionary];
    for (NSString *infoKey in userInfo) {
        if (![infoKey isEqualToString:@"aps"]) {
            [customDict setValue:[userInfo valueForKey:infoKey] forKey:infoKey];
        }
    }
    customContent = [doJsonHelper ExportToText:customDict :YES];
    [resultDict setValue:title forKey:@"title"];
    [resultDict setValue:description forKey:@"description"];
    if (customContent.length > 0) {
        [resultDict setValue:customContent forKey:@"customContent"];
    }
    customContent = [doJsonHelper ExportToText:resultDict :YES];
    [_invokeResult SetResultText:customContent];
    [self.EventCenter FireEvent:@"notificationClicked" :_invokeResult];
}
@end

















