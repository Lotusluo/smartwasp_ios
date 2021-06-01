//
//  HWFooterRefresh.m
//  Demo
//
//  Created by Howe on 16/2/24.
//  Copyright © 2016年 Howe. All rights reserved.
//

#import "HWFooterRefresh.h"
#import "HWValue.h"
#import "HWRefreshKeyValue.h"

@interface HWFooterRefresh()

@property (nonatomic, copy) HWRefreshBlock hwFooterLoadBlock;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *loadView;

@property (nonatomic, strong) UILabel *loadLabel;

@property (nonatomic, strong) UIActivityIndicatorView *loadActView;

@property (nonatomic, assign) BOOL loadDataing;

@property (nonatomic, assign) BOOL isCanLoad;
@end


@implementation HWFooterRefresh

- (void)hw_addFooterRefreshWithView:(__kindof UIScrollView * _Nonnull)scrollView hw_footerRefreshBlock:(HWRefreshBlock _Nonnull)block
{
    if (![scrollView isKindOfClass:[UIScrollView class]])
    {
        NSLog(@"请检查添加了刷新控件的视图是否是一个滑动视图 View :%@",scrollView);
        self.isCanLoad = NO;
        return;
    }
    self.isCanLoad = YES;
    self.hwFooterLoadBlock = block;
    self.scrollView = scrollView;
    [self _checkSuperView];
}


- (UIView *)loadView
{
    if (_loadView == nil) {
        self.loadView = [[UIView alloc]init];
        [self.scrollView addSubview:_loadView];
        _loadView.backgroundColor = [UIColor grayColor];
    }
    return _loadView;
}

- (UILabel *)loadLabel
{
    if (_loadLabel == nil)
    {
        self.loadLabel = [[UILabel alloc]init];
        [self.loadView addSubview:_loadLabel];
    }
    return _loadLabel;
}

- (UIActivityIndicatorView *)loadActView
{
    if (_loadActView == nil)
    {
        self.loadActView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.loadView addSubview:_loadActView];
    }
    return _loadActView;
}




- (void)_checkSuperView
{
    if ([self.scrollView isKindOfClass:[UIScrollView class]])
    {
        [self _setup];
    }
}

- (void)_setup
{
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self _toNoneState];
}

/**
 *  到正在刷新状态
 */
- (void)_toRefreshState
{
    self.loadLabel.text = HWFooterRefreshViewWillRefreshText;
    if (!self.scrollView.dragging)
    {
        self.loadDataing = YES;
        
        self.loadActView.frame = CGRectMake(HWLoadActViewX, HWLoadActViewY, HWLoadActViewW, HWLoadActViewH);
                                            
        [UIView animateWithDuration:0.25f animations:^{
            [self.scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 40.0f, 0.0f)];
            self.loadLabel.text = HWFooterRefreshViewRefreshingText;

            [self.loadActView startAnimating];
            self.loadActView.hidden = NO;
            if (self.hwFooterLoadBlock)
            {
                self.hwFooterLoadBlock();
            }
        }];
    }
}


/**
 *  没有刷新状态
 */
- (void)_toNoneState{
    self.loadLabel.text = HWFooterRefreshViewNoneText;
    self.loadLabel.frame = CGRectMake(HWRefreshRefLabelX, HWRefreshRefLabelY, HWRefreshRefLabelW, HWRefreshRefLabelH);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (![keyPath isEqualToString:@"contentOffset"] && ![keyPath isEqualToString:@"contentSize"])
        return;
    
    if (self.loadDataing){
        return;
    }
    
    if ([keyPath isEqualToString:@"contentOffset"]){
        NSValue *offsetValue =  [change objectForKey:NSKeyValueChangeNewKey];
        CGPoint movePoint = [offsetValue CGPointValue];
        CGFloat moveH = movePoint.y +  CGRectGetHeight(self.scrollView.frame);
        CGFloat contentH = self.scrollView.contentSize.height;
        NSLog(@"moveH:%f,contentH:%f,boundsH:%f",moveH,contentH,CGRectGetHeight(self.scrollView.bounds));
    
        if (moveH >= (contentH + HWRefreshViewH) && contentH > CGRectGetHeight(self.scrollView.bounds)){
            [self _toRefreshState];
        }else{
            [self _toNoneState];
        }
        return;
    }
    
    NSValue *sizeValue =  [change objectForKey:NSKeyValueChangeNewKey];
    
    CGSize size = [sizeValue CGSizeValue];
    self.loadView.frame  = CGRectMake(0.0f,size.height, CGRectGetWidth(self.scrollView.bounds), HWHeadRefreshViewHeight);
    
    

}


- (void)hw_endRefreshState
{
    if (!self.isCanLoad) return;
    if (!self.loadDataing)
    {
        return;
    }
    [UIView animateWithDuration:0.25f animations:^{
        [self.scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        self.loadLabel.text = HWHeadRefreshViewNoneText;
        self.loadActView.hidden = YES;
        [self.loadActView stopAnimating];
        self.loadDataing = NO;
    }];
    
    
}

- (void)hw_toRfreshState
{
    if (!self.isCanLoad) return;
    if (self.loadDataing)
    {
        return;
    }
    self.loadActView.frame = CGRectMake(HWLoadActViewX, HWLoadActViewY, HWLoadActViewW, HWLoadActViewH);
    [self.scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 40.0f, 0.0f)];
    self.loadDataing = YES;
    self.loadLabel.text = HWFooterRefreshViewRefreshingText;
    [self.loadActView startAnimating];
    self.loadActView.hidden = NO;
    if (self.hwFooterLoadBlock)
    {
        self.hwFooterLoadBlock();
    }

}
@end
