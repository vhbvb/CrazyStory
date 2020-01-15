//
//  MAXContentsCollectionViewCell.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/15.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXContentsCollectionViewCell.h"
#import "UIImage+MAXExtend.h"
#import "AVUser+MAXExtend.h"
#import "Masonry.h"

@interface MAXContentsCollectionViewCell()

@property(nonatomic ,strong) UITextView *contentTextView ;
//@property (nonatomic, strong) UILabel * contentCreatTime ;
@property(nonatomic, strong) UILabel * contentOwner ;
@property(nonatomic, strong) UIImageView * headImageView ;
@property(nonatomic, strong) UILabel * branch ;

@end

@implementation MAXContentsCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self configUI];
    }
    return self ;
}

- (void)configUI
{
    
    self.headImageView =
    ({
        UIImageView *headImageView = [[UIImageView alloc] init];
        UIImage * placeholdHeadImg = [UIImage imageNamed:@"defaultHeadImg"];
        headImageView.image = [placeholdHeadImg imageScaledToSize:CGSizeMake(39, 39)];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.top.equalTo(self).offset(15);
            make.height.width.equalTo(@39);
        }];
        headImageView ;
    });
    
    self.contentOwner =
    ({
        UILabel *contentOwner = [[UILabel alloc] init];
        contentOwner.text = @" - - " ;
        contentOwner.font = [UIFont systemFontOfSize:13];
        contentOwner.textColor = [UIColor darkGrayColor];
        contentOwner.textAlignment = NSTextAlignmentCenter;
        contentOwner.numberOfLines = 0 ;
        [self addSubview:contentOwner];
        [contentOwner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_headImageView) ;
            make.top.equalTo(_headImageView.mas_bottom).offset(10);
            make.width.equalTo(@44);
        }];
        contentOwner ;
    });
    
    UIView * line = [[UIView alloc] init];
    line.backgroundColor = [UIColor lightGrayColor];
    line.alpha = 0.5 ;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(49);
        make.width.equalTo(@1);
    }];
    
    self.contentTextView =
    ({
        UITextView * contentTextView  = [[UITextView alloc] init];
        contentTextView.scrollEnabled = NO;
        contentTextView.text = @" null ";
        contentTextView.userInteractionEnabled = NO;
        contentTextView.font = [UIFont systemFontOfSize:16];
        contentTextView.editable = NO ;
        [self addSubview:contentTextView];
        [contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.left.equalTo(line.mas_right);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
        contentTextView ;
    });
    
    UIView * topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    UIView * leftLine = [[UIView alloc] init];
    leftLine.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:leftLine];
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self);
        make.width.equalTo(@1);
    }];
    
    UIView * rightLine = [[UIView alloc] init];
    rightLine.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:rightLine];
    [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self);
        make.width.equalTo(@1);
    }];
    
    UIView * bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    self.branch =
    ({
        UILabel * branch = [[UILabel alloc] init];
        branch.text = @"分支 1" ;
        branch.font = [UIFont systemFontOfSize:11];;
        branch.textColor = [UIColor grayColor];
        [self addSubview:branch];
        [branch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_headImageView);
            make.bottom.equalTo(self).offset(-3);
        }];
        branch ;
    });
}

- (void)setModel:(AVObject *)model
{
    _model = model ;
    
    _contentTextView.text = _model[kContentPropertyContent];
    AVUser * user = _model[kContentPropertyOwner];
    if ([user isKindOfClass:[AVUser class]])
    {
        _contentOwner.text = user.username;
    }
    
    [AVUser getCircleHeadImageForUser:user result:^(UIImage *image, NSError *error) {
        if(!error&&image)
        {
            _headImageView.image = image ;
        }
        else
        {
            MAXLog(@"%@ headImg:%@ error:%@",user,image,error);
        }
    }];
}

- (void)setIndex:(NSInteger)index
{
    _index = index ;
    _branch.text = [NSString stringWithFormat:@"分支 %zd",_index];
}

@end
