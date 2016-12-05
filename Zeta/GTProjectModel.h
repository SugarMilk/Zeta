//
//  GTProject.h
//  Zeta
//
//  Created by GOOT on 16/3/31.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTProjectModel : NSObject

@property (nonatomic, copy) NSString *id;               // 项目编号
@property (nonatomic, copy) NSString *user_id;          // 对应客户id
@property (nonatomic, copy) NSString *project_name;     // 项目名称
@property (nonatomic, copy) NSString *project_time;     // 项目开始时间
@property (nonatomic, copy) NSString *project_amount;   // 项目金额
@property (nonatomic, copy) NSString *project_leader;   // 项目负责人
@property (nonatomic, copy) NSString *repay_money;      // 项目尾款（未付金额）

@property (nonatomic, retain) NSArray *milestones;      // 项目里程碑

@end
