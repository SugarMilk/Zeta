//
//  GTIndexViewCell.h
//  Zeta
//
//  Created by GOOT on 16/3/23.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTIndexViewCell;

@protocol GTIndexViewCellDelegate <NSObject>

/**
 *  打开下拉菜单视图调用的方法
 *
 *  @param cell   当前单元格
 *  @param button 触发的按钮
 */
- (void)indexViewCell:(GTIndexViewCell *)cell didShowMenuViewWithButton:(UIButton *)button;

/**
 *  选中菜单项时调用的方法
 *
 *  @param cell  当前单元格
 *  @param index 选中菜单项的索引
 */
- (void)indexViewCell:(GTIndexViewCell *)cell didSelectMentItemAtIndex:(NSInteger)index;

@end


@interface GTIndexViewCell : UITableViewCell

@property (nonatomic, assign) id<GTIndexViewCellDelegate>   delegate;

/**
 *  MenuView的创建与构建
 */
@property (weak, nonatomic) IBOutlet UIView *menuView;

/**
 *  虚拟按钮
 *
 *  覆盖整个单元格,只为获取当前单元格的IndexPath和触发单元格的点击事件
 */
@property (nonatomic, retain) UIButton *button;

@property (nonatomic, assign) BOOL isShowMenuView;                // 是否已经显示下拉菜单

@property (nonatomic, retain) GTIndexModel *index;

@end
