//
//  GTFeedbackViewCtrl.m
//  Zeta
//
//  Created by GOOT on 16/3/25.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTFeedbackViewCtrl.h"
#import "CustomTextView.h"

@interface GTFeedbackViewCtrl ()

@property (nonatomic, retain) CustomTextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation GTFeedbackViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _submitButton.layer.cornerRadius = 2;
    _submitButton.layer.masksToBounds = YES;
    
    _textView = [[CustomTextView alloc] initWithFrame:CGRectMake(20, 90, screenW - 40, 200)];
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.maxLength = 100;
    _textView.placeholder = @"请输入内容";
    [self.view addSubview:_textView];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (IBAction)submitAction
{
    [self.view endEditing:YES];
    
    if (_textView.text.length == 0) {ALERT(@"留言不能为空") return;}
    if (_textView.text.length < 10) {ALERT(@"留言字数不能少于10个") return;}
    
    NSDictionary *params = @{@"user_id":[[[GTAccountManager sharedManager] currentUser] user_id],
                             @"detail" :_textView.text};
    
    [GTURLSession sessionWithString:@"leave_message" method:GET params:params response:^(id responseObject) {
        NSLog(@"%@", responseObject);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = responseObject[@"message"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([responseObject[@"code"] isEqualToString:@"200"]) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
    } error:^(id error) {
        ERROR(YES, error);
    }];
}

- (IBAction)backButtonClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


@end
