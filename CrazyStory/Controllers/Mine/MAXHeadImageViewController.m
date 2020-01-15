//
//  MAXHeadImageViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/21.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXHeadImageViewController.h"
#import "AVUser+MAXExtend.h"
#import "Masonry.h"
#import <Social/Social.h>

@interface MAXHeadImageViewController ()

@property(nonatomic ,strong) UIImageView *imageView ;
@property(nonatomic ,strong) AVUser * user ;

@end

@implementation MAXHeadImageViewController

- (instancetype)initWithImage:(UIImage *)image user:(AVUser *)user
{
    if (self = [super init])
    {
        self.hidesBottomBarWhenPushed = YES ;
        self.imageView = [[UIImageView alloc] initWithImage:image];
        _user = user ;
    }
    return self ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _imageView.size = CGSizeMake(self.view.width, self.view.width);
    [self.view addSubview:_imageView];
    _imageView.center = self.view.center ;
    [self loadOriginImage];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"shareImage"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(_imageView.mas_bottom).offset(44);
        make.height.width.equalTo(@33);
    }];
}

- (void)loadOriginImage
{
    [AVUser getOriginHeadImageForUser:_user result:^(UIImage *image, NSError *error) {
        
        if (!error&&image)
        {
            _imageView.image = image;
            CATransition *animation = [CATransition animation];
            [animation setDuration:1.0];
            [animation setFillMode:kCAFillModeForwards];
            [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
            [animation setType:@"rippleEffect"];// rippleEffect kCATransitionReveal
            [animation setSubtype:kCATransitionFromTop];
            [_imageView.layer addAnimation:animation forKey:nil];
        }
        else
        {
            MAXLog(@"%@",error);
        }
    }];
}

- (void)share:(UIButton *)btn
{
    UIActivityViewController * vc = [[UIActivityViewController alloc] initWithActivityItems:@[_imageView.image] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}
@end
