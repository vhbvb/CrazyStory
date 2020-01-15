//
//  MAXBuyViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/16.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXBuyViewController.h"
#import "MAXCommodityView.h"
#import "MAXBuyerInfoView.h"
#import "Masonry.h"
#import <StoreKit/StoreKit.h>

static NSString * const ProductID_Ink1000 = @"com.mob.test.XYCarzy.Ink1000";
static NSString * const ProductID_Ink500 = @"com.mob.test.XYCarzy.Ink500";
static NSString * const ProductID_Ink250 = @"com.mob.test.XYCarzy.Ink250";
static NSString * const ProductID_Ink100 = @"com.mob.test.XYCarzy.Ink100";

@interface MAXBuyViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate >
{
    MAXCommodityView * _selectedView ;
    NSArray<SKPaymentTransaction *> * _savedTransactions;
}

@property(nonatomic ,strong) MAXBuyerInfoView * buyerView ;

@end

@implementation MAXBuyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setup];
    [self configUI];
}

- (void)setup
{
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.title = @"购买墨水" ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)configUI
{
    self.buyerView =
    ({
        MAXBuyerInfoView * buyerView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(MAXBuyerInfoView.class) owner:self options:nil].lastObject;
        [self.view addSubview:buyerView];
        [buyerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.height.mas_equalTo(NavigationBarOffsetValue);
        }];
        buyerView ;
    });
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor grayColor];
    line.alpha = 0.33 ;
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.right.equalTo(self.view).offset(-5);
        make.top.equalTo(_buyerView.mas_bottom).offset(5);
        make.height.equalTo(@1);
    }];
    
    UIView * MAXCommodityInfoView = [[NSBundle mainBundle] loadNibNamed:@"MAXCommodityInfoView" owner:self options:nil].lastObject;
    [self.view addSubview:MAXCommodityInfoView];
    [MAXCommodityInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_buyerView.mas_bottom).offset(25);
        make.height.equalTo(@125);
    }];
    
    MAXCommodityView *lastView ;
    for (NSInteger i=0; i<4; i++)
    {
        MAXCommodityView * commodityView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(MAXCommodityView.class) owner:self options:nil].lastObject;
        [self.view addSubview:commodityView];
        [commodityView addTapGestureRecognizerWithTarget:self action:@selector(didSelectCommodity:)];
        [commodityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.height.equalTo(@50);
            make.top.equalTo(MAXCommodityInfoView.mas_bottom).offset((50+5)*i-5);
        }];
        commodityView.commodityType = i ;
        if (commodityView.commodityType == MAXCommodityType_500Ink)
        {
            commodityView.select = YES ;
            _selectedView = commodityView ;
        }
        if (i==3)
        {
            lastView = commodityView ;
        }
    }
    
    UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setTitle:@"确 认 购 买" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.borderColor = [UIColor redColor].CGColor;
    confirmBtn.layer.borderWidth = 1.25;
    confirmBtn.layer.cornerRadius = 4.4;
    
    [self.view addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(7);
        make.right.equalTo(self.view).offset(-7);
        make.top.equalTo(lastView.mas_bottom).offset(44);
        make.height.equalTo(@44);
    }];
}

- (void)didSelectCommodity:(UITapGestureRecognizer *)tap
{
    MAXCommodityView * view = (MAXCommodityView *)tap.view ;
    
    if (!view.select) {
        view.select = YES ;
        _selectedView.select = NO ;
        _selectedView = view ;
    }
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirm:(UIButton *)sender
{
    if (![SKPaymentQueue canMakePayments])
    {
        MAXAlert(@"该设备不支持内购");
        return ;
    }
    
    [self setUserInteraction:NO];
    NSArray *commodity = nil ;
    switch (_selectedView.commodityType)
    {
        case MAXCommodityType_100Ink:
            commodity = @[ProductID_Ink100];
            break;
        case MAXCommodityType_250Ink:
            commodity = @[ProductID_Ink250];
            break;
        case MAXCommodityType_500Ink:
            commodity = @[ProductID_Ink500];
            break;
        case MAXCommodityType_1000Ink:
            commodity = @[ProductID_Ink1000];
            break;
        default:
            break;
    }
    
    NSSet *set = [NSSet setWithArray:commodity];
    SKProductsRequest * req = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    req.delegate = self ;
    
    [SVProgressHUD showWithStatus:@"正在生成订单..."];
    [req start];
}

#pragma mark - SKProductsRequestDelegate 

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProduct = response.products ;
    
#ifdef DEBUG
    NSMutableString * responseDesc = @"".mutableCopy ;
    [responseDesc appendFormat:@"\n 产品Product ID:%@",response.invalidProductIdentifiers];
    [responseDesc appendFormat:@"\n 产品付费数量: %d", (int)[myProduct count]];
    
    for(SKProduct *product in myProduct)
    {
        [responseDesc appendFormat:@" \n \n product info \n SKProduct 描述信息%@", [product description]];
        [responseDesc appendFormat:@"\n 产品标题: %@" , product.localizedTitle];
        [responseDesc appendFormat:@"\n 产品描述信息: %@" , product.localizedDescription];
        [responseDesc appendFormat:@"\n 价格: %@" , product.price];
        [responseDesc appendFormat:@"\n Product id: %@" , product.productIdentifier];
    }
    MAXLog(@"%@",responseDesc);
#endif
    
    if (!myProduct.count)
    {
        [SVProgressHUD dismiss];
        [self setUserInteraction:YES];
        MAXAlert(@"订单出错，请重试...");
        return ;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:myProduct.firstObject];
    
    [SVProgressHUD showWithStatus:@"下单成功，支付中..."];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    MAXAlert(@"%@",error);
    [self setUserInteraction:YES];
}

- (void)requestDidFinish:(SKRequest *)request
{
    MAXLog(@"finished");

}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成

                [self completeTransaction:transaction];
            
                break;
            case SKPaymentTransactionStateFailed://交易失败
                
                [self failedTransaction:transaction];
                
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                
                [self restoreTransaction:transaction];
                
            case SKPaymentTransactionStatePurchasing://商品添加进列表
                MAXLog(@"商品添加进列表...");
                break;
                
            default:
                break;
        }
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    MAXAlert(@"交易失败");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [SVProgressHUD dismiss];
    [self setUserInteraction:YES];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    MAXAlert(@"您已购买过此商品");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [SVProgressHUD dismiss];
    [self setUserInteraction:YES];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    MAXLog(@"成功购买此商品...");
    [SVProgressHUD showWithStatus:@"正在验证购买..."];

    [self verifyPurchaseWithPaymentTransaction:transaction];
    
}


#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"
/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 */
-(void)verifyPurchaseWithPaymentTransaction:(SKPaymentTransaction *)transaction
{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    //创建请求到苹果官方进行购买验证
#ifdef DEBUG
    NSURL *url = [NSURL URLWithString:SANDBOX];
#else
    NSURL *url = [NSURL URLWithString:AppStore];
#endif
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    
    if (error)
    {
        [SVProgressHUD dismiss];
        [self setUserInteraction:YES];
        MAXAlert(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    MAXLog(@"%@",dic);
    if([dic[@"status"] intValue]==0)
    {
        [SVProgressHUD showSuccessWithStatus:@"验证通过..."];
        [self didBuyProduct:transaction];
    }
    else
    {
        [SVProgressHUD dismiss];
        [self setUserInteraction:YES];
        MAXAlert(@"购买失败，未通过验证！");
    }
}
//21000 App Store无法读取你提供的JSON数据
//21002 收据数据不符合格式
//21003 收据无法被验证
//21004 你提供的共享密钥和账户的共享密钥不一致
//21005 收据服务器当前不可用
//21006 收据是有效的，但订阅服务已经过期。当收到这个信息时，解码后的收据信息也包含在返回内容中
//21007 收据信息是测试用（sandbox），但却被发送到产品环境中验证
//21008 收据信息是产品环境中使用，但却被发送到测试环境中验证

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
}

- (void)didBuyProduct:(SKPaymentTransaction *)transaction
{
    NSString * productID = transaction.payment.productIdentifier;
    
    if([productID isEqualToString:ProductID_Ink100])
    {
        [self addInkCount:100 paymentTransaction:transaction];
    }
    
    if ([productID isEqualToString:ProductID_Ink250])
    {
        [self addInkCount:250 paymentTransaction:transaction];
    }
    
    if ([productID isEqualToString:ProductID_Ink500])
    {
        [self addInkCount:500 paymentTransaction:transaction];
    }
    
    if ([productID isEqualToString:ProductID_Ink1000])
    {
        [self addInkCount:1000 paymentTransaction:transaction];
    }
}

- (void)setUserInteraction:(BOOL)enable
{
    self.view.userInteractionEnabled = enable ;
    self.navigationItem.leftBarButtonItem.enabled = enable ;
}

- (void)addInkCount:(NSInteger)count paymentTransaction:(SKPaymentTransaction *)transaction
{
    [SVProgressHUD showWithStatus:@"正在添加墨水..."];
    NSNumber *inkCount = [AVUser currentUser][kUserPropertyInkCount];
    
    if (inkCount && [inkCount isKindOfClass:NSNumber.class])
    {
        NSInteger currentInk = inkCount.integerValue + count ;
        [AVUser currentUser][kUserPropertyInkCount] = @(currentInk) ;
        [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            MAXLog(@"addInkCount--> %@",error);
            [self setUserInteraction:YES];
            if (!error)
            {
                [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                [SVProgressHUD dismissWithDelay:1.2];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [_buyerView refreshUserInfo];
            }
            else
            {
                [SVProgressHUD dismiss];
                MAXAlert(@"购买失败:%@",error);
            }
        }] ;
    }
}

@end
