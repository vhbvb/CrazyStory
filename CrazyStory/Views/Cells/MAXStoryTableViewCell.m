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
#import "AVUser+MAXExtend.h"
#import "WclEmitterButton.h"

@interface MAXStoryTableViewCell()
@property (nonatomic, strong) WclEmitterButton * likeBtn;
@property (nonatomic, strong) UILabel * storyNameLabel ;
@property (nonatomic, strong) UILabel * briefLabel ;
@property (nonatomic, strong) UILabel * creatTimeLabel ;
@property (nonatomic, strong) UILabel * watchCountLabel ;
@property (nonatomic, strong) UILabel * likeCountLabel ;
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
    
    self.storyNameLabel =
    ({
        UILabel * storyName = [[UILabel alloc] init];
        storyName.font = [UIFont systemFontOfSize:16.5];
        storyName.text = @"故事名字" ;
        [self addSubview:storyName];
        [storyName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.equalTo(self).offset(20);
        }];
        storyName;
    });
    
    self.likeBtn =
    ({
        WclEmitterButton *likeBtn = [[WclEmitterButton alloc] init];
        [likeBtn setImage:[UIImage imageNamed:@"commentLikeButton"] forState:UIControlStateNormal];
        [likeBtn setImage:[UIImage imageNamed:@"commentLikeButtonClick"] forState:UIControlStateSelected];
        [likeBtn addTarget:self action:@selector(likeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:likeBtn];
        [likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_storyNameLabel);
            make.right.equalTo(self).offset(-19);
//            make.width.height.equalTo(@22);
        }];
        likeBtn ;
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
    
    self.creatTimeLabel =
    ({
        UILabel *creatTimeLabel = [[UILabel alloc] init];
        creatTimeLabel.text = @"CreatBy:xx at:xxxx:xx:xx xx:xx:xx" ;
        creatTimeLabel.font = [UIFont systemFontOfSize:11.5];
        creatTimeLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:creatTimeLabel];
        [creatTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_briefLabel);
            make.top.equalTo(_briefLabel.mas_bottom).offset(13);
        }];
        creatTimeLabel ;
    });
    
    UILabel * submittersLabel = [[UILabel alloc] init];
    submittersLabel.text = @"作者 : ";
    submittersLabel.font = [UIFont systemFontOfSize:14];
    submittersLabel.textColor = [UIColor blackColor];
    [self addSubview:submittersLabel];
    [submittersLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_storyNameLabel);
        make.top.equalTo(_creatTimeLabel).offset(44);
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
    
    self.watchCountLabel =
    ({
        UILabel * watchLabel = [[UILabel alloc] init];
        watchLabel.text = @"XXXX";
        watchLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:watchLabel];
        [watchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.bottom.equalTo(submittersLabel.mas_centerY).offset(-2.5);
        }];
        watchLabel ;
    });
    
    UIImageView *seeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"see.png"]];
    [self addSubview:seeImageView];
    [seeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_watchCountLabel.mas_left).offset(-7);
        make.centerY.equalTo(_watchCountLabel);
        make.width.height.equalTo(@15);
    }];
    
    self.likeCountLabel =
    ({
        UILabel * likeLabel = [[UILabel alloc] init];
        likeLabel.text = @"XXXX";
        likeLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:likeLabel];
        [likeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_watchCountLabel);
            make.top.equalTo(_watchCountLabel.mas_bottom).offset(5);
        }];
        likeLabel ;
    });
    
    UIImageView *likeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeCount"]];
    [self addSubview:likeImageView];
    [likeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(seeImageView);
        make.size.equalTo(seeImageView);
        make.centerY.equalTo(_likeCountLabel);
    }];

}

- (void) congfigSubmitters:(NSMutableArray <AVUser *>*)submitters didSelectUser:(void(^)(AVUser *))process
{
    self.submitters = submitters ;
    self.process = process ;
}

- (void)setModel:(AVObject *)model
{
    _model = model ;
    _storyNameLabel.text = _model [kStoryPropertyTitle];
    _briefLabel.text = _model[kStoryPropertyInstroduction];
    CGFloat fontSize = 20 + (15 - _storyNameLabel.text.length * 1.0)/2.5 ;
    _storyNameLabel.font = [UIFont systemFontOfSize:(fontSize>18?fontSize:18)];
    _watchCountLabel.text = [NSString stringWithFormat:@"%@",_model[kStoryPropertySeeCount]];
    _likeCountLabel.text = [NSString stringWithFormat:@"%@",_model[kStoryPropertyLikeCount]];
    
    NSString * timeText = [NSString localTimeStringWithDate:_model.createdAt] ;
    AVUser * user = _model[kStoryPropertyOwner];
    _creatTimeLabel.text = [NSString stringWithFormat:@"creatBy:%@ at:%@",user.username,timeText];
    
    [self checkIfLiked:^(BOOL isLiked)
    {
        [self.likeBtn setSelected:isLiked];

    }];
}



- (void)setSubmitters:(NSMutableArray *)submitters
{
    _submitters = submitters ;
    NSInteger count  = submitters.count ;
    for (UIView *subView in _submittersView.subviews)
    {
        [subView removeFromSuperview];
    }
    
    UIView * preView ;
    
    NSInteger limit = count>7 ? 7:count;
    
    for (NSInteger i=0; i<limit; i++)
    {
        UIImageView *headImgView = [[UIImageView alloc] init];
        headImgView.image = [UIImage defaultHeadImage];
        headImgView.userInteractionEnabled = YES ;
        headImgView.tag = 100+i ;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userSelected:)];
        [headImgView addGestureRecognizer:tap];
        [_submittersView addSubview:headImgView];
        
        if (preView)
        {
            [headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(preView.mas_right).offset(3);
                make.centerY.equalTo(preView);
                make.width.height.equalTo(@30);
            }];
        }
        else
        {
            [headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_submittersView).offset(3);
                make.centerY.equalTo(_submittersView);
                make.width.height.equalTo(@30);
            }];
        }
        
        preView = headImgView ;
        UILabel * commaSymbol = [[UILabel alloc] init];
        
        if (i>=count-1){
            commaSymbol.text = count>7 ? @".....":@"" ;
        }
        [_submittersView addSubview:commaSymbol];
        [commaSymbol mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(preView.mas_right);
            make.centerY.equalTo(preView);
        }];
        
        [AVUser getCircleHeadImageForUser:submitters[i] result:^(UIImage *image, NSError *error)
        {
            if (!error&&image)
            {
                headImgView.image = image;
            }
            else
            {
                MAXLog(@"%@ 头像获取错误 ：%@",[submitters[i] username],error.localizedDescription);
            }
        }];
    }
}

- (void)userSelected:(UITapGestureRecognizer *)tap
{
    AVUser * user = _submitters[tap.view.tag-100];
    if (_process)
    {
        _process(user);
    }
}

- (void)ownerTap:(UIGestureRecognizer *)sender
{
    if (_process)
    {
        _process(_model[kStoryPropertyOwner]);
    }
}

- (void)likeBtnClicked:(WclEmitterButton *)likeBtn
{
    if (likeBtn.isSelected)
    {
        return ;
    }
    [likeBtn setSelectedWithAnimation:YES];
    
    NSNumber *likeCount = _model[kStoryPropertyLikeCount] ;
    NSInteger currentLikeCount ;
    if ([likeCount isKindOfClass:[NSNumber  class]])
    {
        currentLikeCount = likeCount.integerValue + 1;
    }
    _model[kStoryPropertyLikeCount] = @(currentLikeCount);
    [_model saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
     {
         if (!error)
         {
             AVObject *likeRelation = [AVObject objectWithClassName:kRelationsListClass];
             likeRelation[kRelationPropertyFlag] = kRelationPropertyFlagLike;
             likeRelation[kRelationPropertyUser] = [AVUser currentUser];
             likeRelation[kRelationPropertyStory] = _model ;
             [likeRelation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
              {
                  if (succeeded)
                  {
                      self.likeCountLabel.text = [NSString stringWithFormat:@"%zd",currentLikeCount] ;
                  }
                  else
                  {
                       likeBtn.selected = NO;
                  }
                  MAXLog(@"%@ and %@ like relation saved, error :%@",[AVUser currentUser],_model,error);
              }];
         }
         else
         {
             likeBtn.selected = NO;
             MAXLog(@"like error : %@ --> %@",_model,error);
         }
     }];
}

- (void)checkIfLiked:(void(^)(BOOL isLiked))result
{
    AVQuery *relationQuery = [[AVQuery alloc] initWithClassName:kRelationsListClass];
    [relationQuery whereKey:kRelationPropertyFlag equalTo:kRelationPropertyFlagLike];
    AVQuery *userQuery = [[AVQuery alloc] initWithClassName:kRelationsListClass];
    [userQuery whereKey:kRelationPropertyUser equalTo:[AVUser currentUser]];
    AVQuery *storyQuery = [[AVQuery alloc] initWithClassName:kRelationsListClass];
    [storyQuery whereKey:kRelationPropertyStory equalTo:_model];
    AVQuery * likeQuery = [AVQuery andQueryWithSubqueries:@[relationQuery,userQuery,storyQuery]];
    
    [likeQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error)
    {
        if (!error&&number)
        {
            if (result) {
                result(YES);
            }
        }
        else
        {
            if (error.code == 101 || number==0)
            {
                result(NO);
            }
            else
            {
                result(NO);
            }
        }
    }];
}

@end
