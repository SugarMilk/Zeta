//
//  GTLocationViewCell.m
//  Zeta
//
//  Created by GOOT on 16/3/25.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTLocationViewCell.h"

@interface GTLocationViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation GTLocationViewCell

- (void)awakeFromNib {
    
    // 初始化界面
    self.clipsToBounds = YES; // ?
    self.selectionStyle = UITableViewCellSelectionStyleNone; // ?
    
     _button = [[UIButton alloc] init];
    [_button setFrame:CGRectMake(0, 0, screenW, 80)];
    [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
}

- (void)setLocation:(GTLocationModel *)location
{
    _location = location;
    
    _titleLabel.text = _location.user_name;
    _addressLabel.text = _location.address;
    
    if (_location.address.length == 0)
    {
        _addressLabel.text = @"未提供";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    _isShowMenuView = selected; // 设置单元格菜单是否被打开
}

- (void)buttonClicked:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(locationViewCell:didShowMenuViewWithButton:)]) {
        [_delegate locationViewCell:self didShowMenuViewWithButton:sender];
    }
}

- (IBAction)navigateButtonClicked:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(locationViewCell:didClickedNavigateButton:)]) {
        [_delegate locationViewCell:self didClickedNavigateButton:sender];
    }
}

- (void)menuItemClick:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(locationViewCell:didSelectMentItemAtIndex:)])
    {
        [_delegate locationViewCell:self didSelectMentItemAtIndex:sender.tag];
    }
}

@end

