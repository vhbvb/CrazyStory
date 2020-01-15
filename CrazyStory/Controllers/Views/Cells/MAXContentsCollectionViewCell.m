//
//  MAXContentsCollectionViewCell.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/15.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXContentsCollectionViewCell.h"
#import "Masonry.h"

@interface MAXContentsCollectionViewCell()

@property (nonatomic ,strong) UITextView *contentTextView ;
@property (nonatomic, strong) UILabel * contentCreatTime ;
@property (nonatomic, strong) UILabel * contentOwner ;

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
    self.contentTextView =
    ({
        UITextView * contentTextView  = [[UITextView alloc] init];
//        contentTextView.backgroundColor = [UIColor redColor];
        contentTextView.userInteractionEnabled = NO ;
        contentTextView.text = @" null ";
        contentTextView.font = [UIFont systemFontOfSize:16];
        [self addSubview:contentTextView];
        [contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self).offset(10);
            make.bottom.equalTo(self).offset(-10);
        }];
        contentTextView ;
    });
    
    self.contentCreatTime =
    ({
        UILabel *contentCreatTime = [[UILabel alloc] init];
        contentCreatTime.text = @"at: - - " ;
        contentCreatTime.font = [UIFont systemFontOfSize:12];
        contentCreatTime.textColor = [UIColor darkGrayColor];
        [self addSubview:contentCreatTime];
        [contentCreatTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self);
        }];
        contentCreatTime ;
    });
    
    self.contentOwner =
    ({
        UILabel *contentOwner = [[UILabel alloc] init];
        contentOwner.text = @"creatBy: - - " ;
        contentOwner.font = [UIFont systemFontOfSize:12];
        contentOwner.textColor = [UIColor darkGrayColor];
        [self addSubview:contentOwner];
        [contentOwner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_contentCreatTime.mas_left).offset(-3) ;
            make.centerY.equalTo(_contentCreatTime);
        }];
        contentOwner ;
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
    
    UILabel * branch = [[UILabel alloc] init];
    branch.text = @"branch" ;
    branch.font = [UIFont systemFontOfSize:12];;
    branch.textColor = [UIColor grayColor];
    [self addSubview:branch];
    [branch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(self);
    }];
}

- (void)setModel:(AVObject *)model
{
    _model = model ;
    
    _contentTextView.text = _model[kContentPropertyContent];
    _contentCreatTime.text = [NSString stringWithFormat:@"at: %@",[NSString localTimeStringWithDate:_model.createdAt]];
    AVUser * user = _model[kContentPropertyOwner];
    if ([user isKindOfClass:[AVUser class]])
    {
        _contentOwner.text = [NSString stringWithFormat:@"creatBy: %@ ",user.username];
    }

}


@end
