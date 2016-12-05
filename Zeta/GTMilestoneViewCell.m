//
//  GTProjectLeftViewCell.m
//  Zeta
//
//  Created by GOOT on 16/3/28.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTMilestoneViewCell.h"

@interface GTMilestoneViewCell()

@property (weak, nonatomic) IBOutlet UILabel *phase_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phase_timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *operaterLabel;

@end

@implementation GTMilestoneViewCell

- (void)awakeFromNib {
    
}

- (void)setMilestone:(GTMilestoneModel *)milestone
{
    _milestone = milestone;
    
    _phase_nameLabel.text = _milestone.phase_name;
    _detailLabel.text     = _milestone.detail;
    _phase_timeLabel.text = _milestone.phase_time;
    _operaterLabel.text   = _milestone.operater;
}

@end
