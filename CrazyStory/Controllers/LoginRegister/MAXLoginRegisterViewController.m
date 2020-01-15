//
//  MAXLoginRegisterViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/24.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXLoginRegisterViewController.h"
#import "MAXCompleteUserInfoViewController.h"
#import "MAXResetPasswordViewController.h"
#import "Masonry.h"
#import "SVProgressHUD.h"
#import <ShareSDK/ShareSDK.h>
#import <SMS_SDK/SMSSDK.h>
#import <LeanCloudSocial/AVUser+SNS.h>
#import "UIImage+MAXExtend.h"
#import "NSString+MAXCommon.h"
#import "MAXEMHelper.h"
#import "MAXVerifyCodeButton.h"

@interface MAXLoginRegisterViewController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *loginView ;
@property (nonatomic, strong) UITextField *userNameTextField ;
@property (nonatomic, strong) UITextField *passwordTextField ;
@property (nonatomic, strong) UIButton *loginRegisterSwitcher ;
@property (nonatomic, strong) UIButton *resetPasswordBtn ;
@property (nonatomic, strong) UIButton *loginBtn ;
@property (nonatomic, strong) UIView *registView ;
@property (nonatomic, strong) UITextField *confirmPasswordTextField ;
@property (nonatomic, strong) UITextField *registNumTextField ;
@property (nonatomic, strong) UITextField *verificationCodeTextField ;
@property (nonatomic, strong) UITextField *registPasswordTextField ;
@property (nonatomic, strong) UIButton *registBtn ;
@property (nonatomic, strong) UIButton *qqLoginBtn ;
@property (nonatomic, strong) UIButton *weChatLoginBtn ;
@property (nonatomic, strong) UIButton *sinaWeiboLoginBtn ;
@property (nonatomic, strong) UIButton *googlePlusLoginBtn ;

@end

@implementation MAXLoginRegisterViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES ;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self configUI];
}
- (void)setup
{
    self.navigationItem.title = @"登 录";
    self.navigationController.delegate = self ;
    self.navigationItem.hidesBackButton = YES ;
}
#pragma mark -  配置UI界面
- (void)configUI
{
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.loginRegisterSwitcher =
    ({
        UIButton *loginRegisterSwitcher = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginRegisterSwitcher setTitle:@"没有账号？去注册" forState:UIControlStateNormal];
        [loginRegisterSwitcher setTitle:@"已有账号？去登陆" forState:UIControlStateSelected];
        [loginRegisterSwitcher setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        loginRegisterSwitcher.titleLabel.font = [UIFont systemFontOfSize:14];
        [loginRegisterSwitcher addTarget:self action:@selector(loginRegisterSwitch:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginRegisterSwitcher];
        [loginRegisterSwitcher mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.view).offset(80);
            make.height.equalTo(@20);
        }];
        loginRegisterSwitcher;
    }) ;
    
    // 配置登录视图
    self.loginView =
    ({
        UIView *loginView = [[UIView alloc] init];
        loginView.backgroundColor = [UIColor clearColor] ;
        [self.view addSubview:loginView];
        [loginView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self.view);
            make.top.equalTo(self.loginRegisterSwitcher.mas_bottom);
        }];
        loginView;
    });
    
    self.userNameTextField =
    ({
        UITextField *userNameTextField = [[UITextField alloc] init];
        userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        userNameTextField.placeholder = @"输入手机号码/用户名";
        userNameTextField.keyboardType = UIKeyboardTypeDefault ;
        userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_loginView addSubview:userNameTextField];
        [userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_loginView);
            make.top.equalTo(_loginView).offset(self.view.height/20);
            make.height.equalTo(@(self.view.height/15));
            make.left.equalTo(_loginView).offset(self.view.width/20);
            make.right.equalTo(_loginView).offset(-self.view.width/20);
        }];
        userNameTextField ;
    });
    
    self.passwordTextField =
    ({
        UITextField *passwordTextField = [[UITextField alloc] init];
        passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        passwordTextField.placeholder = @"输入密码";
        passwordTextField.keyboardType = UIKeyboardTypeDefault;
        passwordTextField.secureTextEntry = YES ;
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing ;
        [_loginView addSubview:passwordTextField];
        [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_loginView);
            make.top.equalTo(_userNameTextField.mas_bottom).offset(3);
            make.height.equalTo(@(self.view.height/15));
            make.left.right.equalTo(_userNameTextField);
        }];
        passwordTextField ;
    });
    
    self.resetPasswordBtn =
    ({
        UIButton *resetPasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resetPasswordBtn setTitle:@"忘记密码？" forState:UIControlStateNormal];
        [resetPasswordBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        resetPasswordBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [resetPasswordBtn addTarget:self action:@selector(resetPassword:) forControlEvents:UIControlEventTouchUpInside];
        [_loginView addSubview:resetPasswordBtn];
        [resetPasswordBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_passwordTextField.mas_bottom).offset(15);
            make.right.equalTo(_passwordTextField).offset(-6);
            make.height.equalTo(@20);
        }];
        resetPasswordBtn;
    });
    
    self.loginBtn =
    ({
        UIButton * loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
        loginBtn.backgroundColor = [UIColor redColor];
        [loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        [_loginView addSubview:loginBtn];
        [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_passwordTextField);
            make.top.equalTo(_passwordTextField.mas_bottom).offset(self.view.height/10);
            make.height.equalTo(@(self.view.height/15));
            make.bottom.equalTo(_loginView).offset(-self.view.height/15);
        }];
        loginBtn;
    });
    
/* * * * * * * * 配置注册视图* * * * * * */
    
    self.registView =
    ({
        UIView * registView = [[UIView alloc] init];
        registView.backgroundColor = [UIColor clearColor] ;
        [self.view addSubview:registView];
        [registView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_loginView.mas_right);
            make.width.top.equalTo(_loginView);
        }];
        registView ;
    });
    
    self.registNumTextField =
    ({
        UITextField *registNumTextField = [[UITextField alloc] init];
        registNumTextField.borderStyle = UITextBorderStyleRoundedRect ;
        registNumTextField.placeholder = @"请输入电话号码" ;
        registNumTextField.keyboardType = UIKeyboardTypeNumberPad ;
        registNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing ;
        [_registView addSubview:registNumTextField];
        [registNumTextField mas_makeConstraints:^(MASConstraintMaker *make) {

            make.centerX.equalTo(_registView);
            make.top.equalTo(_registView).offset(self.view.height/25);
            make.height.equalTo(@(self.view.height/17));
            make.left.equalTo(_registView).offset(self.view.width/20);
            make.right.equalTo(_registView).offset(-self.view.width/20);
        }];
        registNumTextField ;
    });
    
    self.verificationCodeTextField =
    ({
        UITextField *verificationCodeTextField = [[UITextField alloc] init];
        verificationCodeTextField.placeholder = @"请输入验证码";
        verificationCodeTextField.borderStyle = UITextBorderStyleRoundedRect;
        verificationCodeTextField.keyboardType = UIKeyboardTypeNumberPad ;
        verificationCodeTextField.rightViewMode = UITextFieldViewModeAlways ;
        [_registView addSubview:verificationCodeTextField];
        [verificationCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_registNumTextField);
            make.top.equalTo(_registNumTextField.mas_bottom).offset(3);
            make.right.equalTo(_registNumTextField);
            make.height.equalTo(@(self.view.height/17));
            
        }];
        verificationCodeTextField;
    });
    
    self.verificationCodeTextField.rightView =
    ({
        MAXVerifyCodeButton *getVerificationCodeBtn = [[MAXVerifyCodeButton alloc] init];
        [getVerificationCodeBtn addTapGestureWithTarget:self action:@selector(getVerificationCode:)];
        getVerificationCodeBtn;
    });
    
    
    self.registPasswordTextField =
    ({
        UITextField *registPasswordTextField = [[UITextField alloc] init];
        registPasswordTextField.placeholder = @"请输入注册密码";
        registPasswordTextField.borderStyle = UITextBorderStyleRoundedRect ;
        registPasswordTextField.keyboardType = UIKeyboardTypeDefault ;
        registPasswordTextField.secureTextEntry = YES ;
        registPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_registView addSubview:registPasswordTextField];
        [registPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_registView);
            make.top.equalTo(_verificationCodeTextField.mas_bottom).offset(3);
            make.height.equalTo(@(self.view.height/17));
            make.left.equalTo(_registView).offset(self.view.width/20);
            make.right.equalTo(_registView).offset(-self.view.width/20);
        }];
        registPasswordTextField;
    });

    
    self.confirmPasswordTextField =
    ({
        UITextField *confirmPasswordTextField = [[UITextField alloc] init];
        confirmPasswordTextField.borderStyle = UITextBorderStyleRoundedRect ;
        confirmPasswordTextField.placeholder = @"再次输入确认密码" ;
        confirmPasswordTextField.secureTextEntry = YES ;
        confirmPasswordTextField.keyboardType = UIKeyboardTypeDefault ;
        confirmPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_registView addSubview:confirmPasswordTextField];
        [confirmPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_registNumTextField);
            make.top.equalTo(_registPasswordTextField.mas_bottom).offset(3);
            make.height.equalTo(@(self.view.height/17));
            make.left.equalTo(_registView).offset(self.view.width/20);
            make.right.equalTo(_registView).offset(-self.view.width/20);
        }];
        confirmPasswordTextField ;
    });
    
    self.registBtn =
    ({
        UIButton * registBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [registBtn setTitle:@"注 册" forState:UIControlStateNormal];
        registBtn.backgroundColor = [UIColor redColor];
        [registBtn addTarget:self action:@selector(regist:) forControlEvents:UIControlEventTouchUpInside];
        [_registView addSubview:registBtn];
        [registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_registPasswordTextField);
            make.top.equalTo(_confirmPasswordTextField.mas_bottom).offset(self.view.height/20);
            make.height.equalTo(@(self.view.height/16));
            make.bottom.equalTo(_registView).offset(-33);
        }];
        registBtn;
    });
    
    
    // 配置快速登录
    UILabel * cutLineLabel = [[UILabel alloc] init];
    cutLineLabel.text = @"快速登录";
    cutLineLabel.font = [UIFont systemFontOfSize:12];
    cutLineLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:cutLineLabel];
    [cutLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_loginView.mas_bottom).offset(self.view.height/40);
    }];
    
    
    UIView * leftCutLine = [[UIView alloc] init];
    leftCutLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:leftCutLine];
    [leftCutLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cutLineLabel.mas_left).offset(-20);
        make.height.equalTo(@2);
        make.width.equalTo(@(self.view.width/3));
        make.centerY.equalTo(cutLineLabel);
    }];
    
    UIView * rightCutLine = [[UIView alloc] init];
    rightCutLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:rightCutLine];
    [rightCutLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cutLineLabel.mas_right).offset(20);
        make.height.equalTo(@2);
        make.width.equalTo(@(self.view.width/3));
        make.centerY.equalTo(cutLineLabel);
    }];
    
    self.sinaWeiboLoginBtn =
    ({
        UIButton * sinaWeiboLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sinaWeiboLoginBtn setImage:[UIImage imageNamed:@"login_sina_icon"] forState:UIControlStateNormal];
        [sinaWeiboLoginBtn setImage:[UIImage imageNamed:@"login_sina_icon_click"] forState:UIControlStateHighlighted];
        [sinaWeiboLoginBtn setTitle:@"微博登录" forState:UIControlStateNormal];
        sinaWeiboLoginBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        sinaWeiboLoginBtn.titleEdgeInsets = UIEdgeInsetsMake(70, -70, 0, 0);
        sinaWeiboLoginBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
        [sinaWeiboLoginBtn addTarget:self action:@selector(loginBySina:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sinaWeiboLoginBtn];
        [sinaWeiboLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(cutLineLabel.mas_bottom).offset(self.view.height/20);
            make.height.equalTo(@90);
            make.width.equalTo(@70);
        }];
        
        sinaWeiboLoginBtn ;
    });
    
    self.qqLoginBtn =
    ({
        UIButton * qqLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [qqLoginBtn setImage:[UIImage imageNamed:@"login_QQ_icon"] forState:UIControlStateNormal];
        [qqLoginBtn setImage:[UIImage imageNamed:@"login_QQ_icon_click"] forState:UIControlStateHighlighted];
        [qqLoginBtn setTitle:@"QQ登录" forState:UIControlStateNormal];
        qqLoginBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        qqLoginBtn.titleEdgeInsets = UIEdgeInsetsMake(70, -70, 0, 0);
        qqLoginBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
        [qqLoginBtn addTarget:self action:@selector(loginByQQ:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:qqLoginBtn];
        [qqLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(leftCutLine);
            make.centerY.equalTo(self.sinaWeiboLoginBtn);
            make.height.equalTo(@90);
            make.width.equalTo(@70);
        }];
        qqLoginBtn ;
    });
    
    self.weChatLoginBtn =
    ({
        UIButton * weChatLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [weChatLoginBtn setImage:[UIImage imageNamed:@"login_tecent_icon"] forState:UIControlStateNormal];
        [weChatLoginBtn setImage:[UIImage imageNamed:@"login_tecent_icon_click"] forState:UIControlStateHighlighted];
        [weChatLoginBtn setTitle:@"微信登录" forState:UIControlStateNormal];
        weChatLoginBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        weChatLoginBtn.titleEdgeInsets = UIEdgeInsetsMake(70, -70, 0, 0);
        weChatLoginBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
        [weChatLoginBtn addTarget:self action:@selector(loginByWeChat:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:weChatLoginBtn];
        [weChatLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(rightCutLine);
            make.centerY.equalTo(self.sinaWeiboLoginBtn);
            make.height.equalTo(@90);
            make.width.equalTo(@70);
        }];
        weChatLoginBtn ;
    });

}

#pragma mark - 点击事件 

- (void)loginRegisterSwitch:(UIButton *)switcher
{
    switcher.selected = !switcher.isSelected ;
    if (switcher.selected) {
        [_loginView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(-self.view.width);
        }];
    }
    else
    {
        [_loginView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
        }];
    }

    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.66
          initialSpringVelocity:0
                        options:0 animations:^{
                            [self.view layoutIfNeeded];
                        } completion:^(BOOL finished) {
                            self.navigationItem.title = switcher.isSelected?@"注 册":@"登 录" ;
                            if (switcher.isSelected) {
                                [self.registNumTextField becomeFirstResponder];
                            }else{
                                [self.userNameTextField becomeFirstResponder];
                            }
                        }];
}

- (void)login:(UIButton *)loginBtn
{
    if ([_userNameTextField.text isUserName])
    {
        [AVUser logInWithUsernameInBackground:_userNameTextField.text password:_passwordTextField.text block:^(AVUser * _Nullable user, NSError * _Nullable error) {
            if (!error)
            {
                isLogined = YES ;
                [self loginEM];
                MAXLog(@"登录成功-->%@,%@",user,[AVUser currentUser]);
                [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                [SVProgressHUD dismissWithDelay:1.2 completion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
            }
            else
            {
                MAXAlert(@"登录失败：%@",error);
            }
        }];
    }
    else if ([_userNameTextField.text isPhoneNumber])
    {
        [AVUser logInWithMobilePhoneNumberInBackground:_userNameTextField.text password:_passwordTextField.text block:^(AVUser * _Nullable user, NSError * _Nullable error) {
            if (!error){
                isLogined = YES ;
                [self loginEM];
                MAXLog(@"登录成功-->%@,%@",user,[AVUser currentUser]);
                [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                [SVProgressHUD dismissWithDelay:1.2 completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else{
                MAXAlert(@"登录失败：%@",error);
            }

        }];
    }
}

- (void)regist:(UIButton *)registBtn
{
    [self.view endEditing:YES];
    
    if (![_registPasswordTextField.text isPassword]) {
        MAXAlert(@"请输入正确格式的密码（6到18位字母和数字）");
        return ;
    }
    
    if (![_registPasswordTextField.text isEqualToString:_confirmPasswordTextField.text]) {
        MAXAlert(@"两次密码输入不一致，请重新输入");
        return ;
    }
    
    if(![_registNumTextField.text isPhoneNumber]){
        MAXAlert(@"手机号码格式有误");
        return ;
    }

    [SVProgressHUD showWithStatus:@"正在验证手机号..."];
    
    [SMSSDK commitVerificationCode:_verificationCodeTextField.text phoneNumber:_registNumTextField.text zone:@"86" result:^(NSError *error) {
        // 执行注册逻辑
#ifndef DEBUG
        if (!error) {
            MAXLog(@"短信验证码验证成功 --> %@",userInfo);
#endif
            // 注册逻辑。
            AVUser * user = [AVUser user];
            user.username = _registNumTextField.text ;
            user.mobilePhoneNumber = _registNumTextField.text ;
            user.password = _registPasswordTextField.text ;
            [user setObject:@120 forKey:kUserPropertyInkCount];
            [SVProgressHUD setStatus:@"正在注册..."];
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded)
                {
                    MAXLog(@"注册成功。");
                    [self registEM];
                    [SVProgressHUD showSuccessWithStatus:@"注册成功"];
                    [SVProgressHUD dismissWithDelay:1.0 completion:^{
                        [self autoLogin];
                    }];
                }
                else
                {
                    MAXAlert(@"注册失败 ,#_# :%@",error.localizedDescription);
                    [SVProgressHUD dismiss];
                }
            }];
#ifndef DEBUG
        }
        else
        {
            MAXAlert(@"验证码错误 ,#_# :%@",error.localizedDescription);
            [SVProgressHUD dismiss];
        }
#endif
    }];
}

- (void)getVerificationCode:(UITapGestureRecognizer *)tap
{
    MAXVerifyCodeButton *sender = (MAXVerifyCodeButton *)tap.view ;
    if (![_registNumTextField.text isPhoneNumber]) {
        MAXAlert(@"请输入正确格式的手机号码");
        return ;
    }
    
    sender.state = MAXVerifyCodeButtonStateDisabled ;
    
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:_registNumTextField.text zone:@"86" result:^(NSError *error) {
        if (!error) {
            MAXLog(@"验证码请求发送成功");
            sender.state = MAXVerifyCodeButtonStateCountdown ;
        }else{
            MAXLog(@"验证码请求发送失败: %@",error);
            sender.state = MAXVerifyCodeButtonStateNormal ;
            MAXAlert(@"验证码请求发送失败: %@",error);
        }
    }];
}

- (void)resetPassword:(UIButton *)sender
{
    [self.navigationController pushViewController:[[MAXResetPasswordViewController alloc] init] animated:YES];
}

#pragma mark - 第三方登录 

- (void)loginBySina:(UIButton *)sender
{
    [ShareSDK getUserInfo:SSDKPlatformTypeSinaWeibo onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess)
        {
            NSDictionary * authData = @{
                                    @"uid": user.credential.uid,
                                    @"access_token": user.credential.token,
                                    @"expiration_in": user.credential.rawData[@"expires_in"],
                                        };
            [AVUser loginWithAuthData:authData platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser * _Nullable currentUser, NSError * _Nullable error) {
                if (!error)
                {
                    [self loginEM];
                    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                    MAXLog(@"%@",currentUser);
                    isLogined = YES ;
                    [self configHeadImageForUserWithURL:user.rawData[@"avatar_large"]];
                    [self configInkCount:currentUser];
                    [SVProgressHUD dismissWithDelay:1.25 completion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
                else
                {
                    MAXAlert(@"login error:%@",error.localizedDescription);
                }
            }];
        }
        else if (state == SSDKResponseStateFail)
        {
            MAXAlert(@"%@",error);
        }
    }];
}

- (void)loginByQQ:(UIButton *)sender
{
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess)
        {
            NSDictionary * authData = @{
                                        @"openid": user.credential.uid,
                                        @"access_token": user.credential.token,
                                        @"expires_in": user.credential.rawData[@"expires_in"],
                                        };
            [AVUser loginWithAuthData:authData platform:AVOSCloudSNSPlatformQQ block:^(AVUser * _Nullable currentUser, NSError * _Nullable error) {
                if (!error)
                {
                    [self loginEM];
                    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                    MAXLog(@"%@",currentUser);
                    [self configHeadImageForUserWithURL:user.rawData[@"figureurl_qq_2"]];
                    [self configInkCount:currentUser];
                    isLogined = YES ;
                    [SVProgressHUD dismissWithDelay:1.25 completion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
                else
                {
                    MAXAlert(@"login error:%@",error.localizedDescription);
                }
            }];
        }
        else if (state == SSDKResponseStateFail)
        {
            MAXAlert(@"%@",error);
        }
    }];
}

- (void)loginByWeChat:(UIButton *)sender
{
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess)
        {
            NSDictionary * authData = @{
                                        @"openid": user.credential.uid,
                                        @"access_token": user.credential.token,
                                        @"expires_in": user.credential.rawData[@"expires_in"],
                                        };
            [AVUser loginWithAuthData:authData platform:AVOSCloudSNSPlatformWeiXin block:^(AVUser * _Nullable currentUser, NSError * _Nullable error) {
                if (!error)
                {
                    [self loginEM];
                    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                    MAXLog(@"%@",currentUser);
                    isLogined = YES ;
                    [self configHeadImageForUserWithURL:user.rawData[@"headimgurl"]];
                    [self configInkCount:currentUser];
                    [SVProgressHUD dismissWithDelay:1.25 completion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
                else
                {
                    MAXAlert(@"login error:%@",error.localizedDescription);
                }
            }];
        }
        else if (state == SSDKResponseStateFail)
        {
            MAXAlert(@"%@",error);
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)autoLogin
{
    [SVProgressHUD setStatus:@"正在登陆..."];
    [AVUser logInWithUsernameInBackground:[AVUser currentUser].username password:[AVUser currentUser].password block:^(AVUser * _Nullable user, NSError * _Nullable error) {
        if (!error){
            MAXLog(@"登录成功-->%@,%@",user,[AVUser currentUser]);
            isLogined = YES ;
            [self loginEM];
            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
            [SVProgressHUD dismissWithDelay:1.2 completion:^{
                [self inviteCodeAlert];
            }];
        }else{
            MAXAlert(@"登录失败：%@",error.localizedDescription);
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)inviteCodeAlert
{
    UIAlertController *inviteCodeAlert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入邀请码，(若无请点取消)" preferredStyle:UIAlertControllerStyleAlert];
    
    [inviteCodeAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入邀请码";
    }];
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * inviteCodeField = [inviteCodeAlert.textFields lastObject];
        [self increaseInkForInviter:inviteCodeField.text];
        [self.navigationController pushViewController:[MAXCompleteUserInfoViewController currentUser] animated:YES];
    }];
    [inviteCodeAlert addAction:okAction];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController pushViewController:[MAXCompleteUserInfoViewController currentUser] animated:YES];
    }];
    [inviteCodeAlert addAction:cancelAction];
    [self presentViewController:inviteCodeAlert animated:YES completion:nil];
}

- (void)retryInputInviteCodeAlert
{
    UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"邀请码格式错误" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self inviteCodeAlert];
    }];
    [vc addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController pushViewController:[MAXCompleteUserInfoViewController currentUser] animated:YES];
    }];
    [vc addAction:cancelAction];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)increaseInkForInviter:(NSString *)userID
{
    if (![userID isObjectID])
    {
        [self retryInputInviteCodeAlert];
    }
    else
    {
        AVQuery *query = [AVQuery queryWithClassName:@"_User"];
        [query getObjectInBackgroundWithId:userID block:^(AVObject * _Nullable object, NSError * _Nullable error) {
            if (object&&!error)
            {
                AVUser * user =(AVUser *)object;
                NSNumber * ink = user[kUserPropertyInkCount] ;
                if (ink)
                {
                    NSInteger inkCount = [ink integerValue];
                    user[kUserPropertyInkCount] = @(inkCount+60);
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        MAXLog(@"inviter :%@ -->%@",user.username,error);
                    }];
                }
            }
        }];
    }
}

#pragma mark - UINavigation Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (isLogined)
    {
        if (self == viewController)
        {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.userNameTextField becomeFirstResponder];
}

- (void)configHeadImageForUserWithURL:(NSString *)url
{
    if ([AVUser currentUser][kUserPropertyCircleHeadImage]
        &&[AVUser currentUser][kUserPropertyHeadImage])
    {
        return ;
    }
    
    AVFile * image = [AVFile fileWithURL:url];
    [image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (!error)
        {
            UIImage * originImage = [UIImage imageWithData:data];
            UIImage * circleImage = [originImage circleImageWithBorderWidth:1 borderColor:[UIColor whiteColor]];
            AVFile *originHeadImg = [AVFile fileWithData:UIImageJPEGRepresentation(originImage, 0)];
            AVFile *circleHeadImg = [AVFile fileWithData:UIImageJPEGRepresentation(circleImage, 0)];
            [AVUser currentUser][kUserPropertyHeadImage] = originHeadImg ;
            [AVUser currentUser][kUserPropertyCircleHeadImage] = circleHeadImg ;
            [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error)
                {
                    MAXLog(@"error : %@",error.localizedDescription);
                }
            }];
        }
    }];
}

- (void) configInkCount:(AVUser *)user
{
    if (!user[kUserPropertyInkCount])
    {
        user[kUserPropertyInkCount] = @120 ;
        [user save] ;
    }
}

- (void)registEM
{
    [[EMClient sharedClient] registerWithUsername:[AVUser currentUser].objectId password:[AVUser currentUser].objectId completion:^(NSString *aUsername, EMError *aError) {
        if (!aError)
        {
            [self loginEM];
            MAXLog(@"环信注册成功");
        }
        else
        {
            MAXLog(@"%@",aError.errorDescription);
        }
    }];
}

- (void)loginEM
{
    [[EMClient sharedClient] loginWithUsername:[AVUser currentUser].objectId password:[AVUser currentUser].objectId completion:^(NSString *aUsername, EMError *aError) {
        if (!aError)
        {
            MAXLog(@"EM loginSuccess...");
            [[EMClient sharedClient] setApnsNickname:[AVUser currentUser].username];
            [[EMClient sharedClient].options setIsAutoLogin:YES] ;
            [[MAXEMHelper shareHelper] asyncGroupFromServer];
            [[MAXEMHelper shareHelper] asyncConversationFromDB];
            [[MAXEMHelper shareHelper] asyncPushOptions];
        }
        if(aError.code == 204)
        {
            [self registEM];
        }
        else
        {
            MAXLog(@"%@-->%@",aUsername,aError.errorDescription);
        }
    }];
}


@end
