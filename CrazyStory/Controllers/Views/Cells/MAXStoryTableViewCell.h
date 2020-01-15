//
//  MAXStoryTableViewCell.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAXStoryTableViewCell : UITableViewCell


@property (nonatomic, strong) AVObject *model ;


- (void) congfigSubmitters:(NSMutableArray <AVUser *>*)submitters didSelectUser:(void(^)(AVUser *))process ;

@end
