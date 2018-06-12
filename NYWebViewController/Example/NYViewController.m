//
//  NYViewController.m
//  NYWebViewController
//
//  Created by ZhangJie on 2018/3/23.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import "NYViewController.h"
#import "NYWebViewController.h"

@interface NYViewController ()<UITableViewDelegate, UITableViewDataSource, NYWebViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arr;
@property (nonatomic, strong) NYWebViewController *webVC;
@end

@implementation NYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.arr = @[@"测试一",@"测试二",@"测试三"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"testCell"];
    self.tableView.tableFooterView = [UIView new];
    
    
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
            [self.navigationController pushViewController:vc animated:YES];
            break;
            
        }
        case 1:{
            NYWebViewController *webVC = [[NYWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
            [self.navigationController pushViewController:webVC animated:YES];
            break;
        }
            
        case 2:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"html"];
            _webVC = [[NYWebViewController alloc] initWithLocalHtmlURL:[NSURL fileURLWithPath:path]];
            [self addScriptMessageHandler];
            [self.navigationController pushViewController:_webVC animated:YES];
            // [self performSelector:@selector(TESTcallJS1:) withObject:_webVC afterDelay:1.0];
            _webVC.delegate = self;
            break;
        }
        default:
            break;
    }
    
}

- (void)webViewController:(NYWebViewController *)webViewController didReceiveScriptMessage:(NYScriptMessage *)message {
    
}

- (void)addScriptMessageHandler {
    [_webVC addScriptMessageHandlerWithName:@[@"share",@"webViewApp"]];
}


- (void)TESTcallJS1:(NYWebViewController *) vc {
    //NYWebViewController *v = vc;
    [vc webViewControllerCallJS:@"alert('调用JS成功1')" handler:^(id response, NSError *error) {
        NSLog(@"调用js回调事件");
    }];
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
