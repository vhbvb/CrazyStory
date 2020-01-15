//
//  MAXStoryDetailViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXStoryDetailViewController.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "MAXAddContentViewController.h"
#import "MAXUserDetailsViewController.h"
#import "MAXStoryContentTableViewCell.h"
#import "MAXContentsCollectionViewCell.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "MAXCoreDataManager.h"
#import "QCCustomUICollectionViewFlowLayout.h"


@interface MAXStoryDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate>
{
    BOOL _isEndOfStory ;//判断是否分支已经完全展开。
}

@property(nonatomic, strong) UITableView * storyDetailTableView ;
@property(nonatomic, strong) NSArray <AVObject *>* contentList ;
@property(nonatomic, strong) NSMutableArray <AVObject*>* tableViewDataList ;
@property(nonatomic, strong) NSArray * footerCollectionViewDataList ;
@property(nonatomic, strong) AVObject * story ;
@property(nonatomic, strong) UIView *footerView ;

@end

@implementation MAXStoryDetailViewController

- (instancetype)initWithStory:(AVObject *)story
{
    if (self = [super init])
    {
        self.hidesBottomBarWhenPushed = YES ;
        _story = story ;
    }
    return self ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self configUI];
    if(!self.tableViewDataList.count)
    {
        [_storyDetailTableView.mj_header beginRefreshing];
    }
    else
    {
        [self requestStoryContents];
    }
}

- (void)setup
{
    self.tableViewDataList = [MAXCoreDataManager contentsOfStory:_story].mutableCopy;
    if (!self.tableViewDataList)
    {
        self.tableViewDataList = [NSMutableArray array];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.story[kStoryPropertyTitle];
}

#pragma mark - 配置UI

- (void)configUI
{
    UIButton * shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"mainCellShareClick"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBarbtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
    self.storyDetailTableView =
    ({
        UITableView *storyDetailTableView = [[UITableView alloc] init];
        storyDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        storyDetailTableView.delegate = self ;
        storyDetailTableView.dataSource = self ;
        [storyDetailTableView registerClass:[MAXStoryContentTableViewCell class]
                     forCellReuseIdentifier:kStoryContentCellReuseIdentifier];
        [self.view addSubview:storyDetailTableView];
        [storyDetailTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        storyDetailTableView;
    });
    
    self.storyDetailTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _isEndOfStory = NO ;
        if ([MAXCoreDataManager deleteCacheOfStory:_story])
        {
            MAXLog(@"cache delete success.");
        }
        [self.tableViewDataList removeAllObjects];
        self.storyDetailTableView.tableFooterView = nil ;
        [self.storyDetailTableView reloadData];
        [self requestStoryContents];
    }];
}

- (UIView *)detailTableViewFooterEndTypeView ;
{
    UIView *footer = [[UIView alloc] init];
    footer.frame = CGRectMake(0, 0, self.view.width , 75);
    UIButton * addContentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addContentBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [addContentBtn addTarget:self action:@selector(addContent:) forControlEvents:UIControlEventTouchUpInside];
    [addContentBtn setTitle:@"让我接着写..." forState:UIControlStateNormal];
    [addContentBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    addContentBtn.layer.borderWidth = 1 ;
    addContentBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [footer addSubview:addContentBtn];
    [addContentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footer).offset(25);
        make.centerX.equalTo(footer);
        make.width.equalTo(footer);
        make.height.equalTo(@44);
    }];
    return footer ;
}

- (UIView *)detailTableViewFooterBranchTypeView
{
    if (!_footerView)
    {
        self.footerView =
        ({
            UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
            
            QCCustomUICollectionViewFlowLayout * layout = [[QCCustomUICollectionViewFlowLayout alloc] init] ;
            [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
            UICollectionView *footerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectNull collectionViewLayout:layout];
            
            footerCollectionView.backgroundColor = [UIColor lightTextColor];
            [footerCollectionView registerClass:[MAXContentsCollectionViewCell class] forCellWithReuseIdentifier:kContentsCollectionViewCellReuseIdentifier];
            footerCollectionView.dataSource = self ;
            footerCollectionView.delegate = self ;
            [footerView addSubview:footerCollectionView];
            [footerCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(footerView);
                make.top.equalTo(footerView).offset(10) ;
            }];
            
            UILabel * branch = [[UILabel alloc] init];
            branch.text = @"分支(左右滑动切换分支)";
            branch.textColor = [UIColor blueColor];
            branch.font = [UIFont systemFontOfSize:13];
            [footerView addSubview:branch];
            [branch mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(footerView);
                make.bottom.equalTo(footerCollectionView.mas_top).offset(10);
            }];
            
            UIView * leftLine = [[UIView alloc] init];
            leftLine.backgroundColor = [UIColor grayColor];
            [footerView addSubview:leftLine];
            [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(branch.mas_left).offset(-5);
                make.left.equalTo(footerView).offset(15);
                make.centerY.equalTo(branch);
                make.height.equalTo(@1);
            }];
            
            UIView * rightLine = [[UIView alloc] init];
            rightLine.backgroundColor = [UIColor grayColor];
            [footerView addSubview:rightLine];
            [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(branch.mas_right).offset(5);
                make.right.equalTo(footerView).offset(-15);
                make.centerY.equalTo(branch);
                make.height.equalTo(@1);
            }];
            
            footerView ;
        });
    }
    return _footerView ;
}



#pragma mark - UITableViewDataSoure && delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAXStoryContentTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kStoryContentCellReuseIdentifier];
    if (indexPath.row<self.tableViewDataList.count) {
        [cell setModel:self.tableViewDataList[indexPath.row] selectUser:^(AVUser *user) {
            [self.navigationController pushViewController:[[MAXUserDetailsViewController alloc] initWithAVUser:user] animated:YES];
        }];
    }
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AVObject * model = self.tableViewDataList[indexPath.row];
    NSNumber * height = model[@"cellHeight"];
    return height.floatValue ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAXStoryContentTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
}

#pragma mark - UICollectionViewDataSource && delegate 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _footerCollectionViewDataList.count ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MAXContentsCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kContentsCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    cell.model = _footerCollectionViewDataList[indexPath.row];
    cell.index = indexPath.row ;
    return cell ;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableViewDataList addObject:_footerCollectionViewDataList[indexPath.row]];
    [self insertCell];
    [self findNextContent];
}

- (void)insertCell
{
    if (_tableViewDataList.count)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_tableViewDataList.count-1 inSection:0];
        [_storyDetailTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - 数据请求与处理

- (void)requestStoryContents
{
    AVQuery *query = [AVQuery queryWithClassName:kContentsListClass];
    [query whereKey:kContentPropertyStory equalTo:self.story];
    [query includeKey:kContentPropertyOwner];
    [query includeKey:@"contentOwner.headImage"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         ReceiveDataLog;
         
         
         
         [_storyDetailTableView.mj_header endRefreshing];
         if (!error)
         {
             
             _contentList = objects;
             if (self.tableViewDataList.count)
             {
                 [self.storyDetailTableView reloadData];
                 [self findNextContent];
             }
             else
             {
                 [self FindFirstContent];
             }
         }
         else
         {
             [self.storyDetailTableView reloadData];
         }
     }];
}

- (void)FindFirstContent
{
    for (AVObject *obj in _contentList)
    {
        if (!obj[kContentPropertySuperContent])
        {
            [_tableViewDataList addObject:obj];
            [self insertCell];
            [self findNextContent];
        }
    }
}

- (void)findNextContent
{
    AVObject *header = [_tableViewDataList lastObject];
    NSMutableArray * arr = [NSMutableArray array];
    for (AVObject *obj in _contentList)
    {
        AVObject *superContent = obj[kContentPropertySuperContent];
        if ([superContent.objectId isEqualToString:header.objectId])
        {
            [arr addObject:obj];
        }
    }
    
    switch (arr.count) {
        case 0:
            _storyDetailTableView.tableFooterView = [self detailTableViewFooterEndTypeView];
            _isEndOfStory = YES ;
            [MAXCoreDataManager updateContentsOfStory:_story contents:_tableViewDataList];
            break;
        case 1:
            [_tableViewDataList addObjectsFromArray:arr];
            [self insertCell];
            [self findNextContent];
            break;
        default:
            _footerCollectionViewDataList = arr ;
            _storyDetailTableView.tableFooterView = [self detailTableViewFooterBranchTypeView];
            [MAXCoreDataManager updateContentsOfStory:_story contents:_tableViewDataList];
            break;
    }
}

#pragma mark - 点击事件
- (void)shareBarbtnClicked:(UIButton *)shareBtn
{
    if (!_isEndOfStory)
    {
        MAXAlert(@"故事还没有看完哦，看完再分享吧...");
        return ;
    }
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSMutableString * storyContent = [NSMutableString string];
    for (AVObject * content in _tableViewDataList)
    {
        [storyContent appendString:[NSString stringWithFormat:@"%@\n",content[kContentPropertyContent]]];
    }
    
    [shareParams SSDKSetupShareParamsByText:storyContent
                                         images:nil
                                            url:nil
                                          title:_story[kStoryPropertyTitle]
                                           type:SSDKContentTypeAuto];
    //有的平台要客户端分享需要加此方法，例如微博
    [shareParams SSDKEnableUseClientShare];
    
    [ShareSDK showShareActionSheet:nil
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state,
                                     SSDKPlatformType platformType,
                                     NSDictionary *userData,
                                     SSDKContentEntity *contentEntity,
                                     NSError *error,
                                     BOOL end){
                   switch (state)
                   {
                       case SSDKResponseStateSuccess:
                       {
                           [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                           [self saveShareRelation];
                           [SVProgressHUD dismissWithDelay:1.25];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           MAXAlert(@"分享失败 : %@",error);
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
                           MAXLog(@"取消分享");
                       }
                       case SSDKResponseStateBegin:
                       {
                           MAXLog(@"开始分享？");
                       }
                       default:
                           break;
                   }
               }];
}

- (void)addContent:(UIButton *)footerBtn
{
    AVObject * lastContent = self.tableViewDataList.lastObject ;
    AVUser * lastSubmitter = lastContent[kContentPropertyOwner] ;
    if ([lastSubmitter.objectId isEqualToString:[AVUser currentUser].objectId]) {
        MAXAlert(@"请不要连续提交哦...");
        return ;
    }
    MAXAddContentViewController * vc = [[MAXAddContentViewController alloc] initWithSuperContentModel:_tableViewDataList.lastObject];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)saveShareRelation
{
    AVQuery *relationQuery = [[AVQuery alloc] initWithClassName:kRelationsListClass];
    [relationQuery whereKey:kRelationPropertyFlag equalTo:KRelationPropertyFlagShare];
    AVQuery *userQuery = [[AVQuery alloc] initWithClassName:kRelationsListClass];
    [userQuery whereKey:kRelationPropertyUser equalTo:[AVUser currentUser]];
    AVQuery *storyQuery = [[AVQuery alloc] initWithClassName:kRelationsListClass];
    [storyQuery whereKey:kRelationPropertyStory equalTo:_story];
    AVQuery * likeQuery = [AVQuery andQueryWithSubqueries:@[relationQuery,userQuery,storyQuery]];
    
    [likeQuery countObjectsInBackgroundWithBlock:^(NSInteger number, NSError * _Nullable error) {
        MAXLog(@"relationship Check number :%zd , error :%@",number,error.localizedDescription);
        if (error.code == 101 || number==0)
        {
            AVObject * share = [AVObject objectWithClassName:kRelationsListClass];
            [share setObject:[AVUser currentUser] forKey:kRelationPropertyUser];
            [share setObject:_story forKey:kRelationPropertyStory];
            [share setObject:KRelationPropertyFlagShare forKey:kRelationPropertyFlag];
            if (![share save])
            {
                MAXLog(@"shareRelationShip Saved error.");
            }
        }
    }];
}

@end
