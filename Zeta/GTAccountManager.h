

#import <Foundation/Foundation.h>

@interface GTAccountManager : NSObject

@property (nonatomic, strong) GTCustomer *currentUser;

+ (instancetype)sharedManager;

- (void)resetUser;  // 注销账号

- (BOOL)isLogined;  // 判断是否已经登录

@end
