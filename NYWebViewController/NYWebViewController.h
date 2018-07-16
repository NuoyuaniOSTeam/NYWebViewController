//
//  NYWebViewController.h
//  NYWebViewController
//
//  Created by ZhangJie on 2018/3/22.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "NYSecurityPolicy.h"
#import "NYScriptMessage.h"

//typedef NSURLSessionAuthChallengeDisposition (^WKWebViewDidReceiveAuthenticationChallengeHandler)(WKWebView *webView, NSURLAuthenticationChallenge *challenge, NSURLCredential * _Nullable __autoreleasing * _Nullable credential);
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
- (instancetype)initWithLocalHtmlURL:(NSURL *)url;

// show progress default yes
@property (nonatomic, assign) BOOL showLoadingProgressView;
// set progress color. default color
@property (nonatomic, strong) UIColor *progressColor;
//@property (nonatomic, assign)CGFloat progressHeight;
// default yes 是否显示导航栏title
@property (nonatomic, assign) BOOL isUseWebPageTitle;
// 导航栏titile长度
@property (assign, nonatomic) NSUInteger maxAllowedTitleLength;

// 网络请求小菊花  default YES
@property (nonatomic, assign) BOOL activityIndicatorVisible;

// 是否禁用返回手势
@property (nonatomic, assign) BOOL enableGOBackGesture;
///
// 是否显示网页来源 default YES
@property(assign, nonatomic) BOOL showHostLabel;

@property (nonatomic, weak) id<NYWebViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL openCache;   //缓存

- (void)loadURL:(NSURL *)pageURL;

/** 重新加载webview */
- (void)reload;

/** 返回上一级 */
- (void)goback;
/** 下一级 */
- (void)goForward;

/** 读取本地磁盘的cookies，包括WKWebview的cookies和sharedHTTPCookieStorage存储的cookies */
- (NSMutableArray *)WKSharedHTTPCookieStorage;

/** 提供cookies插入，用于loadRequest 网页之前*/
- (void)setcookie:(NSHTTPCookie *)cookie;

/** 清除所有的cookies */
- (void)deleteAllWKCookies;

/** 清除所有缓存（cookie除外） */
- (void)deleteAllWebCache;


/** JS 调用OC 添加 messageHandler
 添加 js 调用 OC，addScriptMessageHandler:name:有两个参数，第一个参数是 userContentController的代理对象，第二个参数是 JS 里发送 postMessage 的对象。添加一个脚本消息的处理器,同时需要在 JS 中添加，window.webkit.messageHandlers.<name>.postMessage(<messageBody>)才能起作用。
 @param nameArr JS 里发送 postMessage 的对象数组，可同时添加多个对象
 */
- (void)addScriptMessageHandlerWithName:(NSArray<NSString *> *)nameArr;
- (void)addScriptMessageHandlerWithName:(NSArray<NSString *> *)nameArr observeValue:(MessageBlock)callback;
- (void)removeScriptMessageHandlerForName:(NSString *)name;


/**
 *  调用JS方法（无返回值）
 *
 *  @param jsStr 调用JS的字符串可以是方法名称，或者单独的js语句  
 */
- (void)webViewControllerCallJS:(nonnull NSString *)jsStr;

/**
 *  调用JS方法（可处理返回值）
 *
 *  @param jsStr 调用JS的字符串可以是方法名称，或者单独的js语句
 *  @param handler  回调block
 */
- (void)webViewControllerCallJS:(nonnull NSString *)jsStr handler:(void (^)(id response, NSError *error))handler;

@end


@interface NYWebViewController (NavigationControllerBar)

@property (nonatomic, strong) UIColor *navTintColor;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property(assign, nonatomic) BOOL showsNavigationCloseBarButtonItem;
@property(assign, nonatomic) BOOL showsNavigationBackBarButtonItemTitle;

@end

