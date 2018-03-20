# OpenGL-ES---GLKit
OpenGL-ES 使用苹果提供的 GLKit 框架实现



不采用GLKBaseEffect，使用编译链接自定义的着色器（shader）。用简单的glsl语言来实现顶点、片元着色器，并图形进行简单的变换。


![OpenGL ES -自定义的着色器-](https://caolongs.github.io/images/media/15211019198288/OpenGL%20ES%20-%E8%87%AA%E5%AE%9A%E4%B9%89%E7%9A%84%E7%9D%80%E8%89%B2%E5%99%A8-.png)



### 一、创建图层
`CAEAGLLayer `

> /* CAEAGLLayer is a layer that implements the EAGLDrawable protocol,
 * allowing it to be used as an OpenGLES render target. Use the
 * `drawableProperties' property defined by the protocol to configure
 * the created surface. */

> CAEAGLLayer是一个实现EAGLDrawable协议的层，
  *允许它用作OpenGLES渲染目标。 使用
  *协议定义的`drawableProperties'属性进行配置
  *创建的表面。

1. 创建图层
2. 设置放大倍数

    ```
    [self setContentScaleFactor:[[UIScreen mainScreen]scale]];
    ```

3. 将图层设为不透明（默认是透明的）

    ```
    self.myEagLayer.opaque = YES;
    ```

4. 设置 `drawableProperties` 属性,这里设置不维持渲染内容以及颜色格式为RGBA8

    ```
    self.myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
    ```


```
/************************************************************************/
/* Keys for EAGLDrawable drawableProperties dictionary                  */
/*                                                                      */
/* kEAGLDrawablePropertyRetainedBacking:                                */
/*  Type: NSNumber (boolean)                                            */
/*  Legal Values: True/False                                            */
/*  Default Value: False                                                */
/*  Description: True if EAGLDrawable contents are retained after a     */
/*               call to presentRenderbuffer.  False, if they are not   */
/*                                                                      */
/* kEAGLDrawablePropertyColorFormat:                                    */
/*  Type: NSString                                                      */
/*  Legal Values: kEAGLColorFormat*                                     */
/*  Default Value: kEAGLColorFormatRGBA8                                */
/*  Description: Format of pixels in renderbuffer                       */
/************************************************************************/
```

* kEAGLDrawablePropertyRetainedBacking: 表示绘图表面显示后，是否保留其内容。这个key的值，是一个通过NSNumber包装的bool值。如果是false，则显示内容后不能依赖于相同的内容，ture表示显示后内容不变。一般只有在需要内容保存不变的情况下，才建议设置使用,因为会导致性能降低、内存使用量增减。一般设置为flase.
* kEAGLDrawablePropertyColorFormat: 可绘制表面的内部颜色缓存区格式，这个key对应的值是一个NSString指定特定颜色缓存区对象。默认是kEAGLColorFormatRGBA8
    - kEAGLColorFormatRGBA8：32位RGBA的颜色，4*8=32位
    - kEAGLColorFormatRGB565：16位RGB的颜色，
    - kEAGLColorFormatSRGBA8：sRGB代表了标准的红、绿、蓝，即CRT显示器、LCD显示器、投影机、打印机以及其他设备中色彩再现所使用的三个基本色素。sRGB的色彩空间基于独立的色彩坐标，可以使色彩在不同的设备使用传输中对应于同一个色彩坐标体系，而不受这些设备各自具有的不同色彩坐标的影响。



### 二、创建上下文


1. 指定OpenGL ES 渲染API版本，我们使用2.0

    ```
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    ```
2. 创建图形上下文

    ```
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
    ```
3. 判断是否创建成功

    ```
    if (!context) {
        NSLog(@"Create context failed!");
        return;
    }
    ```
    
4. 设置图形上下文

    ```
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"setCurrentContext failed!");
        return;
    }
    ```
    
5. 将局部context，变成全局的

    ```
    self.myContext = context;
    ```

### 三、清空缓存区

1. 导入框架#import <OpenGLES/ES2/gl.h>

2. 创建2个帧缓存区，渲染缓存区，帧缓存区

     ```
     @property (nonatomic , assign) GLuint myColorRenderBuffer;
     @property (nonatomic , assign) GLuint myColorFrameBuffer;
     ```
     
3. 清空缓存区 
  
    ```
    glDeleteBuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
    
    glDeleteBuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
    ```
    
### 四、设置RenderBuffer

1. 定义一个缓存区

    ```
    GLuint buffer;
    ```
    
2. 申请一个缓存区标志

    ```
    glGenRenderbuffers(1, &buffer);
    //同 glGenRenderbuffers(1, &buffer);
    
    //赋值
    self.myColorRenderBuffer = buffer;
    ```
      
3. 将标识符绑定到GL_RENDERBUFFER

    ```
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    ```
    
    
    
4. myColorRenderBuffer渲染缓存区分配存储空间

    ```
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
    ```
    ```
    注意：frame buffer仅仅是管理者，不需要分配空间；
    render buffer的存储空间的分配，对于不同的render buffer，使用不同的API进行分配，
    而只有分配空间的时候，render buffer句柄才确定其类型
    ```
    
### 五、设置FrameBuffer

1. 定义一个缓存区

    ```
    GLuint buffer;
    ```
    
2. 申请一个缓存区标志

    ```
    glGenRenderbuffers(1, &buffer);
    
    //赋值
    self.myColorFrameBuffer = buffer;
    ```
    
    
4. 将标识符绑定到GL_FRAMEBUFFER

    ```
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    ```
    
5. renderbuffer跟framebuffer进行绑定,将_myColorRenderBuffer 通过glFramebufferRenderbuffer函数绑定到GL_COLOR_ATTACHMENT0上。

    ```
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
    ```
    
    //接下来，可以调用OpenGL ES进行绘制处理，最后则需要在EGALContext的OC方法进行最终的渲染绘制。这里渲染的color buffer,这个方法会将buffer渲染到CALayer上。- (BOOL)presentRenderbuffer:(NSUInteger)target;
    
    
    
### 六、开始绘制
    
     
1. 设置颜色、设置视口大小

    ```
    //设置清屏颜色
    glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
    
    //清除屏幕
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    //设置视口大小
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    ```
    
2. 读取顶点着色程序、片元着色程序

    ```
    NSString *vertFile = [[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle]pathForResource:@"shaderf" ofType:@"fsh"];
    ```

    
3. 加载shader

    ```
    self.myPrograme = [self loadShaders:vertFile Withfrag:fragFile];//见附
    ```
    
    
    
4. 链接

    ```
    glLinkProgram(self.myPrograme);
    GLint linkStatus;
    //获取链接状态
    glGetProgramiv(self.myPrograme, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.myPrograme, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Program Link Error:%@",messageString);
        return;
    }
    
    ```

5. 使用program
    
    ```
    glUseProgram(self.myPrograme);
    ```
    
6. 设置顶点、纹理坐标
    
    ```
    ...
    ```
7. 处理顶点数据

    ```
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    ```

8. 处理纹理数据

    ```
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL + 3);
    ```
     
9. 加载纹理

    * 获取图片的CGImageRef
    
    * 读取图片的大小，宽和高
     
    * 获取图片字节数 宽*高*4（RGBA）
     
    * 创建上下文
 
    * 在CGContextRef上绘图 ,解决图片倒置的方法
   
    * 画图完毕就释放上下文
     
    
    * 绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的 
    
    * 设置纹理属性
     
    * 载入纹理2D数据
        
    * 绑定纹理
 
    * 释放spriteData
 

10. 获取shader里面的变量, 模型视图变换传值


11. 绘制并显示缓存数据 presentRenderbuffer 

    ```
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
    ```




### 附


1. frame buffer 和 render buffer 关系

```
buffer分为frame buffer 和 render buffer2个大类。其中frame buffer 相当于render buffer的管理者。frame buffer object即称FBO，常用于离屏渲染缓存等。render buffer则又可分为3类。colorBuffer、depthBuffer、stencilBuffer。
```
 
2. 加载shader
     
     * 定义2个零时着色器对象
     * 创建program
     * 编译顶点着色程序、片元着色器程序
        - 读取文件路径字符串
        - 创建一个shader（根据type类型）
        - 将顶点着色器源码附加到着色器对象上
        - 把着色器源代码编译成目标代码
     * 创建最终的程序
     * 释放不需要的shader
        

```
-(GLuint)loadShaders:(NSString *)vert Withfrag:(NSString *)frag {
    //定义2个零时着色器对象
    GLuint verShader, fragShader;
    //创建program
    GLint program = glCreateProgram();
    
    //编译顶点着色程序、片元着色器程序
    //参数1：编译完存储的底层地址
    //参数2：编译的类型，GL_VERTEX_SHADER（顶点）、GL_FRAGMENT_SHADER(片元)
    //参数3：文件路径
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    //创建最终的程序
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}
```

```
//链接shader
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    
    //读取文件路径字符串
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    //创建一个shader（根据type类型）
    *shader = glCreateShader(type);
    
    //将顶点着色器源码附加到着色器对象上。
    //参数1：shader,要编译的着色器对象 *shader
    //参数2：numOfStrings,传递的源码字符串数量 1个
    //参数3：strings,着色器程序的源码（真正的着色器程序源码）
    //参数4：lenOfStrings,长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
    glShaderSource(*shader, 1, &source,NULL);
    
    //把着色器源代码编译成目标代码
    glCompileShader(*shader);
    
}
```
