//
//  do_BaiduPush_App.h
//  DoExt_SM
//
//  Created by 刘吟 on 15/4/9.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "doIAppDelegate.h"

@protocol do_BaiduPush_AppDelegate <NSObject>

@optional
- (void) didReceiveNotification:(NSDictionary *)userInfo;
@end

@interface do_BaiduPush_App : NSObject<doIAppDelegate>
+ (instancetype )Instance;
@property (nonatomic,weak) id<do_BaiduPush_AppDelegate> delegate;
@end
