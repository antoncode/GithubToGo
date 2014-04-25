//
//  ARNetworkController.m
//  GitHubViewControllersDemo
//
//  Created by Anton Rivera on 4/22/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARNetworkController.h"
#import "ARRepo.h"
#import "ARUser.h"

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
    
    _completionBlock = completionBlock;
}

- (void)handleOAuthCallbackWithURL:(NSURL *)url
{
    NSString *code = [self getCodeFromCallBackURL:url];
    
    NSString *postString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@", GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, code];
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  // Convert parameters to chunk of data
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]]; // Describes how long our data is
    
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest new];
    [URLRequest setURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]];
    [URLRequest setHTTPMethod:@"POST"];
    [URLRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [URLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [URLRequest setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [_URLSession dataTaskWithRequest:URLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.description);
        }

        _token = [self convertResponseDataIntoToken:data];
        [[NSUserDefaults standardUserDefaults] setObject:_token forKey:@"OAuthToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _completionBlock();
        }];
        
    }];
    
    [postDataTask resume];
}

- (NSString *)convertResponseDataIntoToken:(NSData *)responseData
{
    NSString *tokenResponse = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSArray *tokenComponents = [tokenResponse componentsSeparatedByString:@"&"];
    NSString *accessTokenWithCode = tokenComponents[0];
    NSArray *accessTokenArray = [accessTokenWithCode componentsSeparatedByString:@"="];
    
    // Return access token
    return accessTokenArray[1];
}

- (NSString *)getCodeFromCallBackURL:(NSURL *)callBackURL
{
    NSString *query = [callBackURL query]; // Gives back anything pass '?'
    NSArray *components = [query componentsSeparatedByString:@"="];
    
    return [components lastObject];
}

// Get repos for current user
- (void)getReposForCurrentUser:(void(^)(NSMutableArray *repos))completionBlock
{    
    NSURL *userRepoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/repos",GITHUB_API_URL]];

    NSMutableURLRequest *URLRequest = [NSMutableURLRequest new];
    [URLRequest setURL:userRepoURL];
    [URLRequest setHTTPMethod:@"GET"];
    [URLRequest setValue:[NSString stringWithFormat:@"token %@", self.token] forHTTPHeaderField:@"Authorization"];
    
    
    NSURLSessionDataTask *repoDataTask = [_URLSession dataTaskWithRequest:URLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
        
        NSMutableArray *userReposArray = [NSMutableArray new];
        
        if ([jsonArray isKindOfClass:[NSMutableArray class]]) {
            // Array for loop in a block, adds some functionality
            [jsonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ARRepo *repo = [ARRepo new];
                repo.name = [obj objectForKey:@"name"];
                repo.html_url = [obj objectForKey:@"html_url"];
                [userReposArray addObject:repo];
            }];
            completionBlock(userReposArray);
        }
    }];
    
    [repoDataTask resume];
}

// Get users for search string
- (void)getUsersForQuery:(NSString *)query withCompletion:(void(^)(NSMutableArray *array))completionBlock
{
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSOperationQueue *downloadQueue = [NSOperationQueue new];
    
    [downloadQueue addOperationWithBlock:^{
        NSString *searchURLString = [NSString stringWithFormat:@"%@search/users?q=%@", GITHUB_API_URL, query];
        NSURL *searchURL = [NSURL URLWithString:searchURLString];
        NSData *searchData = [NSData dataWithContentsOfURL:searchURL];
        NSDictionary *searchDict = [NSJSONSerialization JSONObjectWithData:searchData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
        NSMutableArray *resultUsersArray = [searchDict objectForKey:@"items"];
        NSMutableArray *tempUsersArray = [NSMutableArray new];

        if ([resultUsersArray isKindOfClass:[NSMutableArray class]]) {
            [resultUsersArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ARUser *user = [[ARUser alloc] initWithJSON:obj];
                [tempUsersArray addObject:user];
            }];
            completionBlock(tempUsersArray);
        }
        
        //    if ([resultUsersArray isKindOfClass:[NSMutableArray class]]) {
        //        for (NSDictionary *tempDict in resultUsersArray) {
        //            ARUser *user = [[ARUser alloc] initWithJson:tempDict];
        //            [tempUsersArray addObject:user];
        //        }
        //        completionBlock(tempUsersArray);
        //    }

    }];
}

// Get repos for search string
- (void)getReposForQuery: (NSString *)query withCompletion:(void(^)(NSMutableArray *array))completionBlock
{
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSOperationQueue *downloadQueue = [NSOperationQueue new];
    [downloadQueue addOperationWithBlock:^{
        NSString *searchURLString = [NSString stringWithFormat:@"%@search/repositories?q=%@", GITHUB_API_URL, query];
        NSURL *searchURL = [NSURL URLWithString:searchURLString];
        NSData *searchData = [NSData dataWithContentsOfURL:searchURL];
        NSDictionary *searchDict = [NSJSONSerialization JSONObjectWithData:searchData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
        NSMutableArray *resultReposArray = [searchDict objectForKey:@"items"];
        NSMutableArray *tempReposArray = [NSMutableArray new];
        
        if ([resultReposArray isKindOfClass:[NSMutableArray class]]) {
            [resultReposArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ARRepo *repo = [[ARRepo alloc] initWithName:obj];
                [tempReposArray addObject:repo];
            }];
            completionBlock(tempReposArray);
        }
        
//        if ([resultReposArray isKindOfClass:[NSMutableArray class]]) {
//            for (NSDictionary *tempDict in resultReposArray) {
//                ARRepo *repo = [[ARRepo alloc] initWithName:tempDict];
//                [tempReposArray addObject:repo];
//            }
//            completionBlock(tempReposArray);
//        }

    }];
    
//    dispatch_queue_t downloadQueue = dispatch_queue_create("com.Rivera.Anton.downloadQueue", NULL);
//    dispatch_async(downloadQueue, ^{
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
//        if ([tempRepos isKindOfClass:[NSMutableArray class]]){
//            
//            completionBlock(tempRepos);
//        }
//    });
    
}

-(BOOL)checkForUserToken
{
    return (self.token);
}

@end
