//
//  MAXMessageViewController.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseUI.h"

static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";

@interface MAXMessageViewController : UIViewController
{
    EMConnectionState _connectionState;
}

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

- (void)setupUnreadMessageCount ;

- (void)networkChanged:(EMConnectionState)connectionState ;

- (void)playSoundAndVibration ;

- (void)showNotificationWithMessage:(EMMessage *)message ;

- (void)setupUntreatedApplyCount ;


@end
