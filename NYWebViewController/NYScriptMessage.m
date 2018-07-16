//
//  NYScriptMessage.m
//  NYWebViewController
//
//  Created by ZhangJie on 2018/6/1.
//  Copyright © 2018年 nuoyuan. All rights reserved.
//

#import "NYScriptMessage.h"

@implementation NYScriptMessage


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:{handlerName:%@,method:%@,params:%@,callback:%@}>", NSStringFromClass([self class]),self.handlerName,self.method, self.params, self.callback];
}

@end
