//
//  MAXVerifyCodeButton.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/15.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXVerifyCodeButton.h"
#import "Masonry.h"

@interface MAXVerifyCodeButton()

@property(nonatomic, strong) UILabel *count ;
@property(nonatomic, strong) UILabel *hint ;

@end

@implementation MAXVerifyCodeButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 106, 33)];
    if (self) {
        self.userInteractionEnabled = YES ;
        [self configUI];
    }
    return self;
}

- (void)configUI
{
//    self.backgroundColor = [UIColor redColor];
    self.count =
    ({
        UILabel *count = [[UILabel alloc] init] ;
        count.text = @"" ;
        count.textColor = [UIColor blueColor];
        count.font = [UIFont systemFontOfSize:13.9];
        [self addSubview:count];
        [count mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
        }];
        count ;
    });
    
    self.hint =
    ({
        UILabel *hint = [[UILabel alloc] init];
        hint.text = @"点击获取验证码" ;
        hint.textColor = [UIColor blueColor];
        hint.font = [UIFont systemFontOfSize:13.9];
        [self addSubview:hint];
        [hint mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_count.mas_right);
            make.top.bottom.equalTo(self);
        }];
        hint ;
    });


}

- (void)addTapGestureWithTarget:(id)target action:(SEL)selector
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
}

- (void)setState:(MAXVerifyCodeButtonState)state
{
    if (_state !=state)
    {
        switch (state) {
            case MAXVerifyCodeButtonStateDisabled:
                [self disabled];
                break;
            case MAXVerifyCodeButtonStateCountdown:
                [self beginCount];
                break;
            case MAXVerifyCodeButtonStateNormal:
                [self enabled];
                break;
                
            default:
                break;
        }
        
    }
    _state = state ;
}

- (void)disabled
{
    self.userInteractionEnabled = NO ;
    self.hint.textColor = [UIColor darkGrayColor];
}

- (void)enabled
{
    self.count.text = @"" ;
    self.hint.text = @"点击获取验证码" ;
    self.userInteractionEnabled = YES ;
    self.hint.textColor = [UIColor blueColor];
    [self layoutIfNeeded];
}

- (void)beginCount
{
    self.userInteractionEnabled = NO ;
    self.hint.textColor = [UIColor blackColor];
    self.count.text = @"60" ;
    self.hint.text = @" 秒后重新获取" ;
    [self layoutIfNeeded];
    __block NSInteger repeatTimes = 60 ;
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.count.text = [NSString stringWithFormat:@"%zd",--repeatTimes];
        if (repeatTimes<=0)
        {
            [timer invalidate];
            [self enabled];
        }
    }];
}

@end
