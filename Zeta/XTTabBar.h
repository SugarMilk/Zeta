//
//  XTTabBar.h
//  XTPageControl
//
//  Created by imchenglibin on 16/1/26.
//  Copyright © 2016年 xt. All rights reserved.
//  https://github.com/imchenglibin/XTPageControl
//

#import <UIKit/UIKit.h>
#import "XTTabBarStyle.h"
#import "XTTabBarScrollView.h"

@interface XTTabBar : UIView

- (instancetype)initWithTitles:(NSArray<NSString*>*)titles andStyle:(XTTabBarStyle)style;
- (void)moveToIndex:(NSInteger)index;

@property (strong, nonatomic) UIView *leftItemView;
@property (strong, nonatomic) UIView *rightItemView;

@property (strong, nonatomic) UIColor *titleColorNormal;
@property (strong, nonatomic) UIColor *titleColorSelected;
@property (strong, nonatomic) UIColor *cursorColor;
@property (assign, nonatomic) BOOL forceLeftAligment;
@property (weak, nonatomic) id<XTTabBarScrollViewDelegate> tabBarDelegate;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com