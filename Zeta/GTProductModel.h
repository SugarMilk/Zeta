//
//  GTProductModel.h
//  Zeta
//
//  Created by GOOT on 16/3/31.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTProductModel : NSObject

@property (nonatomic, copy) NSString *id;                   // 产品编号
@property (nonatomic, copy) NSString *user_id;              // 对应客户id

@property (nonatomic, copy) NSString *type;                 // 产品类型，0为电商产品，1为教育产品

@property (nonatomic, copy) NSString *start_time;           // 开始时间
@property (nonatomic, copy) NSString *end_time;             // 结束时间

@property (nonatomic, copy) NSString *duration;             // 使用期限
@property (nonatomic, copy) NSString *service_fee;          // 服务费用

@property (nonatomic, copy) NSString *user_count;           // 平台用户
@property (nonatomic, copy) NSString *site_visits;          // 访问统计

@property (nonatomic, copy) NSString *online_count;         // 在线用户
@property (nonatomic, copy) NSString *items;                // 商品种类

@property (nonatomic, copy) NSString *transaction_amount;   // 成交金额
@property (nonatomic, copy) NSString *transaction_count;    // 交易数量

@end
