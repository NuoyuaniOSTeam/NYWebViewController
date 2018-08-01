//
//  NSURL+NYTool.m
//  NYWebViewController
//
//  Created by ZhangJie on 2018/5/31.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import "NSURL+NYTool.h"
#import <UIKit/UIKit.h>
#define IOS10BWK [[UIDevice currentDevice].systemVersion floatValue] >= 10
#define IOS9BWK [[UIDevice currentDevice].systemVersion floatValue] >= 9

@implementation NSURL (NYTool)

+ (void)openURL:(NSURL *)URL
{
    NSLog(@"%@",URL.host.lowercaseString);
    if ([URL.host.lowercaseString isEqualToString:@"itunes.apple.com"] ||
        [URL.host.lowercaseString isEqualToString:@"itunesconnect.apple.com"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"即将打开Appstore下载应用" message:@"如果不是本人操作，请取消" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ActionOne = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *ActionTwo = [UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self SafariOpenURL:URL];
        }];
        [alert addAction:ActionOne];
        [alert addAction:ActionTwo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        });
    }else{
        
        //获取应用名字
        //NSDictionary *urlschemes = [registerURLSchemes urlschemes];
        //        NSDictionary *appInfo = [urlschemes objectForKey:URL.scheme];
        //        NSString *name =[appInfo objectForKey:@"name"];
        
        //        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        //            if (!name) {
        //                name = URL.scheme;
        //            }
        //            [self alertWithTitle:[NSString stringWithFormat:@"即将打开%@",name] message:@"如果不是本人操作，请取消" action1Title:@"取消" action2Title:@"打开" action1:^{
        //
        //                return;
        //            } action2:^{
        //                [self SafariOpenURL:URL];
        //            }];
        //        }else{
        //            if (!appInfo) return;
        //            NSString *urlString = [appInfo objectForKey:@"url"];
        //            if (!urlString) return;
        //            NSURL *appstoreURL = [NSURL URLWithString:urlString];
        //            [self alertWithTitle:[NSString stringWithFormat:@"前往Appstore下载"] message:@"你还没安装该应用，是否前往Appstore下载？" action1Title:@"取消" action2Title:@"去下载" action1:^{
        //                return;
        //            } action2:^{
        //                [self SafariOpenURL:appstoreURL];
        //            }];
        //        }
    }
}

+ (void)alertWithTitle:(NSString *)title  message:(NSString *)message action1Title:(NSString *)action1Title action2Title:(NSString *)action2Title action1:(void (^)(void))action1 action2:(void (^)(void))action2{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ActionOne = [UIAlertAction actionWithTitle:action1Title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        action1 ? action1():NULL;
    }];
    UIAlertAction *ActionTwo = [UIAlertAction actionWithTitle:action2Title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        action2 ? action2():NULL;
    }];
    [alert addAction:ActionOne];
    [alert addAction:ActionTwo];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}


+ (void)SafariOpenURL:(NSURL *)URL {
if (@available(iOS 10.0, *)) {
    [[UIApplication sharedApplication] openURL:URL options:@{ UIApplicationOpenURLOptionUniversalLinksOnly : @NO} completionHandler:^(BOOL success)
     {
         if (!success) {
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"打开失败" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *ActionTrue = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
             [alert addAction:ActionTrue];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
             });
         }
     }];
}else{
    if (![[UIApplication sharedApplication] openURL:URL]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"打开失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ActionTrue = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ActionTrue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        });
    }
}
    
}

@end
