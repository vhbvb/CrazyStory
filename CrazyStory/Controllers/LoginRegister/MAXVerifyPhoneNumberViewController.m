//
//  MAXVerifyPhoneNumberViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/8.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXVerifyPhoneNumberViewController.h"
#import "MAXSetPasswordViewController.h"
#import "MAXVerifyCodeButton.h"
#import <SMS_SDK/SMSSDK.h>

@interface MAXVerifyPhoneNumberViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputPhoneNoOrEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;

@end

@implementation MAXVerifyPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.navigationItem.title = @"验证";
    self.verificationCodeTextField.rightViewMode = UITextFieldViewModeAlways ;
    self.verificationCodeTextField.rightView =
    ({
        MAXVerifyCodeButton *getVerificationCodeBtn = [[MAXVerifyCodeButton alloc] init];
        [getVerificationCodeBtn addTapGestureWithTarget:self action:@selector(getVerificationCode:)];
        getVerificationCodeBtn;
    });
}

- (void)getVerificationCode:(UITapGestureRecognizer *)tap
{
    MAXVerifyCodeButton * sender = (MAXVerifyCodeButton * )tap.view ;
    if ([_inputPhoneNoOrEmailTextField.text isPhoneNumber])
    {
        sender.state = MAXVerifyCodeButtonStateDisabled ;
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:_inputPhoneNoOrEmailTextField.text zone:@"86" result:^(NSError *error)
        {
            if (!error)
            {
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
- (IBAction)confirm:(id)sender
{
    if (![_inputPhoneNoOrEmailTextField.text isEqualToString:[AVUser currentUser].mobilePhoneNumber])
    {
        MAXAlert(@"请输入绑定的手机号码，若未绑定，请先绑定。");
        return ;
    }
    
    if ([_inputPhoneNoOrEmailTextField.text isPhoneNumber])
    {
        [SMSSDK commitVerificationCode:_verificationCodeTextField.text phoneNumber:_inputPhoneNoOrEmailTextField.text zone:@"86" result:^(NSError *error)
        {
            [SVProgressHUD showSuccessWithStatus:@"验证成功"];
            [SVProgressHUD dismissWithDelay:1.2 completion:^{
                [self.navigationController pushViewController:[[MAXSetPasswordViewController alloc] init] animated:YES];
            }];
        }];
    }
    else
    {
        MAXAlert(@"请输入正确格式的电话号码");
    }
}

@end
