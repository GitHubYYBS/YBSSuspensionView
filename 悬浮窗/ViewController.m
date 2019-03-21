//
//  ViewController.m
//  悬浮窗
//
//  Created by 严兵胜 on 2019/3/21.
//  Copyright © 2019 哆啦A咪的哆. All rights reserved.
//

#import "ViewController.h"

#import "YBSSuspensionView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YBSSuspensionView *suspensionView = [[YBSSuspensionView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    suspensionView.backgroundColor = [UIColor redColor];
    suspensionView.ybs_keepBounds = true;
    [self.view addSubview:suspensionView];
    suspensionView.clickSuspensionViewBlock = ^(YBSSuspensionView * _Nonnull suspensionView) {
        NSLog(@"______________ 点击了");
    };
}


@end
