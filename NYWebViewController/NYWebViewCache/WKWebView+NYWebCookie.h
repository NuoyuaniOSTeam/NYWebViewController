//
//  WKWebView+NYWebCookie.h


#import <WebKit/WebKit.h>

@interface WKWebView (NYWebCookie)

/** insert cookies*/
- (void)insertCookie:(NSHTTPCookie *)cookie;

@end
