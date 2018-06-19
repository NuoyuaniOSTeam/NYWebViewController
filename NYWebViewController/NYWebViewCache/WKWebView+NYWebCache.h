//
//  WKWebView+NYWebCache.h


#import <WebKit/WebKit.h>

@interface WKWebView (NYWebCache)

/** 清除webView缓存 */
- (void)deleteAllWebCache;

/** 清理缓存的方法，这个方法会清除缓存类型为HTML类型的文件*/
- (void)clearHTMLCache;

@end
