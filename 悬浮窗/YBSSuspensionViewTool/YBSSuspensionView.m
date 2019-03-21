//
//  YBSSuspensionView.m
//  悬浮窗
//
//  Created by 严兵胜 on 2019/3/21.
//  Copyright © 2019 哆啦A咪的哆. All rights reserved.
//

#import "YBSSuspensionView.h"

@interface YBSSuspensionView ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *ybs_contentView;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGFloat previousScale;
@end

@implementation YBSSuspensionView

-(UIImageView *)ybs_imageView{
    if (_ybs_imageView == nil) {
        _ybs_imageView = [[UIImageView alloc]init];
        _ybs_imageView.userInteractionEnabled = YES;
        _ybs_imageView.clipsToBounds = YES;
        [self.ybs_contentView addSubview:_ybs_imageView];
    }
    return _ybs_imageView;
}
-(UIButton *)ybs_button{
    if (_ybs_button == nil) {
        _ybs_button = [UIButton buttonWithType:UIButtonTypeCustom];
        _ybs_button.clipsToBounds = YES;
        _ybs_button.userInteractionEnabled = NO;
        [self.ybs_contentView addSubview:_ybs_button];
    }
    return _ybs_button;
}
-(UIView *)ybs_contentView{
    if (_ybs_contentView == nil) {
        _ybs_contentView = [[UIView alloc]init];
        _ybs_contentView.clipsToBounds = YES;
        [self addSubview:_ybs_contentView];
    }
    return _ybs_contentView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) [self setUp];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) [self setUp];
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.ybs_freeRect.origin.x != 0 || self.ybs_freeRect.origin.y != 0 || self.ybs_freeRect.size.height != 0 || self.ybs_freeRect.size.width != 0) {
        //设置了ybs_freeRect--活动范围
    }else{
        //没有设置ybs_freeRect--活动范围，则设置默认的活动范围为父视图的frame
        self.ybs_freeRect = (CGRect){CGPointZero,self.superview.bounds.size};
    }
    _ybs_imageView.frame = (CGRect){CGPointZero,self.bounds.size};
    _ybs_button.frame = (CGRect){CGPointZero,self.bounds.size};
    self.ybs_contentView.frame =  (CGRect){CGPointZero,self.bounds.size};
}

- (void)setUp{
    self.ybs_dragEnable = YES;//默认可以拖曳
    self.clipsToBounds = YES;
    self.ybs_keepBounds = NO;
    self.backgroundColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDragView)];
    [self addGestureRecognizer:singleTap];
    
    //添加移动手势可以拖动
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
}

/**
 拖动事件
 @param pan 拖动手势
 */
-(void)dragAction:(UIPanGestureRecognizer *)pan{
    
    if(self.isybs_dragEnable == NO)return;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{//开始拖动
            if (self.beginDragBlock) self.beginDragBlock(self);
            //注意完成移动后，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            //保存触摸起始点位置
            self.startPoint = [pan translationInView:self];
            break;
        }
        case UIGestureRecognizerStateChanged:{//拖动中
            //计算位移 = 当前位置 - 起始位置
            if (self.duringDragBlock) self.duringDragBlock(self);
            
            CGPoint point = [pan translationInView:self];
            float dx;
            float dy;
            switch (self.ybs_dragDirection) {
                case YBSSuspensionViewDirectionAny:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
                case YBSSuspensionViewDirectionHorizontal:
                    dx = point.x - self.startPoint.x;
                    dy = 0;
                    break;
                case YBSSuspensionViewDirectionVertical:
                    dx = 0;
                    dy = point.y - self.startPoint.y;
                    break;
                default:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
            }
            
            //计算移动后的view中心点
            CGPoint newCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            //移动view
            self.center = newCenter;
            //  注意完成上述移动后，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            break;
        }
        case UIGestureRecognizerStateEnded:{//拖动结束
            [self keepBounds];
            if (self.endDragBlock)  self.endDragBlock(self);
            break;
        }
        default:
            break;
    }
}

/// 点击事件
- (void)clickDragView{
    if (self.clickSuspensionViewBlock) self.clickSuspensionViewBlock(self);
}

//黏贴边界效果
- (void)keepBounds{
    //中心点判断
    float centerX = self.ybs_freeRect.origin.x + (self.ybs_freeRect.size.width - self.frame.size.width) / 2;
    CGRect rect = self.frame;
    if (self.isybs_keepBounds == NO) {//没有黏贴边界的效果
        if (self.frame.origin.x < self.ybs_freeRect.origin.x) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.ybs_freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else if(self.ybs_freeRect.origin.x + self.ybs_freeRect.size.width < self.frame.origin.x + self.frame.size.width){
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.ybs_freeRect.origin.x + self.ybs_freeRect.size.width - self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }else if(self.isybs_keepBounds == YES){ //自动粘边
        if (self.frame.origin.x < centerX) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.ybs_freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.ybs_freeRect.origin.x + self.ybs_freeRect.size.width - self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }
    
    if (self.frame.origin.y < self.ybs_freeRect.origin.y) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"topMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.ybs_freeRect.origin.y;
        self.frame = rect;
        [UIView commitAnimations];
    } else if(self.ybs_freeRect.origin.y + self.ybs_freeRect.size.height< self.frame.origin.y + self.frame.size.height){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"bottomMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.ybs_freeRect.origin.y+self.ybs_freeRect.size.height - self.frame.size.height;
        self.frame = rect;
        [UIView commitAnimations];
    }
}





@end
