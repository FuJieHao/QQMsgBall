//
//  ViewController.m
//  QQ消息小气泡
//
//  Created by Mac on 16/9/6.
//  Copyright © 2016年 haofujie. All rights reserved.
//

#import "ViewController.h"
#import "FJQQMessageView.h"

@interface ViewController ()

@end

/**
 * 今天说一下QQ消息小气泡这个东西，你有未读消息，出现小气泡，一拉一拽就没了。就是这个东西。
 
 * 说实话，好累好累，真的不准备写。可是每当想起毛爷爷教导我们的“好好学习，天天向上”，我只得咬紧牙关。每当想起周总理“为中华之崛起”的故事，由不得我放松啊。 好了，装出去的逼泼出去的水，要开始了。
 
 *  如果你们有看我昨天发的内容，一定会有所感悟，这种动画都是很相似的。
 
 *  再给你看一下这张图，我想你一定明白了什么。辣么，我还是要像你麻麻一样，絮絮叨叨的重复下思路。
    1.我有一个消息Label，当我没有未读的时候，label为nil，我不设置尺寸，当label有值我设置label，并在外面加了这层泡泡
    2.为什么能拖拽，而且拖拽一定距离你的原来位置的泡泡会变小然后变没，而你触摸处的泡泡还很大。因为：本身就有两个泡泡。
    3.起先他们厮混在一起，后来你一拖拽，另一个就走了，只留下一个泡泡独守闺房，落泪到天明，然后日渐消瘦（啊，我有点累，只能稍微扯点蛋提升兴趣。
    4.然后我通过图例中建立两圆之间耦合变量，再通过贝塞尔曲线绘制使得两圆之间一定关系。
    5.同样的，你要做到 牵一发而动全身，一个拖拽量位置的改变，要牵连所有的点的位置，进而形成预期的效果。
    6。辣么，可以开始了。
 */

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FJQQMessageView *cuteView = [[FJQQMessageView alloc]initWithPoint:CGPointMake(25, [UIScreen mainScreen].bounds.size.height - 65) superView:self.view];
    cuteView.viscosity  = 20;
    cuteView.bubbleWidth = 35;
    cuteView.bubbleColor = [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];
    [cuteView setupUI];
    
    cuteView.bubbleLabel.text = @"13";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
