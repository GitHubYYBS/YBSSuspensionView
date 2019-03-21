//
//  YBSSuspensionView.h
//  悬浮窗
//
//  Created by 严兵胜 on 2019/3/21.
//  Copyright © 2019 哆啦A咪的哆. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/// 拖曳view的方向
typedef NS_ENUM(NSInteger, YBSSuspensionViewDirection) {
    
    YBSSuspensionViewDirectionAny,          /**< 任意方向 */
    YBSSuspensionViewDirectionHorizontal,   /**< 水平方向 */
    YBSSuspensionViewDirectionVertical,     /**< 垂直方向 */
};


@interface YBSSuspensionView : UIView

/// 是不是能拖曳，默认为YES YES，能拖曳 NO，不能拖曳
@property (nonatomic, assign,getter=isybs_dragEnable) BOOL ybs_dragEnable;

/**
 活动范围，默认为父视图的frame范围内（因为拖出父视图后无法点击，也没意义）
 如果设置了，则会在给定的范围内活动
 如果没设置，则会在父视图范围内活动
 注意：设置的frame不要大于父视图范围
 注意：设置的frame为0，0，0，0表示活动的范围为默认的父视图frame，如果想要不能活动，请设置ybs_freeRect这个属性为NO
 */
@property (nonatomic, assign,getter=isybs_freeRect) CGRect ybs_freeRect;

/// 拖曳的方向，默认为any，任意方向
@property (nonatomic, assign) YBSSuspensionViewDirection ybs_dragDirection;

/**
 contentView内部懒加载的一个UIImageView
 开发者也可以自定义控件添加到本view中
 注意：最好不要同时使用内部的imageView和button
 */
@property (nonatomic, strong) UIImageView *ybs_imageView;
/**
 contentView内部懒加载的一个UIButton
 开发者也可以自定义控件添加到本view中
 注意：最好不要同时使用内部的imageView和button
 */
@property (nonatomic,strong) UIButton *ybs_button;
/**
 是不是总保持在父视图边界，默认为NO,没有黏贴边界效果
 ybs_keepBounds = YES，它将自动黏贴边界，而且是最近的边界
 ybs_keepBounds = NO， 它将不会黏贴在边界，它是free(自由)状态，跟随手指到任意位置，但是也不可以拖出给定的范围frame
 */
@property (nonatomic,assign,getter=isybs_keepBounds) BOOL ybs_keepBounds;



/// 点击的回调block
@property (nonatomic,copy) void(^clickSuspensionViewBlock)(YBSSuspensionView *suspensionView);
/// 开始拖动的回调block
@property (nonatomic,copy) void(^beginDragBlock)(YBSSuspensionView *suspensionView);
/// 拖动中的回调block
@property (nonatomic,copy) void(^duringDragBlock)(YBSSuspensionView *suspensionView);
/// 结束拖动的回调block
@property (nonatomic,copy) void(^endDragBlock)(YBSSuspensionView *suspensionView);

@end

NS_ASSUME_NONNULL_END
