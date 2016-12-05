//
//  GTMilestoneModel.h
//  Zeta
//
//  Created by GOOT on 16/3/31.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTMilestoneModel : NSObject

@property (nonatomic, copy) NSString *project_id;   // 项目编号

@property (nonatomic, copy) NSString *id;           // 里程碑编号
@property (nonatomic, copy) NSString *phase_name;   // 里程碑名称
@property (nonatomic, copy) NSString *phase_time;   // 添加时间
@property (nonatomic, copy) NSString *detail;       // 里程碑内容
@property (nonatomic, copy) NSString *operater;     // 操作人

@end
