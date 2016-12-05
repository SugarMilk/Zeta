

#import "GTAccountManager.h"

@implementation GTAccountManager
{
    KeychainItemWrapper *_keychain;
}

+ (instancetype)sharedManager
{
    static GTAccountManager *mgr = nil;
    
    static dispatch_once_t onceTonken;
    
    dispatch_once(& onceTonken, ^{
        if(mgr == nil) {
            mgr = [[GTAccountManager alloc ]init];
        }
    });
    return mgr;
}

- (instancetype)init
{
    if (self = [super init]) {
        _currentUser = [[GTCustomer alloc] init];
        
        _keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"cn.com.zetadata.Zeta" accessGroup:nil];
        _currentUser.user_name = [_keychain objectForKey:(__bridge id)(kSecAttrAccount)];
        _currentUser.password  = [_keychain objectForKey:(__bridge id)(kSecValueData)];
    }
    return self;
}

- (void)setCurrentUser:(GTCustomer *)currentUser
{
    _currentUser = currentUser;
    
    [_keychain setObject:currentUser.user_name forKey:(__bridge id)(kSecAttrAccount)];
    [_keychain setObject:currentUser.password  forKey:(__bridge id)(kSecValueData)];
}

- (void)resetUser
{
     _currentUser = nil;
    
    [_keychain resetKeychainItem];
}

- (BOOL)isLogined
{
    if (_currentUser.user_name.length && _currentUser.password.length) {return YES;} return NO;
}

@end
