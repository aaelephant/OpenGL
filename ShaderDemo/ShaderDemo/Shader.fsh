//
//  Shader.fsh
//  FirstOpenGLESApp
//
//  Created by Heck on 16/9/27.
//  Copyright © 2016年 battlefire. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
