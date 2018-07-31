//
//  NYWebViewController.h
//  NYWebViewController
//
//  Created by ZhangJie on 2018/3/22.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "NYScriptMessage.h"

typedef void (^MessageBlock)(WKUserContentController *userContentController,NYScriptMessage *message);

@class NYWebViewController;
@protocol NYWebViewControllerDelegate <NSObject>
@optional
- (void)webViewControllerWillGoBack:(NYWebViewController *)webViewController;
- (void)webViewControllerWillGoForward:(NYWebViewController *)webViewController;
- (void)webViewControllerWillReload:(NYWebViewController *)webViewController;
- (void)webViewControllerWillStop:(NYWebViewController *)webViewController;
- (void)webViewControllerDidStartLoad:(NYWebViewController *)webViewController;
- (void)webViewControllerDidFinishLoad:(NYWebViewController *)webViewController;
- (void)webViewController:(NYWebViewController *)webViewController didFailLoadWithError:(NSError *)error;

- (void)webViewController:(NYWebViewController *)webViewController didReceiveScriptMessage:(NYScriptMessage *)message;
- (void)webViewController:(NYWebViewController *)webViewController decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
@end

@interface NYWebViewController : UIViewController

/* url */
@property (nonatomic, strong) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url;

@property (nonatomic, strong) WKWebView *webView;

// 网络请求小菊花  default YES
@property (nonatomic, assign) BOOL activityIndicatorVisible;
// 是否显示网页来源 default YES
@property(assign, nonatomic) BOOL showHostLabel;

@property (nonatomic, weak) id<NYWebViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL openCache;   //缓存（未完成）

- (void)loadURL:(NSURL *)pageURL;

/**  reload */
- (void)reload;

/**  goback */
- (void)goback;

/**  goForward */
- (void)goForward;

/**  set cookie，in loadRequest before*/
- (void)setcookie:(NSHTTPCookie *)cookie;

/**
 *   JavaScript call Objective-c  Add messageHandler
 *   Add javaScript call objective-caddScriptMessageHandler:name:
 *   @param names may add one or more register handle  object. userContentController's delegate object.
 *   javaScript must add : window.webkit.messageHandlers.<name>.postMessage(<messageBody>) to work。
 *
 */
- (void)addScriptMessageHandlerWithName:(NSArray<NSString *> *)names;
- (void)addScriptMessageHandlerWithName:(NSArray<NSString *> *)names observeValue:(MessageBlock)messageCallback;

/**
 *   Remove register's handler.
 *   @param name handler's name
 */
- (void)removeScriptMessageHandlerForName:(NSString *)name;


/**
 *  Native call javaScript method
 *  @param jsStr call javaScript's string text ,It could be a function name or it could be a javaScript statement.
 *
 */
- (void)webViewControllerCallJS:(nonnull NSString *)jsStr;

/**
 *  Native call javaScript method.
 *  @param jsStr call javaScript's string text ,It could be a function name or it could be a javaScript statement.
 *  @param completeBlock callback block.
 */
- (void)webViewControllerCallJS:(nonnull NSString *)jsStr completeBlock:(void (^)(id response, NSError *error))completeBlock;

@end


@interface NYWebViewController (NavigationControllerBar)

@property (nonatomic, strong) UIColor *navTintColor;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property(assign, nonatomic) BOOL showsNavigationCloseBarButtonItem;
@property(assign, nonatomic) BOOL showsNavigationBackBarButtonItemTitle;

@end

