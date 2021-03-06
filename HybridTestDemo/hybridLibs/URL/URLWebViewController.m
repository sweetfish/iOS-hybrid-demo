//
//  WebViewController.m
//  JS_OC_URL
//
//  Created by Harvey on 16/8/4.
//  Copyright © 2016年 Haley. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "URLWebViewController.h"
#import "QRCodeScanVC.h"

@interface URLWebViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, strong) NSString  *codeString;

@end

@implementation URLWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"UIWebView拦截URL";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    NSLog(@"加载html");
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index0.html" withExtension:nil];
//    NSURL *htmlURL = [NSURL URLWithString:@"http://www.baidu.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:htmlURL];
    
    // 如果不想要webView 的回弹效果
    self.webView.scrollView.bounces = NO;
    // UIWebView 滚动的比较慢，这里设置为正常速度
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    _codeString = [[NSString alloc]init];
}

#pragma mark - private method
- (void)handleCustomAction:(NSURL *)URL
{
    NSString *host = [URL host];
    if ([host isEqualToString:@"scanClick"]) {
        NSLog(@"扫一扫");
        [self QRClick];
    } else if ([host isEqualToString:@"alertClick"]) {
        [self alertClick];
    }
}

- (void)QRClick{
    QRCodeScanVC *urlView0 = [[QRCodeScanVC alloc] init];
    urlView0.codeBlock = ^(NSString *codeString){
        NSString *jsStr = [NSString stringWithFormat:@"getQRCode('%@')",codeString];
        [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
    };
    [self.navigationController pushViewController:urlView0 animated:YES];
    
    
}

- (void)alertClick{
    UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"原生弹窗" message:@"这是原生的弹窗调用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)getLocation
{
    // 获取位置信息
    
    // 将结果返回给js--调用函数的方法
    NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')",@"广东省深圳市南山区学府路XXXX号"];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)share:(NSURL *)URL
{
    NSArray *params =[URL.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
        if (dicArray.count > 1) {
            NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [tempDic setObject:decodeValue forKey:dicArray[0]];
        }
    }
    
    NSString *title = [tempDic objectForKey:@"title"];
    NSString *content = [tempDic objectForKey:@"content"];
    NSString *url = [tempDic objectForKey:@"url"];
    // 在这里执行分享的操作
    
    // 将分享结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)changeBGColor:(NSURL *)URL
{
    NSArray *params =[URL.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
        if (dicArray.count > 1) {
            NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [tempDic setObject:decodeValue forKey:dicArray[0]];
        }
    }
    CGFloat r = [[tempDic objectForKey:@"r"] floatValue];
    CGFloat g = [[tempDic objectForKey:@"g"] floatValue];
    CGFloat b = [[tempDic objectForKey:@"b"] floatValue];
    CGFloat a = [[tempDic objectForKey:@"a"] floatValue];
    
    self.view.backgroundColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

- (void)payAction:(NSURL *)URL
{
    NSArray *params =[URL.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
        if (dicArray.count > 1) {
            NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [tempDic setObject:decodeValue forKey:dicArray[0]];
        }
    }
//    NSString *orderNo = [tempDic objectForKey:@"order_no"];
//    long long amount = [[tempDic objectForKey:@"amount"] longLongValue];
//    NSString *subject = [tempDic objectForKey:@"subject"];
//    NSString *channel = [tempDic objectForKey:@"channel"];
    
    // 支付操作
    
    // 将支付结果返回给js
    NSUInteger code = 1;
    NSString *jsStr = [NSString stringWithFormat:@"payResult('%@',%lu)",@"支付成功",(unsigned long)code];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)shakeAction
{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void)goBack
{
    [self.webView goBack];
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *URL = request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"haleyaction"]) {
        [self handleCustomAction:URL];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:@"var arr = [3, 4, 'abc'];"];
}

@end
