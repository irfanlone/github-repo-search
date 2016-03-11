//
//  LoginViewController.m
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/11/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import "LoginViewController.h"
#import "WebViewController.h"
#import "ViewController.h"
#import "Defines.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *signInStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self.signInButton layer] setBorderWidth:1.0f];
    [[self.signInButton layer] setBorderColor:[UIColor darkGrayColor].CGColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString * access_token = [[NSUserDefaults standardUserDefaults] stringForKey:kAccessTokenPrefKey];
    if (access_token) {
        self.signInStatusLabel.text = @"you are already signed in.";
    } else {
        self.signInStatusLabel.text = @"You are not signed in.";
    }
}

- (IBAction)signIn:(id)sender {
    NSString * baseUrl = @"https://github.com/login/oauth/authorize?";
    NSString * urlString = [NSString stringWithFormat:@"%@client_id=%@&redirect_uri=%@&scope=user",baseUrl,GITHUB_CLIENT_ID,GITHUB_CALLBACK_URL];
    WebViewController *webVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"webView"];
    webVC.url = urlString;
    [self presentViewController:webVC animated:YES completion:nil];
}

@end
