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

@property (nonatomic, strong) WKWebView *webView;
/** show progress default yes */
@property (nonatomic, assign) BOOL showLoadingProgressView;

/** set progress color. default color*/
@property (nonatomic, strong) UIColor *progressColor;

//@property (nonatomic, assign)CGFloat progressHeight;
/** default yes 是否显示导航栏title*/
@property (nonatomic, assign) BOOL isUseWebPageTitle;
/** 导航栏titile长度(未完成) */
@property (assign, nonatomic) NSUInteger maxAllowedTitleLength;

// 网络请求小菊花  default YES
@property (nonatomic, assign) BOOL activityIndicatorVisible;

// 是否禁用返回手势 (未完成)
@property (nonatomic, assign) BOOL enableGOBackGesture;
///
// 是否显示网页来源 default YES
@property(assign, nonatomic) BOOL showHostLabel; // host显示优化（跳转多页）

@property (nonatomic, weak) id<NYWebViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL openCache;   //缓存（未完成）

- (void)loadURL:(NSURL *)pageURL;

/**  reload */
- (void)reload;

/**  goback */
- (void)goback;

/**  goForward */
- (void)goForward;

/** Reads cookies for local disks, including WKWebview cookies and sharedHTTPCookieStorage cookies */
- (NSMutableArray *)WKSharedHTTPCookieStorage;

/**  set cookie，in loadRequest before*/
- (void)setcookie:(NSHTTPCookie *)cookie;

/**  Clear all cookies */
- (void)deleteAllWKCookies;

/**  Clear all cache ，uncontains cookie。*/
- (void)deleteAllWebCache;

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

