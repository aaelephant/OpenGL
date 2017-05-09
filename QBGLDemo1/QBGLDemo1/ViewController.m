//
//  ViewController.m
//  QBGLDemo1
//
//  Created by qbshen on 2016/10/29.
//  Copyright © 2016年 qbshen. All rights reserved.
//

#import "ViewController.h"
#import "SQOpenGLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SQOpenGLView * sqGLV = [[SQOpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:sqGLV];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
