//
//  MAXStoryContentTableViewCell.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXStoryContentTableViewCell.h"
#import "Masonry.h"

@interface MAXStoryContentTableViewCell()

@property(nonatomic, strong) UITextView *contentTextView ;
@property(nonatomic, strong) UILabel * contentCreatTime ;
@property(nonatomic, strong) UILabel * contentOwner ;
@end

@implementation MAXStoryContentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configUI];
    }
    return self ;
}

- (void)configUI
{
    self.contentTextView =
    ({
        UITextView * contentTextView  = [[UITextView alloc] init];
        contentTextView.scrollEnabled = NO ;
        contentTextView.text = @" null ";
        contentTextView.font = [UIFont systemFontOfSize:16];
        contentTextView.editable = NO ;
        [self addSubview:contentTextView];
        [contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self).offset(24);
            make.height.equalTo(@36);
        }];
        contentTextView ;
    });
    
    self.contentCreatTime =
    ({
        UILabel *contentCreatTime = [[UILabel alloc] init];
        contentCreatTime.text = @"at: - - " ;
        contentCreatTime.font = [UIFont systemFontOfSize:13];
        contentCreatTime.textColor = [UIColor darkGrayColor];
        [self addSubview:contentCreatTime];
        [contentCreatTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.bottom.equalTo(self).offset(-5);
        }];
        contentCreatTime ;
    });
    
    self.contentOwner =
    ({
        UILabel *contentOwner = [[UILabel alloc] init];
        contentOwner.text = @"creatBy: - - " ;
        contentOwner.font = [UIFont systemFontOfSize:13];
        contentOwner.textColor = [UIColor darkGrayColor];
        [self addSubview:contentOwner];
        [contentOwner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_contentCreatTime.mas_left).offset(-3) ;
            make.top.equalTo(_contentCreatTime);
        }];
        
        contentOwner ;
    });
}

- (void)setModel:(AVObject *)model
{
    _model = model ;

    _contentTextView.text = _model[kContentPropertyContent];
    CGFloat height = [_contentTextView sizeThatFits:CGSizeMake(kScreenWidth-25, CGFLOAT_MAX)].height;
    [_contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
    
    _contentCreatTime.text = [NSString stringWithFormat:@"at: %@",[NSString localTimeStringWithDate:_model.createdAt]];
    AVUser * user = _model[kContentPropertyOwner];
    if ([user isKindOfClass:[AVUser class]])
    {
        _contentOwner.text = [NSString stringWithFormat:@"creatBy: %@ ",user.username];
    }
    
    if (!_model[@"cellHeight"])
    {
        CGFloat creatTimeLabelHeight = 15.67 ; //算出来的。
        _model[@"cellHeight"] = @(24+height+creatTimeLabelHeight+15) ;
    }
}

@end
