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
#import "doDefines.h"

@interface do_BaiduPush_SM ()
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
    //自己的代码实现
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        doInvokeResult *invoke = [[doInvokeResult alloc]init:self.UniqueKey];
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        
        [resultDict setValue:[result valueForKey:BPushRequestAppIdKey] forKey:@"appId"];
        [resultDict setValue:[result valueForKey:BPushRequestChannelIdKey] forKey:@"channelId"];
        [resultDict setValue:[result valueForKey:BPushRequestUserIdKey] forKey:@"userId"];
        [resultDict setValue:[result valueForKey:BPushRequestErrorCodeKey] forKey:@"errorCode"];
        NSString *resultStr = [doJsonHelper ExportToText:resultDict :NO];
        [invoke SetResultText:resultStr];
        [self.EventCenter FireEvent:@"bind" :invoke];
    }];
}
- (void)stopWork:(NSArray *)parms
{
    //自己的代码实现
    [BPush unbindChannelWithCompleteHandler:^(id result, NSError *error) {
        doInvokeResult *invoke = [[doInvokeResult alloc]init:self.UniqueKey];
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        long errorStr = (long)[result valueForKey:@"errorCode"];
        if (errorStr == 0) {
            [resultDict setValue:@"0" forKey:@"errorCode"];
        }
        else
        {
            [resultDict setValue:[result valueForKey:BPushRequestErrorCodeKey] forKey:@"errorCode"];
        }
        NSString *resultStr = [doJsonHelper ExportToText:resultDict :YES];
        [invoke SetResultText:resultStr];
        [self.EventCenter FireEvent:@"unbind" :invoke];
    }];
}
- (void)setIconBadgeNumber:(NSArray *)parms
{
    NSDictionary * _dictParas = [parms objectAtIndex:0];
    NSInteger quantity = [[_dictParas objectForKey:@"quantity"] integerValue];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:quantity];
}

- (void)getIconBadgeNumber:(NSArray *)parms
{
    NSInteger quantity = [UIApplication sharedApplication].applicationIconBadgeNumber;
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    [_invokeResult SetResultInteger:(int)quantity];
}

//异步
//异步
- (void)removeTags:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scriptEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSArray *tags = [doJsonHelper GetOneArray:_dictParas :@"tag"];
    [BPush delTags:tags withCompleteHandler:^(id result, NSError *error) {
        doInvokeResult *invoke = [[doInvokeResult alloc]init:self.UniqueKey];
        if (error) {
            [invoke SetResultBoolean:NO];
        }
        else
        {
            [invoke SetResultBoolean:YES];
        }
        [self.EventCenter FireEvent:@"removeTagssResult" :invoke];
    }];
    doInvokeResult *result = [[doInvokeResult alloc]init:self.UniqueKey];
    NSString  *_callBackName = [parms objectAtIndex:2];
    [_scriptEngine Callback:_callBackName :result];
    //回调函数名_callbackName
}
- (void)setTags:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scriptEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSArray *tags = [doJsonHelper GetOneArray:_dictParas :@"tag"];
    [BPush setTags:tags withCompleteHandler:^(id result, NSError *error) {
        doInvokeResult *invoke = [[doInvokeResult alloc]init:self.UniqueKey];
        if (error) {
            [invoke SetResultBoolean:NO];
        }
        else
        {
            [invoke SetResultBoolean:YES];
        }
        [self.EventCenter FireEvent:@"setTagsResult" :invoke];
    }];
    NSString  *_callBackName = [parms objectAtIndex:2];
    doInvokeResult *result = [[doInvokeResult alloc]init:self.UniqueKey];
    [_scriptEngine Callback:_callBackName :result];
}
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

//- (void)onMethod:(NSString *)method response:(NSDictionary *)data
//{
//    doInvokeResult * _invokeResult = [[doInvokeResult alloc]init:self.UniqueKey];
//    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
//    if ([method isEqualToString:@"bind"]) {
//        [resultDict setValue:[data valueForKey:BPushRequestAppIdKey] forKey:@"appId"];
//        [resultDict setValue:[data valueForKey:BPushRequestChannelIdKey] forKey:@"channelId"];
//        [resultDict setValue:[data valueForKey:BPushRequestUserIdKey] forKey:@"userId"];
//        [resultDict setValue:[data valueForKey:BPushRequestErrorCodeKey] forKey:@"errorCode"];
//        NSString *resultStr = [doJsonHelper ExportToText:resultDict :YES];
//        [_invokeResult SetResultText:resultStr];
//        [self.EventCenter FireEvent:@"bind" :_invokeResult];
//        return;
//    }
//    else if ([method isEqualToString:@"unbind"])
//    {
//        [resultDict removeAllObjects];
//        long errorStr = (long)[data valueForKey:@"errorCode"];
//        if (errorStr == 0) {
//            [resultDict setValue:@"0" forKey:@"errorCode"];
//        }
//        else
//        {
//            [resultDict setValue:[data valueForKey:BPushRequestErrorCodeKey] forKey:@"errorCode"];
//        }
//        NSString *resultStr = [doJsonHelper ExportToText:resultDict :YES];
//        [_invokeResult SetResultText:resultStr];
//        [self.EventCenter FireEvent:@"unbind" :_invokeResult];
//    }
//    else if ([method isEqualToString:BPushRequestMethodSetTag])
//    {
//        doInvokeResult *invoke = [[doInvokeResult alloc]init:self.UniqueKey];
//        [invoke SetResultBoolean:YES];
//        if ([data.allKeys containsObject:BPushRequestErrorCodeKey]) {
//            [invoke SetResultBoolean:NO];
//        }
//        [_scriptEngine Callback:_callBackName :invoke];
//    }
//    else if ([method isEqualToString:BPushRequestMethodDelTag])
//    {
//        doInvokeResult *invoke = [[doInvokeResult alloc]init:self.UniqueKey];
//        [invoke SetResultBoolean:YES];
//        if ([data.allKeys containsObject:BPushRequestErrorCodeKey]) {
//            [invoke SetResultBoolean:NO];
//        }
//        [_scriptEngine Callback:_callBackName :invoke];
//    }
//}

@end