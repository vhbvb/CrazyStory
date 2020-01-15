//
//  MAXConversationListViewController.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/9.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "EaseConversationListViewController.h"

@interface MAXConversationListViewController : EaseConversationListViewController

- (void)refreshDataSource ;

- (void)refresh ;

- (void)isConnect:(BOOL)isConnect;

- (void)networkChanged:(EMConnectionState)connectionState ;

@end
