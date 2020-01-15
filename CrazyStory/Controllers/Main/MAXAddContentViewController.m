//
//  MAXAddContentViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/13.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXAddContentViewController.h"
#import "MAXLoginRegisterViewController.h"
#import "MAXStoryContentTableViewCell.h"
#import "Masonry.h"
#import "SVProgressHUD.h"

@interface MAXAddContentViewController ()<UITextViewDelegate>

@property(nonatomic, strong) MAXStoryContentTableViewCell *superContentView ;
@property(nonatomic, strong) UITextView *addContentTextView ;
@property(nonatomic, strong) AVObject * superContentModel ;
@property(nonatomic, strong) UILabel * alertLabel ;

@end

@implementation MAXAddContentViewController


- (instancetype)initWithSuperContentModel:(AVObject *)model
{
    if (self = [super init]) {
        self.superContentModel = model ;
    }
    return self ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self configUI];
}

- (void) setup
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.navigationItem.title = @"写故事";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(post:)];
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
    [self.addContentTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configUI
{
    self.superContentView =
    ({
        MAXStoryContentTableViewCell * cell = [[MAXStoryContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStoryContentCellReuseIdentifier];
        cell.model = _superContentModel;
        [self.view addSubview:cell];
        [cell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.height.equalTo(_superContentModel[@"cellHeight"]);
        }];
        cell ;
    });

    UILabel * alertLabel = [[UILabel alloc] init];
    alertLabel.text = @"接着写 ：";
    alertLabel.font = [UIFont systemFontOfSize:14];
    alertLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:alertLabel];
    [alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(_superContentView.mas_bottom);
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

    
    self.addContentTextView =
    ({
        UITextView *addContentTextView = [[UITextView alloc] init];
        addContentTextView.font = [UIFont systemFontOfSize:16];
        addContentTextView.delegate = self ;
        [self.view addSubview:addContentTextView];
        [addContentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(_alertLabel.mas_top);
            make.top.equalTo(alertLabel.mas_bottom).offset(5);
        }];
        addContentTextView ;
    });
    
}

- (void)post:(UIBarButtonItem *)barBtn
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
    
    if (_addContentTextView.text.length>160) {
        MAXAlert(@"故事不要写太长哦.(160字以内)");
        return ;
    }
    
    NSString *content = [_addContentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (content.length<10) {
        MAXAlert(@"故事内容不少于10个字符");
        return ;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO ;
    AVObject * AddedContent = [AVObject objectWithClassName:kContentsListClass];
    AddedContent[kContentPropertyOwner] = [AVUser currentUser];
    AddedContent[kContentPropertySuperContent] = _superContentModel;
    AddedContent[kContentPropertyStory] = _superContentModel[kContentPropertyStory];
    AddedContent[kContentPropertyContent] = _addContentTextView.text ;
    [AddedContent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(!succeeded)
        {
            self.navigationItem.rightBarButtonItem.enabled = YES ;
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"发布失败:%@",error]];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"发布成功"];
            [self deductInkCount];
            [SVProgressHUD dismissWithDelay:1.2 completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
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
    NSInteger textLength = _addContentTextView.text.length + text.length ;
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
