//
//  MAXVerifyPhoneNumberViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/8.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXVerifyPhoneNumberViewController.h"
#import "MAXSetPasswordViewController.h"
#import <SMS_SDK/SMSSDK.h>

@interface MAXVerifyPhoneNumberViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputPhoneNoOrEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getVerificationCodeBtn;

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
}

- (IBAction)getVerificationCode:(id)sender
{
    if ([_inputPhoneNoOrEmailTextField.text isPhoneNumber])
    {
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:_inputPhoneNoOrEmailTextField.text zone:@"86" customIdentifier:nil result:^(NSError *error)
        {
            if (!error) {
                MAXLog(@"发送验证码成功");
            }else{
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
    if ([_inputPhoneNoOrEmailTextField.text isPhoneNumber])
    {
        [SMSSDK commitVerificationCode:_verificationCodeTextField.text phoneNumber:_inputPhoneNoOrEmailTextField.text zone:@"86" result:^(SMSSDKUserInfo *userInfo, NSError *error)
        {
            [SVProgressHUD showSuccessWithStatus:@"验证成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithCompletion:^{
                    [self.navigationController pushViewController:[[MAXSetPasswordViewController alloc] init] animated:YES];
                }];
            });
        }];
    }
    else
    {
        MAXAlert(@"请输入正确格式的电话号码");
    }
}

@end
