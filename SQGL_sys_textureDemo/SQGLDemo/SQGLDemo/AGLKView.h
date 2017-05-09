//
//  AGLKView.h
//  SQGLDemo
//
//  Created by qbshen on 17/3/13.
//  Copyright © 2017年 qbshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;
@protocol AGLKViewDelegate;

typedef enum{
    AGLKViewDrawableDepthFormatNone = 0,
    AGLKViewDrawableDepthFormat16,
    
} AGLKViewDrawableDepthFormat;

@interface AGLKView : UIView

{
    EAGLContext *context;
    GLuint      defaultFrameBuffer;
    GLuint      colorRenderBuffer;
    GLuint      depthRenderBuffer;
    GLuint      drawableWidth;
    GLuint      drawableHeight;
    
}

@property (nonatomic, weak) IBOutlet id <AGLKViewDelegate> delegate;

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, readonly) NSInteger drawableWidth;
@property (nonatomic, readonly) NSInteger drawableHeight;
@property (nonatomic) AGLKViewDrawableDepthFormat drawableDepthFormat;

-(void)display;

@end

#pragma mark - AGLKViewDelegate

@protocol AGLKViewDelegate <NSObject>

@required
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect;

@end
