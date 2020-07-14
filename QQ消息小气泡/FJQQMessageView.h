   //
//  FJQQMessageView.h
//  QQ消息小气泡
//
//  Created by Mac on 16/9/6.
//  Copyright © 2016年 haofujie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJQQMessageView : UIView

//容器view，装着这些东西
@property (nonatomic,strong) UIView *containerView;

//拖拽的圆，如果需要隐藏气泡的时候可以.hidden = YES
@property (nonatomic,strong) UIView *frontView;

@property (nonatomic,strong) UILabel *bubbleLabel;

//粘度系数
@property (nonatomic,assign) CGFloat viscosity;
//未读消息数
@property (nonatomic,assign) CGFloat bubbleWidth;
//气泡颜色
@property (nonatomic,strong) UIColor *bubbleColor;

- (instancetype)initWithPoint:(CGPoint)point superView:(UIView *)view;
- (void)setupUI;

@end
