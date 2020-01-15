//
//  MAXCommodityView.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/16.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXCommodityView.h"

@interface MAXCommodityView()
@property (weak, nonatomic) IBOutlet UILabel *buyInkCount;
@property (weak, nonatomic) IBOutlet UILabel *money;

@end

@implementation MAXCommodityView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.userInteractionEnabled = YES ;
    self.layer.borderWidth = 1.5 ;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.cornerRadius = 5 ;
}

- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)selector
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
}

- (void)setCommodityType:(MAXCommodityType)commodityType
{
    _commodityType = commodityType ;
    
    switch (_commodityType) {
        case MAXCommodityType_100Ink:
            _buyInkCount.text = @"100" ;
            _money.text = @"¥ 1.0" ;
            break;
        case MAXCommodityType_250Ink:
            _buyInkCount.text = @"250" ;
            _money.text = @"¥ 2.5" ;
            break;
        case MAXCommodityType_500Ink:
            _buyInkCount.text = @"500" ;
            _money.text = @"¥ 5.0" ;
            break;
        case MAXCommodityType_1000Ink:
            _buyInkCount.text = @"1000" ;
            _money.text = @"¥ 10.0" ;
            break;
            
        default:
            break;
    }
}

- (void)setSelect:(BOOL)select
{
    if (_select != select)
    {
        if (select)
        {
            self.layer.borderColor  = [UIColor greenColor].CGColor;
        }
        else
        {
            self.layer.borderColor  = [UIColor lightGrayColor].CGColor;
        }
        
    }
     _select = select ;
}

@end
