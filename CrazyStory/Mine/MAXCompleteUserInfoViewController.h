//
//  MAXCompleteUserInfoViewController.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/7.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVUser ;

@interface MAXCompleteUserInfoViewController : UIViewController

- (instancetype)initWithUserInfo:(AVUser *)user ;

+ (instancetype) currentUser ;

@end
