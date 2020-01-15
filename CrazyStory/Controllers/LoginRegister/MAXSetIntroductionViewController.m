//
//  MAXSetIntroductionViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/8.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXSetIntroductionViewController.h"

@interface MAXSetIntroductionViewController ()
@property (weak, nonatomic) IBOutlet UITextView *inputIntroductionTextView;
@property (weak, nonatomic) IBOutlet UILabel *textViewPlaceholdLabel;

@end

@implementation MAXSetIntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.navigationItem.title = @"设置简介" ;
    self.navigationItem.backBarButtonItem.title = @"取消";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(setIntroduction)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_inputIntroductionTextView becomeFirstResponder];
}

- (void)setIntroduction
{
    if (_inputIntroductionTextView.text.length>100)
    {
        MAXAlert(@"简介长度不要超过100.");
        return ;
    }
    
    [[AVUser currentUser] setObject:_inputIntroductionTextView.text forKey:kUserPropertyInstroduction];
    [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded)
        {
            [SVProgressHUD showSuccessWithStatus:@"更新成功"];
            [SVProgressHUD dismissWithDelay:1.2 completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
        {
            MAXAlert(@"更新简介失败： %@",error.localizedDescription);
        }
    }];
}
@end
