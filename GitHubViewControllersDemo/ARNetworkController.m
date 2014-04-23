//
//  ARNetworkController.m
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/22/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARNetworkController.h"
#import "ARRepo.h"
//#import "ARAppDelegate.h"

#define GITHUB_CLIENT_ID @"714adee8cb043ef2ae65"
#define GITHUB_CLIENT_SECRET @"ceb6b83b6cfbf19ac965e9e352a523a3e72389b2"
#define GITHUB_CALLBACK_URI @"gitauth://git_callback"
#define GITHUB_OAUTH_URL @"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@"
#define GITHUB_API_URL @"https://api.github.com/"

@interface ARNetworkController ()

@property (nonatomic, strong) NSString *token;

@end

@implementation ARNetworkController

- (id)init
{
    self = [super init];
    if (self) {
        self.token = [[NSUserDefaults standardUserDefaults] objectForKey:@"OAuthToken"];
        if (!self.token) {
            [self requestOAuthAccess];
        }
    }
    
    return self;
}

- (void)requestOAuthAccess
{
    NSString *urlString = [[NSString alloc] initWithFormat:GITHUB_OAUTH_URL, GITHUB_CLIENT_ID, GITHUB_CALLBACK_URI, @"user,repo"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)handleOAuthCallbackWithURL:(NSURL *)url
{
    NSString *code = [self getCodeFromCallBackURL:url];
    
    NSString *postString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@", GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, code];
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  // Convert parameters to chunk of data
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]]; // Describes how long our data is
    
    NSURLSessionConfiguration *sessionCongifuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    sessionCongifuration.HTTPAdditionalHeaders = @{@"Authorization:": @""};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionCongifuration];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.description);
        }
        
//        NSLog(@"%@", response.description);
        
        self.token = [self convertResponseDataIntoToken:data];
        [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:@"OAuthToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    [postDataTask resume];
}

- (NSString *)convertResponseDataIntoToken:(NSData *)responseData
{
    NSString *tokenResponse = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSArray *tokenComponents = [tokenResponse componentsSeparatedByString:@"&"];
    NSString *accessTokenWithCode = tokenComponents[0];
    NSArray *access_token_array = [accessTokenWithCode componentsSeparatedByString:@"="];
    
//    NSLog(@"%@", access_token_array[1]);
    
    return access_token_array[1];
}

- (NSString *)getCodeFromCallBackURL:(NSURL *)callBackURL
{
    NSString *query = [callBackURL query]; // Gives back anything pass '?'
    NSArray *components = [query componentsSeparatedByString:@"="];
    
    return [components lastObject];
}

- (void)retrieveReposForCurrentUser
{    
    NSURL *userRepoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/repos",GITHUB_API_URL]];
    NSURLSessionConfiguration *sessionCongifuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionCongifuration];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:userRepoURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"token %@", self.token] forHTTPHeaderField:@"Authorization"];
    
    
    NSURLSessionDataTask *repoDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(@"response: %@", response.description);
        NSMutableArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        self.reposArray = [NSMutableArray new];
        
        for (NSDictionary *tempDict in jsonArray) {
            ARRepo *repo = [ARRepo new];
            repo.name = [tempDict objectForKey:@"full_name"];
            repo.html_url = [tempDict objectForKey:@"html_url"];
            [self.reposArray addObject:repo];
        }
        
        [self.delegate finishedNetworkDownload:self.reposArray];
    }];
    
    [repoDataTask resume];
    
}

@end
