//
//  MAXStoryContentTableViewCell.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXStoryContentTableViewCell.h"
#import "AVUser+MAXExtend.h"
#import "Masonry.h"
#import "UIImage+MAXExtend.h"

@interface MAXStoryContentTableViewCell()

@property(nonatomic, strong) UITextView *contentTextView ;

@property(nonatomic, strong) UIImageView * headImageView ;

@property(nonatomic, copy) void (^process)(AVUser *) ;

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
    self.headImageView =
    ({
        UIImageView *headImageView = [[UIImageView alloc] init];
        UIImage * placeholdHeadImg = [UIImage imageNamed:@"defaultHeadImg"];
        headImageView.image = [placeholdHeadImg imageScaledToSize:CGSizeMake(39, 39)];
        headImageView.userInteractionEnabled = YES ;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectOwner:)];
        [headImageView addGestureRecognizer:tap];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(3);
            make.top.equalTo(self).offset(13);
            make.height.width.equalTo(@33);
        }];
        headImageView ;
    });
    

    UIView * line = [[UIView alloc] init];
    line.backgroundColor = [UIColor lightGrayColor];
    line.alpha = 0.5 ;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(39);
        make.width.equalTo(@1);
    }];
    
    self.contentTextView =
    ({
        UITextView * contentTextView  = [[UITextView alloc] init];
        contentTextView.scrollEnabled = NO ;
        contentTextView.text = @" null ";
        contentTextView.editable = NO ;
        [self addSubview:contentTextView];
        [contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.left.equalTo(line.mas_right);
            make.top.equalTo(self);
            make.height.equalTo(@36);
        }];
        contentTextView ;
    });
}

- (void)setModel:(AVObject *)model selectUser:(void (^)(AVUser *))process
{
    self.model = model ;
    _process = process ;
}

- (void)setModel:(AVObject *)model
{
    _model = model ;
    
    _contentTextView.attributedText = [[NSAttributedString alloc] initWithString:_model[kContentPropertyContent] attributes:self.textViewAttributes];
    
    CGFloat height = [_contentTextView sizeThatFits:CGSizeMake(kScreenWidth-49, CGFLOAT_MAX)].height;
    [_contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
    
    AVUser * user = _model[kContentPropertyOwner];
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
    
    CGFloat cellHeight ;
    if ([_model[@"cellHeight"] isKindOfClass:[NSNumber class]])
    {
        cellHeight = [_model[@"cellHeight"] floatValue];
    }

    if (height!=cellHeight)
    {
        [self layoutIfNeeded];
        CGFloat nameMaxY = CGRectGetMaxY(_headImageView.frame);
        CGFloat cellHeight = nameMaxY > height ? nameMaxY : height ;
        _model[@"cellHeight"] = @(cellHeight) ;
    }
}

- (NSDictionary *)textViewAttributes
{
    static NSDictionary * attrs ;
    if (!attrs)
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.firstLineHeadIndent = 33.f;    /**首行缩进宽度*/
        paragraphStyle.alignment = NSTextAlignmentJustified;
        attrs = @{
                  NSFontAttributeName:[UIFont systemFontOfSize:16],
                  NSParagraphStyleAttributeName:paragraphStyle
                  };
    }
    return attrs ;
}

- (void)didSelectOwner:(UITapGestureRecognizer *)sender
{
    if (_process) {
        _process(_model[kContentPropertyOwner]);
    }
}

@end
