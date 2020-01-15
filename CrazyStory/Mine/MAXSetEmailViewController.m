//
//  MAXSetEmailViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/8.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXSetEmailViewController.h"

@interface MAXSetEmailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputEmailTextField;
//@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;

@end

@implementation MAXSetEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.navigationItem.title = @"设置邮箱" ;
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.navigationItem.backBarButtonItem.title = @"取消";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(setEmail)];
}

- (void)setEmail
{
    if (![_inputEmailTextField.text isEmail])
    {
        MAXAlert(@"请输入正确格式的邮箱");
        return ;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO ;
    [AVUser currentUser].email = _inputEmailTextField.text ;
    [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"更新成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithCompletion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            });
        }else{
            MAXAlert(@"设置邮箱失败：%@",error);
            self.navigationItem.rightBarButtonItem.enabled = YES ;
        }
    }];

}
@end
