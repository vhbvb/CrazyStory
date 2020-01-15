//
//  MAXSetUserNameViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/8.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXSetUserNameViewController.h"
#import "NSString+MAXCommon.h"

@interface MAXSetUserNameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *inputUserNameTextFiled;

@end

@implementation MAXSetUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.navigationItem.title = @"修改昵称" ;
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.navigationItem.backBarButtonItem.title = @"取消";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(setUserName)];
}

- (void)setUserName
{
    
    if (![_inputUserNameTextFiled.text isUserName]) {
        MAXAlert(@"格式错误：用户名由3到12位字母数字汉字下划线组成，不能以下划线开头和结尾。");
        return ;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO ;
    
    [AVUser currentUser].username = _inputUserNameTextFiled.text ;
    [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            [SVProgressHUD dismissWithDelay:1.2 completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            MAXAlert(@"修改失败 :%@",error.localizedDescription);
            self.navigationItem.rightBarButtonItem.enabled = YES ;
        }
    }];
}
@end
