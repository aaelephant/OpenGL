//
//  SQOpenGLView.m
//  QBGLDemo1
//
//  Created by qbshen on 2016/10/29.
//  Copyright © 2016年 qbshen. All rights reserved.
//

#import "SQOpenGLView.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>


@interface SQOpenGLView ()

{
    CAEAGLLayer *eaglLayer;
    EAGLContext *context;
    GLuint colorRenderBuffer;
    GLuint depthRenderBuffer;
    GLuint framebuffer;
}


@end
@implementation SQOpenGLView

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(void)setup{
    
    //
    eaglLayer = (CAEAGLLayer *)self.layer;
    
    // 创建上下文
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // 设置它为当前上下文
    [EAGLContext setCurrentContext:context];
    
    // 创建渲染缓冲区
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    
    // 创建帧缓冲区
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    // 将渲染缓冲区和帧缓冲区关联
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
    
    // 将渲染缓冲区和layer关联在一起
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    
    // 检测帧对象是否创建成功
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
    
        
    // 清除颜色缓冲区
    glClearColor(1,1, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 将渲染缓冲区呈现出来
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self setup];
}

@end
