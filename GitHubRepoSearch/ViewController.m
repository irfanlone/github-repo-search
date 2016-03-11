//
//  ViewController.m
//  GitHubRepoSearch
//
//  Created by Irfan Lone on 3/10/16.
//  Copyright © 2016 Ilone Labs. All rights reserved.
//

#import "ViewController.h"
#import "GitRepoObject.h"
#import "WebViewController.h"
#import "GitRepoCell.h"

NSString *const kAccessTokenPrefKey = @"access_token";

@interface ViewController ()<UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<GitRepoObject*> * results;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)loadView {
    [super loadView];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.color = [UIColor grayColor];
    [self.view addSubview:self.activityIndicator];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect viewBounds = self.tableView.bounds;
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds));
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
    GitRepoObject * repoItem = self.results[indexPath.row];
    cell.title.text = repoItem.title;
    cell.repoDescription.text = repoItem.repositoryDescription;
    cell.ownerName.text = [NSString stringWithFormat:@"Owner: %@",repoItem.ownerName];
    cell.language.text = repoItem.respositoryLanguage;
    cell.lastUpdatedTimeStamp.text = [NSString stringWithFormat:@"Updated at: %@",repoItem.lastUpdateTimeStamp];
    cell.identifier = repoItem.identifier;
    
    [self getDataAtUrl:[NSURL URLWithString:repoItem.ownerAvatar] withIdentifier:repoItem.identifier andCompletionBlock:^(BOOL sucess, NSData *data, NSNumber * identifier) {
        if (sucess && cell.identifier == identifier) {
            UIImage * image = [UIImage imageWithData:data];
            // TODO: optimize this by reducing the image size. the incoming images are large in size than required.
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatarImageView.image = image;
            });
        }
    }];
    return cell;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)searchPressed:(id)sender {
    if (self.searchTextField.text.length == 0) {
        [self alertUserWithMessage:@"Enter a value for search"];
        return;
    }
    [self.activityIndicator startAnimating];
    NSString * access_token = [[NSUserDefaults standardUserDefaults] stringForKey:kAccessTokenPrefKey];
    NSString * searchString = self.searchTextField.text;
    searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString * baseUrl = @"https://api.github.com/search/repositories?";
    NSString * urlString = nil;
    if (access_token) {
        urlString = [NSString stringWithFormat:@"%@%@=%@&q=%@&sort=stars&order=desc",baseUrl,kAccessTokenPrefKey,access_token,searchString];
    } else {
        urlString = [NSString stringWithFormat:@"%@q=%@&sort=stars&order=desc",baseUrl,searchString];
    }
    NSURL * url = [NSURL URLWithString:urlString];
    __weak typeof(self) weakSelf = self;
    [self getDataAtUrl:url withIdentifier:nil andCompletionBlock:^(BOOL sucess, NSData *data, NSNumber * identifier) {
        typeof(self) strongSelf = weakSelf;
        if (sucess) {
            NSArray * response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [strongSelf processJsonResponseToObjects:[response valueForKey:@"items"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
                if (strongSelf.results.count == 0) {
                    [strongSelf alertUserWithMessage:@"No results found."];
                }
                [strongSelf.activityIndicator stopAnimating];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf alertUserWithMessage:@"Error."];
                [strongSelf.activityIndicator stopAnimating];
            });
        }
    }];
}

- (void)processJsonResponseToObjects:(NSArray*)response {
    self.results = [NSMutableArray array];
    for (NSArray * responseObj in response) {
        GitRepoObject * newObj = [[GitRepoObject alloc] init];
        newObj.identifier = [response valueForKey:@"id"];
        newObj.title = ([responseObj valueForKey:@"name"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"name"];
        newObj.repositoryDescription = ([responseObj valueForKey:@"description"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"description"];
        newObj.respositoryLanguage = ([responseObj valueForKey:@"language"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"language"];

        NSString * dateStr = ([responseObj valueForKey:@"updated_at"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"updated_at"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
        NSDate *date = [dateFormat dateFromString:dateStr];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        NSString * newDate = [dateFormat stringFromDate:date];
        newObj.lastUpdateTimeStamp = newDate;

        newObj.url = ([responseObj valueForKey:@"html_url"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"html_url"];
        NSDictionary * owner = ([responseObj valueForKey:@"owner"] == (id)[NSNull null]) ? nil : [responseObj valueForKey:@"owner"];
        newObj.ownerName = ([owner valueForKey:@"login"] == (id)[NSNull null]) ? nil : [owner valueForKey:@"login"];
        newObj.ownerAvatar = ([owner valueForKey:@"avatar_url"] == (id)[NSNull null]) ? nil : [owner valueForKey:@"avatar_url"];
        [self.results addObject:newObj];
    }
}

- (void)alertUserWithMessage:(NSString*)alertMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertMessage message:@"Please try again" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark private

-(void)getDataAtUrl:(NSURL*)url withIdentifier:(NSNumber*)identifier andCompletionBlock:(void(^)(BOOL sucess, NSData * data, NSNumber * identifier))completion {
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    NSURLSessionDataTask * datatask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error) {
            completion(YES, data, identifier);
        } else {
            NSLog(@"Error : %@",error);
            completion(NO, nil, identifier);
        }
    }];
    [datatask resume];
}


@end
