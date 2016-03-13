//
//  WebViewController.m
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/10/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import "WebViewController.h"
#import "Defines.h"
#import "ViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *responseURL = [request.URL absoluteString];
    NSString *codeString = [NSString stringWithFormat:@"%@?code=", GITHUB_CALLBACK_URL];
    NSLog(@"responseURL = %@",responseURL);
    if([responseURL hasPrefix:codeString])
    {
        NSString * access_token = [[NSUserDefaults standardUserDefaults] stringForKey:kAccessTokenPrefKey];
        if (access_token) {
            return YES;
        }
        NSInteger strLen = [codeString length];
        NSString *code = [responseURL substringFromIndex:strLen];
        
        //Request the token.
        NSString * baseUrl = @"https://github.com/login/oauth/access_token?";
        NSString * urlString = [NSString stringWithFormat:@"%@code=%@&client_id=%@&client_secret=%@&redirect_uri=%@",baseUrl,code,GITHUB_CLIENT_ID,GITHUB_CLIENT_SECRET,GITHUB_CALLBACK_URL];
        NSURL * url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask * datatask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(!error) {
                NSString * responseString = [NSString stringWithUTF8String:[data bytes]];
                NSDictionary * pairs = [self convertStringToDictionary:responseString];
                NSString * access_token = [pairs valueForKey:@"access_token"];
                [[NSUserDefaults standardUserDefaults] setValue:access_token forKey:kAccessTokenPrefKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self alertUserWithMessage:@"sign in successful"];
                });
            } else {
                NSLog(@"Error : %@",error);
            }
        }];
        [datatask resume];
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.backButton setEnabled:[self.webView canGoBack]];
}

- (void)alertUserWithMessage:(NSString*)alertMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertMessage message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
