//
//  GTRegistViewCtrl.m
//  Zeta
//
//  Created by GOOT on 16/5/20.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTRegistViewCtrl.h"

@interface GTRegistViewCtrl () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *uTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pTextfield;
@property (weak, nonatomic) IBOutlet UITextField *aTextfield;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *registButton;

@property (nonatomic, retain) UIButton *sendAuthCodeButton;

@end

@implementation GTRegistViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initControls];
}

- (void)initControls
{
    [_uTextfield.layer setCornerRadius:2];
    [_pTextfield.layer setCornerRadius:2];
    [_aTextfield.layer setCornerRadius:2];
    
    [_uTextfield.layer setMasksToBounds:YES];
    [_pTextfield.layer setMasksToBounds:YES];
    
    _registButton.layer.cornerRadius = 1;
    _registButton.layer.masksToBounds = YES;
    
    UIView *uLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    [_uTextfield setLeftView:uLeftView];
    [_uTextfield setLeftViewMode:UITextFieldViewModeAlways];
    
    UIView *pLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    [_pTextfield setLeftView:pLeftView];
    [_pTextfield setLeftViewMode:UITextFieldViewModeAlways];
    
    UIView *aLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    [_aTextfield setLeftView:aLeftView];
    [_aTextfield setLeftViewMode:UITextFieldViewModeAlways];
    
    UIView *aRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 38)];
    [_aTextfield setRightView:aRightView];
    [_aTextfield setRightViewMode:UITextFieldViewModeAlways];
    
    _sendAuthCodeButton = [[UIButton alloc] initWithFrame:aRightView.bounds];
    _sendAuthCodeButton.backgroundColor = RGBColor(0, 128, 255);
    _sendAuthCodeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_sendAuthCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
    [_sendAuthCodeButton addTarget:self action:@selector(sendAuthCodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [aRightView addSubview:_sendAuthCodeButton];
}

- (void)sendAuthCodeButtonAction:(UIButton *)sender
{
    if (_uTextfield.text.length == 0) {return;}
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已发送验证码，请注意查收" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSDictionary *params = @{@"phone":_uTextfield.text};
        
        [GTURLSession sessionWithString:@"sendcode" method:POST params:params response:^(id responseObject) {
            
            NSLog(@"res: %@", responseObject);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([responseObject[@"code"] intValue] == 200) {
                    [self alert:responseObject[@"message"]];
                } else {
                    [self alert:responseObject[@"message"]];
                }
            });
            
        } error:^(id error) {
            NSLog(@"%@", error);
        }];
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alert:(NSString *)content
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:content message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)registButtonAction:(UIButton *)sender
{
    NSLog(@"点击注册");
    
    NSDictionary *params = @{@"user_phone":_uTextfield.text,
                             @"password":_pTextfield.text,
                             @"code":_aTextfield.text};
    
    [GTURLSession sessionWithString:@"doregister" method:POST params:params response:^(id responseObject) {
        
        NSLog(@"res: %@", responseObject);
        
        
        if ([responseObject[@"code"] intValue] == 200) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注册成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.view endEditing:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            });
            
        } else {
            
        }
        
    } error:^(id error) {
        NSLog(@"%@", error);
    }];
    
}

- (IBAction)closeButtonAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
