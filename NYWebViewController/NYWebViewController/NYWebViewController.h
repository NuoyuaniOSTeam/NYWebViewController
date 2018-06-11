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
//typedef NSURLSessionAuthChallengeDisposition (^WKWebViewDidReceiveAuthenticationChallengeHandler)(WKWebView *webView, NSURLAuthenticationChallenge *challenge, NSURLCredential * _Nullable __autoreleasing * _Nullable credential);

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
- (void)webViewController:(NYWebViewController *)webViewController didReceiveScriptMessage:(NSString *)message;

@end

@interface NYWebViewController : UIViewController

/* url */
@property (nonatomic, strong) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithRequest:(NSURLRequest *)request;
- (instancetype)initWithURL:(NSURL *)URL configuration:(WKWebViewConfiguration *)configuration;
- (instancetype)initWithRequest:(NSURLRequest *)request configuration:(WKWebViewConfiguration *)configuration;

// show progress default yes
@property (nonatomic, assign) BOOL showLoadingProgressView;
// set progress color. default color
@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, assign)CGFloat progressHeight;
// default yes 是否显示导航栏title
@property (nonatomic, assign) BOOL isUseWebPageTitle;
// 导航栏titile长度
@property (assign, nonatomic) NSUInteger maxAllowedTitleLength;

// 网络请求小菊花  default yes
@property (nonatomic, assign) BOOL activityIndicatorVisible;

// 是否禁用返回手势
@property (nonatomic, assign) BOOL enableGOBackGesture;
///
// 是否显示网页来源
@property(assign, nonatomic) BOOL showsBackgroundLabel;

@property (nonatomic, weak) id<NYWebViewControllerDelegate> delegate;


- (void)reloadWebView;
- (void)setCookie:(NSString *)cookieStr;

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
- (void)webViewControllerCallJS:(nonnull NSString *)jsStr handler:(nullable void(^)(__nullable id response))handler;

@end


@interface NYWebViewController (NavigationControllerBar)

@property (nonatomic, strong) UIColor *navTintColor;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property(assign, nonatomic) BOOL showsNavigationCloseBarButtonItem;
@property(assign, nonatomic) BOOL showsNavigationBackBarButtonItemTitle;

@end

/**
 WebCache clearing.
 */
@interface NYWebViewController (WebCache)
/** 读取本地磁盘的cookies，包括WKWebview的cookies和sharedHTTPCookieStorage存储的cookies */
- (NSMutableArray *)WKSharedHTTPCookieStorage;

/** 提供cookies插入，用于loadRequest 网页之前*/
- (void)setcookie:(NSHTTPCookie *)cookie;

/** 清除所有的cookies */
- (void)deleteAllWKCookies;

/** 清除所有缓存（cookie除外） */
- (void)deleteAllWebCache;


@end

@interface NYWebViewController (Security)
/// Challenge handler for the credential.
//@property(copy, nonatomic, nullable) WKWebViewDidReceiveAuthenticationChallengeHandler challengeHandler;
/// The security policy used by created session to evaluate server trust for secure connections.
/// `AXWebViewController` uses the `defaultPolicy` unless otherwise specified.
@property(readwrite, nonatomic, nullable) AXSecurityPolicy *securityPolicy;
@end
