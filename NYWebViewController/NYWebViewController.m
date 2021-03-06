//
//  NYWebViewController.m
//  NYWebViewController
//
//  Created by ZhangJie on 2018/3/22.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import "NYWebViewController.h"
#import <objc/runtime.h>
#import "NYWebViewController+Navigation.h"

#ifndef kBY404NotFoundHTMLPath
#define kBY404NotFoundHTMLPath [[NSBundle bundleForClass:NSClassFromString(@"NYWebViewController")] pathForResource:@"html.bundle/404" ofType:@"html"]
#endif
#ifndef kBYNetworkErrorHTMLPath
#define kBYNetworkErrorHTMLPath [[NSBundle bundleForClass:NSClassFromString(@"NYWebViewController")] pathForResource:@"html.bundle/neterror" ofType:@"html"]
#endif

#ifndef NYWKCookiesKey
#define NYWKCookiesKey @"NYWKCookiesKey_AAA"
#endif

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
# define NSLog(...) {}
#endif

#define iphoneX_5_8 ([UIScreen mainScreen].bounds.size.height==812.0f)
#define defaultMaxTitleLength 10

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
@interface UIProgressView (WebKit)
/// Hidden when progress approach 1.0 Default is NO.
@property(assign, nonatomic) BOOL ny_hiddenWhenProgressApproachFullSize;
@end
#endif

static MessageBlock messageCallback = nil;
@interface NYWebViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>{
     //WKWebViewDidReceiveAuthenticationChallengeHandler _challengeHandler;
    WKWebViewConfiguration *_configuration;
    UIBarButtonItem * __weak _doneItem;
}
//@property (strong, nonatomic) CALayer *progresslayer;
@property (nonatomic, strong) WKWebViewConfiguration *config;
@property (nonatomic, retain) NSArray *messageHandlerName;
@property (nonatomic, strong) UILabel *hostLable;

@property (nonatomic, strong) UIProgressView *progressView;

/// Navigation back bar button item.
@property(strong, nonatomic) UIBarButtonItem *navigationBackBarButtonItem;
/// Navigation close bar button item.
@property(strong, nonatomic) UIBarButtonItem *navigationCloseBarButtonItem;

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
        self.maxAllowedTitleLength = defaultMaxTitleLength;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    if ([self init]) {
        self.url = url;
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addBackButton]; //添加返回按钮
    
    [self.view addSubview:self.webView];
    if (self.showHostLabel) {
        [self.webView insertSubview:self.hostLable belowSubview:self.webView.scrollView];
    }
    if ([[self.url scheme] isEqualToString:@"file"]) {
        [self loadLocalHTMLURL:_url];
    }else{
        [self loadURL:_url];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

+ (UIButton *)backButtonForNav
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"NYWebViewController.bundle/backItemImage"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"NYWebViewController.bundle/backItemImage_hl"] forState:UIControlStateHighlighted];
    btn.frame = CGRectMake(0, 0, 40, 44);
    return btn;
}

- (void)addBackButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateHighlighted];
    btn.frame = CGRectMake(0, 0, 40, 44);
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)btnClick:(UIButton *)button
{
    if (self.navigationController) {
        if ([self.webView canGoBack]) {
            [self.webView goBack];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
#pragma mark - load html
- (void)loadURL:(NSURL *)pageURL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pageURL];
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
        _webView.scrollView.backgroundColor = [UIColor clearColor];
       
        if (self.showLoadingProgressView) {
           [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
//            [self initWithProgressView];
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
        _config.preferences = [[WKPreferences alloc] init];
        _config.preferences.minimumFontSize = 10;
        _config.preferences.javaScriptEnabled = YES; //是否支持 JavaScript
        _config.processPool = [[WKProcessPool alloc] init];
        NSMutableString *javascript = [NSMutableString string];
        [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [_config.userContentController addUserScript:noneSelectScript];
    }
    return _config;
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        if (progress >= _progressView.progress) {
            [_progressView setProgress:progress animated:YES];
        } else {
            [_progressView setProgress:progress animated:NO];
        }
    }
    else if ([keyPath isEqualToString:@"title"]){
        if (object == self.webView) {
            if ([self isUseWebPageTitle]) {
                NSString *title = [self.webView title];
                if (self.maxAllowedTitleLength > defaultMaxTitleLength) {
                       if (title.length > defaultMaxTitleLength) {
                                title = [[title substringToIndex:defaultMaxTitleLength -1] stringByAppendingString:@"…"];
                       }
                } else if (self.maxAllowedTitleLength <= defaultMaxTitleLength){
                    if (title.length > self.maxAllowedTitleLength) {
                        title = [[title substringToIndex:self.maxAllowedTitleLength-1] stringByAppendingString:@"…"];
                    }
                }
                self.title = title;
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
    self.navigationItem.title = @"加载中...";
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerDidStartLoad:)]) {
        [_delegate webViewControllerDidStartLoad:self];
    }
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:didStartProvisionalNavigation:)]) {
        [self.delegate webViewController:self didStartProvisionalNavigation:navigation];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:didCommitNavigation:)]) {
        [self.delegate webViewController:self didCommitNavigation:navigation];
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSLog(@"%s", __FUNCTION__);
    [self performSelector:@selector(updateHostLable) withObject:nil afterDelay:0.3];
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
    
    [self performSelector:@selector(updateHostLable) withObject:nil afterDelay:0.3];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:didFinishNavigation:)]) {
        [self.delegate webViewController:self didFinishNavigation:navigation];
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
    [self performSelector:@selector(updateHostLable) withObject:nil afterDelay:0.3];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:didFailProvisionalNavigation:withError:)]) {
        [self.delegate webViewController:self didFailProvisionalNavigation:navigation withError:error];
    }
}

/**
 *  接收到服务器跳转请求之后调用
 *
 *  @param webView      实现该代理的webview
 *  @param navigation   当前navigation
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:didReceiveServerRedirectForProvisionalNavigation:)]) {
        [self.delegate webViewController:self didReceiveServerRedirectForProvisionalNavigation:navigation ];
    }
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [self.delegate webViewController:self decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler ];
    }else{
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
    
}

/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
        NSLog(@"URL: %@", navigationAction.request.URL.absoluteString);
        //NSString *scheme = navigationAction.request.URL.scheme.lowercaseString;
        if ([navigationAction.request.URL.host.lowercaseString isEqualToString:@"itunes.apple.com"]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否打开appstore？" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ActionOne = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [webView goBack];
                }];
                UIAlertAction *ActionTwo = [UIAlertAction actionWithTitle:@"去下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (![[UIApplication sharedApplication] openURL:navigationAction.request.URL]) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"打开失败" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *ActionTrue = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                        [alert addAction:ActionTrue];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                        });
                    }
                    
                }];
                [alert addAction:ActionOne];
                [alert addAction:ActionTwo];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                });
                
                decisionHandler(WKNavigationActionPolicyCancel);
                return;            
        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:decidePolicyForNavigationAction:decisionHandler:)]) {
                [self.delegate webViewController:self decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
            }else{
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        }
}



#pragma  mark - Navigation
- (void)updateHostLable
{
    if (_showHostLabel && self.hostLable) {
        _hostLable.center = CGPointMake(self.webView.scrollView.center.x, 110);
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        [self.webView insertSubview:self.hostLable belowSubview:self.webView.scrollView];
    }
}

- (UIBarButtonItem *)navigationCloseBarButtonItem {
    if (_navigationCloseBarButtonItem) return _navigationCloseBarButtonItem;
    if (self.navigationItem.rightBarButtonItem == _doneItem && self.navigationItem.rightBarButtonItem != nil) {
        _navigationCloseBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(doneButtonClicked:)];
    } else {
        _navigationCloseBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(navigationIemHandleClose:)];
    }
    return _navigationCloseBarButtonItem;
}

- (UIBarButtonItem *)navigationBackBarButtonItem {
    if (_navigationBackBarButtonItem) return _navigationBackBarButtonItem;
    UIImage* backItemImage = [[[UINavigationBar appearance] backIndicatorImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]?:[[UIImage imageNamed:@"NYWebViewController.bundle/backItemImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(backItemImage.size, NO, backItemImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, backItemImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, backItemImage.size.width, backItemImage.size.height);
    CGContextClipToMask(context, rect, backItemImage.CGImage);
    [[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage* backItemHlImage = newImage?:[[UIImage imageNamed:@"NYWebViewController.bundle/backItemImage-hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    NSDictionary *attr = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
    if (attr) {
        [backButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"返回" attributes:attr] forState:UIControlStateNormal];
        UIOffset offset = [[UIBarButtonItem appearance] backButtonTitlePositionAdjustmentForBarMetrics:UIBarMetricsDefault];
        backButton.titleEdgeInsets = UIEdgeInsetsMake(offset.vertical, offset.horizontal, 0, 0);
        backButton.imageEdgeInsets = UIEdgeInsetsMake(offset.vertical, offset.horizontal, 0, 0);
    } else {
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    }
    [backButton setImage:backItemImage forState:UIControlStateNormal];
    [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
    [backButton sizeToFit];
    
    [backButton addTarget:self action:@selector(navigationItemHandleBack:) forControlEvents:UIControlEventTouchUpInside];
    _navigationBackBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return _navigationBackBarButtonItem;
}

- (void)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)navigationIemHandleClose:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationItemHandleBack:(UIBarButtonItem *)sender {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    if ([_webView canGoBack]) {
        [_webView goBack];
//        _navigation = [_webView goBack];
        return;
    }
#else
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        return;
    }
#endif
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark - progress
- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
}

- (UIProgressView *)progressView {
    if (_progressView) return _progressView;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - 2, navigationBarBounds.size.width, 2);
    _progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    _progressView.trackTintColor = [UIColor clearColor];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _progressView.progressTintColor = self.progressColor;
    _progressView.ny_hiddenWhenProgressApproachFullSize = YES;
    return _progressView;
}

- (void)setShowLoadingProgressView:(BOOL)showLoadingProgressView {
    _showLoadingProgressView = showLoadingProgressView;
    if (!showLoadingProgressView) {
        self.progressView.ny_hiddenWhenProgressApproachFullSize = NO;
        self.progressView.hidden = YES;
    }
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

- (void)addScriptMessageHandlerWithName:(NSArray<NSString *> *)names {
    if (_config.userContentController) return;
    /* removeScriptMessageHandlerForName 同时使用，否则内存泄漏 */
    for (NSString * objStr in names) {
        [self.config.userContentController addScriptMessageHandler:self name:objStr];
    }
    self.messageHandlerName = names;
}

- (void)addScriptMessageHandlerWithName:(NSArray<NSString *> *)names observeValue:(MessageBlock)messageCallback {
    messageCallback = messageCallback;
    [self addScriptMessageHandlerWithName:names];
}

/**
 *  注销 注册过的js回调oc通知方式，适用于 iOS8 之后
 */
- (void)removeScriptMessageHandlerForName:(NSString *)name {
    [_config.userContentController removeScriptMessageHandlerForName:name];
}

- (void)webViewControllerCallJS:(NSString *)jsStr {
    [self webViewControllerCallJS:jsStr completeBlock:nil];
}

- (void)webViewControllerCallJS:(NSString *)jsStr completeBlock:(void (^)(id response, NSError *error))completeBlock {
    NSLog(@"call js:%@",jsStr);
    // NSString *inputValueJS = @"document.getElementsByName('input')[0].attributes['value'].value";
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        completeBlock ? completeBlock(response,error) : NULL;
    }];
    
}

#pragma mark -
#pragma mark - WKWebview 缓存 cookie／cache
- (void)setcookie:(NSHTTPCookie *)cookie
{
    @autoreleasepool {
        if (@available(iOS 11.0, *)) {
            WKHTTPCookieStore *cookieStore = self.webView.configuration.websiteDataStore.httpCookieStore;
            [cookieStore setCookie:cookie completionHandler:nil];
            return;
        }
        
        NSMutableArray *TempCookies = [NSMutableArray array];
        NSMutableArray *localCookies =[NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: NYWKCookiesKey]];
        for (int i = 0; i < localCookies.count; i++) {
            NSHTTPCookie *TempCookie = [localCookies objectAtIndex:i];
            if ([cookie.name isEqualToString:TempCookie.name]) {
                [localCookies removeObject:TempCookie];
                i--;
                break;
            }
        }
        [TempCookies addObjectsFromArray:localCookies];
        [TempCookies addObject:cookie];
        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: TempCookies];
        [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:NYWKCookiesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark - dealloc
- (void)dealloc {
    [_webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _webView.UIDelegate = nil;
    _webView.navigationDelegate = nil;
    if (self.showLoadingProgressView) {
        [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    [_webView removeObserver:self forKeyPath:@"title"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
@implementation UIProgressView (WebKit)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Inject "-popViewControllerAnimated:"
        Method originalMethod = class_getInstanceMethod(self, @selector(setProgress:));
        Method swizzledMethod = class_getInstanceMethod(self, @selector(ny_setProgress:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        originalMethod = class_getInstanceMethod(self, @selector(setProgress:animated:));
        swizzledMethod = class_getInstanceMethod(self, @selector(ny_setProgress:animated:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)ny_setProgress:(float)progress {
    [self ny_setProgress:progress];
    
    [self checkHiddenWhenProgressApproachFullSize];
}

- (void)ny_setProgress:(float)progress animated:(BOOL)animated {
    [self ny_setProgress:progress animated:animated];
    
    [self checkHiddenWhenProgressApproachFullSize];
}

- (void)checkHiddenWhenProgressApproachFullSize {
    if (!self.ny_hiddenWhenProgressApproachFullSize) {
        return;
    }
    
    float progress = self.progress;
    if (progress < 1) {
        if (self.hidden) {
            self.hidden = NO;
        }
    } else if (progress >= 1) {
        [UIView animateWithDuration:0.35 delay:0.15 options:7 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                self.hidden = YES;
                self.progress = 0.0;
                self.alpha = 1.0;
            }
        }];
    }
}

- (BOOL)ny_hiddenWhenProgressApproachFullSize {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setNy_hiddenWhenProgressApproachFullSize:(BOOL)ny_hiddenWhenProgressApproachFullSize {
    objc_setAssociatedObject(self, @selector(ny_hiddenWhenProgressApproachFullSize), @(ny_hiddenWhenProgressApproachFullSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
#endif











