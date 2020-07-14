//
//  FJQQMessageView.m
//  QQ消息小气泡
//
//  Created by Mac on 16/9/6.
//  Copyright © 2016年 haofujie. All rights reserved.
//

#import "FJQQMessageView.h"

@implementation FJQQMessageView
{
    /**
     *  图层的添加
        这里说一下CAShapeLayer，一般在开发的时候，我们用CALayer比较多，ShapeLayer是他的子类，比起父类更加的灵活，
        shape：形状，更偏重于复杂的形状效果，比如尖角遮罩这类的绘制
        有三个比较重要的点:
         1. 它依附于一个给定的path,必须给与path,而且,即使path不完整也会自动首尾相接
         2. strokeStart以及strokeEnd代表着在这个path中所占用的百分比
         3. CAShapeLayer动画仅仅限于沿着边缘的动画效果,它实现不了填充效果
     
        也正因为这样，所以我要单独设置一个衔接处的填充颜色
     */
    CAShapeLayer *shapeLayer;
    UIBezierPath * cutePath;
    
    //通过观察那张图，所以你要知道我们需要哪些变量
    
    //坐标系上的点
    CGFloat x1,x2,y1,y2;
    //两个圆心
    CGFloat r1,r2;
    
    //两个圆径上的点以及牵连处的两个点
    CGPoint pointA,pointB,pointC,pointD;
    CGPoint pointO,pointP;
    
    //圆心距
    CGFloat centerDistance;
    
    //夹角
    CGFloat cosThite;
    CGFloat sinTHite;
    
    //两个圆所在View;
    UIView *backView;
    
    //初始化要出现的位置
    CGPoint initialPoint;
    
    //暂时先这么多，后面还会继续补齐
    
    //记录之前的位置,以及中心点
    CGRect oldBackViewFrame;
    CGPoint oldBackViewCenter;
    
    //在这里要设置一个连接填充颜色，否则是黑色的
    UIColor *fillColorForCute;
}

//声明一个初始化小球的方法
- (instancetype)initWithPoint:(CGPoint)point superView:(UIView *)view
{
    self = [super initWithFrame:CGRectMake(point.x, point.y, self.bubbleWidth, self.bubbleWidth)];
    if (self) {
        
        //指定初始化气泡所在的位置
        initialPoint = point;
        self.containerView = view;
        [self.containerView addSubview:self];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)drawRect
{
    x1 = backView.center.x;
    y1 = backView.center.y;
    
    x2 = self.frontView.center.x;
    y2 = self.frontView.center.y;
    
    //圆心距的计算
    centerDistance = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    //如果圆心距为0，两圆重叠的时候
    if (centerDistance == 0) {
        //thite为0度
        cosThite = 1;
        sinTHite = 0;
    } else {
        cosThite = (y2 - y1) / centerDistance;
        sinTHite = (x2 - x1) / centerDistance;
    }
    
    //backView的半径是一个变小的过程,因为在下面已经写过，如果在r1的半径小于某值的时候，我就断开连接
    //并且我不能直接这样算r1 = oldBackViewFrame.size.width / 2 - centerDistance，因为这样的话，圆心距默认就在12.5左右，初始的半径是17.5，就已经不能显示了，更不用说圆心距增大了。所以我需要引进一个变量，让圆心距除以它变小，同时如果这个值够大的话，我的r1变小的过程就会缓慢，那么拉动的距离就能变远。所以，我称我引入的变量为粘度系数，系数越大，粘性越大，拖动距离就越大。
    r1 = oldBackViewFrame.size.width / 2 - centerDistance / self.viscosity;
    
    //通过数学的运算确定ABCDOP的位置
    pointA = CGPointMake(x1 - r1 * cosThite, y1 + r1 * sinTHite);
    pointB = CGPointMake(x1 + r1 * cosThite, y1 - r1 * sinTHite);
    pointD = CGPointMake(x2 - r2 * cosThite, y2 + r2 * sinTHite);
    pointC = CGPointMake(x2 + r2 * cosThite, y2 - r2 * sinTHite);
    
    pointO = CGPointMake(pointA.x + (centerDistance / 2) * sinTHite , pointA.y +
                         centerDistance / 2 * cosThite);
    pointP = CGPointMake(pointB.x + (centerDistance / 2) * sinTHite , pointB.y +
                         centerDistance / 2 * cosThite);
    
    backView.center = oldBackViewCenter;
    backView.bounds = CGRectMake(0, 0, r1 * 2, r1 * 2);
    backView.layer.cornerRadius = r1;
    
    //在这里要通过贝塞尔曲线连接两个圆,定义这个属性cutePath
    cutePath = [UIBezierPath bezierPath];
    [cutePath moveToPoint:pointA];
    //- (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint,这个方法是绘制二元曲线用的，
    //参数1：曲线的终点   参数2：曲线的基准点，看图可知，这样我就可以 A O D之间连接一条平滑的曲线
    [cutePath addQuadCurveToPoint:pointD controlPoint:pointO];
    [cutePath addLineToPoint:pointC];
    [cutePath addQuadCurveToPoint:pointB controlPoint:pointP];
    [cutePath moveToPoint:pointA];
    //到上面位置，我已经连接好各个点
    
    //如果back是显示的
    if (backView.hidden == NO) {
        shapeLayer.path = cutePath.CGPath;
        
        //设置图层填充颜色
        shapeLayer.fillColor = fillColorForCute.CGColor;
        
        //在这里我把shapelayer的图层插入在frontLayer的下面(因为shapeLayer大)
        [self.containerView.layer insertSublayer:shapeLayer below:self.frontView.layer];
    }
    
}

- (void)setupUI
{
    //初始化一下图层
    shapeLayer = [CAShapeLayer layer];
    
    self.backgroundColor = [UIColor purpleColor];
    
    self.frontView = [[UIView alloc]initWithFrame:CGRectMake(initialPoint.x, initialPoint.y, _bubbleWidth, _bubbleWidth)];
    self.frontView.backgroundColor = [UIColor blackColor];
    
    r2 = self.frontView.bounds.size.width / 2;
    self.frontView.layer.cornerRadius = r2;
    self.frontView.backgroundColor = self.bubbleColor;
    
    backView = [[UIView alloc]initWithFrame:self.frontView.frame];
    r1 = backView.bounds.size.width / 2;
    backView.layer.cornerRadius = r1;
    backView.backgroundColor = self.bubbleColor;
    
    //气泡消息数的设置
    self.bubbleLabel = [[UILabel alloc]init];
    self.bubbleLabel.frame = CGRectMake(0, 0, self.frontView.bounds.size.width, self.frontView.bounds.size.height);
    self.bubbleLabel.textColor = [UIColor whiteColor];
    self.bubbleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.frontView insertSubview:self.bubbleLabel atIndex:0];
    
    //添加两个圆
    [self.containerView addSubview:backView];
    [self.containerView addSubview:self.frontView];
    
    x1 = backView.center.x;
    y1 = backView.center.y;
    x2 = self.frontView.center.x;
    y2 = self.frontView.center.y;
    
    pointA = CGPointMake(x1 - r1, y1);
    pointB = CGPointMake(x1 + r1, y1);
    pointD = CGPointMake(x2 - r2, y2);
    pointC = CGPointMake(x2 + r2, y2);
    pointO = CGPointMake(x1 - r1, y1);
    pointP = CGPointMake(x2 + r2, y2);
    
    oldBackViewFrame  = backView.frame;
    oldBackViewCenter = backView.center;
    
    //如果你观察过我添加的顺序，就会发现我的backView是添加在frontView上的，那么刚开始的时候，因为我是要拖动frontVeiw，所以在
    //这里我就隐藏了backView(还有就是，我要给球球(frontView)添加一个浮游效果)
    backView.hidden = YES;
    //初始化的时候添加浮游效果
    [self addAniamtionLikeGameCenterBubble];
    
    
    //添加个拖拽的手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleDragGesture:)];
    [self.frontView addGestureRecognizer:pan];
}

- (void)handleDragGesture:(UIPanGestureRecognizer *)sender
{
    CGPoint dragPoint = [sender locationInView:self.containerView];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        fillColorForCute = self.bubbleColor;
        //一旦我开始拖动，就不再隐藏back
        backView.hidden = NO;
        [self RemoveAniamtionLikeGameCenterBubble];
        
    } else if (sender.state == UIGestureRecognizerStateChanged)
    {
        //在这里我把拖动到的位置赋值给frontView
        self.frontView.center = dragPoint;
        
        //在这里要做一个判断，就是什么时候我的两个圆是藕断丝连的，什么时候是断开的
        if (r1 <= 6) {
            //隐藏back
            backView.hidden = YES;
            
            //如果小,没必要再显示连接的填充颜色
            fillColorForCute = [UIColor clearColor];
            
            //如果是小的话，我需要移除掉之前的Layer,显示断开连接
            [shapeLayer removeFromSuperlayer];
        }
        //重绘一下
        [self drawRect];
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled) {
        //拖拽结束以后，backView显示出来
        backView.hidden = YES;
        
        //移除图层,因为我回弹的时候，是没有连接效果，快速回弹回去的
        [shapeLayer removeFromSuperlayer];
        
        //如果拖拽完毕的话,我也没必要再显示填充颜色
        fillColorForCute = [UIColor clearColor];
        
        //做一下那个球球弹回去的效果
        
        /**
         在这里说明一下这个方法和别的不同之处：这个是ios7之后苹果官方一直在用的一个动画，就是一个减速运动，
         相比与匀速运动而言，可以给用户一种快速、干净的感觉。苹果也在IOS8开放了这个API，从运动的曲线来说，我们可以把速度设置为一个对数函数来模拟这个效果。
         参数上的说明：usingSpringWithDamping[0.0~1.0]之间，数值越小的话，弹簧的震动效果越明显，可以从图例中看出
                     initialSpringVelocity 这个参数描述的就是初速度v0；
         另外要说明的是，这个动画光能用于位置上的移动，还适用于所有被添加动画效果的属性
         */
        [UIView animateWithDuration:.5 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            //你要回去的话，就要记录一下之前的位置，所以在这里我们加一个属性
            self.frontView.center = oldBackViewCenter;
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                
                 //在回去的时候，我重新添加上浮游效果
                [self addAniamtionLikeGameCenterBubble];
            }
        }];
    }
}

/**
 *  浮游效果
 */
//这个效果QQ消息是没有的，纯属赠品啦，哈哈，其实GAMECENTER里面是有这个效果的，也很好看，就写一下
- (void)addAniamtionLikeGameCenterBubble
{
    
    /**
     *  这里说明一下BaseAnimation 和 KeyframeAnimation的区别
        先引入一下动画的概念：任何动画要表现出运动或者变化,至少需要两个不同的关键状态,而中间的状态的变化可以通过插值计算完成,从而形成补间动画,表示关键状态的帧叫做关键帧.
     
        CABasicAnimation其实可以看作一种特殊的关键帧动画,只有头尾两个关键
        CAKeyframeAnimation则可以支持任意多个关键帧
     */
    
    //创建动画对象，设置成为根据position改变型
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //设置帧的计算模式,calculationMode,计算模式.其主要针对的是每一帧的内容为一个座标点的情况,也就是对anchorPoint 和 position 进行的动画.
    /**
     介绍一下计算的模式的五个属性
     kCAAnimationLinear calculationMode的默认值,表示当关键帧为坐标点的时候,关键帧之间直接直线相连进行插值计算;
     
     kCAAnimationDiscrete 离散的,就是不进行插值计算,所有关键帧直接逐个进行显示;
     
     kCAAnimationPaced 使得动画均匀进行,而不是按keyTimes设置的或者按关键帧平分时间,此时keyTimes和timingFunctions无效;
     
     kCAAnimationCubic 对关键帧为座标点的关键帧进行圆滑曲线相连后插值计算,主要目的是使得运行的轨迹变得圆滑;
     
     kCAAnimationCubicPaced在kCAAnimationCubic的基础上使得动画运行变得均匀,就是系统时间内运动的距离相同,此时keyTimes以及timingFunctions也是无效的.
     */
    pathAnimation.calculationMode = kCAAnimationPaced;
    
    
    //然后设置一下fillMode 它决定了当前对象在非执行活动时间段的行为，就是没事干的时候做的事
    /**
     同样的，在这里，介绍一下它的四个属性
     kCAFillModeRemoved 这个是默认值,也就是说当动画开始前和动画结束后,动画对layer都没有影响,动画结束后,layer会恢复到之前的状态。
     
     kCAFillModeForwards 当动画结束后,layer会一直保持着动画最后的状态.
     
     kCAFillModeBackwards 在动画开始前,你只要将动画加入了一个layer,layer便立即进入动画的初始状态并等待动画开始. 你可以这样设定测试代码,将一个动画加入一个layer的时候延迟5秒执行.然后就会发现在动画没有开始的时候,只要动画被加入了layer,layer便处于动画初始状态
     
     kCAFillModeBoth 这个其实就是上面两个的合成.动画加入后开始之前,layer便处于动画初始状态,动画结束后layer保持动画最后的状态

     */
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    //👆这两个属性是一套的，设置完成后，当你动画执行完成后，还是显示在动画开始之前，你运动的位置，这个具体的介绍可以看我的截图
    
    pathAnimation.duration = 5.0;
    
    //绘制浮游路径
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    
    //设定浮游范围
    CGRect circleContainer = CGRectInset(self.frontView.frame, self.frontView.bounds.size.width / 2 - 3, self.frontView.bounds.size.width / 2 - 3);
    
    //添加路径
    CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
    
    pathAnimation.path = curvedPath;
    //释放路径
    CGPathRelease(curvedPath);
    
    //在frontView的图层添加浮游路径
    [self.frontView.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
    
    //在浮游的同时对圆做稍微的变形(x方向)
    CAKeyframeAnimation *scaleX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleX.duration = 1.0;
    //变化的大小,指定三个关键尺寸
    scaleX.values = @[@1.0, @1.1, @1.0];
    //在指定的时间点进行变化（都是比例制的）
    scaleX.keyTimes = @[@0.0, @0.5, @1.0];
    //设定重复次数
    scaleX.repeatCount = INFINITY;
    //如果设置YES，代表每次执行的动画会跟上一次的相反
    scaleX.autoreverses = YES;
    //设置变化类型
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//两边慢，中间快
    [self.frontView.layer addAnimation:scaleX forKey:@"scaleXAnimation"];
    
    //同理，对y方向进行变化
    CAKeyframeAnimation *scaleY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleY.duration = 1.5;
    scaleY.values = @[@1.0, @1.1, @1.0];
    scaleY.keyTimes = @[@0.0, @0.5, @1.0];
    scaleY.repeatCount = INFINITY;
    scaleY.autoreverses = YES;
    
    scaleY.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.frontView.layer addAnimation:scaleY forKey:@"scaleYAnimation"];
}

/**
 *  关闭浮游效果
 */
- (void)RemoveAniamtionLikeGameCenterBubble
{
    //把浮游效果(图层）从frontView移除就好
    [self.frontView.layer removeAllAnimations];
}

@end





















