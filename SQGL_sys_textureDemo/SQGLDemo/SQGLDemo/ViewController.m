//
//  ViewController.m
//  SQGLDemo
//
//  Created by qbshen on 16/10/29.
//  Copyright © 2016年 qbshen. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVertex;

// Define vertex data for a triangle to use in example
static const SceneVertex vertices[]={
//    {{-0.5f, -0.5f, 0.0},{0.0f, 0.0f}},
//    {{0.5f, -0.5f, 0.0},{1.0f, 0.0f}},
//    {{-0.5f, 0.5f, 0.0},{0.0f, 1.0f}},
//    {{0.5f, 0.0f, 0.f}, {1.0f, 0.0f}},
//    {{-5.0f, 0.0f, 0.f}, {0.0f, 1.0f}},
//    {{0.5f, 0.0f, 0.f}, {1.0f, 1.0f}},
//    {{-0.5f, -0.5f, 0.0}}, // lower left corner左下角
//    {{ 0.5f, 0.5f, 0.0}}, // lower right corner右下角
//    {{-0.5f,  0.5f, 0.0}}  // upper left corner左上角
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // first triangle
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // second triangle
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};

@interface ViewController ()

{
    GLuint vertexBufferID;
    
}
@property (strong, nonatomic) GLKBaseEffect
*baseEffect;

@property (strong, nonatomic) GLKTextureInfo *textureInfo0;
@property (strong, nonatomic) GLKTextureInfo *textureInfo1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView * view = (GLKView*)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"view is not a GLKView");
    //创建一个openGL上下文，并把上下文提供给GLKView
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [EAGLContext setCurrentContext:view.context];
    
    //创建一个基本效果，它提供标准的OpenGL ES 2.0着色语言程序
    //并设置要用于所有后续渲染的常量
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    //三角形的颜色
    self.baseEffect.constantColor = GLKVector4Make(
        1.0f, //Red
        1.0f, //Green
        1.0f, //Blue
        1.0f);//Alpha
    
    //设置存储在当前上下文中的背景颜色
    glClearColor(0.1f, 0.5f, 0.6f, 1.0f);//背景色
    
    //生成，绑定和初始化缓冲区内容
    //以存储在GPU内存中
    glGenBuffers(1,
                 &vertexBufferID); // STEP 1 生成
    glBindBuffer(GL_ARRAY_BUFFER,
                 vertexBufferID);  // STEP 2 绑定
    
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER, // 初始化缓冲区
                 sizeof(vertices), // 要复制的字节数
                 vertices,          //要复制的字节地址
                 GL_STATIC_DRAW);   //提示：在GPU内存中缓存
    
//Setup texture0
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves_1.gif"] CGImage];
    GLKTextureInfo * textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0 options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                            [NSNumber numberWithBool:YES],
                                                                                            GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
//    self.textureInfo0 = textureInfo0;
    self.baseEffect.texture2d0.name = textureInfo0.name;
    self.baseEffect.texture2d0.target = textureInfo0.target;
    
    //Setup texture1
    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle.png"] CGImage];
    GLKTextureInfo * textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                            [NSNumber numberWithBool:YES],
                                                                                            GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
//    self.textureInfo1 = textureInfo1;
    self.baseEffect.texture2d1.name = textureInfo1.name;
    self.baseEffect.texture2d1.target = textureInfo1.target;
    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    // Enable fragment blending with Frame Buffer contents
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    
//    [self.baseEffect prepareForInterfaceBuilder];
    //清除帧缓冲区（删除上一个图形）
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER,
                 vertexBufferID);  // STEP 2 绑定
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER, // 初始化缓冲区
                 sizeof(vertices), // 要复制的字节数
                 vertices,          //要复制的字节地址
                 GL_STATIC_DRAW);   //提示：在GPU内存中缓存
    

    //允许使用来自绑定顶点缓冲区的位置
    glEnableVertexAttribArray(          // STEP 4
                              GLKVertexAttribPosition);
    
    glVertexAttribPointer(              // STEP 5
                          GLKVertexAttribPosition,
                          3,            //每个顶点三个分量
                          GL_FLOAT,     //数据是浮点数
                          GL_FALSE,     //无固定点缩放
                          sizeof(SceneVertex),//数据中没有间隙
                          NULL+offsetof(SceneVertex, positionCoords));          //NULL告诉GPU(OpenGL ES)可以从当前绑定的顶点缓存的开始位置访问顶点数据
    
    
    
    
    glBindBuffer(GL_ARRAY_BUFFER,
                 vertexBufferID);  // STEP 2 绑定
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER, // 初始化缓冲区
                 sizeof(vertices), // 要复制的字节数
                 vertices,          //要复制的字节地址
                 GL_STATIC_DRAW);   //提示：在GPU内存中缓存
    
    
    //允许使用来自绑定顶点缓冲区的位置
    glEnableVertexAttribArray(          // STEP 4
                              GLKVertexAttribTexCoord0);
    
    glVertexAttribPointer(              // STEP 5
                          GLKVertexAttribTexCoord0,
                          2,            //每个顶点三个分量
                          GL_FLOAT,     //数据是浮点数
                          GL_FALSE,     //无固定点缩放
                          sizeof(SceneVertex),//数据中没有间隙
                          NULL+offsetof(SceneVertex, textureCoords));          //NULL告诉GPU(OpenGL ES)可以从当前绑定的顶点缓存的开始位置访问顶点数据
    
    //允许使用来自绑定顶点缓冲区的位置
    glEnableVertexAttribArray(          // STEP 4
                              GLKVertexAttribTexCoord1);
    
    glVertexAttribPointer(              // STEP 5
                          GLKVertexAttribTexCoord1,
                          2,            //每个顶点三个分量
                          GL_FLOAT,     //数据是浮点数
                          GL_FALSE,     //无固定点缩放
                          sizeof(SceneVertex),//数据中没有间隙
                          NULL+offsetof(SceneVertex, textureCoords));          //NULL告诉GPU(OpenGL ES)可以从当前绑定的顶点缓存的开始位置访问顶点数据
    
//    self.baseEffect.texture2d0.name = self.textureInfo0.name;
//    self.baseEffect.texture2d0.target = self.textureInfo0.target;
    [self.baseEffect prepareToDraw];
    //使用当前绑定的顶点缓冲区中的前三个顶点绘制三角形
    glDrawArrays(GL_TRIANGLES,          //  STEP 6
                 0,           //从当前绑定缓冲区中的第一个顶点开始
                 sizeof(vertices));          //使用来自当前绑定缓冲区的三个顶点
    
    
    
//    self.baseEffect.texture2d0.name = self.textureInfo1.name;
//    self.baseEffect.texture2d0.target = self.textureInfo1.target;
//    [self.baseEffect prepareToDraw];
//    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertices));
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    GLKView * view = (GLKView*)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    if (0 != vertexBufferID) {
        glDeleteBuffers(1,
                        &vertexBufferID);
        vertexBufferID = 0;
        
    }
    
    ((GLKView*)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}


@end
