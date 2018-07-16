# NYWebViewContorller
####
***
* **NYWebViewController**基于**WKWebView**做的一些封装的控制器，使用简单方便，能够满足大部门App加载网页。包括功能有，导航栏自定义，加载网页进度条，网页来源，JS与OC交互等功能，后续会增加更多的一些使用功能，敬请关注！

* ***系统版本支持：iOS8以后；Xcode9***

* ###使用方法

1. 在工程中的Podfile中新增pod 'NYWebViewController','~>1.0.1', install pod

2. 然后import头文件 "NYWebViewController.h"

3. code
	
	***
			NSString *path = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"html"];
			_webVC = [[NYWebViewController alloc] initWithLocalHtmlURL:[NSURL fileURLWithPath:path]];
			[self addScriptMessageHandler]; // 注册messageHandler。
			[self.navigationController pushViewController:_webVC animated:YES];
			_webVC.delegate = self;
	***




