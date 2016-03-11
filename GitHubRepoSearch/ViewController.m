//
//  ViewController.m
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/10/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import "ViewController.h"
#import "GitRepo.h"
#import "WebViewController.h"
#import "GitRepoCell.h"

@interface ViewController ()<UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<GitRepo*> * results;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;


@end

@implementation ViewController

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
    GitRepo * repoItem = self.results[indexPath.row];
    cell.title.text = repoItem.title;
    cell.repoDescription.text = repoItem.repositoryDescription;
    cell.ownerName.text = repoItem.ownerName;
    cell.language.text = repoItem.respositoryLanguage;
    cell.lastUpdatedTimeStamp.text = repoItem.lastUpdateTimeStamp;
    return cell;
}

#pragma mark UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self loadWebViewWithRepository:self.results[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loadWebViewWithRepository:(GitRepo*)repository {
    WebViewController *webVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"webView"];
    webVC.url = repository.url;
    [self presentViewController:webVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)searchPressed:(id)sender {
    if (self.searchTextField.text.length == 0) {
        // alert user
        return;
    }
    NSString * searchString = self.searchTextField.text;
    searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString * baseUrl = @"https://api.github.com/search/repositories?";
    NSString * urlString = [NSString stringWithFormat:@"%@q=%@&sort=stars&order=desc",baseUrl,searchString];
    NSURL * url = [NSURL URLWithString:urlString];
    [self getDataAtUrl:url withCompletionBlock:^(BOOL sucess, NSData *data) {
        if (sucess) {
            NSArray * response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [self processJsonResponseToObjects:[response valueForKey:@"items"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                if (self.results.count == 0) {
                    // alert user
                }
            });
        }
    }];
}

- (void)processJsonResponseToObjects:(NSArray*)response {
    self.results = [NSMutableArray array];
    for (NSArray * responseObj in response) {
        GitRepo * newObj = [[GitRepo alloc] init];
        newObj.title = [responseObj valueForKey:@"name"];
        newObj.repositoryDescription = [responseObj valueForKey:@"description"];
        newObj.respositoryLanguage = [responseObj valueForKey:@"language"];
        newObj.lastUpdateTimeStamp = [responseObj valueForKey:@"updated_at"];
        newObj.url = [responseObj valueForKey:@"html_url"];
        NSDictionary * owner = [responseObj valueForKey:@"owner"];
        newObj.ownerName = [owner valueForKey:@"login"];
        newObj.ownerAvatar = [responseObj valueForKey:@"avatar_url"];
        [self.results addObject:newObj];
    }
}

#pragma mark private

-(void)getDataAtUrl:(NSURL*)url withCompletionBlock:(void(^)(BOOL sucess, NSData * data))completion {
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    NSURLSessionDataTask * datatask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error) {
            completion(YES, data);
        } else {
            NSLog(@"Error : %@",error);
            completion(NO, nil);
        }
    }];
    [datatask resume];
}


@end
