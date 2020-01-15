//
//  MAXMineCountView.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/17.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXMineCountView.h"
#import "Masonry.h"

@interface MAXMineCountView()

@property(nonatomic, strong) UILabel *namelabel ;
@property(nonatomic, strong) UILabel *countLabel ;

@end

@implementation MAXMineCountView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self configUI];
    }
    return self ;
}

- (void)configUI
{
    self.namelabel =
    ({
        UILabel * nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = [UIColor grayColor];
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(-10);
        }];
        nameLabel;
    });
    
    self.countLabel =
    ({
        UILabel *countLabel = [[UILabel alloc] init] ;
        countLabel.font = [UIFont boldSystemFontOfSize:18];
        countLabel.textColor = [UIColor blackColor];
        [self addSubview:countLabel];
        [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(10);
        }];
        countLabel ;
    });

}


- (void)setName:(NSString *)name
{
    _name = name ;
    self.namelabel.text = name ;
}

- (void)setCount:(NSInteger)count
{
    _count = count ;
    self.countLabel.text = [NSString stringWithFormat:@"%zd",count];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected ;
    
    if (_selected)
    {
        self.backgroundColor = [UIColor colorWithDisplayP3Red:200/256.0 green:200/256.0 blue:200/256.0 alpha:1];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)addTapGestureWithTarget:(nullable id)target selector:(nullable SEL)selector
{
    self.userInteractionEnabled = YES ;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
}

@end
