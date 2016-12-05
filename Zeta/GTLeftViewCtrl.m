//
//  GTLeftViewCtrl.m
//  Zeta
//
//  Created by GOOT on 16/3/21.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTLeftViewCtrl.h"
#import "UIImage+Category.h"
#import "AFNetworking.h"

@interface GTLeftViewCtrl () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel     *nameLabel;
@property (weak, nonatomic) IBOutlet UIView      *backView;

@property (weak, nonatomic) IBOutlet UIButton    *feedbackButton;
@property (weak, nonatomic) IBOutlet UIButton    *loginOutButton;
@property (weak, nonatomic) IBOutlet UILabel     *versionLabel;

@property (nonatomic, strong) NSMutableData *mResponseData;

@property (nonatomic, retain) UIImagePickerController *picker;

@end

@implementation GTLeftViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initControls];
}

- (void)initControls
{
    [_iconImageView.layer setCornerRadius:50];
    [_iconImageView.layer setMasksToBounds:YES];
    
    [_feedbackButton.layer setCornerRadius:20];
    [_feedbackButton.layer setMasksToBounds:YES];
    
    [_loginOutButton.layer setCornerRadius:20];
    [_loginOutButton.layer setMasksToBounds:YES];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    CFShow((__bridge CFTypeRef)(infoDictionary));
    NSString *app_build  = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    
    _versionLabel.text = [NSString stringWithFormat:@"Version %@", app_build];
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender
{
    if (![[GTAccountManager sharedManager] isLogined]) {
        GTLoginViewCtrl *login = [[GTLoginViewCtrl alloc] init];
        [self.view.window.rootViewController presentViewController:login animated:YES completion:nil];
    } else {
        [self uploadImage];
    }
}

- (void)uploadImage
{
    _picker = [[UIImagePickerController alloc]init];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.delegate = self;
    [self.view.window.rootViewController presentViewController:_picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    UIImage *image = [UIImage imageNamed:@"dotLine2"];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *image64 = [NSString stringWithFormat:@"%@", [imageData base64EncodedStringWithOptions:0]];

//    NSString *imageString = [[NSString alloc] initWithData:[self replaceNoUtf8:imageData] encoding:NSUTF8StringEncoding];
    
//    NSString *image64 = [NSString stringWithFormat:@"%@", [self image2DataURL:image]];
    
    // ====================================================================
    // http://app.zetadata.com.cn/member/common/upface?user_id=154&img=?
    
    
    NSString *user_id = [[[GTAccountManager sharedManager] currentUser] user_id];
//    [self upload:@"img" filename:@"test.png" mimeType:@"image/png" data:imageData parmas:@{@"user_id":user_id}];
    
    
//    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
//    NSString *imageString=[[NSString alloc]initWithData:imageData encoding:enc];
    
    
//    NSLog(@"-- %@", user_id);
//    NSLog(@"-- %@", [self UIImageToBase64Str:image]);
//    
//    NSString *url = @"http://app.zetadata.com.cn/member/common/upimg";
    
//    NSDictionary *params = @{@"user_id":user_id};
    
    NSDictionary *params = @{@"user_id":user_id,
                             @"img":image64};
    /*
    NSString *url = [NSString stringWithFormat:@"%@%@", _RESOURCE, user.face_img];
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    */
//    NSLog(@"-- %@", params);
    [GTURLSession sessionWithString:@"upface" method:POST params:params response:^(id responseObject) {
        
        NSLog(@"session返回： %@", responseObject);
        
        if ([responseObject[@"code"] intValue] == 200) {
            
//            [picker dismissViewControllerAnimated:YES completion:^{
                NSString *imagePath = responseObject[@"data"][@"face_img"];
                GTCustomer *user = [[GTAccountManager sharedManager] currentUser];
                user.face_img = imagePath;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *url = [NSString stringWithFormat:@"%@%@", _RESOURCE, imagePath];
                    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"icon"]];
                    [picker dismissViewControllerAnimated:YES completion:nil];
                });
//            }];
            
            
            NSLog(@"上传头像成功");
        }
        
        NSLog(@"上传头像完成");
        
    } error:^(id error) {
        ERROR(YES, error);
    }];
    
}

//图片转字符串
-(NSString *)UIImageToBase64Str:(UIImage *) image
{
    NSData *data = UIImagePNGRepresentation(image);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

- (NSData *)UTF8Data:(NSData *)data
{
    //保存结果
    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:data.length];
    
    //无效编码替代符号(常见 � □ ?)
    NSData *replacement = [@"�" dataUsingEncoding:NSUTF8StringEncoding];
    
    uint64_t index = 0;
    const uint8_t *bytes = data.bytes;
    
    while (index < data.length)
    {
        uint8_t len = 0;
        uint8_t header = bytes[index];
        
        //单字节
        if ((header&0x80) == 0)
        {
            len = 1;
        }
        //2字节(并且不能为C0,C1)
        else if ((header&0xE0) == 0xC0)
        {
            if (header != 0xC0 && header != 0xC1)
            {
                len = 2;
            }
        }
        //3字节
        else if((header&0xF0) == 0xE0)
        {
            len = 3;
        }
        //4字节(并且不能为F5,F6,F7)
        else if ((header&0xF8) == 0xF0)
        {
            if (header != 0xF5 && header != 0xF6 && header != 0xF7)
            {
                len = 4;
            }
        }
        
        //无法识别
        if (len == 0)
        {
            [resData appendData:replacement];
            index++;
            continue;
        }
        
        //检测有效的数据长度(后面还有多少个10xxxxxx这样的字节)
        uint8_t validLen = 1;
        while (validLen < len && index+validLen < data.length)
        {
            if ((bytes[index+validLen] & 0xC0) != 0x80)
                break;
            validLen++;
        }
        
        //有效字节等于编码要求的字节数表示合法,否则不合法
        if (validLen == len)
        {
            [resData appendBytes:bytes+index length:len];
        }else
        {
            [resData appendData:replacement];
        }
        
        //移动下标
        index += validLen;
    }
    
    return resData;
}
#define YYEncode(str) [str dataUsingEncoding:NSUTF8StringEncoding]
- (void)upload:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)data parmas:(NSDictionary *)params
{
    // 文件上传
    NSURL *url = [NSURL URLWithString:@"http://app.zetadata.com.cn/member/common/upface"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 设置请求体
    NSMutableData *body = [NSMutableData data];
    
    /***************文件参数***************/
    // 参数开始的标志
    [body appendData:YYEncode(@"--YY\r\n")];
    // name : 指定参数名(必须跟服务器端保持一致)
    // filename : 文件名
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename];
    [body appendData:YYEncode(disposition)];
    NSString *type = [NSString stringWithFormat:@"Content-Type: %@\r\n", mimeType];
    [body appendData:YYEncode(type)];
    
    [body appendData:YYEncode(@"\r\n")];
    [body appendData:data];
    [body appendData:YYEncode(@"\r\n")];
    
    /***************普通参数***************/
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // 参数开始的标志
        [body appendData:YYEncode(@"--YY\r\n")];
        NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key];
        [body appendData:YYEncode(disposition)];
        
        [body appendData:YYEncode(@"\r\n")];
        [body appendData:YYEncode(obj)];
        [body appendData:YYEncode(@"\r\n")];
    }];
    
    /***************参数结束***************/
    // YY--\r\n
    [body appendData:YYEncode(@"--YY--\r\n")];
    request.HTTPBody = body;
    
    // 设置请求头
    // 请求体的长度
    [request setValue:[NSString stringWithFormat:@"%zd", body.length] forHTTPHeaderField:@"Content-Length"];
    // 声明这个POST请求是个文件上传
    [request setValue:@"multipart/form-data; boundary=YY" forHTTPHeaderField:@"Content-Type"];
    
    // 发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"上传%@", dict);
        } else {
            NSLog(@"上传失败");
        }
        
        NSLog(@"上传头像方法执行完成=============================");
        [_picker dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
}

- (IBAction)problemFeedback:(UIButton *)sender
{
    if ([[GTAccountManager sharedManager] isLogined]) {
        GTFeedbackViewCtrl *feedback = [[GTFeedbackViewCtrl alloc] init];
        [self.view.window.rootViewController presentViewController:feedback animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请先登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)loginOut:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"退出账号" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [[GTAccountManager sharedManager] resetUser];
        
        // 发送退出账号通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logOutNotify" object:nil];
        
        DDMenuController *_ddMenu = [(id)[[UIApplication sharedApplication] delegate] ddMenu];
        [_ddMenu showRootController:YES];
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[GTAccountManager sharedManager] isLogined]) {
        GTCustomer *user = [[GTAccountManager sharedManager] currentUser];
        [_nameLabel setText:user.user_name];
        [_loginOutButton setHidden:NO];
        NSString *url = [NSString stringWithFormat:@"%@%@", _RESOURCE, user.face_img];
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    } else {
        [_nameLabel setText:@"客户登录"];
        [_loginOutButton setHidden:YES];
        [_iconImageView setImage:[UIImage imageNamed:@"icon"]];
    }
}

@end
