//
//  UIImage+Category.h
//
//  Copyright (c) 2015年 黄健. All rights reserved.

#import <UIKit/UIKit.h>

@interface UIImage (Category)

- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height;

- (UIImage *)fixOrientation:(UIImage *)aImage;

@end
