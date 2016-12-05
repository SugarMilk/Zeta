//
//  GTURLSession.m
//  GTURLSession
//
//  Created by GOOT on 16/3/29.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTURLSession.h"

@implementation GTURLSession

+ (void)sessionWithString:(NSString *)_string method:(RequestMethod)_method params:(NSDictionary *)_params
                 response:(ResponseBlock)_response error:(ErrorBlock)_error
{
    NSString *string;
    
    NSString *params = [GTURLSession paramsToString:_params];

    if (_method == GET) {
        string = [NSString stringWithFormat:@"%@%@?%@", HOSTNAME, _string, params];
        
//        NSLog(@" GET请求：%@", [string substringFromIndex:40]);
    } else {
        string = [NSString stringWithFormat:@"%@%@", HOSTNAME, _string];
        
//        NSLog(@"POST请求：%@?%@", [string substringFromIndex:40], params);
    }
    
    string = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
//    NSLog(@"string: %@", string);
    
    NSURL *URL = [NSURL URLWithString:string];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];

    if (_method == GET) {
        [request setHTTPMethod:@"GET"];
    } else {
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            _response([NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
        } else {
            _error(error);
        }
    }] resume];
}

+ (NSString *)paramsToString:(NSDictionary *)dic
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in dic) {
        NSString *value = [dic objectForKey:key];
        [array addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    return [array componentsJoinedByString:@"&"];
}

@end
