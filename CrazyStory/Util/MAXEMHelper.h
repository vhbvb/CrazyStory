//
//  MAXEMHelper.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/13.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MAXConversationListViewController.h"
#import "MAXContactListViewController.h"
#import "MAXMessageViewController.h"
#import "MAXChatViewController.h"

#define kHaveUnreadAtMessage    @"kHaveAtMessage"
#define kAtYouMessage           1
#define kAtAllMessage           2

@interface MAXEMHelper : NSObject <EMClientDelegate,EMChatManagerDelegate,EMContactManagerDelegate,EMGroupManagerDelegate,EMChatroomManagerDelegate>




@property (nonatomic, weak) MAXContactListViewController *contactViewVC;

@property (nonatomic, weak) MAXConversationListViewController *conversationListVC;

@property (nonatomic, weak) MAXMessageViewController *mainVC;

@property (nonatomic, weak) MAXChatViewController *chatVC;

+ (instancetype)shareHelper;

- (void)asyncPushOptions;

- (void)asyncGroupFromServer;

- (void)asyncConversationFromDB;

@end
