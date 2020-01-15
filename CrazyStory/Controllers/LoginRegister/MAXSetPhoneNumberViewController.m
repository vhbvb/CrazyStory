//
//  MAXSetPhoneNumberViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/8.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXSetPhoneNumberViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import "MAXVerifyCodeButton.h"

@interface MAXSetPhoneNumberViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputPhoneNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCode;

@end

@implementation MAXSetPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.navigationItem.title = @"修改手机号码";
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.navigationItem.backBarButtonItem.title = @"取消";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(setPhoneNumber)];
    self.verificationCode.rightViewMode = UITextFieldViewModeAlways ;
    self.verificationCode.rightView =
    ({
        MAXVerifyCodeButton *getVerificationCodeBtn = [[MAXVerifyCodeButton alloc] init];
        [getVerificationCodeBtn addTapGestureWithTarget:self action:@selector(getVerification:)];
        getVerificationCodeBtn;
    });
}

- (void)getVerification:(UITapGestureRecognizer *)tap
{
    MAXVerifyCodeButton * sender = (MAXVerifyCodeButton *)tap.view ;
    if ([_inputPhoneNumTextField.text isPhoneNumber])
    {
        sender.state = MAXVerifyCodeButtonStateDisabled ;
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:_inputPhoneNumTextField.text zone:@"86" result:^(NSError *error) {
            if (!error) {
                MAXLog(@"发送验证码成功");
                sender.state = MAXVerifyCodeButtonStateCountdown ;
            }else{
                sender.state = MAXVerifyCodeButtonStateNormal ;
                MAXAlert(@"验证码发送失败：%@",error);
            }
        }];
    }
    else
    {
        MAXAlert(@"请输入正确格式的电话号码");
    }
    
}

- (void)setPhoneNumber
{
    if (![_inputPhoneNumTextField.text isPhoneNumber])
    {
        MAXAlert(@"请输入正确格式的电话号码");
        return ;
    }
    
    if ([_inputPhoneNumTextField.text isEqualToString:[AVUser currentUser].mobilePhoneNumber])
    {
        MAXAlert(@"已绑定此号码，不需要重复绑定");
        return ;
    }

    self.navigationItem.rightBarButtonItem.enabled = NO ;

    [SMSSDK commitVerificationCode:_verificationCode.text phoneNumber:_inputPhoneNumTextField.text zone:@"86" result:^(NSError *error) {
        if (!error)
        {
            [AVUser currentUser].mobilePhoneNumber = _inputPhoneNumTextField.text ;
            [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
            {
                if (succeeded)
                {
                    [SVProgressHUD showSuccessWithStatus:@"更新成功"];
                    [SVProgressHUD dismissWithDelay:1.2 completion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
                else
                {
                    MAXAlert(@"设置失败：%@",error);
                    self.navigationItem.rightBarButtonItem.enabled = YES ;
                }
            }];
        }
        else
        {
            MAXAlert(@"验证码错误：%@",error);
            self.navigationItem.rightBarButtonItem.enabled = YES ;
        }
    }];
}

@end
