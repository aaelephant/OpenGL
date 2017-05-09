//
//  ViewController.m
//  SQGL_custom_textureDemo
//
//  Created by qbshen on 2017/4/24.
//  Copyright © 2017年 qbshen. All rights reserved.
//

#import "ViewController.h"

typedef struct {
    GLKVector3 positionCoords;
    GLKVector3 normalCoords;
//    GLKVector4 textureCoords;
}SceneVertex;

static const SceneVertex vertices[]={
    {{0.0f, 0.0f, 0.5f}, {0.0f,0.0f,0.0f}},
    {{-0.5f, -0.5f, 0.0f},{0.2f,0.2f,0.2f}},// {1.0f,1.0f,0.5f,0.0f}
    {{0.5f, -0.5f, 0.0f}, {0.4f,0.4f,0.4f}},
    
    {{0.0f, 0.0f, 0.5f}, {0.0f,0.0f,0.0f}},
    {{0.5f, -0.5f, 0.0f}, {0.5f,0.5f,0.5f}},
    {{0.7f, 0.0f, 0.0f}, {0.6f,0.6f,0.6f}},
    
    {{0.0f, 0.0f, 0.5f}, {0.0f,0.0f,0.0f}},
    {{0.7f, 0.0f, 0.0f}, {0.7f,0.7f,0.7f}},
    {{0.5f,  0.5f, 0.0f}, {0.8f,0.8f,0.8f}},
    
    {{0.0f, 0.0f, 0.5f}, {0.0f,0.0f,0.0f}},
    {{0.5f,  0.5f, 0.0f}, {0.5f,0.5f,0.0f}},
    {{-0.5f,  0.5f, 0.0f}, {0.5f,0.5f,0.0f}},
    
    {{0.0f, 0.0f, 0.5f}, {0.0f,0.0f,0.0f}},
    {{-0.5f,  0.5f, 0.0f}, {0.2f,0.2f,0.5f}},
    {{-0.7f, 0.0f, 0.0f}, {0.3f,0.3f,0.5f}},
    
    {{0.0f, 0.0f, 0.5f}, {1.0f,1.0f,0.0f}},
    {{-0.5f, -0.5f, 0.0f}, {1.0f,1.0f,0.5f}},
    {{-0.7f, 0.0f, 0.0f}, {0.5f,0.5f,0.5f}},
};

@interface ViewController ()
{
    GLuint vertexBufferID;
//    GLfloat vertices[14];
    
//    GLfloat vertexColor[18];
}

@property (nonatomic, strong) GLKBaseEffect * baseEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCurContext];
    [self initBaseEffect];
    [self setupBackColor];
    [self genBuffers];
    [self createVertices];
    [self bindAndCopyBufferData];
}

-(void)createVertices
{
    GLfloat scale = -0.55f;
    
}

-(void)createCurContext
{
    GLKView *view = (GLKView*)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    //创建一个OpenGL3.0 的上下文context 并把这个上下文给当前的view
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    //把
    [EAGLContext setCurrentContext:view.context];
    
}

-(void)initBaseEffect
{
    if (!self.baseEffect) {
        self.baseEffect = [[GLKBaseEffect alloc] init];
        self.baseEffect.useConstantColor = GL_TRUE;
        self.baseEffect.constantColor = GLKVector4Make(
                                                       1.0f,
                                                       1.0f,
                                                       1.0f,
                                                       1.0f);
        self.baseEffect.light0.enabled = GL_TRUE;
        self.baseEffect.light0.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
        self.baseEffect.light0.position = GLKVector4Make(1.0f, 1.0f, 0.5f, 1.0f);
    }
}

-(void)setupBackColor
{
    glClearColor(0.1f, 0.5f, 0.6f, 1.0f);
}

-(void)genBuffers
{
    glGenBuffers(1, &vertexBufferID);
}

-(void)bindAndCopyBufferData
{
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER,
                 sizeof(vertices),
                 vertices,
                 GL_STATIC_DRAW);
}
#define BUFFER_OFFSET(i) ((char *)NULL + (i))
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVertex),
                          NULL+offsetof(SceneVertex, positionCoords));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL+offsetof(SceneVertex, normalCoords));
    
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    
//    glVertexAttribPointer(GLKVertexAttribColor,
//                          4,
//                          GL_FLOAT,
//                          GL_FALSE,
//                          sizeof(SceneVertex),
//                          NULL+offsetof(SceneVertex, textureCoords));

    [self drawDatas];
}

-(void)drawDatas
{
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertices)/6);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
