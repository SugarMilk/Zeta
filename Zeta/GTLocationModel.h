//
//  GTLocationModel.h
//  Zeta
//
//  Created by GOOT on 16/4/1.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTLocationModel : NSObject

@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *latitude;

@property (nonatomic, assign) int distance;

@end
