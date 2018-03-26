//
//  NYWebViewController.m
//  NYWebViewController
//
//  Created by ZhangJie on 2018/3/22.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import "NYWebViewController.h"

@interface NYWebViewController ()<WKUIDelegate, WKNavigationDelegate>


@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@end

@implementation NYWebViewController

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    if ([self init]) {
        self.url = url;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self loadURL:_url];
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = _configuration;
        if (!config) {
            config = [[WKWebViewConfiguration alloc] init];
            config.preferences.minimumFontSize = 9.0;
            if ([config respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
                [config setAllowsInlineMediaPlayback:YES];
            }
            if (@available(iOS 9.0, *)) {
                if ([config respondsToSelector:@selector(setApplicationNameForUserAgent:)]) {
                    
                    [config setApplicationNameForUserAgent:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
                }
            } else {
                // Fallback on earlier versions
            }
            
            if (@available(iOS 10.0, *)) {
                if ([config respondsToSelector:@selector(setMediaTypesRequiringUserActionForPlayback:)]){
                    [config setMediaTypesRequiringUserActionForPlayback:WKAudiovisualMediaTypeNone];
                }
            } else if (@available(iOS 9.0, *)) {
                if ( [config respondsToSelector:@selector(setRequiresUserActionForMediaPlayback:)]) {
                    [config setRequiresUserActionForMediaPlayback:NO];
                }
            } else {
                if ( [config respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
                    [config setMediaPlaybackRequiresUserAction:NO];
                }
            }
            
        }
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        // Set auto layout enabled.
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
         _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        // Obverse the content offset of the scroll view.
        //[_webView addObserver:self forKeyPath:@"scrollView.contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        //[_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return _webView;
}

- (void)loadURL:(NSURL *)pageURL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pageURL];
    [_webView loadRequest:request];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
