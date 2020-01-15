//
//  MAXStoryTableViewCell.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXStoryTableViewCell.h"
#import "UIImage+MAXExtend.h"
#import "Masonry.h"

@interface MAXStoryTableViewCell()

@property (nonatomic, strong) UIImageView * headImgView ;
@property (nonatomic, strong) UILabel * authorLabel ;
@property (nonatomic, strong) UILabel * creatTimeLabel ;
@property (nonatomic, strong) UILabel * watchCountLabel ;
@property (nonatomic, strong) UILabel * likeCountLabel ;
@property (nonatomic, strong) UILabel * storyNameLabel ;
@property (nonatomic, strong) UILabel * briefLabel ;
@property (nonatomic, strong) UIView * submittersView ;
@property (nonatomic, strong) NSMutableArray <AVUser *>* submitters ;
@property (nonatomic, copy) void (^process)(AVUser *) ;

@end

@implementation MAXStoryTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self ;
}

- (void)setupUI
{
    self.headImgView =
    ({
        UIImageView *headImgView = [[UIImageView alloc] init];
        headImgView.image = [UIImage imageNamed:@"defaultHeadImg"];
        [self addSubview:headImgView];
        [headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.top.equalTo(self).offset(15);
            make.width.height.equalTo(@40);
        }];
        headImgView ;
    });
    
    self.authorLabel =
    ({
        UILabel * authorLabel = [[UILabel alloc] init];
        authorLabel.text = @"作者 ：";
        authorLabel.font = [UIFont systemFontOfSize:12.5];
        authorLabel.textColor = [UIColor blueColor];
        [self addSubview:authorLabel];
        [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headImgView).offset(3);
            make.left.equalTo(_headImgView.mas_right).offset(5);
        }];
        authorLabel ;
    });
    
    self.creatTimeLabel =
    ({
        UILabel *creatTimeLabel = [[UILabel alloc] init];
        creatTimeLabel.text = @"xxxx:xx:xx xx:xx:xx" ;
        creatTimeLabel.font = [UIFont systemFontOfSize:11.5];
        creatTimeLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:creatTimeLabel];
        [creatTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_authorLabel);
            make.top.equalTo(_authorLabel.mas_bottom).offset(5);
        }];
        creatTimeLabel ;
    });

    self.storyNameLabel =
    ({
        UILabel * storyName = [[UILabel alloc] init];
        storyName.font = [UIFont systemFontOfSize:16.5];
        storyName.text = @"故事名字" ;
        [self addSubview:storyName];
        [storyName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.equalTo(_headImgView.mas_bottom).offset(20);
        }];
        storyName;
    });
    
    self.briefLabel =
    ({
        UILabel *briefLabel = [[UILabel alloc] init];
        briefLabel.textColor = [UIColor darkGrayColor];
        briefLabel.font = [UIFont systemFontOfSize:15];
        briefLabel.text = @"" ;
        [self addSubview:briefLabel];
        [briefLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_storyNameLabel);
            make.top.equalTo(_storyNameLabel.mas_bottom).offset(5);
        }];
        briefLabel ;
    });

    
    self.watchCountLabel =
    ({
        UILabel * watchLabel = [[UILabel alloc] init];
        watchLabel.text = @"浏览 ：XXXX";
        watchLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:watchLabel];
        [watchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(_headImgView);
        }];
        watchLabel ;
    });
    
    self.likeCountLabel =
    ({
        UILabel * likeLabel = [[UILabel alloc] init];
        likeLabel.text = @"喜欢 ：XXXX";
        likeLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:likeLabel];
        [likeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_watchCountLabel);
            make.top.equalTo(_watchCountLabel.mas_bottom).offset(5);
        }];
        likeLabel ;
    });
    
    UILabel * submittersLabel = [[UILabel alloc] init];
    submittersLabel.text = @"作者 : ";
    submittersLabel.font = [UIFont systemFontOfSize:14];
    submittersLabel.textColor = [UIColor blackColor];
    [self addSubview:submittersLabel];
    [submittersLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(_briefLabel).offset(44);
    }];
    
    self.submittersView =
    ({
        UIView *submittersView = [[UIView alloc] init];
        [self addSubview:submittersView];
        [submittersView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(submittersLabel.mas_right);
            make.centerY.equalTo(submittersLabel);
            make.right.equalTo(self);
            make.height.equalTo(submittersLabel).offset(10);
        }];
        submittersView ;
    });
}

- (void) congfigSubmitters:(NSMutableArray <AVUser *>*)submitters didSelectUser:(void(^)(AVUser *))process
{
    self.submitters = submitters ;
    self.process = process ;
}

- (void)setModel:(AVObject *)model
{
    _model = model ;
    [self setupHeadImg];
    _storyNameLabel.text = _model [kStoryPropertyTitle];
    if (_storyNameLabel.text.length>20)
    {
        _storyNameLabel.font = [UIFont systemFontOfSize:17];
    }
    else
    {
        _storyNameLabel.font = [UIFont systemFontOfSize:20];
    }
    
    _watchCountLabel.text = [NSString stringWithFormat:@"浏览 ：%@",_model[kStoryPropertySeeCount]];
    _likeCountLabel.text = [NSString stringWithFormat:@"喜欢 ：%@",_model[kStoryPropertyLikeCount]];
    _creatTimeLabel.text = [NSString localTimeStringWithDate:_model.createdAt];
    _briefLabel.text = _model[kStoryPropertyInstroduction];
    AVUser * user = _model[kStoryPropertyOwner];
    if ([user isKindOfClass:[AVUser class]])
    {
        _authorLabel.text = user.username;
    }
}

- (void)setupHeadImg
{
    AVUser * user = _model[kStoryPropertyOwner];
    
    [UIImage getHeadImageForUser:user result:^(UIImage *headImg, NSError *error) {
        if (!error) {
            if (headImg) {
                _headImgView.image = headImg;
            }
        }else{
            MAXLog(@"%@ 头像获取错误 ：%@",user.username,error.localizedDescription);
        }
        
    }];
}

- (void)setSubmitters:(NSMutableArray *)submitters
{
    _submitters = submitters ;
    NSInteger count  = submitters.count ;
    for (UIView *subView in _submittersView.subviews) {
        [subView removeFromSuperview];
    }
    
    UIView * preView ;
    
    NSInteger limit = count>5 ? 5:count;
    
    for (NSInteger i=0; i<limit; i++)
    {
        UIButton * userBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        userBtn.titleLabel.textColor = [UIColor blackColor];
        [userBtn setTitle:_submitters[i].username forState:UIControlStateNormal];
        userBtn.titleLabel.font = [UIFont systemFontOfSize:14.5];
        userBtn.tag = 100+i ;
        [userBtn addTarget:self action:@selector(userSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_submittersView addSubview:userBtn];
        
        if (preView)
        {
            [userBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(preView.mas_right).offset(3);
                make.centerY.equalTo(preView);
            }];
        }
        else
        {
            [userBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_submittersView).offset(3);
                make.centerY.equalTo(_submittersView);
            }];
        }
        preView = userBtn ;
        UILabel * commaSymbol = [[UILabel alloc] init];
        
        if (i>=count-1){
            commaSymbol.text = count>6 ? @"......":@"" ;
        }else
        {
            commaSymbol.text = @" , " ;
        }
        
        [_submittersView addSubview:commaSymbol];
        [commaSymbol mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(preView.mas_right);
            make.centerY.equalTo(preView);
        }];
        preView = commaSymbol ;
    }
}

- (void)userSelected:(UIButton *)userBtn
{
    AVUser * user = _submitters[userBtn.tag-100];
    if (_process) {
        _process(user);
    }
}

@end
