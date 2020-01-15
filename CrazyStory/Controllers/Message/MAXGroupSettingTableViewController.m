//
//  MAXGroupSettingTableViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/10.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXGroupSettingTableViewController.h"
@interface MAXGroupSettingTableViewController ()
{
    EMGroup *_group;
    UISwitch *_pushSwitch;
    UISwitch *_blockSwitch;
}

@end

@implementation MAXGroupSettingTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)initWithGroup:(EMGroup *)group
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        _group = group;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"群设置";
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    backButton.accessibilityIdentifier = @"back";
    [backButton setBackgroundImage:[UIImage imageNamed:@"backItem.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
    saveItem.accessibilityIdentifier = @"save";
    [self.navigationItem setRightBarButtonItem:saveItem];
    
    _pushSwitch = [[UISwitch alloc] init];
    _pushSwitch.accessibilityIdentifier = @"push_switch";
    [_pushSwitch addTarget:self action:@selector(pushSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [_pushSwitch setOn:_group.isPushNotificationEnabled animated:YES];
    
    _blockSwitch = [[UISwitch alloc] init];
    _blockSwitch.accessibilityIdentifier = @"block_switch";
    [_blockSwitch addTarget:self action:@selector(blockSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [_blockSwitch setOn:_group.isBlocked animated:YES];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (_blockSwitch.isOn) {
        return 1;
    }
    else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 1) {
        _pushSwitch.frame = CGRectMake(self.tableView.frame.size.width - (_pushSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - _pushSwitch.frame.size.height) / 2, _pushSwitch.frame.size.width, _pushSwitch.frame.size.height);
        
        if (_pushSwitch.isOn) {
            cell.textLabel.text = @"接受并提示群消息";
        }
        else{
            cell.textLabel.text = @"直接受不提示群消息";
        }
        
        [cell.contentView addSubview:_pushSwitch];
        [cell.contentView bringSubviewToFront:_pushSwitch];
    }
    else if(indexPath.row == 0){
        _blockSwitch.frame = CGRectMake(self.tableView.frame.size.width - (_blockSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - _blockSwitch.frame.size.height) / 2, _blockSwitch.frame.size.width, _blockSwitch.frame.size.height);
        
        cell.textLabel.text = @"屏蔽群消息";
        [cell.contentView addSubview:_blockSwitch];
        [cell.contentView bringSubviewToFront:_blockSwitch];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - private

- (void)enablePush:(BOOL)isEnable
{
    [SVProgressHUD showWithStatus:@"正在保存..."];
    [[EMClient sharedClient].groupManager updatePushServiceForGroup:_group.groupId isPushEnabled:isEnable completion:^(EMGroup *aGroup, EMError *aError) {
        [SVProgressHUD dismiss];
        if (!aError) {
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"保存失败"];
        }
    }];
}

#pragma mark - action

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushSwitchChanged:(id)sender
{
    //    [self enablePush:[_pushSwitch isOn]];
    [self.tableView reloadData];
}

- (void)blockSwitchChanged:(id)sender
{
    [self.tableView reloadData];
}

- (void)saveAction:(id)sender
{
    if (_blockSwitch.isOn != _group.isBlocked) {
      [SVProgressHUD showWithStatus:@"正在保存..."];
        if (_blockSwitch.isOn) {
            [[EMClient sharedClient].groupManager blockGroup:_group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
                [SVProgressHUD dismiss];
                if (!aError) {
                    [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                }
                else{
                    [SVProgressHUD showErrorWithStatus:@"保存失败"];
                }
            }];
        }
        else{
            [[EMClient sharedClient].groupManager unblockGroup:_group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
                [SVProgressHUD dismiss];
                if (!aError) {
                    [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                }
                else{
                    [SVProgressHUD showErrorWithStatus:@"保存失败"];
                }
            }];
        }
    }
    
    if (_pushSwitch.isOn != _group.isPushNotificationEnabled) {
        [self enablePush:_pushSwitch.isOn];
    }
}

@end
