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
    // App 收到推送的通知
    do_BaiduPush_SM *baidu = (do_BaiduPush_SM*)[doScriptEngineHelper ParseSingletonModule:nil :@"do_BaiduPush" ];
    [baidu startWork:nil];
    if ([self.delegate respondsToSelector:@selector(didReceiveNotification:)]) {
        [self.delegate didReceiveNotification:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    do_BaiduPush_SM *baidu = (do_BaiduPush_SM*)[doScriptEngineHelper ParseSingletonModule:nil :@"do_BaiduPush" ];
    [baidu startWork:nil];
    if ([self.delegate respondsToSelector:@selector(didReceiveNotification:)]) {
        [self.delegate didReceiveNotification:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
