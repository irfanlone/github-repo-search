//
//  ViewController.m
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/10/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import "SearchViewController.h"
#import "GitRepoObject.h"
#import "WebViewController.h"
#import "GitRepoCell.h"
#import "SVProgressHud.h"
#import "KeychainManager.h"
#import "Transport.h"

NSString *const kAccessTokenKey = @"access_token";

@interface SearchViewController ()<UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<GitRepoObject*> * results;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * reuseIdentifier = @"tableCell";
    GitRepoCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexpath:indexPath];
    return cell;
}

- (void)configureCell:(GitRepoCell*)cell atIndexpath:(NSIndexPath*)indexPath {
    GitRepoObject * repoItem = self.results[indexPath.row];
    cell.title.text = repoItem.title;
    cell.repoDescription.text = repoItem.repositoryDescription;
    cell.ownerName.text = [NSString stringWithFormat:@"Owner: %@",repoItem.ownerName];
    cell.language.text = repoItem.respositoryLanguage;
    cell.lastUpdatedTimeStamp.text = [NSString stringWithFormat:@"Updated at: %@",repoItem.lastUpdateTimeStamp];
    cell.avatarImageView.image = [UIImage imageNamed:@"No-Cover"];
    
    Transport * transport = [[Transport alloc] init];
    [transport getDataAtUrl:[NSURL URLWithString:repoItem.ownerAvatar] completionBlock:^(BOOL success, TransportResponseObject *responseObject) {
        if (success) {
            UIImage *avatarImage = [UIImage imageWithData:responseObject.data];
            if (avatarImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    GitRepoCell *updateCell = [self.tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell) {
                        updateCell.avatarImageView.image = avatarImage;
                    }
                });
            }
        }
    }];
}

#pragma mark UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self loadWebViewWithRepository:self.results[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loadWebViewWithRepository:(GitRepoObject*)repository {
    WebViewController *webVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"webView"];
    webVC.url = repository.url;
    [self presentViewController:webVC animated:YES completion:nil];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchPressed:nil];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)searchPressed:(id)sender {
    [self.searchTextField resignFirstResponder];
    if (self.searchTextField.text.length == 0) {
        [self alertUserWithMessage:@"Enter a value for search"];
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeBlack];
    });
    NSString * access_token = [KeychainManager valueForKey:kAccessTokenKey];
    NSString * searchString = self.searchTextField.text;
    searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString * baseUrl = @"https://api.github.com/search/repositories?";
    NSString * urlString = nil;
    if (access_token) {
        urlString = [NSString stringWithFormat:@"%@%@=%@&q=%@&sort=stars&order=desc",baseUrl,kAccessTokenKey,access_token,searchString];
    } else {
        urlString = [NSString stringWithFormat:@"%@q=%@&sort=stars&order=desc",baseUrl,searchString];
    }
    NSURL * url = [NSURL URLWithString:urlString];
    __weak typeof(self) weakSelf = self;
    Transport * transport = [[Transport alloc] init];
    [transport getDataAtUrl:url completionBlock:^(BOOL success, TransportResponseObject *responseObject) {
        typeof(self) strongSelf = weakSelf;
        if (success) {
            NSArray * response = [NSJSONSerialization JSONObjectWithData:responseObject.data options:0 error:nil];
            [strongSelf processJsonResponse:[response valueForKey:@"items"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
                if (strongSelf.results.count == 0) {
                    [strongSelf alertUserWithMessage:@"No results found."];
                }
                [SVProgressHUD dismiss];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf alertUserWithMessage:@"Error."];
                [SVProgressHUD dismiss];
            });
        }
    }];
}

- (void)processJsonResponse:(NSArray*)response {
    self.results = [NSMutableArray array];
    for (NSArray * responseObj in response) {
        
        NSString * title = ([responseObj valueForKey:@"name"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"name"];
        NSString * description = ([responseObj valueForKey:@"description"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"description"];
        NSString * language = ([responseObj valueForKey:@"language"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"language"];

        NSString * dateStr = ([responseObj valueForKey:@"updated_at"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"updated_at"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
        NSDate *date = [dateFormat dateFromString:dateStr];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        NSString * newDate = [dateFormat stringFromDate:date];
        NSString * lastUpdateTimeStamp = newDate;

        NSString * url = ([responseObj valueForKey:@"html_url"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"html_url"];
        NSDictionary * owner = ([responseObj valueForKey:@"owner"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"owner"];
        NSString * ownerName = ([owner valueForKey:@"login"] == (id)[NSNull null]) ? nil : [owner valueForKey:@"login"];
         NSString * ownerAvatar = ([owner valueForKey:@"avatar_url"] == (id)[NSNull null]) ? nil : [owner valueForKey:@"avatar_url"];
        GitRepoObject * newObj = [[GitRepoObject alloc] initWithTitle:title description:description language:language ownerName:ownerName ownerAvatar:ownerAvatar lastUpdateTimeStamp:lastUpdateTimeStamp url:url];
        [self.results addObject:newObj];
    }
}

- (void)alertUserWithMessage:(NSString*)alertMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertMessage message:@"Please try again" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
