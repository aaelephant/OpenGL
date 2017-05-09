//
//  ViewController.h
//  SQGL_lightDemo
//
//  Created by qbshen on 2017/4/26.
//  Copyright © 2017年 qbshen. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController

- (IBAction)takeShouldUseFaceNormalsFrom:(UISwitch *)sender;
- (IBAction)takeShouldDrawNormalsFrom:(UISwitch *)sender;
- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender;
@end

