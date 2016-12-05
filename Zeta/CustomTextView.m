//
//  CustomTextView.m
//  CustomTextView
//
//  Created by 袁灿 on 16/1/11.
//  Copyright © 2016年 yuancan. All rights reserved.
//

#define kCornerRadius   1.0

#import "CustomTextView.h"

@interface CustomTextView ()<UITextViewDelegate>
{
    UILabel *labPlaceholder;
    UILabel *numWords;
    UITextView *textView;
}

@end

@implementation CustomTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        background.layer.cornerRadius = kCornerRadius;
        background.layer.borderWidth = 1.0f;
        background.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        background.layer.masksToBounds = YES;
        background.backgroundColor = [UIColor whiteColor];
        [self addSubview:background];
        
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20)];
        textView.delegate = self;
        [background addSubview:textView];
        
        labPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 7, 200, 20)];
        labPlaceholder.textColor = [UIColor grayColor];
        [background addSubview:labPlaceholder];
        
        numWords = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-75-3, CGRectGetMaxY(textView.frame) - 3, 70, 20)];
        numWords.textAlignment = NSTextAlignmentRight;
        numWords.font = [UIFont systemFontOfSize:15.0];
        numWords.textColor = [UIColor grayColor];
        [background addSubview:numWords];
        
    }
    return self;
}

- (void)setFont:(UIFont *)font
{
    textView.font = font;
    labPlaceholder.font = font;
    labPlaceholder.frame = CGRectMake(5, 7, 200, labPlaceholder.font.lineHeight+2);
}

- (void)setMaxLength:(NSInteger)maxLength {
    _maxLength = maxLength;
    numWords.text = [NSString stringWithFormat:@"0/%ld",(long)_maxLength];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    labPlaceholder.text = _placeholder;
}

- (void)textViewDidChange:(UITextView *)textView {
    numWords.text = [NSString stringWithFormat:@"%ld/%ld",(long)textView.text.length,(long)_maxLength];
    labPlaceholder.hidden = (textView.text.length >0);
    self.text = textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger length = textView.text.length - range.length + text.length;
    return length <= _maxLength;
}

@end
