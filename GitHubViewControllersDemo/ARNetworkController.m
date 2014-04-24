//
//  ARNetworkController.m
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/22/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARNetworkController.h"
#import "ARRepo.h"

#define GITHUB_CLIENT_ID @"714adee8cb043ef2ae65"
#define GITHUB_CLIENT_SECRET @"ceb6b83b6cfbf19ac965e9e352a523a3e72389b2"
#define GITHUB_CALLBACK_URI @"gitauth://git_callback"
#define GITHUB_OAUTH_URL @"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@"
#define GITHUB_API_URL @"https://api.github.com/"

@interface ARNetworkController ()

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSURLSession *URLSession;
@property (nonatomic, copy) void(^completionBlock)();

@end

@implementation ARNetworkController

- (id)init
{
    self = [super init];
    
    if (self) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.allowsCellularAccess = NO; // Only WIFI allowed
        _URLSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        
        _token = [[NSUserDefaults standardUserDefaults] objectForKey:@"OAuthToken"];
    }
    
    return self;
}

- (void)requestOAuthAccessWithCompletion:(void (^)())completionBlock
{
    NSString *urlString = [[NSString alloc] initWithFormat:GITHUB_OAUTH_URL, GITHUB_CLIENT_ID, GITHUB_CALLBACK_URI, @"user,repo"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
    self.completionBlock = completionBlock;
}

- (void)handleOAuthCallbackWithURL:(NSURL *)url
{
    NSString *code = [self getCodeFromCallBackURL:url];
    
    NSString *postString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@", GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, code];
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  // Convert parameters to chunk of data
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]]; // Describes how long our data is
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [_URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.description);
        }

        self.token = [self convertResponseDataIntoToken:data];
        [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:@"OAuthToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.completionBlock();
        }];
        
    }];
    
    [postDataTask resume];
}

- (NSString *)convertResponseDataIntoToken:(NSData *)responseData
{
    NSString *tokenResponse = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSArray *tokenComponents = [tokenResponse componentsSeparatedByString:@"&"];
    NSString *accessTokenWithCode = tokenComponents[0];
    NSArray *access_token_array = [accessTokenWithCode componentsSeparatedByString:@"="];
    
    // Return access token
    return access_token_array[1];
}

- (NSString *)getCodeFromCallBackURL:(NSURL *)callBackURL
{
    NSString *query = [callBackURL query]; // Gives back anything pass '?'
    NSArray *components = [query componentsSeparatedByString:@"="];
    
    return [components lastObject];
}

- (void)retrieveReposForCurrentUser:(void(^)(NSMutableArray *repos))completionBlock
{    
    NSURL *userRepoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/repos",GITHUB_API_URL]];

    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:userRepoURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"token %@", self.token] forHTTPHeaderField:@"Authorization"];
    
    
    NSURLSessionDataTask *repoDataTask = [_URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        self.reposArray = [NSMutableArray new];
        
//        for (NSDictionary *tempDict in jsonArray) {
//            ARRepo *repo = [[ARRepo alloc] initWithJSON:tempDict];
//            repo.name = [tempDict objectForKey:@"name"];
//            repo.html_url = [tempDict objectForKey:@"html_url"];
//            [self.reposArray addObject:repo];
//        }

        // Doing for loop in a block
        [jsonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ARRepo *repo = [[ARRepo alloc] initWithJSON:obj];
            repo.name = [obj objectForKey:@"name"];
            repo.html_url = [obj objectForKey:@"html_url"];
            [self.reposArray addObject:repo];
        }];
        
        if ([jsonArray isKindOfClass:[NSMutableArray class]]) {
            completionBlock(_reposArray);
        }
    }];
    
    [repoDataTask resume];
}

-(BOOL)checkForUserToken
{
    return (self.token);
}

- (void)getReposForQuery:(void(^)(NSMutableArray *array))completionBlock
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("com.Rivera.Anton.downloadQueue", NULL);
    dispatch_async(downloadQueue, ^{
        NSString *searchURLString = [NSString stringWithFormat:@"https://api.github.com/search/repositories?q=%@", _query];
        NSURL *searchURL = [NSURL URLWithString:searchURLString];
        NSData *searchData = [NSData dataWithContentsOfURL:searchURL];
        NSDictionary *searchDict = [NSJSONSerialization JSONObjectWithData:searchData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
        
        NSMutableArray *tempRepos = [NSMutableArray new];
        
        for (NSDictionary *repo in [searchDict objectForKey:@"items"]) {
            ARRepo *downloadedRepo = [[ARRepo alloc] initWithJSON:repo];
            [tempRepos addObject:downloadedRepo];
        }
        
        if ([tempRepos isKindOfClass:[NSMutableArray class]]){
            completionBlock(tempRepos);
        }
    });
    
    //    NSOperationQueue *downloadQueue = [NSOperationQueue new];
    //    [downloadQueue addOperationWithBlock:^{
    //        NSString *searchURLString = [NSString stringWithFormat:@"https://api.github.com/search/repositories?q=%@", query];
    //        NSURL *searchURL = [NSURL URLWithString:searchURLString];
    //        NSData *searchData = [NSData dataWithContentsOfURL:searchURL];
    //        NSDictionary *searchDict = [NSJSONSerialization JSONObjectWithData:searchData
    //                                                                   options:NSJSONReadingMutableContainers
    //                                                                     error:nil];
    //
    //        NSMutableArray *tempRepos = [NSMutableArray new];
    //
    //        for (NSDictionary *repo in [searchDict objectForKey:@"items"]) {
    //            ARRepo *downloadedRepo = [[ARRepo alloc] initWithJSON:repo];
    //            [tempRepos addObject:downloadedRepo];
    //        }
    //
    //        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    //        [mainQueue addOperationWithBlock:^{
    //            _repos = tempRepos;
    //            [self.tableView reloadData];
    //        }];
    //    }];
}

@end
