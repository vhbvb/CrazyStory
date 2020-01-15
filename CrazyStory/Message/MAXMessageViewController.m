//
//  MAXMessageViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXMessageViewController.h"
#import "MAXLoginRegisterViewController.h"

@implementation MAXMessageViewController

- (void)viewDidLoad
{
    [self setup];
}

- (void)setup
{
    self.navigationItem.title = @"消息";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!isLogined) {
        [self.navigationController pushViewController:[[MAXLoginRegisterViewController alloc] init] animated:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}

@end
