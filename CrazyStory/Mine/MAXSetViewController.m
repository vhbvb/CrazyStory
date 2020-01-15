//
//  MAXSetViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/4.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXSetViewController.h"
#import "MAXCompleteUserInfoViewController.h"
#import "MAXLoginRegisterViewController.h"

@interface MAXSetViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) UITableView * setTableView ;

@end

@implementation MAXSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.navigationItem.title = @"设 置";
    self.navigationItem.backBarButtonItem.title = @"返回" ;
    self.setTableView =
    ({
        UITableView * setTableView  = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        setTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        setTableView.delegate = self ;
        setTableView.dataSource = self ;
        [self.view addSubview:setTableView];
        setTableView;
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2 ;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3 ;
        case 1:
            return 1 ;
        default:
            return 0 ;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:@"setTableViewCellReuseIdentifier"];
    if (indexPath.section)
    {
        cell.textLabel.text = @"购买";
    }
    else
    {
        if (indexPath.row == 1)
        {
           cell.textLabel.text = @"修改个人信息";
        }
        else if (indexPath.row == 0)
        {
            cell.textLabel.text = @"邀请好友";
        }
        else
        {
            cell.textLabel.text = @"退出登录";
        }
    }
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    if (!indexPath.section) {
        switch (indexPath.row) {
            case 0:
                
                break;
            case 1:
                if ([AVUser currentUser]) {
                    [self.navigationController pushViewController:[MAXCompleteUserInfoViewController currentUser] animated:YES];
                }else{
                    [self.navigationController pushViewController:[[MAXLoginRegisterViewController alloc] init] animated:YES];
                }
                break;
            default:
                break;
        }
    }
}


@end
