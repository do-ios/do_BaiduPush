//
//  do_BaiduPush_App.m
//  DoExt_SM
//
//  Created by 刘吟 on 15/4/9.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_BaiduPush_App.h"
#import "BPush.h"
#import "doScriptEngineHelper.h"
#import "do_BaiduPush_SM.h"
#import "doServiceContainer.h"
#import "doIModuleExtManage.h"
#import "doJsonHelper.h"

static do_BaiduPush_App * instance;
@implementation do_BaiduPush_App
@synthesize OpenURLScheme;
+ (instancetype)Instance
{
    if (instance == nil) {
        instance = [[do_BaiduPush_App alloc]init];
    }
    return instance;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // iOS8 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    NSString *baiduKey = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"BaiduPush.plist" :@"BaiduPushKey"];
    [BPush registerChannel:launchOptions apiKey:baiduKey pushMode:BPushModeProduction isDebug:NO];
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [BPush handleNotification:userInfo];
        [self fireEvent:userInfo];
    }
    
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"test:%@",deviceToken);
    [BPush registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"DeviceToken 获取失败，原因：%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (application.applicationState == UIApplicationStateInactive) {
        [self fireMessage:userInfo];
    }
    else if (application.applicationState == UIApplicationStateActive)
    {
        [self fireEvent:userInfo];
    }
    [self fireMessage:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (application.applicationState == UIApplicationStateInactive) {
        [self fireMessage:userInfo];
    }
    else if (application.applicationState == UIApplicationStateActive)
    {
        [self fireEvent:userInfo];
    }
    [self fireMessage:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
//收到推送触发
- (void)fireMessage:(NSDictionary *)messageDict
{
    do_BaiduPush_SM *baidu = (do_BaiduPush_SM*)[doScriptEngineHelper ParseSingletonModule:nil :@"do_BaiduPush" ];
    NSString *message = [[messageDict objectForKey:@"aps"] objectForKey:@"alert"];
    NSMutableDictionary *customDict = [NSMutableDictionary dictionary];
    for (NSString *infoKey in messageDict) {
        if (![infoKey isEqualToString:@"aps"]) {
            [customDict setValue:[messageDict valueForKey:infoKey] forKey:infoKey];
        }
    }
    NSString *customContent = [doJsonHelper ExportToText:customDict :YES];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    [resultDict setObject:message forKey:@"message"];
    [resultDict setObject:customContent forKey:@"customContent"];
    doInvokeResult *resul = [[doInvokeResult alloc]init];
    [resul SetResultNode:resultDict];
    [baidu.EventCenter FireEvent:@"iOSMessage" :resul];
}
//点击推送触发
- (void)fireEvent:(NSDictionary *)userInfo
{
    UIApplicationState appState = [UIApplication sharedApplication].applicationState;
    if (appState == UIApplicationStateActive) {
        return;
    }
    do_BaiduPush_SM *baidu = (do_BaiduPush_SM*)[doScriptEngineHelper ParseSingletonModule:nil :@"do_BaiduPush" ];
    doInvokeResult *resul = [[doInvokeResult alloc]init];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSString *description = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    NSString *customContent;
    NSMutableDictionary *customDict = [NSMutableDictionary dictionary];
    for (NSString *infoKey in userInfo) {
        if (![infoKey isEqualToString:@"aps"]) {
            [customDict setValue:[userInfo valueForKey:infoKey] forKey:infoKey];
        }
    }
    customContent = [doJsonHelper ExportToText:customDict :YES];
    [resultDict setValue:@"" forKey:@"title"];
    [resultDict setValue:description forKey:@"description"];
    if (customContent.length > 0) {
        [resultDict setValue:customContent forKey:@"customContent"];
    }
    customContent = [doJsonHelper ExportToText:resultDict :YES];
    [resul SetResultText:customContent];
    [baidu.EventCenter FireEvent:@"notificationClicked" :resul];
}
@end
