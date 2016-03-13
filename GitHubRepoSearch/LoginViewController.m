//
//  LoginViewController.m
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/11/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import "LoginViewController.h"
#import "WebViewController.h"
#import "SearchViewController.h"
#import "Defines.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self.signInButton layer] setBorderWidth:1.0f];
    [[self.signInButton layer] setBorderColor:[UIColor darkGrayColor].CGColor];
}

- (IBAction)signIn:(id)sender {
    if ([GITHUB_CLIENT_ID isEqualToString:@"Your github client_id"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Client ID" message:@"Please define your Client_Id and and Client_Secrect in Defines.h" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        NSString * baseUrl = @"https://github.com/login/oauth/authorize?";
        NSString * urlString = [NSString stringWithFormat:@"%@client_id=%@&redirect_uri=%@&scope=user",baseUrl,GITHUB_CLIENT_ID,GITHUB_CALLBACK_URL];
        WebViewController *webVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"webView"];
        webVC.url = urlString;
        [self presentViewController:webVC animated:YES completion:nil];
    }
}

@end
