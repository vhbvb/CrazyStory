//
//  MAXWriteStoryViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/9.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXWriteStoryViewController.h"
#import "MAXLoginRegisterViewController.h"
#import "NSString+MAXCommon.h"
#import "Masonry.h"
#import "SVProgressHUD.h"

@interface MAXWriteStoryViewController ()<UITextViewDelegate>

@property(nonatomic, strong) UITextField * titleField ;
@property(nonatomic, strong) UITextField * briefField ;
@property(nonatomic, strong) UITextView * contentField ;
@property(nonatomic, strong) UILabel * alertLabel ;

@end

@implementation MAXWriteStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.navigationItem.title = @"开始故事" ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postStory:)];
}

- (void)configUI
{
    self.titleField =
    ({
        UITextField * titleFiled = [[UITextField alloc] init];
        titleFiled.placeholder = @"请输入故事名,不要超过15个字符";
        [self.view addSubview:titleFiled];
        [titleFiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(25);
            make.height.equalTo(@44);
        }];
        titleFiled ;
    });
    
    UIView * cutLine = [[UIView alloc] init];
    cutLine.backgroundColor = [UIColor grayColor];
    cutLine.alpha = 0.66;
    [self.view addSubview:cutLine];
    [cutLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_titleField.mas_bottom);
        make.height.equalTo(@1);
    }];
    
    self.briefField =
    ({
        UITextField * briefField = [[UITextField alloc] init];
        briefField.placeholder = @"简介：（可不填,不要超过30个字）";
        [self.view addSubview:briefField];
        [briefField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(cutLine.mas_bottom);
            make.height.equalTo(@44);
        }];
        briefField ;
    });
    
    UIView * cutLine1 = [[UIView alloc] init];
    cutLine1.backgroundColor = [UIColor grayColor];
    cutLine1.alpha = 0.66;
    [self.view addSubview:cutLine1];
    [cutLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_briefField.mas_bottom);
        make.height.equalTo(@1);
    }];
    
    self.alertLabel =
    ({
        UILabel * alertLabel = [[UILabel alloc] init];
        alertLabel.text = @"还可以输入500字符" ;
        alertLabel.textColor = [UIColor grayColor];
        alertLabel.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:alertLabel];
        [alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        alertLabel ;
    });
    
    self.contentField =
    ({
        UITextView *contentField = [[UITextView alloc] init];
        contentField.font = [UIFont systemFontOfSize:16];
        contentField.delegate = self ;
        [self.view addSubview:contentField];
        [contentField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(cutLine1.mas_bottom);
            make.bottom.equalTo(_alertLabel.mas_top);
        }];
        contentField ;
    });
}

- (void)postStory:(UINavigationItem *)item
{
    if (!isLogined)
    {
        [self.navigationController pushViewController:[[MAXLoginRegisterViewController alloc] init] animated:YES];
        return ;
    }
    
    if ([_titleField.text length]>15)
    {
        MAXAlert(@"故事名不要超过15个字符");
        return ;
    }
    
    if ([_briefField.text length]>30) {
        MAXAlert(@"简介不要写太多哦.(30字以内)");
        return ;
    }
    
    if ([_contentField.text length]>500) {
        MAXAlert(@"故事不要写太长哦.(500字以内)");
        return ;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO ;
    AVObject *story = [AVObject objectWithClassName:kStoriesListClass];
    story[kStoryPropertyTitle] = self.titleField.text ;
    story[kStoryPropertyOwner] = [AVUser currentUser];
    story[kStoryPropertyInstroduction] = _briefField.text ;
    story[kStoryPropertySeeCount] = @0 ;
    story[kStoryPropertyLikeCount] = @0 ;
    [SVProgressHUD showWithStatus:@"正在保存..."];
    [story saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            AVObject *storyContent = [AVObject objectWithClassName:kContentsListClass];
            storyContent[kContentPropertyContent] = self.contentField.text;
            storyContent[kContentPropertyOwner] = [AVUser currentUser];
            storyContent[kContentPropertyStory] = story ;
            [storyContent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded)
                {
                    [SVProgressHUD showSuccessWithStatus:@"发布成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    self.navigationItem.rightBarButtonItem.enabled = YES ;
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"发布失败：%@",error]];
                }
            }];
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = YES ;
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"发布失败：%@",error]];
        }
    }];
}

#pragma mark - TextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger textLength = _contentField.text.length + text.length ;
    if (textLength > 500) {
        return NO ;
    }else{
        self.alertLabel.text = [NSString stringWithFormat:@"还可以输入%zd个字符",500 - textLength];
        return YES ;
    }
}

#pragma mark -  UIKeyboardNotification

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat height = [aValue CGRectValue].size.height;
    
    [self.alertLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-(height-44));
    }];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    [self.alertLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
