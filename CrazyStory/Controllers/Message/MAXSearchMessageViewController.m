//
//  MAXSearchMessageViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/10.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXSearchMessageViewController.h"

#import "EaseUI.h"
#import "UIViewController+SearchController.h"
#import "MAXSearchChatViewController.h"
#import "AVUser+MAXExtend.h"

#define SEARCHMESSAGE_PAGE_SIZE 30

@interface MAXSearchMessageViewController () <UISearchBarDelegate, UITextFieldDelegate, EMSearchControllerDelegate>
{
    dispatch_queue_t _searchQueue;
    void* _queueTag;
}

@property (strong, nonatomic) EMConversation *conversation;

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;

@property (strong, nonatomic) UILabel *fromLabel;
@property (strong, nonatomic) UITextField *textField;

@property (assign, nonatomic) BOOL hasMore;

@end

@implementation MAXSearchMessageViewController

- (instancetype)initWithConversationId:(NSString *)conversationId
                      conversationType:(EMConversationType)conversationType
{
    self = [super init];
    if (self) {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationId type:conversationType createIfNotExist:NO];
        _searchQueue = dispatch_queue_create("com.easemob.search.message", DISPATCH_QUEUE_SERIAL);
        _queueTag = &_queueTag;
        dispatch_queue_set_specific(_searchQueue, _queueTag, _queueTag, NULL);
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    self.title = @"查找聊天记录";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    backButton.accessibilityIdentifier = @"back";
    [backButton setImage:[UIImage imageNamed:@"backItem.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [self setupSearchController];
    
//        UIButton *timeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//        [timeButton setTitle:@"筛选" forState:UIControlStateNormal];
//        [timeButton addTarget:self action:@selector(timeAction) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *timeItem = [[UIBarButtonItem alloc] initWithCustomView:timeButton];
//        [self.navigationItem setRightBarButtonItem:timeItem];
}

- (UILabel*)fromLabel
{
    if (_fromLabel == nil) {
        _fromLabel = [[UILabel alloc] init];
        _fromLabel.frame = CGRectMake(0, CGRectGetMaxY(self.searchController.searchBar.frame) + 5, CGRectGetWidth([UIScreen mainScreen].bounds), 20);
        _fromLabel.text = @"筛选发送者:";
        _fromLabel.textColor = [UIColor blackColor];
        _fromLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _fromLabel;
}

- (UILabel*)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame) + 5, CGRectGetWidth([UIScreen mainScreen].bounds), 20);
        _timeLabel.text = @"筛选发送时间:";
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

- (UIDatePicker*)datePicker
{
    if(_datePicker == nil){
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.frame = CGRectMake(0, CGRectGetMaxY(self.timeLabel.frame), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight(_datePicker.frame));
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSDate *minDate = [formatter dateFromString:@"2012-01-01"];
        _datePicker.minimumDate = minDate;
        _datePicker.date = [NSDate date];
    }
    return _datePicker;
}

- (UITextField*)textField
{
    if (_textField == nil) {
        _textField = [[UITextField alloc] init];
        _textField.frame = CGRectMake(0, CGRectGetMaxY(self.fromLabel.frame), CGRectGetWidth([UIScreen mainScreen].bounds), 50.f);
        _textField.textColor = [UIColor blackColor];
        _textField.placeholder = @"填写发送者";
        _textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textField.layer.borderWidth = 0.5f;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _textField;
}

#pragma mark - EMSearchControllerDelegate

- (void)searchTextChangeWithString:(NSString *)aString
{
    __weak typeof(self) weakSelf = self;
    [self.conversation loadMessagesWithKeyword:aString timestamp:[self.datePicker.date timeIntervalSince1970]*1000 count:SEARCHMESSAGE_PAGE_SIZE fromUser:self.textField.text searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        MAXSearchMessageViewController *strongSelf = weakSelf;
        if (strongSelf) {
            if([aMessages count]<SEARCHMESSAGE_PAGE_SIZE) {
                strongSelf.hasMore = NO;
            } else {
                strongSelf.hasMore = YES;
            }
            [strongSelf.resultController.displaySource removeAllObjects];
            [strongSelf.resultController.displaySource addObjectsFromArray:[[aMessages reverseObjectEnumerator] allObjects]];
            [strongSelf.resultController.tableView reloadData];
        }
    }];
}

#pragma mark - private

- (void)setupSearchController
{
    [self enableSearchController];
    
    __weak MAXSearchMessageViewController *weakSelf = self;
    [self.resultController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        if (indexPath.section == 0) {
            NSString *CellIdentifier = [EaseConversationCell cellIdentifierWithModel:nil];
            EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[EaseConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            EMMessage *message = [weakSelf.resultController.displaySource objectAtIndex:indexPath.row];
//            [AVUser loadUserWithUserID:message.from result:^(AVUser *user, NSError *error) {
//                 cell.titleLabel.text = user.username;
//            }];
            cell.titleLabel.text = [AVUser SyncLoadUserWithUserID:message.from].username;
            cell.detailLabel.text = [weakSelf getContentFromMessage:message];
            AVFile * headImg = [AVUser SyncLoadUserWithUserID:message.from][kUserPropertyCircleHeadImage] ;
            UIImage * image = [[AVUser userCache] objectForKey:headImg.objectId];
            if (image)
            {
                cell.avatarView.image = image ;
            }
            else
            {
                cell.avatarView.image = [UIImage imageNamed:@"chatListCellHead.png"] ;
            }
            
            return cell;
        } else {
            NSString *CellIdentifier = @"loadMoreCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.text = @"加载更多";
            return cell;
        }
    }];
    
    [self.resultController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        return [EaseConversationCell cellHeightWithModel:nil];
    }];
    
    [self.resultController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        MAXLog(@"%zd -> %zd",indexPath.section,indexPath.row);
        if (indexPath.section == 0) {
            EMMessage *message = [weakSelf.resultController.displaySource objectAtIndex:indexPath.row];
            MAXSearchChatViewController *chatView = [[MAXSearchChatViewController alloc] initWithConversationChatter:weakSelf.conversation.conversationId conversationType:weakSelf.conversation.type fromMessageId:message.messageId];
            [weakSelf.navigationController pushViewController:chatView animated:YES];
        } else {
            EMMessage *message = [weakSelf.resultController.displaySource objectAtIndex:[weakSelf.resultController.displaySource count] - 1];
            [weakSelf.conversation loadMessagesWithKeyword:weakSelf.searchController.searchBar.text timestamp:message.timestamp count:SEARCHMESSAGE_PAGE_SIZE fromUser:weakSelf.textField.text searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
                if (!aError)
                {
                    if ([aMessages count] < SEARCHMESSAGE_PAGE_SIZE) {
                        weakSelf.hasMore = NO;
                    }
                    else {
                        weakSelf.hasMore = YES;
                    }
                    [weakSelf.resultController.displaySource addObjectsFromArray:[[aMessages reverseObjectEnumerator] allObjects]];
                    [weakSelf.resultController.tableView reloadData];
                }
            }];
        }
        
        [weakSelf cancelSearch];
    }];
    
    [self.resultController setNumberOfSectionsInTableViewCompletion:^NSInteger(UITableView *tableView) {
        if (weakSelf.hasMore) {
            return 2;
        } else {
            return 1;
        }
    }];
    
    [self.resultController setNumberOfRowsInSectionCompletion:^NSInteger(UITableView *tableView, NSInteger section) {
        if (section == 0) {
            return [weakSelf.resultController.displaySource count];
        } else {
            return 1;
        }
    }];
    
    self.searchController.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [self.view addSubview:self.searchController.searchBar];
}

- (NSString*)getContentFromMessage:(EMMessage*)message
{
    NSString *content = @"";
    if (message) {
        EMMessageBody *messageBody = message.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                content = @"[image]";
            } break;
            case EMMessageBodyTypeText:{
                // 表情映射。
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                content = didReceiveText;
                if ([message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
                    content = @"[动画表情]";
                }
            } break;
            case EMMessageBodyTypeVoice:{
                content = @"[voice]";
            } break;
            case EMMessageBodyTypeLocation: {
                content = @"[location]";
            } break;
            case EMMessageBodyTypeVideo: {
                content = @"[video]";
            } break;
            case EMMessageBodyTypeFile: {
                content = @"[file]";
            } break;
            default: {
            } break;
        }
    }
    return content;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)timeAction
{
    if (![self.datePicker superview]) {
        [self.view addSubview:self.timeLabel];
        [self.view addSubview:self.fromLabel];
        [self.view addSubview:self.datePicker];
        [self.view addSubview:self.textField];
        self.searchController.searchBar.hidden = YES;
    } else {
        [self.timeLabel removeFromSuperview];
        [self.fromLabel removeFromSuperview];
        [self.datePicker removeFromSuperview];
        [self.textField removeFromSuperview];
        self.searchController.searchBar.hidden = NO;
    }
}


@end
