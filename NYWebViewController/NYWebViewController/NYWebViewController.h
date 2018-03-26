//
//  NYWebViewController.h
//  NYWebViewController
//
//  Created by ZhangJie on 2018/3/22.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface NYWebViewController : UIViewController

/* url */
@property (nonatomic, strong) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url;

@end



@interface NYWebViewController(NYProgess)

@property (nonatomic, assign) BOOL showProgess;
@property (nonatomic, strong) UIColor *progessColor;

@end

