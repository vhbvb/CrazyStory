//
//  MAXMainViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXMainViewController.h"
#import "MAXStoryTableViewCell.h"
#import "Masonry.h"
#import "MAXStoryDetailViewController.h"
#import "MAXWriteStoryViewController.h"
#import "MJRefresh.h"

@interface MAXMainViewController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *storiesTableView;
@property (nonatomic, strong) NSMutableArray <AVObject *>*storiesArr ;
@property (nonatomic, strong) NSMutableDictionary *submittersDic ;

@end

@implementation MAXMainViewController


- (void)viewDidLoad
{
    [self setup];
    [self configUI];
    [_storiesTableView.mj_header beginRefreshing];
}

- (void)setup
{
    self.storiesArr = @[].mutableCopy ;
    self.submittersDic = @{}.mutableCopy ;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"CrazyStory";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"写故事" style:UIBarButtonItemStylePlain target:self action:@selector(writeStory:)];
    
}

- (void)configUI
{
    self.storiesTableView =
    ({
        UITableView *storiesTableView = [[UITableView alloc] init];
        
        [self.view addSubview:storiesTableView];
        [storiesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        storiesTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [_storiesArr removeAllObjects];
            [self requestStoriesList];
        }];
        storiesTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
        storiesTableView.delegate = self ;
        storiesTableView.dataSource = self ;
        [storiesTableView registerClass:[MAXStoryTableViewCell class]
                  forCellReuseIdentifier:kStoryCellReuseIdentifier];
        storiesTableView ;
    });

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.storiesArr.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAXStoryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kStoryCellReuseIdentifier];
    AVObject * story = self.storiesArr[indexPath.row];
    NSMutableArray * submitters = _submittersDic[story.objectId];
    cell.model = story;
    [cell congfigSubmitters:submitters didSelectUser:^(AVUser *user) {
        // 选择了user ;
        MAXLog(@"%@",user);
    }];
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 175 ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAXStoryTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    AVObject *story = self.storiesArr[indexPath.row];
    MAXStoryDetailViewController * storyDetailVC = [[MAXStoryDetailViewController alloc] initWithStory:story];
    [self.navigationController pushViewController:storyDetailVC animated:YES];
    [self increaseSeeCountOfStory:story];
}

- (void)increaseSeeCountOfStory:(AVObject *)story
{
    NSNumber * seeCount = story[kStoryPropertySeeCount];
    NSInteger currentSeeCount ;
    if ([seeCount isKindOfClass:[NSNumber class]])
    {
        currentSeeCount = seeCount.integerValue + 1 ;
    }
    story[kStoryPropertySeeCount] = @(currentSeeCount);
    [story saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
    {
        if (!error)
        {
            MAXLog(@"seeCount + 1 :%@",story);
        }
        else
        {
            MAXLog(@"SeeCount error:%@ --> %@",story,error);
        }
    }];
}

- (void)writeStory:(UIBarButtonItem *)item
{
    [self.navigationController pushViewController:[[MAXWriteStoryViewController alloc] init] animated:YES];
}

#pragma mark -  getter 

- (void)requestStoriesList
{
    AVQuery *query = [AVQuery queryWithClassName:kStoriesListClass];
    [query orderByDescending:kQueryKeyCreatedAt];
    query.limit = 10 ;
    [query includeKey:kStoryPropertyOwner];//不加这一句只返回user的objectId
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error)
        {
            [_storiesArr addObjectsFromArray:objects] ;
            [self getSubmittersOfStory:_storiesArr];
        }
        else
        {
            MAXLog(@"get storiesList error:%@",error);
            if (error.code==101) {
                [self.storiesTableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.storiesTableView.mj_header endRefreshing];
        }
    }];
}

- (void)loadMore
{
    AVQuery *query = [AVQuery queryWithClassName:kStoriesListClass];
    [query whereKey:kQueryKeyCreatedAt lessThan:[self.storiesArr lastObject].createdAt];
    query.limit = 10 ;
    [query includeKey:kStoryPropertyOwner];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
    {
        if(!error)
        {
            if (objects.count<10)
            {
                [_storiesTableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [_storiesArr addObjectsFromArray:objects];
            [self getSubmittersOfStory:objects.mutableCopy];
        }
    }];
}

- (void)getSubmittersOfStory:(NSMutableArray <AVObject *>*)stories
{
    static NSInteger flag = 0 ;
    flag = 0 ;
    
    for (AVObject * story in stories)
    {
        AVQuery * query = [AVQuery queryWithClassName:kContentsListClass];
        [query whereKey:kContentPropertyStory equalTo:story];
        [query includeKey:kContentPropertyOwner];
        NSMutableArray * submitters = [NSMutableArray array];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
        {
            if (!error)
            {
                for (AVObject * content in objects) {
                    AVUser *user = content[kContentPropertyOwner];
                    if (user) [submitters addObject:user];
                }
                _submittersDic[story.objectId] = [self duplicateChecking:submitters];
            }
            else
            {
                MAXLog(@"%@ requestSubmittersArr error:%@",story,error.localizedDescription);
            }
            flag++;
            if (flag == stories.count)
            {
                MAXLog(@"%@",_submittersDic);
                [self.storiesTableView reloadData];
                [self.storiesTableView.mj_header endRefreshing];
            }
        }];
    }
}

//查重
- (NSMutableArray *)duplicateChecking:(NSMutableArray *)submitters
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    for (AVUser *user in submitters)
    {
        dic[user.objectId] = user ;
    }
    return [dic allValues].mutableCopy;
}
@end
