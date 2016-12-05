//
//  GTProjectRightViewCell.m
//  Zeta
//
//  Created by GOOT on 16/3/29.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTProjectRightViewCell.h"

@interface GTProjectRightViewCell()

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *start_timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *end_timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *service_feeLabel;
@property (weak, nonatomic) IBOutlet UILabel *user_countLabel;
@property (weak, nonatomic) IBOutlet UILabel *site_visitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *online_countLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemsLabel;
@property (weak, nonatomic) IBOutlet UILabel *transaction_amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *transaction_countLabel;

@end

@implementation GTProjectRightViewCell

- (void)awakeFromNib {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setProduct:(GTProductModel *)product
{
    _product = product;
    
    _typeLabel.text               = _product.type;
    _start_timeLabel.text         = _product.start_time;
    _end_timeLabel.text           = _product.end_time;
    _durationLabel.text           = _product.duration;
    _service_feeLabel.text        = _product.service_fee;
    _user_countLabel.text         = _product.user_count;
    _site_visitsLabel.text        = _product.site_visits;
    _online_countLabel.text       = _product.online_count;
    _itemsLabel.text              = _product.items;
    _transaction_amountLabel.text = _product.transaction_amount;
    _transaction_countLabel.text  = _product.transaction_count;
}

@end
