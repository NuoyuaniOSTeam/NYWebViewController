//
//  NYScriptMessage.h
//  NYWebViewController
//
//  Created by ZhangJie on 2018/6/1.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NYScriptMessage : NSObject

@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, copy) NSString *callback;


@end
