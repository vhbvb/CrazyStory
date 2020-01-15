//
//  MAXSearchChatViewController.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/10.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXChatViewController.h"

@interface MAXSearchChatViewController : MAXChatViewController

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType
                              fromMessageId:(NSString*)messageId;

@end
