//
//  MAXBuyerInfoView.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/16.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXBuyerInfoView.h"
#import "AVUser+MAXExtend.h"

@interface MAXBuyerInfoView()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *inkCount;

@end

@implementation MAXBuyerInfoView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self refreshUserInfo];
}

- (void)refreshUserInfo
{
    _username.text = [AVUser currentUser].username ;
    _inkCount.text = [NSString stringWithFormat:@"墨水 : %@ 滴",[AVUser currentUser][kUserPropertyInkCount]];
    
    [AVUser getCircleHeadImageForUser:[AVUser currentUser] result:^(UIImage *image, NSError *error) {
        _headImageView.image = image ;
    }];
}

@end
