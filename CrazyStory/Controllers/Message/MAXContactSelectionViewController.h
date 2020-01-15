//
//  MAXContactSelectionViewController.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/10.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "EMChooseViewController.h"

@interface MAXContactSelectionViewController : EMChooseViewController

//已有选中的成员username，在该页面，这些成员不能被取消选择
- (instancetype)initWithBlockSelectedUsernames:(NSArray *)blockUsernames;

- (instancetype)initWithContacts:(NSArray *)contacts;

@end
