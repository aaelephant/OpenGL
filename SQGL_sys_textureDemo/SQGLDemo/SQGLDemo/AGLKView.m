//
//  AGLKView.m
//  SQGLDemo
//
//  Created by qbshen on 17/3/13.
//  Copyright © 2017年 qbshen. All rights reserved.
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AGLKView
@synthesize delegate;
@synthesize context;
@synthesize drawableDepthFormat;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

-(id)initWithFrame:(CGRect)frame context:(EAGLContext *)aContext;
{
    if ((self = [super initWithFrame:frame])) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.drawableProperties =
        [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
         kEAGLDrawablePropertyRetainedBacking,
         kEAGLColorFormatRGBA8,
         kEAGLDrawablePropertyColorFormat,
         nil];
        
        self.context = aContext;
    }
    return self;
}


- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.drawableProperties =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:NO],
         kEAGLDrawablePropertyRetainedBacking,
         kEAGLColorFormatRGBA8,
         kEAGLDrawablePropertyColorFormat,
         nil];
    }
    
    return self;
}

- (void)setContext:(EAGLContext *)aContext
{
    if (context != aContext) {
        [EAGLContext setCurrentContext:context];
        if (0 != defaultFrameBuffer) {
            glDeleteBuffers(1, &defaultFrameBuffer);
            defaultFrameBuffer = 0;
        }
        
        if (0 != colorRenderBuffer) {
            glDeleteRenderbuffers(1, &colorRenderBuffer);
            colorRenderBuffer = 0;
        }
        
        if (0 != depthRenderBuffer) {
            glDeleteRenderbuffers(1, &depthRenderBuffer);
            depthRenderBuffer = 0;
        }
        
        context = aContext;
        
        if (nil != context) {
            context = aContext;
            [EAGLContext setCurrentContext:context];
            
            glGenFramebuffers(1, &defaultFrameBuffer);
            glBindRenderbuffer(
                               GL_RENDERBUFFER,
                               colorRenderBuffer);
            
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
            
            [self layoutSubviews];
        }
    }
}

- (EAGLContext *)context
{
    return context;
}

-(void)display
{
    [EAGLContext setCurrentContext:self.context];
    glViewport(0, 0, (GLint)self.drawableWidth, (GLint)self.drawableHeight);
    
    [self drawRect:[self bounds]];
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)drawRect:(CGRect)rect
{
    if (delegate) {
        [self.delegate glkView:self drawInRect:[self bounds]];
    }
}

-(void)layoutSubviews
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    [EAGLContext setCurrentContext:self.context];
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    
    if (0 != depthRenderBuffer) {
        glDeleteRenderbuffers(1, &depthRenderBuffer);
        depthRenderBuffer = 0;
    }
    
    GLint currentDrawableWidth = (GLint)self.drawableWidth;
    GLint currentDrawableHeight = (GLint)self.drawableHeight;
    
    if (self.drawableDepthFormat !=
        AGLKViewDrawableDepthFormatNone &&
        0 < currentDrawableWidth &&
        0 < currentDrawableHeight) {
        glGenRenderbuffers(1, &depthRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, currentDrawableWidth, currentDrawableHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
    }
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete frame buffer object %x", status);
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
}

/////////////////////////////////////////////////////////////////
// This method returns the width in pixels of current context's
// Pixel Color Render Buffer
- (NSInteger)drawableWidth;
{
    GLint          backingWidth;
    
    glGetRenderbufferParameteriv(
                                 GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_WIDTH,
                                 &backingWidth);
    
    return (NSInteger)backingWidth;
}


/////////////////////////////////////////////////////////////////
// This method returns the height in pixels of current context's
// Pixel Color Render Buffer
- (NSInteger)drawableHeight;
{
    GLint          backingHeight;
    
    glGetRenderbufferParameteriv(
                                 GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_HEIGHT,
                                 &backingHeight);
    
    return (NSInteger)backingHeight;
}


/////////////////////////////////////////////////////////////////
// This method is called automatically when the reference count
// for a Cocoa Touch object reaches zero.
- (void)dealloc
{
    // Make sure the receiver's OpenGL ES Context is not current
    if ([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    
    // Deletes the receiver's OpenGL ES Context
    context = nil;
}
@end
