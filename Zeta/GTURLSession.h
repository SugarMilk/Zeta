//
//  GTURLSession.h
//  GTURLSession
//
//  Created by GOOT on 16/3/29.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GET,
    POST
} RequestMethod;

typedef void(^ResponseBlock)(id responseObject);
typedef void(^ErrorBlock)(id error);

@interface GTURLSession : NSObject

+ (void)sessionWithString:(NSString *)_string method:(RequestMethod)_method params:(NSDictionary *)_params
                 response:(ResponseBlock)_response error:(ErrorBlock)_error;

@end
