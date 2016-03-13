//
//  WebViewController.m
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/10/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import "WebViewController.h"
#import "Defines.h"
#import "SearchViewController.h"
#import "SVProgressHud.h"
#import "KeychainManager.h"
#import "Transport.h"

typedef enum {
    NetworkErrorBadUrl = -1000,
    NetworkErrorRequestTimedOut = -1001,
    NetworkErrorCannotFindHost = -10003,
    NetworkErrorCannotConnectToHost = -1004,
    NetworkErrorNetworkConnectionLost = -1005,
    NetworkErrorNSLookupFailed = -1006
}NetworkError;

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) NSTimer * webviewTimeoutTimer;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [self.webView loadRequest:urlRequest];
    [self.webView goBack];
    [self.backButton setEnabled:[self.webView canGoBack]];
    self.webView.scalesPageToFit = YES;
}

- (IBAction)goBack:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)dealloc {
    [self.webviewTimeoutTimer invalidate];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *responseURL = [request.URL absoluteString];
    NSString *codeString = [NSString stringWithFormat:@"%@?code=", GITHUB_CALLBACK_URL];
    NSLog(@"responseURL = %@",responseURL);
    if([responseURL hasPrefix:codeString])
    {
        if ([KeychainManager valueForKey:kAccessTokenKey]) {
            return YES;
        }
        NSInteger strLen = [codeString length];
        NSString *code = [responseURL substringFromIndex:strLen];
        
        //Request the token.
        NSString * baseUrl = @"https://github.com/login/oauth/access_token?";
        NSString * urlString = [NSString stringWithFormat:@"%@code=%@&client_id=%@&client_secret=%@&redirect_uri=%@",baseUrl,code,GITHUB_CLIENT_ID,GITHUB_CLIENT_SECRET,GITHUB_CALLBACK_URL];
        NSURL * url = [NSURL URLWithString:urlString];
        
        Transport * transport = [[Transport alloc] init];
        [transport getDataAtUrl:url completionBlock:^(BOOL success, TransportResponseObject *responseObject) {
            if(success) {
                NSString * responseString = [NSString stringWithUTF8String:[responseObject.data bytes]];
                NSDictionary * pairs = [self convertStringToDictionary:responseString];
                NSString * access_token = [pairs valueForKey:@"access_token"];
                [KeychainManager saveAccessTokenToKeyChain:access_token forKey:kAccessTokenKey];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    __weak typeof(self) wealself = self;
                    [self alertUserWithMessage:@"sign in successful" andActionBlock:^{
                        [wealself dismissViewControllerAnimated:YES completion:nil];
                    }];
                });
            }
        }];        
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeBlack];
    [self.webviewTimeoutTimer invalidate];
    self.webviewTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(cancelWebviewLoading) userInfo:nil repeats:NO];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
    [self.backButton setEnabled:[self.webView canGoBack]];
    [self.webviewTimeoutTimer invalidate];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    [SVProgressHUD dismiss];
    if (error.code == NetworkErrorRequestTimedOut) {
        [self alertUserWithMessage:@"Taking too long to load" andActionBlock:nil];
    }
    [self.webviewTimeoutTimer invalidate];
}

- (void)alertUserWithMessage:(NSString*)alertMessage andActionBlock:(void(^)())completion{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertMessage message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSDictionary*)convertStringToDictionary:(NSString*)responseString {
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    for (NSString *pairString in [responseString componentsSeparatedByString:@"&"]) {
        NSArray *pair = [pairString componentsSeparatedByString:@"="];
        if ([pair count] != 2)
            continue;
        [pairs setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
    }
    return [pairs copy];
}

- (IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelWebviewLoading {
    [SVProgressHUD dismiss];
    [self alertUserWithMessage:@"Taking too long to load" andActionBlock:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
