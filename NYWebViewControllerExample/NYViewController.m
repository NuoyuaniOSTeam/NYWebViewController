//
//  NYViewController.m
//  NYWebViewController
//
//  Created by ZhangJie on 2018/3/23.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import "NYViewController.h"
#import "NYWebViewController.h"
#import "NSURL+NYTool.h"
#define iOS10_0Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)

@interface NYViewController ()<UITableViewDelegate, UITableViewDataSource, NYWebViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arr;
@property (nonatomic, strong) NYWebViewController *webVC;
@property (nonatomic, strong) UIView *tableFooterView;
@end

@implementation NYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.arr = @[@"测试一",@"测试二",@"测试三"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"testCell"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:0 target:nil action:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"testCell"];
    if(cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"testCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = self.arr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:{
            NYWebViewController *vc = [[NYWebViewController alloc] initWithURL:[NSURL URLWithString:@"https://nyonline.cn"]];
            vc.progressColor = [UIColor greenColor];
            vc.showLoadingProgressView = NO;
        
            [self.navigationController pushViewController:vc animated:YES];
            break;
            
        }
        case 1:{
            NYWebViewController *webVC = [[NYWebViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
            [self.navigationController pushViewController:webVC animated:YES];
            break;
        }
            
        case 2:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"html"];
            _webVC = [[NYWebViewController alloc] initWithLocalHtmlURL:[NSURL fileURLWithPath:path]];
            [self addScriptMessageHandler];
            [self.navigationController pushViewController:_webVC animated:YES];
            _webVC.delegate = self;
            _webVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"调用JS" style:0 target:self action:@selector(rightClick)];
            break;
        }
        default:
            break;
    }
    
}

- (void)webViewController:(NYWebViewController *)webViewController didReceiveScriptMessage:(NYScriptMessage *)message {
    NSDictionary *dict = message.params;
    if ([message.method isEqualToString:@"share"]) {
        NSString *textToShare = @"分享的标题。";
        NSURL *urlToShare = [NSURL URLWithString:[dict objectForKey:@"url"]];
        NSArray *activityItems = @[textToShare, urlToShare];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
        [self presentViewController:activityVC animated:YES completion:nil];
        activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            if (completed) {
                NSLog(@"completed");
                //分享 成功
            } else  {
                NSLog(@"cancled");
                //分享 取消
            }
        };
    }else if ([message.method isEqualToString:@"openset"]) {
        [self openAppSetting];
    }else if([message.method isEqualToString:@"appStroe"]){
        NSString *str = [message.params objectForKey:@"url"];
        [_webVC loadURL:[NSURL URLWithString:str]];
    }else if([message.method isEqualToString:@"tobackpage"]){
        [self.navigationController popViewControllerAnimated:YES];
    }else if([message.method isEqualToString:@"hello"]) {
        NSLog(@"%@",message);
    }
}

- (void)addScriptMessageHandler {
    [_webVC addScriptMessageHandlerWithName:@[@"share",@"webViewApp",@"exit"]];
//    [_webVC addScriptMessageHandlerWithName:@[@"share",@"webViewApp",@"exit"] observeValue:^(WKUserContentController *userContentController, NYScriptMessage *message) {
//        if ([message.method isEqualToString:@"share"]) {
//
//        }
//    }];
}


- (void)rightClick {
    [self testcallJS:_webVC];
}

- (void)testcallJS:(NYWebViewController *) vc {
    //NYWebViewController *v = vc;
    [vc webViewControllerCallJS:@"callJs('oc原生调用js')" handler:^(id response, NSError *error) {
        NSLog(@"调用js回调事件");
    }];
}

- (void)openAppSetting{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        if (iOS10_0Later) {
            [self openUrl:url completion:^(BOOL success) {
                NSLog(@"跳转设置%@",success?@"成功":@"失败");
            }];
        }else{
            [self openUrl:url];
        }
    }
}

//iOS10之前跳转
- (void)openUrl:(NSURL *)url{
    [[UIApplication sharedApplication] openURL:url];
}

//iOS10之后跳转
- (void)openUrl:(NSURL *)url completion:(void(^)(BOOL success))block{
    [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@NO} completionHandler:^(BOOL success) {
        if(block)
            block(success);
    }];
}

- (void)webViewController:(NYWebViewController *)webViewController decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"URL: %@", navigationAction.request.URL.absoluteString);
    NSString *scheme = navigationAction.request.URL.scheme.lowercaseString;
    if (![scheme containsString:@"http"] && ![scheme containsString:@"about"] && ![scheme containsString:@"file"]) {
        // 对于跨域，需要手动跳转， 用系统浏览器（Safari）打开
        if ([navigationAction.request.URL.host.lowercaseString isEqualToString:@"itunes.apple.com"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否打开appstore？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ActionOne = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [_webVC goback];
            }];
            UIAlertAction *ActionTwo = [UIAlertAction actionWithTitle:@"去下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [NSURL SafariOpenURL:navigationAction.request.URL];
            }];
            [alert addAction:ActionOne];
            [alert addAction:ActionTwo];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            });
            
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        
        [NSURL openURL:navigationAction.request.URL];
        // 不允许web内跳转
        decisionHandler(WKNavigationActionPolicyCancel);
        
    } else {
        
        if ([navigationAction.request.URL.host.lowercaseString isEqualToString:@"itunes.apple.com"])
        {
            [NSURL openURL:navigationAction.request.URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        
        decisionHandler(WKNavigationActionPolicyAllow);
    }
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
