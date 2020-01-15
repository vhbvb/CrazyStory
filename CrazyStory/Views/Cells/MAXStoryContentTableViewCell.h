//
//  MAXStoryContentTableViewCell.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAXStoryContentTableViewCell : UITableViewCell

@property (nonatomic, strong) AVObject *model ;

- (void)setModel:(AVObject *)model selectUser:(void(^)(AVUser *))process ;

@end
