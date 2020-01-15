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
@property(nonatomic, strong) UITextView * contentField ;
@property(nonatomic, strong) UILabel * alertLabel ;

@end

@implementation MAXWriteStoryViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES ;
    }
    return self;
}

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(postStory:)];

}

- (void)configUI
{
    self.titleField =
    ({
        UITextField * titleFiled = [[UITextField alloc] init];
        titleFiled.placeholder = @"请输入故事名,不要超过45个字符";
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
    
    self.alertLabel =
    ({
        UILabel * alertLabel = [[UILabel alloc] init];
        alertLabel.text = @"还可以输入160字符" ;
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
            make.top.equalTo(cutLine.mas_bottom);
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
    
    NSInteger inkCount = [[AVUser currentUser][kUserPropertyInkCount] integerValue];
    if (inkCount<=0)
    {
        MAXAlert(@"你没有墨水了，请及时充值后再试");
        return ;
    }
    
    NSString * title = [_titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (title.length>45 || title.length < 1)
    {
        MAXAlert(@"请输入1到45个字符的故事名");
        return ;
    }
    
    
    if (_contentField.text.length>160) {
        MAXAlert(@"故事不要写太长哦.(160字以内)");
        return ;
    }
    
    NSString *content = [_contentField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (content.length<10) {
        MAXAlert(@"故事内容不少于10个字符");
        return ;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO ;
    AVObject *story = [AVObject objectWithClassName:kStoriesListClass];
    story[kStoryPropertyTitle] = self.titleField.text ;
    story[kStoryPropertyOwner] = [AVUser currentUser];
    
    NSString * brief = content.length>16 ? [content substringToIndex:16] : content;
    
    story[kStoryPropertyInstroduction] = [brief stringByAppendingString:@"......"];
    story[kStoryPropertySeeCount] = @0 ;
    story[kStoryPropertyLikeCount] = @0 ;
    [SVProgressHUD showWithStatus:@"正在保存..."];
    [story saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            AVObject *storyContent = [AVObject objectWithClassName:kContentsListClass];
            storyContent[kContentPropertyContent] = content;
            storyContent[kContentPropertyOwner] = [AVUser currentUser];
            storyContent[kContentPropertyStory] = story ;
            [storyContent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded)
                {
                    [SVProgressHUD showSuccessWithStatus:@"发布成功"];
                    [self deductInkCount];
                    [SVProgressHUD dismissWithDelay:1.3 completion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
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

- (void)deductInkCount
{
    NSNumber *inkCount = [AVUser currentUser][kUserPropertyInkCount];
    
    if (inkCount && [inkCount isKindOfClass:NSNumber.class])
    {
        NSInteger currentInk = inkCount.integerValue - 12 ;
        [AVUser currentUser][kUserPropertyInkCount] = @(currentInk) ;
        [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            MAXLog(@"deductInkCount--> %@",error);
        }] ;
    }
}

#pragma mark - TextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger textLength = _contentField.text.length + text.length ;
    if (textLength > 160) {
        return NO ;
    }else{
        self.alertLabel.text = [NSString stringWithFormat:@"还可以输入%zd个字符",160 - textLength];
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
        make.bottom.equalTo(self.view).offset(-height);
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
