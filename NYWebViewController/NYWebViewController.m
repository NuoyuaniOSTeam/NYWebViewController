//
//  NYWebViewController.m
//  NYWebViewController
//
//  Created by ZhangJie on 2018/3/22.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import "NYWebViewController.h"
#import <objc/runtime.h>
#import "WKWebView+NYWebCookie.h"
#import "WKWebView+NYWebCache.h"

#ifndef kBY404NotFoundHTMLPath
#define kBY404NotFoundHTMLPath [[NSBundle bundleForClass:NSClassFromString(@"NYWebViewController")] pathForResource:@"html.bundle/404" ofType:@"html"]
#endif
#ifndef kBYNetworkErrorHTMLPath
#define kBYNetworkErrorHTMLPath [[NSBundle bundleForClass:NSClassFromString(@"NYWebViewController")] pathForResource:@"html.bundle/neterror" ofType:@"html"]
#endif

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
# define NSLog(...) {}
#endif

#define iphoneX_5_8 ([UIScreen mainScreen].bounds.size.height==812.0f)
#define kProgressViewHeight 1.5f


static MessageBlock messageCallback = nil;
@interface NYWebViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>{
     //WKWebViewDidReceiveAuthenticationChallengeHandler _challengeHandler;
    NYSecurityPolicy *_securityPolicy;
    WKWebViewConfiguration *_configuration;
    BOOL _isLoadLocal;
}

@property (nonatomic, strong) WKWebView *webView;
@property (strong, nonatomic) CALayer *progresslayer;
@property (nonatomic, strong) WKWebViewConfiguration *config;
@property (nonatomic, retain) NSArray *messageHandlerName;
@property (nonatomic, strong) UILabel *hostLable;


@end

@implementation NYWebViewController

#pragma mark - init
- (instancetype)init {
    if (self = [super init]) {
        self.progressColor = [UIColor colorWithRed:22.f / 255.f green:126.f / 255.f blue:251.f / 255.f alpha:.8];
        self.showLoadingProgressView = YES;
        self.isUseWebPageTitle = YES;
        self.activityIndicatorVisible = YES;
        self.showHostLabel = YES;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    if ([self init]) {
        self.url = url;
    }
    return self;
}

- (instancetype)initWithLocalHtmlURL:(NSURL *)url {
    if ([self init]) {
        self.url = url;
        _isLoadLocal = YES;
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.webView];
    });
    
    if (self.showHostLabel) {
        [self.webView insertSubview:self.hostLable belowSubview:self.webView.scrollView];
    }
    if (_isLoadLocal) {
        [self loadLocalHTMLURL:_url];
    }else{
        [self loadURL:_url];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - load html
- (void)loadURL:(NSURL *)pageURL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pageURL];
    [request setValue:@"" forHTTPHeaderField:@"Cookie"];
    if (_showHostLabel && _hostLable && request.URL.host) {
        _hostLable.text = [NSString stringWithFormat:@"网页由%@提供",request.URL.host];
        [_hostLable sizeToFit];
    }
    [self.webView loadRequest:request];
}

- (void)loadLocalHTMLURL:(NSURL *)url {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlstr = [[NSString alloc]initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlstr baseURL:baseURL];
}

- (UILabel *)hostLable{
    if (!_hostLable) {
        _hostLable = [UILabel new];
        _hostLable.text = nil;
        _hostLable.font = [UIFont systemFontOfSize:14];
        _hostLable.textColor = [UIColor darkGrayColor];
        [_hostLable sizeToFit];
    }
    return _hostLable;
}

- (WKWebView *)webView {

    if (!_webView) {
        _webView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:self.config];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
//        _webView.backgroundColor = [UIColor clearColor];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        if (self.showLoadingProgressView) {
            [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
            [self initWithProgressView];
        }
        
        if (self.isUseWebPageTitle) {
            [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
    
    return _webView;
}

- (WKWebViewConfiguration *)config {
    if (_config == nil) {
        _config = [[WKWebViewConfiguration alloc] init];
        _config.userContentController = [[WKUserContentController alloc] init];
        _config.allowsInlineMediaPlayback = YES;        // 允许在线播放
        //_config.allowsAirPlayForMediaPlayback = YES;  //允许视频播放
        _config.preferences = [[WKPreferences alloc] init];
        _config.preferences.minimumFontSize = 10;
        _config.preferences.javaScriptEnabled = YES; //是否支持 JavaScript
        _config.processPool = [[WKProcessPool alloc] init];
        NSMutableString *javascript = [NSMutableString string];
        [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
        //[javascript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [_config.userContentController addUserScript:noneSelectScript];
    }
    return _config;
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progresslayer.opacity = 1;
        //不要让进度条倒着走...有时候goback会出现这种情况
        if ([change[@"new"] floatValue] < [change[@"old"] floatValue]) {
            return;
        }
        self.progresslayer.frame = CGRectMake(0, 0, self.view.bounds.size.width * [change[@"new"] floatValue], kProgressViewHeight);
        NSLog(@"%f",[change[@"new"] floatValue]);
        if ([change[@"new"] floatValue] == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progresslayer.opacity = 0;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progresslayer.frame = CGRectMake(0, 0, 0, kProgressViewHeight);
            });
        }
    }
    else if ([keyPath isEqualToString:@"title"]){
        if (object == self.webView) {
            if ([self isUseWebPageTitle]) {
                self.title = self.webView.title;
            }
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

#pragma mark - action
- (void)willGoBack{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillGoBack:)]) {
        [_delegate webViewControllerWillGoBack:self];
    }
}
- (void)willGoForward{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillGoForward:)]) {
        [_delegate webViewControllerWillGoForward:self];
    }
}
- (void)willReload{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillReload:)]) {
        [_delegate webViewControllerWillReload:self];
    }
}
- (void)willStop{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillStop:)]) {
        [_delegate webViewControllerWillStop:self];
    }
}

- (void)didStartLoad{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerDidStartLoad:)]) {
        [_delegate webViewControllerDidStartLoad:self];
    }
}

- (void)goback{
    [self willGoBack];
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}

- (void)goForward {
    [self willGoForward];
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}

- (void)reload {
    [self willReload];
    [self loadURL:_url];
}

- (void)didStartLoadWithNavigation:(WKNavigation *)navigation {
    [self didStartLoad];
}


- (void)didFailLoadWithError:(NSError *)error{
    if (error.code == NSURLErrorCancelled) {
        [_webView reload];
        return;
    }
    if (error.code == NSURLErrorCannotFindHost) {// 404
        [self loadURL:[NSURL fileURLWithPath:kBY404NotFoundHTMLPath]];
    } else {
        [self loadURL:[NSURL fileURLWithPath:kBYNetworkErrorHTMLPath]];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(webViewController:didFailLoadWithError:)]) {
        [_delegate webViewController:self didFailLoadWithError:error];
    }
}


#pragma mark - UIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(nonnull WKWebViewConfiguration *)configuration forNavigationAction:(nonnull WKNavigationAction *)navigationAction windowFeatures:(nonnull WKWindowFeatures *)windowFeatures {
    NSLog(@"createWebViewWithConfiguration");
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// 处理js里的alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message ? message : @"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    
    [self nyPresentViewController:alertController animated:YES];
}

// 处理js里的Confirm
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(nonnull NSString *)message initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(BOOL))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message ? message : @"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    
    [self nyPresentViewController:alertController animated:YES];
}
// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self nyPresentViewController:alertController animated:YES];
}

- (void)nyPresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag{
    
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:viewControllerToPresent animated:YES completion:nil];
    });
}



#pragma mark - WKNavigationDelegate

/**
 *  页面开始加载时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {

    NSLog(@"%s：%@", __FUNCTION__,webView.URL);
    if (_activityIndicatorVisible) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

/**
 *  当内容开始返回时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  页面加载完成之后调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
    
    if (_activityIndicatorVisible) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    if (_showHostLabel && self.hostLable) {
        _hostLable.center = CGPointMake(self.webView.scrollView.center.x, 125);
    }

}

/**
 *  加载失败时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 *  @param error      错误
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"%s%@", __FUNCTION__,error);
    if (_activityIndicatorVisible) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    [self didFailLoadWithError:error];

}

/**
 *  接收到服务器跳转请求之后调用
 *
 *  @param webView      实现该代理的webview
 *  @param navigation   当前navigation
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  在收到响应后，决定是否跳转
 *
 *  @param webView            实现该代理的webview
 *  @param navigationResponse 当前navigation
 *  @param decisionHandler    是否跳转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSLog(@"%s", __FUNCTION__);
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.delegate webViewController:self decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
//    NSLog(@"URL: %@", navigationAction.request.URL.absoluteString);
//    NSString *scheme = navigationAction.request.URL.scheme.lowercaseString;
//    if (![scheme containsString:@"http"] && ![scheme containsString:@"about"] && ![scheme containsString:@"file"]) {
//        // 对于跨域，需要手动跳转， 用系统浏览器（Safari）打开
//        if ([navigationAction.request.URL.host.lowercaseString isEqualToString:@"itunes.apple.com"]) {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否打开appstore？" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *ActionOne = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [webView goBack];
//            }];
//            UIAlertAction *ActionTwo = [UIAlertAction actionWithTitle:@"去下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [NSURL SafariOpenURL:navigationAction.request.URL];
//            }];
//            [alert addAction:ActionOne];
//            [alert addAction:ActionTwo];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
//            });
//
//            decisionHandler(WKNavigationActionPolicyCancel);
//            return;
//        }
//
//        [NSURL openURL:navigationAction.request.URL];
//        // 不允许web内跳转
//        decisionHandler(WKNavigationActionPolicyCancel);
//        
//    } else {
//
//        if ([navigationAction.request.URL.host.lowercaseString isEqualToString:@"itunes.apple.com"])
//        {
//            [NSURL openURL:navigationAction.request.URL];
//            decisionHandler(WKNavigationActionPolicyCancel);
//            return;
//        }
//
//        decisionHandler(WKNavigationActionPolicyAllow);
//    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"webViewWebContentProcessDidTerminate");
}

#pragma  mark - progress
- (void)initWithProgressView{
    UIView *progress = [[UIView alloc]initWithFrame:CGRectMake(0, (44-kProgressViewHeight), CGRectGetWidth(self.view.frame), kProgressViewHeight)];
    progress.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:progress];
    [progress.layer addSublayer:self.progresslayer];
}

- (CALayer *)progresslayer {
    if (!_progresslayer) {
        _progresslayer = [CALayer layer];
        _progresslayer.frame = CGRectMake(0, 0, 0, kProgressViewHeight);
        _progresslayer.backgroundColor = self.progressColor.CGColor;
    }
    return _progresslayer;
}

- (void)setShowLoadingProgressView:(BOOL)showLoadingProgressView {
    _showLoadingProgressView = showLoadingProgressView;
    self.progresslayer.hidden = !showLoadingProgressView;
}

#pragma mark - js
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"message:%@",message.body);
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        NSDictionary *body = (NSDictionary *)message.body;
        NYScriptMessage *msg = [NYScriptMessage new];
        [msg setValuesForKeysWithDictionary:body];
        if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:didReceiveScriptMessage:)]) {
            [self.delegate webViewController:self didReceiveScriptMessage:msg];
        }
        
        messageCallback ? messageCallback(userContentController,msg) : NULL;
    }
    
}

- (void)addScriptMessageHandlerWithName:(NSArray<NSString *> *)nameArr {
    if (_config.userContentController) return;
    /* removeScriptMessageHandlerForName 同时使用，否则内存泄漏 */
    for (NSString * objStr in nameArr) {
        [self.config.userContentController addScriptMessageHandler:self name:objStr];
    }
    self.messageHandlerName = nameArr;
}

- (void)addScriptMessageHandlerWithName:(NSArray<NSString *> *)nameArr observeValue:(MessageBlock)callback {
    messageCallback = callback;
    [self addScriptMessageHandlerWithName:nameArr];
}

/**
 *  注销 注册过的js回调oc通知方式，适用于 iOS8 之后
 */
- (void)removeScriptMessageHandlerForName:(NSString *)name {
    [_config.userContentController removeScriptMessageHandlerForName:name];
}

- (void)webViewControllerCallJS:(NSString *)jsStr {
    [self webViewControllerCallJS:jsStr handler:nil];
}

- (void)webViewControllerCallJS:(NSString *)jsStr handler:(void (^)(id response, NSError *error))handler {
    NSLog(@"call js:%@",jsStr);
    // NSString *inputValueJS = @"document.getElementsByName('input')[0].attributes['value'].value";
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        handler ? handler(response,error) : NULL;
    }];
    
}

#pragma mark -
#pragma mark - WKWebview 缓存 cookie／cache
- (void)setcookie:(NSHTTPCookie *)cookie
{
    [self.webView insertCookie:cookie];
}

/** 获取本地磁盘的cookies */
- (NSMutableArray *)WKSharedHTTPCookieStorage
{
    return [self.webView sharedHTTPCookieStorage];
}

/** 删除所有的cookies */
- (void)deleteAllWKCookies
{
    [self.webView deleteAllWKCookies];
}

/** 删除所有缓存不包括cookies */
- (void)deleteAllWebCache
{
    [self.webView deleteAllWebCache];
}

#pragma mark - dealloc
- (void)dealloc {
    [_webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _webView.UIDelegate = nil;
    _webView.navigationDelegate = nil;
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end














