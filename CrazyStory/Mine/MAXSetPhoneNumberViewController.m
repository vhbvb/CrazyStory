//
//  MAXSetPhoneNumberViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/8.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXSetPhoneNumberViewController.h"
#import <SMS_SDK/SMSSDK.h>

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
}

- (IBAction)getVerification:(id)sender
{
    if ([_inputPhoneNumTextField.text isPhoneNumber])
    {
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:_inputPhoneNumTextField.text zone:@"86" customIdentifier:nil result:^(NSError *error) {
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

- (void)setPhoneNumber
{
    if (![_inputPhoneNumTextField.text isPhoneNumber])
    {
        MAXAlert(@"请输入正确格式的电话号码");
        return ;
    }

    self.navigationItem.rightBarButtonItem.enabled = NO ;

    [SMSSDK commitVerificationCode:_verificationCode.text phoneNumber:_inputPhoneNumTextField.text zone:@"86" result:^(SMSSDKUserInfo *userInfo, NSError *error) {
        if (!error)
        {
            [AVUser currentUser].mobilePhoneNumber = _inputPhoneNumTextField.text ;
            [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
            {
                if (succeeded)
                {
                    [SVProgressHUD showSuccessWithStatus:@"更新成功"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(),^
                    {
                        [SVProgressHUD dismissWithCompletion:^
                        {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    });
                }else{
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
