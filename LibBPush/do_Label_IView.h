//
//  TYPEID_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol do_Label_IView <NSObject>

@required
//属性方法
- (void)change_text:(NSString *)newValue;
- (void)change_fontColor:(NSString *)newValue;
- (void)change_fontStyle:(NSString *)newValue;
- (void)change_fontSize:(NSString *)newValue;
- (void)change_textAlign:(NSString *)newValue;
- (void)change_maxWidth:(NSString *)newValue;
- (void)change_maxHeight:(NSString *)newValue;
- (void)change_maxLines:(NSString *)newValue;

@end
