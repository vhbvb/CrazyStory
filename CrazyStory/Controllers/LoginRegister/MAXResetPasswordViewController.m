//
//  MAXResetPasswordViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/22.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXResetPasswordViewController.h"
#import "MAXVerifyCodeButton.h"

@interface MAXResetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;

@end

@implementation MAXResetPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.verifyCodeTextField.rightView =
    ({
        MAXVerifyCodeButton * verifyCodeButton = [[MAXVerifyCodeButton alloc] init];
        [verifyCodeButton addTapGestureWithTarget:self action:@selector(getVerifyCode:)];
        verifyCodeButton ;
    });
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.navigationItem.title = @"重置密码";
    [self.phoneNumberTextField becomeFirstResponder];
}

- (IBAction)resetPassword:(id)sender
{
    if (![_passwordTextField.text isPassword])
    {
        MAXAlert(@"密码格式错误：6-18位大小写字母和数字组成");
        return ;
    }
    
    if (![_passwordTextField.text isEqualToString:_repeatPasswordTextField.text])
    {
        MAXAlert(@"两次输入的密码不一致");
        return ;
    }
    
    [SVProgressHUD showWithStatus:@"正在重置..."];
    [AVUser resetPasswordWithSmsCode:_verifyCodeTextField.text newPassword:_passwordTextField.text block:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [SVProgressHUD showSuccessWithStatus:@"密码已重置"];
            [SVProgressHUD dismissWithDelay:1.2 completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
        {
            [SVProgressHUD dismiss];
            MAXAlert(@"resetPassword error: %@",error.localizedDescription);
        }
    }];
}

- (void)getVerifyCode:(UITapGestureRecognizer *)tap
{
    MAXVerifyCodeButton * sender = (MAXVerifyCodeButton *)tap.view ;
    
    if(![_phoneNumberTextField.text isPhoneNumber])
    {
        MAXAlert(@"请输入正确格式的手机号码");
        return ;
    }
    
    sender.state = MAXVerifyCodeButtonStateDisabled ;
    [AVUser requestPasswordResetWithPhoneNumber:_phoneNumberTextField.text block:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            sender.state = MAXVerifyCodeButtonStateCountdown ;
        }
        else
        {
            MAXLog(@"%@",error.localizedDescription);
            sender.state = MAXVerifyCodeButtonStateNormal ;
        }
    }];
}

@end
