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
/// Called when web view will go back.
///
/// @param webViewController a web view controller.
- (void)webViewControllerWillGoBack:(NYWebViewController *)webViewController;
/// Called when web view will go forward.
///
/// @param webViewController a web view controller.
- (void)webViewControllerWillGoForward:(NYWebViewController *)webViewController;
/// Called when web view will reload.
///
/// @param webViewController a web view controller.
- (void)webViewControllerWillReload:(NYWebViewController *)webViewController;
/// Called when web view will stop load.
///
/// @param webViewController a web view controller.
- (void)webViewControllerWillStop:(NYWebViewController *)webViewController;
/// Called when web view did start loading.
///
/// @param webViewController a web view controller.
- (void)webViewControllerDidStartLoad:(NYWebViewController *)webViewController;
/// Called when web view did finish loading.
///
/// @param webViewController a web view controller.
- (void)webViewControllerDidFinishLoad:(NYWebViewController *)webViewController;
/// Called when web viw did fail loading.
///
/// @param webViewController a web view controller.
///
/// @param error a failed loading error.
- (void)webViewController:(NYWebViewController *)webViewController didFailLoadWithError:(NSError *)error;

// js
- (void)webViewController:(NYWebViewController *)webViewController didReceiveScriptMessage:(NSString *)message;
@end


@interface NYWebViewController : UIViewController

/* url */
@property (nonatomic, strong) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithRequest:(NSURLRequest *)request;
- (instancetype)initWithURL:(NSURL *)URL configuration:(WKWebViewConfiguration *)configuration;

// show progress default yes
@property (nonatomic, assign) BOOL showLoadingProgressView;

// set progress color. default color
@property (nonatomic, strong) UIColor *progressColor;

// default yes
@property (nonatomic, assign) BOOL isUseWebPageTitle;

@property (nonatomic, assign) BOOL activityIndicatorVisible;

@property (assign, nonatomic) NSUInteger maxAllowedTitleLength;

@property (nonatomic, weak) id<NYWebViewControllerDelegate> delegate;

/**
 *  调用JS方法（无返回值）
 *
 *  @param jsStr 调用JS的字符串可以是方法名称，或者单独的js语句  
 */
- (void)callJS:(nonnull NSString *)jsStr;

/**
 *  调用JS方法（可处理返回值）
 *
 *  @param jsStr 调用JS的字符串可以是方法名称，或者单独的js语句
 *  @param handler  回调block
 */
- (void)callJS:(nonnull NSString *)jsStr handler:(nullable void(^)(__nullable id response))handler;

@end


@interface NYWebViewController (SubclassingHooks)
/// Called when web view will go back. Do not call this directly. Same to the bottom methods.
/// @discussion 使用的时候需要子类化，并且调用super的方法!切记！！！
///
- (void)willGoBack NS_REQUIRES_SUPER;
/// Called when web view will go forward. Do not call this directly.
///
- (void)willGoForward NS_REQUIRES_SUPER;
/// Called when web view will reload. Do not call this directly.
///
- (void)willReload NS_REQUIRES_SUPER;
/// Called when web view will stop load. Do not call this directly.
///
- (void)willStop NS_REQUIRES_SUPER;
/// Called when web view did start loading. Do not call this directly.
///
- (void)didStartLoad NS_REQUIRES_SUPER NS_DEPRECATED_IOS(2_0, 8_0);
/// Called when web view(WKWebView) did start loading. Do not call this directly.
///
/// @param navigation Navigation object of the current request info.
- (void)didStartLoadWithNavigation:(WKNavigation *)navigation NS_REQUIRES_SUPER NS_AVAILABLE(10_10, 8_0);
/// Called when web view did finish loading. Do not call this directly.
///
- (void)didFinishLoad NS_REQUIRES_SUPER;
/// Called when web viw did fail loading. Do not call this directly.
///
/// @param error a failed loading error.
- (void)didFailLoadWithError:(NSError *)error NS_REQUIRES_SUPER;
@end


/**
 WebCache clearing.
 */
@interface NYWebViewController (WebCache)
// Clear cache data of web view.

// @param completion completion block.
+ (void)clearWebCacheCompletion:(dispatch_block_t _Nullable)completion;
@end

@interface NYWebViewController (Security)
/// Challenge handler for the credential.
//@property(copy, nonatomic, nullable) WKWebViewDidReceiveAuthenticationChallengeHandler challengeHandler;
/// The security policy used by created session to evaluate server trust for secure connections.
/// `AXWebViewController` uses the `defaultPolicy` unless otherwise specified.
@property(readwrite, nonatomic, nullable) AXSecurityPolicy *securityPolicy;
@end
