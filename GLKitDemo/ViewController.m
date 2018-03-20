//
//  ViewController.m
//  GLKitDemo
//
//  Created by cao longjian on 2018/3/20.
//  Copyright © 2018年 caolongjian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic,strong)EAGLContext *mContext;
@property(nonatomic,strong)GLKBaseEffect *mEffect;

@property(nonatomic,assign)int count;

//旋转度数
@property(nonatomic,assign)float xDegree;
@property(nonatomic,assign)float yDegree;
@property(nonatomic,assign)float zDegree;

//是否能在对应轴旋转
@property(nonatomic,assign)BOOL XB;
@property(nonatomic,assign)BOOL YB;
@property(nonatomic,assign)BOOL ZB;

@end

@implementation ViewController
{
    //定时器
    dispatch_source_t timer;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //1.新建图层
    [self setupContext];
    
    //2.渲染图形
    [self render];
    
}


-(void)setupContext
{
    //1.新建OpenGL ES 上下文
    self.mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    //2.GLKView
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.mContext];
    
    glEnable(GL_DEPTH_TEST);
    
    
}

-(void)render
{
    //1.顶点数据
    //1.顶点数据
    //前3个元素，是顶点数据xyz；中间3个元素，是顶点颜色值rgb，最后2个是纹理坐标st
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
        0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
        
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    };
    
    //2.绘图索引
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    //3.顶点的个数
    self.count = sizeof(indices)/sizeof(GLuint);
    
    
    //4.将顶点数组放入缓存区内--?GL_ARRAY_BUFFER
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    
    
    //5.将索引数组放入缓存区
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    
    //6.使用顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), NULL);
    
    //7.颜色数据
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat),(GLfloat *)NULL + 3);
    
    //8.纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat),(GLfloat *)NULL + 6);
    
    //9.获取纹理数据
    //思维导图
    //存储路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"cTest" ofType:@"jpg"];
    
    //设置纹理的读取参数
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"1",GLKTextureLoaderOriginBottomLeft, nil];
    
    //通过GLKTextureInfo 加载纹理
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    
    //10 效果
    self.mEffect = [[GLKBaseEffect alloc]init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
    
    
    //11.设置透视投影
    CGSize size = self.view.bounds.size;
    
    //纵横比
    float aspect = fabs(size.width / size.height);
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 10.0f);
    
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);
    self.mEffect.transform.projectionMatrix = projectionMatrix;
    
    //12.模型视图变换
    //往屏幕深度上移动了-2.0个距离
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
    
    //13.定时器
    //GCD开启
    double seconds = 0.1;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC, 0.0f);
    dispatch_source_set_event_handler(timer, ^{
        
        self.xDegree += 0.1f * self.XB;
        self.yDegree += 0.1f * self.YB;
        self.zDegree += 0.1f * self.ZB;
        
    });
    dispatch_resume(timer);
    
}

-(void)update
{
    //更新
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, _xDegree);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, _yDegree);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, _zDegree);
    
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
    
    //10:11 分上课!!!!
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //准备绘制
    [self.mEffect prepareToDraw];
    
    //索引绘制
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
    
}

#pragma mark --Button Click
- (IBAction)XClick:(id)sender {
    _XB = !_XB;
    
}
- (IBAction)YClick:(id)sender {
    _YB = !_YB;
    
}
- (IBAction)ZClick:(id)sender {
    _ZB = !_ZB;
}


@end
