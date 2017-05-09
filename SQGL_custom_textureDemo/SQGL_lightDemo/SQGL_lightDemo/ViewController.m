//
//  ViewController.m
//  SQGL_lightDemo
//
//  Created by qbshen on 2017/4/26.
//  Copyright © 2017年 qbshen. All rights reserved.
//

#import "ViewController.h"

//for store each vertex
typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
}
SceneVertex;

//for store triangles
typedef struct {
    SceneVertex vertices[3];
}
SceneTriangle;

/////////////////////////////////////////////////////////////////
// The scene to be rendered is composed of 8 triangles. There are
// 4 triangles in the pyramid itself and othe 4 horizontal
// triangles represent a base for teh pyramid.
#define NUM_FACES (8)

/////////////////////////////////////////////////////////////////
// 48 vertices are needed to draw all of the normal vectors:
//    8 triangles * 3 vertices per triangle = 24 vertices
//    24 vertices * 1 normal vector per vertex * 2 vertices to
//       draw each normal vector = 48 vertices
#define NUM_NORMAL_LINE_VERTS (48)

/////////////////////////////////////////////////////////////////
// 50 vertices are needed to draw all of the normal vectors
// and the light direction vector:
//    8 triangles * 3 vertices per triangle = 24 vertices
//    24 vertices * 1 normal vector per vertex * 2 vertices to
//       draw each normal vector = 48 vertices
//    plus 2 vertices to draw the light direction = 50
#define NUM_LINE_VERTS (NUM_NORMAL_LINE_VERTS + 2)


//postion and normal for each vertex
static const SceneVertex vertexA =
{{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexB =
{{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexC =
{{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexD =
{{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexE =
{{ 0.0,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexF =
{{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexG =
{{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexH =
{{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexI =
{{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

static SceneTriangle SceneTriangleMake(const SceneVertex vertexA, const SceneVertex vertexB, const SceneVertex vertexC);
static void SceneTrianglesUpdateVertexNormals(
                                              SceneTriangle someTriangles[NUM_FACES]);

static GLKVector3 SceneTriangleFaceNormal(
                                          const SceneTriangle triangle);
GLKVector3 SceneVector3UnitNormal(
                                  const GLKVector3 vectorA,
                                  const GLKVector3 vectorB);
static void SceneTrianglesUpdateFaceNormals(
                                            SceneTriangle someTriangles[NUM_FACES]);
@interface ViewController ()
{
    GLuint name;
    GLuint nameextra;
    SceneTriangle triangles[NUM_FACES];
    
}
@property (strong, nonatomic) GLKBaseEffect
*baseEffect;
@property (strong, nonatomic) GLKBaseEffect
*extraEffect;

@property (nonatomic) GLfloat
centerVertexHeight;
@property (nonatomic) BOOL
shouldUseFaceNormals;
@property (nonatomic) BOOL
shouldDrawNormals;

@end

@implementation ViewController

@synthesize baseEffect;
@synthesize extraEffect;
@synthesize centerVertexHeight;
@synthesize shouldUseFaceNormals;
@synthesize shouldDrawNormals;


- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         0.7f, 0.7f, 0.7f, 1.0f);
    self.baseEffect.light0.position = GLKVector4Make(
                                                     1.0f,
                                                     1.0f,
                                                     0.5f,
                                                     0.0f);
    
    self.extraEffect = [[GLKBaseEffect alloc] init];
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor = GLKVector4Make(
                                                    0.0f, // Red 
                                                    1.0f, // Green 
                                                    0.0f, // Blue 
                                                    1.0f);// Alpha
    {  // Comment out this block to render the scene top down
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(
                                                            GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
        modelViewMatrix = GLKMatrix4Rotate(
                                           modelViewMatrix,
                                           GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
        modelViewMatrix = GLKMatrix4Translate(
                                              modelViewMatrix,
                                              0.0f, 0.0f, 0.25f);
        
        self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
        self.extraEffect.transform.modelviewMatrix = modelViewMatrix;
    }
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    glGenBuffers(1, &name);
    glBindBuffer(GL_ARRAY_BUFFER, name);
    glBufferData(GL_ARRAY_BUFFER, sizeof(triangles),  triangles, GL_DYNAMIC_DRAW);
    
    
    glGenBuffers(1,                // STEP 1
                 &nameextra);
    glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                 nameextra);
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER,  // Initialize buffer contents
                 0,  // Number of bytes to copy
                 NULL,          // Address of bytes to copy
                 GL_DYNAMIC_DRAW);
    
    self.centerVertexHeight = 0.0f;
    self.shouldUseFaceNormals = YES;
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Clear back frame buffer (erase previous drawing)
    glClear(GL_COLOR_BUFFER_BIT);
    
//    glBindBuffer(GL_ARRAY_BUFFER,     // STEP 2
//                 name);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glVertexAttribPointer(            // Step 5
                          GLKVertexAttribPosition,               // Identifies the attribute to use
                          3,               // number of coordinates for attribute
                          GL_FLOAT,            // data is floating point
                          GL_FALSE,            // no fixed point scaling
                          sizeof(SceneVertex),         // total num bytes stored per vertex
                          NULL+offsetof(SceneVertex, position));
    
    glBindBuffer(GL_ARRAY_BUFFER,     // STEP 2
                 name);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    
    glVertexAttribPointer(            // Step 5
                          GLKVertexAttribNormal,               // Identifies the attribute to use
                          3,               // number of coordinates for attribute
                          GL_FLOAT,            // data is floating point
                          GL_FALSE,            // no fixed point scaling
                          sizeof(SceneVertex),         // total num bytes stored per vertex
                          NULL+offsetof(SceneVertex, normal));
    
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sizeof(triangles) / sizeof(SceneVertex));
        // Draw triangles using vertices in the currently bound vertex
    // buffer
    
    if(self.shouldDrawNormals)
    {
        [self drawNormals];
    }
}

/////////////////////////////////////////////////////////////////
// This method draws lines to represent the normal vectors and
// light direction
- (void)drawNormals
{
    GLKVector3  normalLineVertices[NUM_LINE_VERTS];
    
    // calculate all 50 vertices based on 8 triangles
    SceneTrianglesNormalLinesUpdate(triangles,
                                    GLKVector3MakeWithArray(self.baseEffect.light0.position.v),
                                    normalLineVertices);
    
    glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                 nameextra);
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER,  // Initialize buffer contents
                 NUM_LINE_VERTS*sizeof(GLKVector3),  // Number of bytes to copy
                 normalLineVertices,          // Address of bytes to copy
                 GL_DYNAMIC_DRAW);
    
//    glBindBuffer(GL_ARRAY_BUFFER,     // STEP 2
//                 nameextra);
    
    glEnableVertexAttribArray(     // Step 4
                                  GLKVertexAttribPosition);
    
    glVertexAttribPointer(            // Step 5
                          GLKVertexAttribPosition,               // Identifies the attribute to use
                          3,               // number of coordinates for attribute
                          GL_FLOAT,            // data is floating point
                          GL_FALSE,            // no fixed point scaling
                          sizeof(SceneVertex),         // total num bytes stored per vertex
                          NULL);
    
    // Draw lines to represent normal vectors and light direction
    // Don't use light so that line color shows
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor =
    GLKVector4Make(0.0, 1.0, 0.0, 1.0); // Green
    
    [self.extraEffect prepareToDraw];
    glDrawArrays(GL_LINES, 0, NUM_NORMAL_LINE_VERTS); // Step 6

    
    self.extraEffect.constantColor =
    GLKVector4Make(1.0, 1.0, 0.0, 1.0); // Yellow
    
    [self.extraEffect prepareToDraw];
    
     glDrawArrays(GL_LINES, NUM_NORMAL_LINE_VERTS, (NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS)); // Step 6
    
}

- (void)setCenterVertexHeight:(GLfloat)aValue
{
    centerVertexHeight = aValue;
    
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = self.centerVertexHeight;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
    [self updateNormals];
}


/////////////////////////////////////////////////////////////////
// Called recalculate the normal vectors for the receiver's
// triangles using either face normals or averaged vertex normals.
- (void)updateNormals
{
    if(self.shouldUseFaceNormals)
    {  // Use face normal vectors to produce facets effect
        // Lighting Step 3
        SceneTrianglesUpdateFaceNormals(triangles);
    }
    else
    {  // Interpolate normal vectors for smooth rounded effect
        // Lighting Step 3
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                 name);
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER,  // Initialize buffer contents
                 sizeof(triangles),  // Number of bytes to copy
                 triangles,          // Address of bytes to copy
                 GL_DYNAMIC_DRAW);
    // Reinitialize the vertex buffer containing vertices to draw
    
}
/////////////////////////////////////////////////////////////////
// This method sets the value of shouldUseFaceNormals and updates
// vertex normals if necessary
- (void)setShouldUseFaceNormals:(BOOL)aValue
{
    if(aValue != shouldUseFaceNormals)
    {
        shouldUseFaceNormals = aValue;
        
        [self updateNormals];
    }
}

#pragma mark - Actions

/////////////////////////////////////////////////////////////////
// This method sets the value of shouldUseFaceNormals to the
// value obtained from sender
- (IBAction)takeShouldUseFaceNormalsFrom:(UISwitch *)sender;
{
    self.shouldUseFaceNormals = sender.isOn;
}


/////////////////////////////////////////////////////////////////
// This method sets the value of shouldUseFaceNormals to the
// value obtained from sender
- (IBAction)takeShouldDrawNormalsFrom:(UISwitch *)sender;
{
    self.shouldDrawNormals = sender.isOn;
}


/////////////////////////////////////////////////////////////////
// This method sets the value of the center vertex height to the
// value obtained from sender
- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender;
{
    self.centerVertexHeight = sender.value;
}


#pragma mark - Accessors with side effects

/////////////////////////////////////////////////////////////////
// This method returns the value of centerVertexHeight.
- (GLfloat)centerVertexHeight
{
    return centerVertexHeight;
}


/////////////////////////////////////////////////////////////////
// This method returns the value of shouldUseFaceNormals.
- (BOOL)shouldUseFaceNormals
{
    return shouldUseFaceNormals;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////////////////////////////////////////////////////////////////
// This function initializes the values in someNormalLineVertices
// with vertices for lines that represent the normal vectors for
// 8 triangles and a line that represents the light direction.
static  void SceneTrianglesNormalLinesUpdate(
                                             const SceneTriangle someTriangles[NUM_FACES],
                                             GLKVector3 lightPosition,
                                             GLKVector3 someNormalLineVertices[NUM_LINE_VERTS])
{
    int                       trianglesIndex;
    int                       lineVetexIndex = 0;
    
    // Define lines that indicate direction of each normal vector
    for (trianglesIndex = 0; trianglesIndex < NUM_FACES;
         trianglesIndex++)
    {
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[0].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[0].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[0].normal,
                                               0.5));
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[1].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[1].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[1].normal,
                                               0.5));
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[2].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[2].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[2].normal, 
                                               0.5));
    }
    
    // Add a line to indicate light direction
    someNormalLineVertices[lineVetexIndex++] = 
    lightPosition;
    
    someNormalLineVertices[lineVetexIndex] = GLKVector3Make(
                                                            0.0, 
                                                            0.0, 
                                                            -0.5);
}

@end

static SceneTriangle SceneTriangleMake(const SceneVertex vertexA, const SceneVertex vertexB, const SceneVertex vertexC){
    SceneTriangle result;
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    
    return result;
}

/////////////////////////////////////////////////////////////////
// This function calculates the face normal vectors for 8
// triangles and then updates the normal vector for each vertex
// by averaging the face normal vectors of each triangle that
// shares the vertex.
static void SceneTrianglesUpdateVertexNormals(
                                              SceneTriangle someTriangles[NUM_FACES])
{
    SceneVertex newVertexA = vertexA;
    SceneVertex newVertexB = vertexB;
    SceneVertex newVertexC = vertexC;
    SceneVertex newVertexD = vertexD;
    SceneVertex newVertexE = someTriangles[3].vertices[0];
    SceneVertex newVertexF = vertexF;
    SceneVertex newVertexG = vertexG;
    SceneVertex newVertexH = vertexH;
    SceneVertex newVertexI = vertexI;
    GLKVector3 faceNormals[NUM_FACES];
    
    // Calculate the face normal of each triangle
    for (int i=0; i<NUM_FACES; i++)
    {
        faceNormals[i] = SceneTriangleFaceNormal(
                                                 someTriangles[i]);
    }
    
    // Average each of the vertex normals with the face normals of
    // the 4 adjacent vertices
    newVertexA.normal = faceNormals[0];
    newVertexB.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[1]),
                                                                             faceNormals[2]),
                                                               faceNormals[3]), 0.25);
    newVertexC.normal = faceNormals[1];
    newVertexD.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[2]),
                                                                             faceNormals[4]),
                                                               faceNormals[6]), 0.25);
    newVertexE.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[2],
                                                                                           faceNormals[3]),
                                                                             faceNormals[4]),
                                                               faceNormals[5]), 0.25);
    newVertexF.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[1], 
                                                                                           faceNormals[3]), 
                                                                             faceNormals[5]), 
                                                               faceNormals[7]), 0.25);
    newVertexG.normal = faceNormals[6];
    newVertexH.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[4], 
                                                                                           faceNormals[5]), 
                                                                             faceNormals[6]), 
                                                               faceNormals[7]), 0.25);
    newVertexI.normal = faceNormals[7];
    
    // Recreate the triangles for the scene using the new
    // vertices that have recalculated normals
    someTriangles[0] = SceneTriangleMake(
                                         newVertexA, 
                                         newVertexB, 
                                         newVertexD);
    someTriangles[1] = SceneTriangleMake(
                                         newVertexB, 
                                         newVertexC, 
                                         newVertexF);
    someTriangles[2] = SceneTriangleMake(
                                         newVertexD, 
                                         newVertexB, 
                                         newVertexE);
    someTriangles[3] = SceneTriangleMake(
                                         newVertexE, 
                                         newVertexB, 
                                         newVertexF);
    someTriangles[4] = SceneTriangleMake(
                                         newVertexD, 
                                         newVertexE, 
                                         newVertexH);
    someTriangles[5] = SceneTriangleMake(
                                         newVertexE, 
                                         newVertexF, 
                                         newVertexH);
    someTriangles[6] = SceneTriangleMake(
                                         newVertexG, 
                                         newVertexD, 
                                         newVertexH);
    someTriangles[7] = SceneTriangleMake(
                                         newVertexH, 
                                         newVertexF, 
                                         newVertexI);
}

/////////////////////////////////////////////////////////////////
// This function returns the face normal vector for triangle.
static GLKVector3 SceneTriangleFaceNormal(
                                          const SceneTriangle triangle)
{
    GLKVector3 vectorA = GLKVector3Subtract(
                                            triangle.vertices[1].position,
                                            triangle.vertices[0].position);
    GLKVector3 vectorB = GLKVector3Subtract(
                                            triangle.vertices[2].position,
                                            triangle.vertices[0].position);
    
    return SceneVector3UnitNormal(
                                  vectorA,
                                  vectorB);
}

/////////////////////////////////////////////////////////////////
// Returns a unit vector in the same direction as the cross
// product of vectorA and VectorB
GLKVector3 SceneVector3UnitNormal(
                                  const GLKVector3 vectorA,
                                  const GLKVector3 vectorB)
{
    return GLKVector3Normalize(
                               GLKVector3CrossProduct(vectorA, vectorB));
}

/////////////////////////////////////////////////////////////////
// Calculates the face normal vectors for 8 triangles and then
// update the normal vectors for each vertex of each triangle
// using the triangle's face normal for all three for the
// triangle's vertices
static void SceneTrianglesUpdateFaceNormals(
                                            SceneTriangle someTriangles[NUM_FACES])
{
    int                i;
    
    for (i=0; i<NUM_FACES; i++)
    {
        GLKVector3 faceNormal = SceneTriangleFaceNormal(
                                                        someTriangles[i]);
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}
