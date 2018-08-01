#
#  Be sure to run `pod spec lint NYWebViewController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#
Pod::Spec.new do |s|
    s.name         = 'NYWebViewController'
    s.version      = '1.0.2'
    s.summary      = 'NYWebViewController base on WKWebView'
    s.homepage     = 'NYWebViewController base on WKWebView, addtion with cocoapod support.'
    s.license      = 'MIT'
    s.authors      = {'NuoYuaniOS' => 'appleco@nuoayuan.com.cn'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/NuoyuaniOSTeam/NYWebViewContorller.git', :tag => s.version}
    s.source_files = 'NYWebViewController/**/*.{h,m}'
    s.requires_arc = true
end