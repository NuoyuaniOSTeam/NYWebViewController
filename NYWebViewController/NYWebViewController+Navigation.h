//
//  NYWebViewController+Navigation.h
//  NYWebViewControllerExample
//
//  Created by nuoyuan on 2018/7/26.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#ifndef NYWebViewController_Navigation_h
#define NYWebViewController_Navigation_h

#import "NYWebViewController.h"

@interface NYWebViewController ()

// default yes
@property (nonatomic, assign) BOOL isUseWebPageTitle;

// show progress default yes
@property (nonatomic, assign) BOOL showLoadingProgressView;

// Navigation bar title length defaults to no more than 10 words long
@property (assign, nonatomic) NSUInteger maxAllowedTitleLength;

// set progress color. default color
@property (nonatomic, strong) UIColor *progressColor;

@end


#endif /* NYWebViewController_Navigation_h */
