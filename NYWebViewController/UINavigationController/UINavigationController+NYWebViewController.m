//
//  UINavigationController+NYWebViewController.m
//  NYWebViewControllerExample
//
//  Created by nuoyuan on 2018/7/16.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import "UINavigationController+NYWebViewController.h"
#import "NYWebViewController.h"
#import <objc/runtime.h>

@implementation UINavigationController (NYWebViewController)

+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Method originalMethod = class_getInstanceMethod(self, @selector(navigationBar:shouldPopItem:));
//        Method swizzledMethod = class_getInstanceMethod(self, @selector(ny_navigationBar:shouldPopItem:));
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    });
}

- (BOOL)ny_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    BOOL shouldPopItemAfterPopViewController = [[self valueForKey:@"_isTransitioning"] boolValue];
    if (shouldPopItemAfterPopViewController) {
        return [self ny_navigationBar:navigationBar shouldPopItem:item];
    }
    
    // Should not pop. It appears clicked the back bar button item. We should decide the action according to the content of web view.
    if ([self.topViewController isKindOfClass:[NYWebViewController class]]) {
        NYWebViewController* webVC = (NYWebViewController*)self.topViewController;
        if (webVC.webView.canGoBack) {
            if (webVC.webView.isLoading) {
                [webVC.webView stopLoading];
            }
            [webVC.webView goBack];
            [[self.navigationBar subviews] lastObject].alpha = 1;
            return NO;
        }else{
            return [self ny_navigationBar:navigationBar shouldPopItem:item];
        }
    }else{
        return [self ny_navigationBar:navigationBar shouldPopItem:item];
    }
}
@end
