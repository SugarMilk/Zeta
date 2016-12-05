//
//  GTLoginViewCtrl.m
//  Zeta
//
//  Created by GOOT on 16/3/25.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTLoginViewCtrl.h"

@interface GTLoginViewCtrl ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation GTLoginViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initControls];
}

- (void)initControls
{
    [_usernameTextfield.layer setCornerRadius:2];
    [_passwordTextfield.layer setCornerRadius:2];
    
    [_usernameTextfield.layer setBorderWidth:0.6];
    [_passwordTextfield.layer setBorderWidth:0.6];
    
    [_usernameTextfield.layer setMasksToBounds:YES];
    [_passwordTextfield.layer setMasksToBounds:YES];
    
    _loginButton.layer.cornerRadius = 1;
    _loginButton.layer.masksToBounds = YES;
    
    [_usernameTextfield.layer setBorderColor:WAColor(0.8, 1).CGColor];
    [_passwordTextfield.layer setBorderColor:WAColor(0.8, 1).CGColor];
    
    UIView *uLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    [_usernameTextfield setLeftView:uLeftView];
    [_usernameTextfield setLeftViewMode:UITextFieldViewModeAlways];
    
    UIView *pLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    [_passwordTextfield setLeftView:pLeftView];
    [_passwordTextfield setLeftViewMode:UITextFieldViewModeAlways];
}

- (IBAction)loginButtonClicked:(UIButton *)sender
{
    [_usernameTextfield resignFirstResponder];
    [_passwordTextfield resignFirstResponder];
    
    if (_usernameTextfield.text.length == 0) {ALERT(@"用户名不能为空") return;}
    if (_passwordTextfield.text.length == 0) {ALERT(@"密码不能为空") return;}
    
    NSDictionary *params = @{@"user_name":_usernameTextfield.text,
                             @"password" :_passwordTextfield.text};
    
    [GTURLSession sessionWithString:@"check_login" method:POST params:params response:^(id responseObject) {
        NSLog(@"登录成功");
        NSLog(@"登录成功返回 %@", responseObject);
        
        // 登录成功，包括账号
        if ([responseObject[@"code"] isEqualToString:@"200"]) {
            NSDictionary *userInfo = responseObject[@"data"];
            
            GTCustomer *user = [[GTCustomer alloc] init];
            [user setPassword:_passwordTextfield.text];
            [user setValuesForKeysWithDictionary:userInfo];
            [[GTAccountManager sharedManager] setCurrentUser:user];
        }
        
        // 登录成功/失败，弹出提示框
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
        NSLog(@"%@", error);
    }];
}

- (IBAction)backButtonClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goToRegistAction:(UIButton *)sender
{
    GTRegistViewCtrl *regist = [[GTRegistViewCtrl alloc] init];
    [self presentViewController:regist animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
