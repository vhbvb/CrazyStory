//
//  MAXSetPasswordViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/8.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXSetPasswordViewController.h"

@interface MAXSetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation MAXSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}

- (void)setup
{
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.navigationItem.title = @"设置密码" ;
}

- (IBAction)confirm:(UIButton *)sender
{
    sender.enabled = NO ;
    BOOL isPassword = [_inputPasswordTextField.text isPassword];
    BOOL isSame = [_inputPasswordTextField.text isEqualToString:_confirmPasswordTextField.text];
    
    if (isPassword)
    {
        if (isSame)
        {
            //修改密码
            [self changePassword:sender];
        }
        else
        {
            MAXAlert(@"两次输入的密码不一致");
            sender.enabled = YES ;
        }
    }
    else
    {
        MAXAlert(@"请输入正确格式的密码");
        sender.enabled = YES ;
    }
}

- (void)changePassword:(UIButton *)sender
{
    [AVUser currentUser].password = _inputPasswordTextField.text;
    [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            [SVProgressHUD showSuccessWithStatus:@"密码修改成功"];
            [AVUser logOut];
            isLogined = NO ;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithCompletion:^{
                    [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count-4] animated:YES];
                }];
            });
        }else
        {
            MAXAlert(@"密码更新失败:%@",error.localizedDescription);
            sender.enabled = YES ;
        }
    }];
}

@end
