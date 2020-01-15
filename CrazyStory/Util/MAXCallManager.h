//
//  MAXCallManager.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/17.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAXMessageViewController.h"

@interface MAXCallManager : NSObject

@property (strong, nonatomic) MAXMessageViewController *mainController;

+ (instancetype)sharedManager;

- (void)saveCallOptions;

- (void)makeCallWithUsername:(NSString *)aUsername
                        type:(EMCallType)aType;

- (void)answerCall:(NSString *)aCallId;

- (void)hangupCallWithReason:(EMCallEndReason)aReason;

@end
