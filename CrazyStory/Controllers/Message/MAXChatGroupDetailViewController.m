//
//  MAXChatGroupDetailViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/10.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXChatGroupDetailViewController.h"

#import "MAXContactSelectionViewController.h"
#import "MAXGroupSettingTableViewController.h"
#import "MAXGroupSubjectChangingViewController.h"
#import "MAXSearchMessageViewController.h"
#import "EaseUI/EaseUI.h"
#import "EMGroupAdminsViewController.h"
#import "EMGroupMembersViewController.h"
#import "EMGroupMutesViewController.h"
#import "EMGroupBansViewController.h"
#import "AVUser+MAXExtend.h"

#pragma mark - ChatGroupDetailViewController

#define kColOfRow 5
#define kContactSize 60

#define ALERTVIEW_CHANGEOWNER 100

@interface MAXChatGroupDetailViewController ()<EMGroupManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) EMGroup *chatGroup;
@property (strong, nonatomic) UIBarButtonItem *addMemberItem;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIButton *clearButton;
@property (strong, nonatomic) UIButton *exitButton;
@property (strong, nonatomic) UIButton *dissolveButton;
@property (strong, nonatomic) UIButton *configureButton;

@end

@implementation MAXChatGroupDetailViewController

- (instancetype)initWithGroup:(EMGroup *)chatGroup
{
    self = [super init];
    if (self) {
        // Custom initialization
        _chatGroup = chatGroup;
    }
    return self;
}

- (instancetype)initWithGroupId:(NSString *)chatGroupId
{
    EMGroup *chatGroup = nil;
    NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
    for (EMGroup *group in groupArray) {
        if ([group.groupId isEqualToString:chatGroupId]) {
            chatGroup = group;
            break;
        }
    }
    
    if (chatGroup == nil) {
        chatGroup = [EMGroup groupWithId:chatGroupId];
    }
    
    self = [self initWithGroup:chatGroup];
    if (self) {
        //
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"群组信息";
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    backButton.accessibilityIdentifier = @"back";
    [backButton setBackgroundImage:[UIImage imageNamed:@"backItem.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    addButton.accessibilityIdentifier = @"add";
    [addButton setTitle:@"+ 成员" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont systemFontOfSize:16.5];
    [addButton addTarget:self action:@selector(addMemberButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.addMemberItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    
    self.showRefreshHeader = YES;
    self.tableView.tableFooterView = self.footerView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:@"UpdateGroupDetail" object:nil];
    [self registerNotifications];
    
    [self fetchGroupInfo];
}

- (void)dealloc {
    [self unregisterNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerNotifications {
    [self unregisterNotifications];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications {
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark - getter

- (UIButton *)clearButton
{
    if (_clearButton == nil) {
        _clearButton = [[UIButton alloc] init];
        _clearButton.accessibilityIdentifier = @"clear_message";
        [_clearButton setTitle:@"清空聊天记录" forState:UIControlStateNormal];
        [_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
        [_clearButton setBackgroundColor:[UIColor colorWithRed:87 / 255.0 green:186 / 255.0 blue:205 / 255.0 alpha:1.0]];
    }
    
    return _clearButton;
}

- (UIButton *)dissolveButton
{
    if (_dissolveButton == nil) {
        _dissolveButton = [[UIButton alloc] init];
        _dissolveButton.accessibilityIdentifier = @"leave";
        [_dissolveButton setTitle:@"解散群组" forState:UIControlStateNormal];
        [_dissolveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_dissolveButton addTarget:self action:@selector(dissolveAction) forControlEvents:UIControlEventTouchUpInside];
        [_dissolveButton setBackgroundColor: [UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];
    }
    
    return _dissolveButton;
}

- (UIButton *)exitButton
{
    if (_exitButton == nil) {
        _exitButton = [[UIButton alloc] init];
        _exitButton.accessibilityIdentifier = @"leave";
        [_exitButton setTitle:@"退出群组" forState:UIControlStateNormal];
        [_exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
        [_exitButton setBackgroundColor:[UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];
    }
    
    return _exitButton;
}

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 160)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        self.clearButton.frame = CGRectMake(20, 40, _footerView.frame.size.width - 40, 35);
        [_footerView addSubview:self.clearButton];
        
        self.dissolveButton.frame = CGRectMake(20, CGRectGetMaxY(self.clearButton.frame) + 30, _footerView.frame.size.width - 40, 35);
        
        self.exitButton.frame = CGRectMake(20, CGRectGetMaxY(self.clearButton.frame) + 30, _footerView.frame.size.width - 40, 35);
    }
    
    return _footerView;
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
    if (self.chatGroup.permissionType == EMGroupPermissionTypeOwner || self.chatGroup.permissionType == EMGroupPermissionTypeAdmin) {
        return 9;
    }
    else {
        return 7;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"群号";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = _chatGroup.groupId;
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"群设置";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"修改群名称";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 3) {
        cell.textLabel.text = @"查找聊天记录";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 4) {
        cell.textLabel.text = @"群主";
        [AVUser loadUserWithUserID:self.chatGroup.owner result:^(AVUser *user, NSError *error) {
            cell.detailTextLabel.text = user.username;
        }];
        
        if (self.chatGroup.permissionType == EMGroupPermissionTypeOwner) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.row == 5) {
        cell.textLabel.text = @"管理员";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", (int)[self.chatGroup.adminList count]];
    }
    else if (indexPath.row == 6) {
        cell.textLabel.text = @"成员";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i / %i", (int)(self.chatGroup.occupantsCount - 1 - [self.chatGroup.adminList count]), (int)self.chatGroup.setting.maxUsersCount];
        NSLog(@"%@", [NSString stringWithFormat:@"111111=========%ld", (long)self.chatGroup.occupantsCount]);
    }
    else if (indexPath.row == 7) {
        cell.textLabel.text = @"禁言的成员";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 8) {
        cell.textLabel.text = @"黑名单";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    
    if (indexPath.row == 1)
    {
        MAXGroupSettingTableViewController *settingController = [[MAXGroupSettingTableViewController alloc] initWithGroup:_chatGroup];
        [self.navigationController pushViewController:settingController animated:YES];
    }
    else if (indexPath.row == 2)
    {
        MAXGroupSubjectChangingViewController *changingController = [[MAXGroupSubjectChangingViewController alloc] initWithGroup:_chatGroup];
        [self.navigationController pushViewController:changingController animated:YES];
    }
    else if (indexPath.row == 3) {
        MAXSearchMessageViewController *searchMsgController = [[MAXSearchMessageViewController alloc] initWithConversationId:_chatGroup.groupId conversationType:EMConversationTypeGroupChat];
        [self.navigationController pushViewController:searchMsgController animated:YES];
    }
    else if (indexPath.row == 4) { //群主转换
        if (self.chatGroup.permissionType == EMGroupPermissionTypeOwner) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"更改群主" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            alert.tag = ALERTVIEW_CHANGEOWNER;
            
            UITextField *textField = [alert textFieldAtIndex:0];
            
            [AVUser loadUserWithUserID:self.chatGroup.owner result:^(AVUser *user, NSError *error) {
                textField.text = user.username;
            }];
            
            
            [alert show];
        }
    }
    else if (indexPath.row == 5) { //展示群管理员
        EMGroupAdminsViewController *adminController = [[EMGroupAdminsViewController alloc] initWithGroup:self.chatGroup];
        [self.navigationController pushViewController:adminController animated:YES];
    }
    else if (indexPath.row == 6) { //展示群成员
        EMGroupMembersViewController *membersController = [[EMGroupMembersViewController alloc] initWithGroup:self.chatGroup];
        [self.navigationController pushViewController:membersController animated:YES];
    }
    else if (indexPath.row == 7) { //展示被禁言列表
        EMGroupMutesViewController *mutesController = [[EMGroupMutesViewController alloc] initWithGroup:self.chatGroup];
        [self.navigationController pushViewController:mutesController animated:YES];
    }
    else if (indexPath.row == 8) { //展示黑名单
        EMGroupBansViewController *bansController = [[EMGroupBansViewController alloc] initWithGroup:self.chatGroup];
        [self.navigationController pushViewController:bansController animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate

//弹出提示的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView cancelButtonIndex] == buttonIndex) {
        return;
    }
    
    if (alertView.tag == ALERTVIEW_CHANGEOWNER) {
        //获取文本输入框
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *newOwner = textField.text;
        if ([newOwner length] > 0) {
            
            [self showHudInView:self.view hint:@"Hold on ..."];
            [AVUser loadUserWithUsername:newOwner result:^(AVUser *user, NSError *error) {
                if (!user) {
                    [self hideHud];
                    MAXLog(@"%@",error.localizedDescription);
                    MAXAlert(@"未查询到此用户,请确认用户名后重试");
                    return ;
                }
                EMError *errorEM = nil;
                self.chatGroup = [[EMClient sharedClient].groupManager updateGroupOwner:self.chatGroup.groupId newOwner:user.objectId error:&errorEM];
                [self hideHud];
                if (errorEM) {
                    [self showHint:@"群主更换失败"];
                } else {
                    [self.tableView reloadData];
                }
            }];
        }
        
    }
}

#pragma mark - EMChooseViewDelegate

- (BOOL)viewController:(EMChooseViewController *)viewController didFinishSelectedSources:(NSArray *)selectedSources
{
    NSInteger maxUsersCount = self.chatGroup.setting.maxUsersCount;
    if (([selectedSources count] + self.chatGroup.membersCount) > maxUsersCount) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"超出群组数量限制" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        return NO;
    }
    
    [self showHudInView:self.view hint:@"加入一个成员"];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *source = [NSMutableArray array];
        for (NSString *username in selectedSources) {
            [source addObject:username];
        }
        
        NSString *username = [[EMClient sharedClient] currentUsername];
        NSString *messageStr = [NSString stringWithFormat:@"%@ invite you to join group \'%@\'", username, weakSelf.chatGroup.subject];
        EMError *error = nil;
        weakSelf.chatGroup = [[EMClient sharedClient].groupManager addOccupants:source toGroup:weakSelf.chatGroup.groupId welcomeMessage:messageStr error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [weakSelf reloadDataSource];
            }
            else {
                [weakSelf hideHud];
                [weakSelf showHint:error.errorDescription];
            }
            
        });
    });
    
    return YES;
}

#pragma mark - EMGroupManagerDelegate

- (void)groupInvitationDidAccept:(EMGroup *)aGroup
                         invitee:(NSString *)aInvitee
{
    if ([aGroup.groupId isEqualToString:self.chatGroup.groupId]) {
        [self fetchGroupInfo];
    }
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    [self fetchGroupInfo];
}

- (void)fetchGroupInfo
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:@"正在加载数据..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = nil;
        EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:weakSelf.chatGroup.groupId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            [weakSelf tableViewDidFinishTriggerHeader:YES reload:NO];
        });
        
        if (!error) {
            weakSelf.chatGroup = group;
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:group.groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
            if ([group.groupId isEqualToString:conversation.conversationId]) {
                NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                [ext setObject:group.subject forKey:@"subject"];
                [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                conversation.ext = ext;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadDataSource];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showHint:@"加载失败，请稍后重试..."];
            });
        }
    });
}

- (void)reloadDataSource
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.chatGroup.permissionType == EMGroupPermissionTypeOwner || self.chatGroup.permissionType == EMGroupPermissionTypeAdmin || self.chatGroup.setting.style == EMGroupStylePrivateMemberCanInvite) {
            self.navigationItem.rightBarButtonItem = self.addMemberItem;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        [self.tableView reloadData];
        [self refreshFooterView];
        [self hideHud];
    });
}

- (void)refreshFooterView
{
    if (self.chatGroup.permissionType == EMGroupPermissionTypeOwner) {
        [_exitButton removeFromSuperview];
        [_footerView addSubview:self.dissolveButton];
    }
    else{
        [_dissolveButton removeFromSuperview];
        [_footerView addSubview:self.exitButton];
    }
}

#pragma mark - action

- (void)updateUI:(NSNotification *)aNotif
{
    id obj = aNotif.object;
    if (obj && [obj isKindOfClass:[EMGroup class]]) {
        self.chatGroup = (EMGroup *)obj;
        [self reloadDataSource];
    }
}

- (void)addMemberButtonAction
{
    NSMutableArray *occupants = [[NSMutableArray alloc] init];
    [occupants addObject:self.chatGroup.owner];
    [occupants addObjectsFromArray:self.chatGroup.adminList];
    [occupants addObjectsFromArray:self.chatGroup.memberList];
    MAXContactSelectionViewController *selectionController = [[MAXContactSelectionViewController alloc] initWithBlockSelectedUsernames:occupants];
    selectionController.delegate = self;
    [self.navigationController pushViewController:selectionController animated:YES];
}

//清空聊天记录
- (void)clearAction
{
    __weak typeof(self) weakSelf = self;
    
    UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请确定删除" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:cancel];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:weakSelf.chatGroup.groupId];
    }];
    [vc addAction:ok];
}

//解散群组
- (void)dissolveAction
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:@"解散此群"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = [[EMClient sharedClient].groupManager destroyGroup:weakSelf.chatGroup.groupId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (error) {
                [weakSelf showHint:@"操作失败"];
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitChat" object:nil];
            }
        });
    });
}

//设置群组
- (void)configureAction {
    // todo
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [[EMClient sharedClient].groupManager ignoreGroupPush:weakSelf.chatGroup.groupId ignore:weakSelf.chatGroup.isPushNotificationEnabled];
    });
}

//退出群组
- (void)exitAction
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:@"退出群组"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = nil;
        [[EMClient sharedClient].groupManager leaveGroup:weakSelf.chatGroup.groupId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (error) {
                [weakSelf showHint:@"操作失败"];
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitChat" object:nil];
            }
        });
    });
}

- (void)didIgnoreGroupPushNotification:(NSArray *)ignoredGroupList error:(EMError *)error {
    // todo
    NSLog(@"ignored group list:%@.", ignoredGroupList);
}

@end

