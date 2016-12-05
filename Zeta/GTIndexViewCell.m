//
//  GTIndexViewCell.m
//  Zeta
//
//  Created by GOOT on 16/3/23.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTIndexViewCell.h"

@interface GTIndexViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel     *contentLabel;

@end

@implementation GTIndexViewCell

- (void)awakeFromNib {
    
    // 初始化界面
    self.clipsToBounds = YES; // ?
    self.selectionStyle = UITableViewCellSelectionStyleNone; // ?
    
     _button = [[UIButton alloc] init];
    [_button setFrame:CGRectMake(0, 0, screenW, 140)];
    [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
}

- (void)setIndex:(GTIndexModel *)index
{
    _index = index;
    
    [_contentLabel setText:_index.title];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", RESOURCE, _index.art_img]];
    
    [_iconImageView sd_setImageWithURL:URL placeholderImage:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    _isShowMenuView = selected; // 设置单元格菜单是否被打开
}

- (void)buttonClicked:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(indexViewCell:didShowMenuViewWithButton:)]) {
        [_delegate indexViewCell:self didShowMenuViewWithButton:sender];
    }
}

- (IBAction)menuItemClick:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(indexViewCell:didSelectMentItemAtIndex:)])
    {
        [_delegate indexViewCell:self didSelectMentItemAtIndex:sender.tag];
    }
}

@end
