//
//  MAXMineViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXMineViewController.h"
#import "MAXStoryDetailViewController.h"
#import "MAXLoginRegisterViewController.h"
#import "MAXSetViewController.h"
#import "MAXCompleteUserInfoViewController.h"
#import "MAXHeadImageViewController.h"

#import "MAXStoryTableViewCell.h"
#import "Masonry.h"
#import "MAXMineCountView.h"
#import "UIImage+MAXExtend.h"
#import "MJRefresh.h"

@interface MAXMineViewController()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>

@property(nonatomic, strong) UITableView *myStoriesTableView;
@property(nonatomic, strong) UIImageView *headImgView ;
@property(nonatomic, strong) UIButton *userName ;
@property(nonatomic, strong) UIButton *inkCount ;
@property(nonatomic, strong) MAXMineCountView *creatView ;
@property(nonatomic, strong) MAXMineCountView *submitView ;
@property(nonatomic, strong) MAXMineCountView *shareView ;
@property(nonatomic, strong) MAXMineCountView *likeView ;
@property(nonatomic, strong) NSMutableArray *tableViewDataSourceArr ;
@property(nonatomic, strong) NSMutableArray *createdStoriesArr ;
@property(nonatomic, strong) NSMutableArray *submitedStoriesArr ;
@property(nonatomic, strong) NSMutableArray *likedStoriesArr ;
@property(nonatomic, strong) NSMutableArray *sharedStoriesArr ;

@end

@implementation MAXMineViewController

- (void)viewDidLoad
{
    [self setup];
    [self configUI];
    [self creatViewClicked:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!isLogined)
    {
        [self.navigationController pushViewController:[[MAXLoginRegisterViewController alloc] init] animated:YES];
    }
    else
    {
        NSString * ink = [NSString stringWithFormat:@"墨水 : %@滴",[AVUser currentUser][kUserPropertyInkCount]] ;
        [self.userName setTitle:[AVUser currentUser].username forState:UIControlStateNormal];
        [self.inkCount setTitle:ink forState:UIControlStateNormal];
        [UIImage getHeadImageForUser:[AVUser currentUser] result:^(UIImage *headImg, NSError *error) {
            if (!error&&headImg) {
                _headImgView.image = headImg ;
            }
        }];
        [self requestCountForViews];
    }
}

- (void)setup
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"我的";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self ;
}

#pragma mark - 配置UI

- (void)configUI
{
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"mine-setting-icon"] forState:UIControlStateNormal];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"mine-setting-icon-click"] forState:UIControlStateHighlighted];
    setBtn.frame = CGRectMake(0, 0, 25, 25);
    [setBtn addTarget:self action:@selector(setupBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:setBtn];
    
    self.headImgView =
    ({
        UIImage * placeholdHeadImg = [UIImage imageNamed:@"defaultHeadImg"];
        UIImageView * headImgView = [[UIImageView alloc] initWithImage:placeholdHeadImg];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigHeadImage:)];
        headImgView.userInteractionEnabled = YES ;
        [headImgView addGestureRecognizer:tap];
        [self.view addSubview:headImgView];
        [headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(10);
            make.top.equalTo(self.view).offset(15);
            make.height.equalTo(@66);
            make.width.equalTo(@66);
        }];
        
        headImgView;
    });
    
    self.userName =
    ({
        UIButton *userName = [UIButton buttonWithType:UIButtonTypeCustom];
        [userName setTitle:@"用户名" forState:UIControlStateNormal];
        [userName setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        userName.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [userName addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:userName];
        [userName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_headImgView);
            make.left.equalTo(_headImgView.mas_right).offset(15);
        }];
        userName;
    });
    
    self.inkCount =
    ({
        UIButton * inkCount = [UIButton buttonWithType:UIButtonTypeCustom];
        [inkCount setTitle:@"墨水 ：" forState:UIControlStateNormal];
        [inkCount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        inkCount.titleLabel.font = [UIFont systemFontOfSize:16];
        [inkCount addTarget:setBtn action:@selector(buyInk:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:inkCount];
        [inkCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userName.mas_right).offset(20);
            make.bottom.equalTo(_userName);
        }];
        inkCount;
    });
    
    /* * * * * * * * * 配置中间 分享数，创建数，提交数 视图 * * * * * * * */
    
    UIView * lineTop = [[UIView alloc] init];
    lineTop.backgroundColor = [UIColor grayColor];
    lineTop.alpha = 0.15 ;
    [self.view addSubview:lineTop];
    [lineTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@1);
        make.top.equalTo(_headImgView.mas_bottom).offset(5);
    }];
    
    UIView * actionView = [[UIView alloc] init];
    [self.view addSubview:actionView];
    [actionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@66);
        make.top.equalTo(lineTop.mas_bottom);
    }];
    
    UIView * lineMid = [[UIView alloc] init];
    lineMid.backgroundColor = [UIColor grayColor];
    lineMid.alpha = 0.075 ;
    [actionView addSubview:lineMid];
    [lineMid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(actionView);
        make.top.equalTo(actionView).offset(10);
        make.bottom.equalTo(actionView).offset(-10);
        make.width.equalTo(@1);
    }];
    
    self.submitView = ({
        MAXMineCountView * view = [[MAXMineCountView alloc] init];
        [view addTapGestureWithTarget:self selector:@selector(submitViewClicked:)];
        view.name = @"提交的片段" ;
        view.count = 0 ;
        [actionView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(lineMid.mas_left);
            make.width.mas_equalTo(kScreenWidth/4);
            make.top.bottom.equalTo(actionView);
        }];
        view;
    });
    
    UIView * lineLeft = [[UIView alloc] init];
    lineLeft.backgroundColor = [UIColor grayColor];
    lineLeft.alpha = 0.075 ;
    [actionView addSubview:lineLeft];
    [lineLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_submitView.mas_left);
        make.width.equalTo(@1);
        make.top.equalTo(actionView).offset(10);
        make.bottom.equalTo(actionView).offset(-10);
    }];
    
    self.creatView = ({
        MAXMineCountView * view = [[MAXMineCountView alloc] init];
        [view addTapGestureWithTarget:self selector:@selector(creatViewClicked:)];
        view.name = @"创建的故事" ;
        view.count = 0 ;
        [actionView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(lineLeft.mas_left);
            make.left.top.bottom.equalTo(actionView);
        }];
        view;
    });
    
    self.likeView = ({
        MAXMineCountView * view = [[MAXMineCountView alloc] init];
        [view addTapGestureWithTarget:self selector:@selector(likeViewClicked:)];
        view.name = @"喜欢的故事" ;
        view.count = 0 ;
        [actionView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lineMid.mas_right);
            make.width.mas_equalTo(kScreenWidth/4);
            make.top.bottom.equalTo(actionView);
        }];
        view;
    });
    
    UIView * lineRight = [[UIView alloc] init];
    lineRight.backgroundColor = [UIColor grayColor];
    lineRight.alpha = 0.075 ;
    [actionView addSubview:lineRight];
    [lineRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_likeView.mas_right);
        make.width.equalTo(@1);
        make.top.equalTo(actionView).offset(10);
        make.bottom.equalTo(actionView).offset(-10);
    }];

    self.shareView = ({
        MAXMineCountView * view = [[MAXMineCountView alloc] init];
        [view addTapGestureWithTarget:self selector:@selector(shareViewClicked:)];
        view.name = @"分享的故事" ;
        view.count = 0 ;
        [actionView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lineRight.mas_right);
            make.top.bottom.right.equalTo(actionView);
        }];
        view;
    });
    
    UIView * lineBottom = [[UIView alloc] init];
    lineBottom.backgroundColor = [UIColor grayColor];
    lineBottom.alpha = 0.15 ;
    [self.view addSubview:lineBottom];
    [lineBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@1);
        make.top.equalTo(actionView.mas_bottom);
    }];
    
    /* * * * * * * * * * * * * */
    self.myStoriesTableView =
    ({
        UITableView *myStoriesTableView = [[UITableView alloc] init];
        myStoriesTableView.dataSource = self ;
        myStoriesTableView.delegate = self ;
        [myStoriesTableView registerClass:[MAXStoryTableViewCell class] forCellReuseIdentifier:kStoryCellReuseIdentifier];
        myStoriesTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadDataSource)];
        myStoriesTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
        [self.view addSubview:myStoriesTableView];
        [myStoriesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineBottom.mas_bottom);
            make.left.right.bottom.equalTo(self.view);
        }];
        
        myStoriesTableView;
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewDataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAXStoryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kStoryCellReuseIdentifier];
    if (indexPath.row>self.tableViewDataSourceArr.count) {
        MAXLog(@"数组超限");
    }else{
        cell.model = self.tableViewDataSourceArr[indexPath.row];
    }
    return cell ;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 170 ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAXStoryTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    AVObject *story = self.tableViewDataSourceArr[indexPath.row];
    MAXStoryDetailViewController * storyDetailVC = [[MAXStoryDetailViewController alloc] initWithStory:story];
    [self.navigationController pushViewController:storyDetailVC animated:YES];
    [self increaseSeeCountOfStory:story];
}




#pragma mark - clickEvent

MAXMineCountView *selectedView ;
- (void)submitViewClicked:(id)sender
{
    if (!_submitView.selected) {
        _submitView.selected = YES ;
        selectedView.selected = NO ;
        selectedView = _submitView ;
        if (!_submitedStoriesArr)
        {
            _submitedStoriesArr = [NSMutableArray array];
            self.tableViewDataSourceArr = _submitedStoriesArr ;
            [self.myStoriesTableView.mj_header beginRefreshing];
        }else
        {
            self.tableViewDataSourceArr = self.submitedStoriesArr ;
            [self.myStoriesTableView reloadData];
        }
    
    }
}

- (void)creatViewClicked:(id)sender
{
    if (!_creatView.selected) {
        _creatView.selected = YES ;
        selectedView.selected = NO ;
        selectedView = _creatView ;
        if (!_createdStoriesArr) {
            _createdStoriesArr = [NSMutableArray array];
            self.tableViewDataSourceArr = _createdStoriesArr ;
            [self.myStoriesTableView.mj_header beginRefreshing];
        }else
        {
            self.tableViewDataSourceArr = self.createdStoriesArr ;
           [self.myStoriesTableView reloadData];
        }
    }
}

- (void)shareViewClicked:(id)sender
{
    if (!_shareView.selected) {
        _shareView.selected = YES ;
        selectedView.selected = NO ;
        selectedView = _shareView ;
        if (!_sharedStoriesArr) {
            _sharedStoriesArr = [NSMutableArray array];
            self.tableViewDataSourceArr = _sharedStoriesArr ;
            [self.myStoriesTableView.mj_header beginRefreshing];
        }
        else
        {
            self.tableViewDataSourceArr = self.sharedStoriesArr ;
            [self.myStoriesTableView reloadData];
        }
    }
}

- (void)likeViewClicked:(id)sender
{
    if (!_likeView.selected) {
        _likeView.selected = YES ;
        selectedView.selected = NO ;
        selectedView = _likeView ;
        if (!_likedStoriesArr) {
            _likedStoriesArr = [NSMutableArray array];
            self.tableViewDataSourceArr = self.likedStoriesArr ;
            [self.myStoriesTableView.mj_header beginRefreshing];
        }
        else
        {
            self.tableViewDataSourceArr = self.likedStoriesArr ;
            [self.myStoriesTableView reloadData];
        }
    }
}

- (void)detailUserinfo:(UIButton *)sender
{
    [self.navigationController pushViewController:[[MAXLoginRegisterViewController alloc] init] animated:YES];
}

- (void)showUserInfo:(UIButton *)sender ;
{
    [self.navigationController pushViewController:[MAXCompleteUserInfoViewController currentUser] animated:YES];
}

- (void)buyInk:(UIButton *)sender
{
    
}
- (void)setupBtnClicked:(UIButton *)setBtn
{
    [self.navigationController pushViewController:[[MAXSetViewController alloc] init] animated:YES];
}

- (void)bigHeadImage:(id)sender
{
    MAXHeadImageViewController * vc = [[MAXHeadImageViewController alloc] initWithImage:_headImgView.image];
    vc.hidesBottomBarWhenPushed = YES ;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - request data

- (void)requestCountForViews
{
    [self.submitedQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        self.submitView.count = number ;
        MAXLog(@"num -> %zd, error :%@",number,error.localizedDescription);
    }];
    
    [self.createdQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        self.creatView.count = number ;
        MAXLog(@"num -> %zd, error :%@",number,error.localizedDescription);
    }];
    
    [self.likedQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        self.likeView.count = number ;
        MAXLog(@"num -> %zd, error :%@",number,error.localizedDescription);
    }];
    
    [self.likedQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        self.likeView.count = number ;
        MAXLog(@"num -> %zd, error :%@",number,error.localizedDescription);
    }];
}

- (void)requestSubmitedStories
{
    AVQuery * query = self.submitedQuery  ;
    query.limit = 25 ;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.myStoriesTableView.mj_header endRefreshing];
        if (!error) {
            if (objects.count<=25)
            {
                [self.myStoriesTableView.mj_footer endRefreshingWithNoMoreData];
            }
            [_submitedStoriesArr addObjectsFromArray:[self duplicateChecking:objects.mutableCopy]];
            [self.myStoriesTableView reloadData];
        }else{
            MAXLog(@"submitedStories error : %@",error.localizedDescription);
            if(error.code == 101)
            {
                [_myStoriesTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }];
}

- (void)submitedStoriesLoadMore
{
    AVQuery *query = self.submitedQuery;
    query.limit = 25 ;
    [query whereKey:kQueryKeyCreatedAt lessThan:submitedTime];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            
            if (objects.count<=25)
            {
                [self.myStoriesTableView.mj_footer endRefreshingWithNoMoreData];
            }
            else
            {
                [self.myStoriesTableView.mj_footer endRefreshing];
            }
            [_submitedStoriesArr addObjectsFromArray:[self duplicateChecking:objects]];
            [self.myStoriesTableView reloadData];
        }else{
            [self.myStoriesTableView.mj_footer endRefreshing];
            MAXLog(@"error : %@",error.localizedDescription);
        }
    }];
}
//查重
NSDate * submitedTime ;
- (NSMutableArray *)duplicateChecking:(NSArray *)contents
{
    submitedTime = [NSDate distantFuture];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    for (AVObject *obj in contents)
    {
        if ([submitedTime compare:obj[kQueryKeyCreatedAt]]==NSOrderedDescending) {
            submitedTime = obj[kQueryKeyCreatedAt];
            NSLog(@"----------------------->%@",submitedTime);
        }
        
        AVObject *story = obj[kContentPropertyStory];
        dic[story.objectId] = story ;
    }
    return [dic allValues].mutableCopy;
}

- (void)requestCreatedStoriesArr
{
    AVQuery * query = self.createdQuery;
    query.limit = 10 ;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.myStoriesTableView.mj_header endRefreshing];
        if (!error)
        {
            if (objects.count<10)
            {
                [self.myStoriesTableView.mj_footer endRefreshingWithNoMoreData];
            }
            [_createdStoriesArr addObjectsFromArray:objects] ;
            [self.myStoriesTableView reloadData];
        }
        else
        {
            MAXLog(@"error : %@",error.localizedDescription);
            if(error.code == 101)
            {
                [_myStoriesTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }];
}

- (void)createdStoriesLoadMore
{
    AVQuery *query = self.createdQuery ;
    [query whereKey:kQueryKeyCreatedAt lessThan:_createdStoriesArr.lastObject[kQueryKeyCreatedAt]];
    query.limit = 10 ;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.myStoriesTableView.mj_footer endRefreshing];
        if (!error)
        {
            if (objects.count<=10)
            {
                [self.myStoriesTableView.mj_footer endRefreshingWithNoMoreData];
            }
            else
            {
                [self.myStoriesTableView.mj_footer endRefreshing];
            }

            [_createdStoriesArr addObjectsFromArray:objects];
            [self.myStoriesTableView reloadData];
        }
        else
        {
            [self.myStoriesTableView.mj_footer endRefreshing];
            MAXLog(@"error : %@",error.localizedDescription);
        }
    }];

}

- (void)requestLikedStoriesArr
{
    AVQuery *query = self.likedQuery;
    query.limit = 10 ;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.myStoriesTableView.mj_header endRefreshing];
        if (!error)
        {
            if (objects.count<10) {
                [self.myStoriesTableView.mj_footer endRefreshingWithNoMoreData];
            }
            for (NSInteger i=0; i<objects.count; i++) {
                [_likedStoriesArr addObject:objects[i][kRelationPropertyStory]];
            }
            [self.myStoriesTableView reloadData];
        }
        else
        {
            MAXLog(@"error:%@",error.localizedDescription);
            if(error.code == 101)
            {
                [_myStoriesTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }];
}

- (void)likedStoriesLoadMore
{
    AVQuery *query = self.likedQuery;
    query.limit = 10 ;
    [query whereKey:kQueryKeyCreatedAt lessThan:_likedStoriesArr.lastObject[kQueryKeyCreatedAt]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.myStoriesTableView.mj_footer endRefreshing];
        if (!error) {
            
                if (objects.count<10)
                {
                    [self.myStoriesTableView.mj_footer endRefreshingWithNoMoreData];
                }
                else
                {
                    [self.myStoriesTableView.mj_footer endRefreshing];
                }

            for (NSInteger i=0; i<objects.count; i++)
            {
                [_likedStoriesArr addObject:objects[i][kRelationPropertyStory]];
            }
                [self.myStoriesTableView reloadData];
            }
        else
        {
            MAXLog(@"error:%@",error.localizedDescription);
        }
    }];
}

- (void)requestSharedStoriesArr
{
    [self.myStoriesTableView.mj_header endRefreshing];
    [self.myStoriesTableView reloadData];
}

- (void)shareStoriesLoadMore
{

}

- (void)reloadDataSource
{
    if (selectedView==_creatView)
    {
        [_createdStoriesArr removeAllObjects] ;
        [self requestCreatedStoriesArr];
        
    }
    else if (selectedView==_submitView)
    {
        [_submitedStoriesArr removeAllObjects] ;
        [self requestSubmitedStories];
    }
    else if (selectedView==_likeView)
    {
        [_likedStoriesArr removeAllObjects] ;
        [self requestLikedStoriesArr];
    }
    else if (selectedView==_shareView)
    {
        [_sharedStoriesArr removeAllObjects] ;
        [self requestSharedStoriesArr];
    }
}

- (void)loadMore
{
    if (selectedView==_creatView)
    {
        [self createdStoriesLoadMore] ;
    }
    else if (selectedView==_submitView)
    {
        [self submitedStoriesLoadMore] ;
    }
    else if (selectedView==_likeView)
    {
        [self likedStoriesLoadMore] ;
    }
    else if (selectedView==_shareView)
    {
        [self shareStoriesLoadMore] ;
    }
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

#pragma mark - AVQuery getter

- (AVQuery *)createdQuery
{
    AVQuery *query = [AVQuery queryWithClassName:kStoriesListClass];
    [query orderByDescending:kQueryKeyCreatedAt];
    [query includeKey:kStoryPropertyOwner];
    [query whereKey:kStoryPropertyOwner equalTo:[AVUser currentUser]];
    return query ;
}

- (AVQuery *)submitedQuery
{
    AVQuery *query = [AVQuery queryWithClassName:kContentsListClass];
    [query whereKey:kContentPropertyOwner equalTo:[AVUser currentUser]];
    [query whereKeyExists:kContentPropertySuperContent];
    [query includeKey:kContentPropertyStory];
    [query orderByDescending:kQueryKeyCreatedAt];
    [query includeKey:@"story.owner"];
    return query ;
}

- (AVQuery *)likedQuery
{
    AVQuery *query =[AVQuery queryWithClassName:kRelationsListClass];
    [query whereKey:kRelationPropertyFlag equalTo:kRelationPropertyFlagLike];
    [query whereKey:kRelationPropertyUser equalTo:[AVUser currentUser]];
    [query includeKey:@"story.owner"];
    [query orderByAscending:kQueryKeyCreatedAt];
    [query includeKey:kRelationPropertyStory];
    return query ;
}

- (AVQuery *)sharedQuery{
    return nil ;
}

@end
