/**
 * @brief Implementation of  interface.
 * @author Jackey Cheung
 */
#import "FlowCoverViewGL.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark - Constants

/**
 * @brief Default width and height of texture, must be power of 2.
 */
#define TEXTURE_DEFAULT_SIZE  256
/**
 * @brief Minimum width and height of texture, power of 2.
 */
#define TEXTURE_MINSIZE       64
/**
 * @brief Maximum allocated 256x256 tiles in cache
 */
#define MAXTILES              48
/**
 * @brief Number of tiles left and right of center tile visible on screen
 */
#define VISTILES              6

/**
 * @brief Friction when the view is rolling.
 */
#define FRICTION             10.0
/**
 * @brief Throttles rolling speed to this value.
 */
#define MAXSPEED             10.0


#pragma mark - Model Constants
/**
 * @brief Quad array of tiles.
 */
const GLfloat GVertices[] =
{
  -1.0f, -1.0f,  0.0f,
  1.0f,  -1.0f,  0.0f,
  -1.0f, 1.0f,   0.0f,
  1.0f,  1.0f,   0.0f
};

/**
 * @brief Texture index array.
 */
const GLshort GTextures[] =
{
  0, 0,
  1, 0,
  0, 1,
  1, 1
};

/**
 * @brief Reflection quads to left.
 */
const GLfloat GReflectionLeft[] =
{
  1, 1, 1, .9,
  1, 1, 1, 0,
  1, 1, 1, .9,
  1, 1, 1, 0
};

/**
 * @brief Reflection quads to top.
 */
const GLfloat GReflectionTop[] =
{
  1, 1, 1, 0,
  1, 1, 1, 0,
  1, 1, 1, .9,
  1, 1, 1, .9
};

/**
 * @brief Reflection quads to right.
 */
const GLfloat GReflectionRight[] =
{
  1, 1, 1, 0,
  1, 1, 1, .9,
  1, 1, 1, 0,
  1, 1, 1, .9
};

/**
 * @brief Reflection quads to bottom.
 */
const GLfloat GReflectionBottom[] =
{
  1, 1, 1, .9,
  1, 1, 1, .9,
  1, 1, 1, 0,
  1, 1, 1, 0
};


#pragma mark - Internal Objects
/**
 * @brief Stores one texture reference.
 */
@interface FlowCoverRecord : NSObject
{
  /**
   * @brief The texture ID.
   */
  GLuint texture;
}
/**
 * @brief The texture ID.
 */
@property GLuint texture;
/**
 * @brief Constructore
 * @param[in] t The texture ID.
 * @returns @c id of the newly created object.
 */
- (id)initWithTexture:(GLuint)t;
@end

@implementation FlowCoverRecord
@synthesize texture;

/**
 * @brief Constructore
 * @param[in] t The texture ID.
 * @returns @c id of the newly created object.
 */
- (id)initWithTexture:(GLuint)t
{
  if(nil != (self = [super init])) texture = t;
  return self;
}

- (void)dealloc
{
  if(texture) glDeleteTextures(1, &texture);
  [super dealloc];
}
@end


#pragma mark - FlowCover Implementation
@implementation FlowCoverViewGL
@synthesize delegate;
@synthesize direction;
@synthesize facing;
@synthesize reflection;
@synthesize screenDisplayRatio;
@synthesize imageSize;
@synthesize imageSpread;
@synthesize imageRotation;
@synthesize depthSpread;
@synthesize alphaSpread;
@synthesize focusedIndex;
@synthesize numVisibleTile;


#pragma mark - OpenGL ES Support

/**
 * @brief Returns the CAEAGLLayer class.
 * @returns The @c CAEAGLLayer class.
 */
+ (Class)layerClass
{
  return [CAEAGLLayer class];
}

/**
 * @brief Creates and initializes buffers for OpenGL ES operation.
 * @returns True if created complete frame buffer, otherwise false.
 */
- (BOOL)createFrameBuffer
{
  // Create an abstract frame buffer
  glGenFramebuffersOES(1, &viewFramebuffer);
  glGenRenderbuffersOES(1, &viewRenderbuffer);
  glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
  glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);

  // Create a render buffer with color,
  // attach to view and attach to frame buffer.
  [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id <
      EAGLDrawable >)self.layer];
  glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
    GL_COLOR_ATTACHMENT0_OES,
    GL_RENDERBUFFER_OES,
    viewRenderbuffer);

  glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
    GL_RENDERBUFFER_WIDTH_OES,
    &backingWidth);
  glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
    GL_RENDERBUFFER_HEIGHT_OES,
    &backingHeight);

  if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) !=
    GL_FRAMEBUFFER_COMPLETE_OES)
  {
    #if TARGET_IPHONE_SIMULATOR
    NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
    #endif
    return NO;
  }

  return YES;
}  /* createFrameBuffer */

/**
 * @brief Destroys buffers
 */
- (void)destroyFrameBuffer
{
  glDeleteFramebuffersOES(1, &viewFramebuffer);
  viewFramebuffer = 0;
  glDeleteRenderbuffersOES(1, &viewRenderbuffer);
  viewRenderbuffer = 0;

  if(depthRenderbuffer)
  {
    glDeleteRenderbuffersOES(1, &depthRenderbuffer);
    depthRenderbuffer = 0;
  }
}  /* destroyFrameBuffer */

/**
 * @brief Layout subviews
 */
- (void)layoutSubviews
{
  [EAGLContext setCurrentContext:context];
  [self destroyFrameBuffer];
  [self createFrameBuffer];
  [self redraw];
}


#pragma mark - Construction / Destruction

/**
 * @brief
 * Handles the common initialization tasks from the initWithFrame
 * and initWithCoder routines
 * @returns @c id of the newly initialized object.
 */
- (id)internalInit
{
  CAEAGLLayer *eaglLayer;

  eaglLayer = (CAEAGLLayer*)self.layer;
  eaglLayer.opaque = YES;

  CGSize screenSize = [[UIScreen mainScreen] bounds].size;
  screenDisplayRatio = screenSize.width / screenSize.height;

  cgData = NULL;
  memcpy(vertices, GVertices, sizeof(GVertices));
  
  alphaSpread    = 0;
  depthSpread    = 0;
  imageSpread    = .1;
  imageRotation  = .4;
  numVisibleTile = VISTILES;
  reflection     = FlowCoverReflectOnBottom;
  self.imageSize = CGSizeMake(TEXTURE_DEFAULT_SIZE, TEXTURE_DEFAULT_SIZE);

  context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
  if(!context || ![EAGLContext setCurrentContext:context] ||
    ![self createFrameBuffer])
  {
    [self release];
    return nil;
  }
  self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];

  cache  = [[FCDataCache alloc] initWithCapacity:MAXTILES];
  offset = 0;

  return self;
}  /* internalInit */

- (id)initWithFrame:(CGRect)frame
{
  if((self = [super initWithFrame:frame]))
    self = [self internalInit];
  return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
  if((self = [super initWithCoder:coder]))
    self = [self internalInit];
  return self;
}

- (void)dealloc
{
  [EAGLContext setCurrentContext:context];

  [self destroyFrameBuffer];
  [cache release];

  [EAGLContext setCurrentContext:nil];

  [context release];
  context = nil;

  [super dealloc];
}  /* dealloc */


#pragma mark - Delegate Calls

/**
 * @brief
 * Returns the number of tiles to be shown.
 * Asks delegate for the number of tiles.
 * @returns The number of tiles to be shown.
 */
- (int)numTiles
{
  if(delegate) return [delegate flowCoverGLNumberOfImages:self];
  else return 0;
}

/**
 * @brief Returns the image at the given index. Asks delegate for the image.
 * @param[in] image Index of the image to be retrieved.
 * @returns The image at the specified index.
 */
- (UIImage*)tileImage:(int)image
{
  if(delegate) return [delegate flowCoverGL:self cover:image];

  else return nil;  /* should never happen */
}

/**
 * @brief Tells delegate that a tile has been pressed.
 * @param[in] index Index of the tile that was pressed.
 */
- (void)touchAtIndex:(int)index
{
  if(delegate) [delegate flowCoverGL:self didSelect:index];
}


#pragma mark - Properties

/**
 * @brief Returns the index of focused tile.
 * @returns The index of the focused tile.
 */
- (int)getFocusedIndex
{
  return (int)offset;
}

/**
 * @brief Sets the index of focused tile.
 * @param[in] index The index of the tile to be focused.
 */
- (void)setFocusedIndex:(int)index
{
  offset = index;
}

/**
 * @brief Sets image size, and alter tile model accordingly.
 * @param[in] size Image size to be used.
 */
- (void)setImageSize:(CGSize)size
{
  imageSize    = size;
  textureRange = TEXTURE_MINSIZE;
  while(imageSize.width > textureRange || imageSize.height >
        textureRange) textureRange *= 2;
  if(imageSize.width > imageSize.height)
  {
    tileOriginX  = -1;
    tileOriginY  = -imageSize.height / (float)imageSize.width;
    vertices[0] = vertices[6] = tileOriginX;
    vertices[3] = vertices[9] = -tileOriginX;
    vertices[1] = vertices[4] = tileOriginY;
    vertices[7] = vertices[10] = -tileOriginY;
  }
  else
  {
    tileOriginY  = -1;
    tileOriginX  = -imageSize.width / (float)imageSize.height;
    vertices[1] = vertices[4] = tileOriginY;
    vertices[7] = vertices[10] = -tileOriginY;
    vertices[0] = vertices[6] = tileOriginX;
    vertices[3] = vertices[9] = -tileOriginX;
  }
}  /* setImageSize */


#pragma mark - Tile Management
/**
 * @brief Converts image to texture.
 * @param[in] image The image to be converted.
 * @returns Texture ID created from the image.
 */
- (GLuint)imageToTexture:(UIImage*)image
{
  /* Set up off screen drawing */
  CGSize size = image.size;

  if(cgData == NULL) cgData = malloc(4 * size.width * size.height);
  CGColorSpaceRef cref = CGColorSpaceCreateDeviceRGB();
  CGContextRef gc = CGBitmapContextCreate(cgData, size.width, size.height, 8,
    size.width * 4, cref, kCGImageAlphaPremultipliedLast);
  CGColorSpaceRelease(cref);
  UIGraphicsPushContext(gc);

  /* Set to transparent */
  [[UIColor colorWithWhite:0 alpha:0] setFill];
  CGRect r = CGRectMake(0, 0, size.width, size.height);
  UIRectFill(r);
  [image drawInRect:r];

  /* Create the texture */
  UIGraphicsPopContext();
  CGContextRelease(gc);
  GLuint texture = 0;
  glGenTextures(1, &texture);
  [EAGLContext setCurrentContext:context];
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA,
    GL_UNSIGNED_BYTE, cgData);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  /* clean up */
  free(cgData);
  cgData = NULL;

  return texture;
}  /* imageToTexture */

/**
 * @brief Retrieves the tile texture at the specific index.
 * @param[in] index Index of the tile to be retieved.
 * @returns The texture record.
 */
- (FlowCoverRecord*)getTileAtIndex:(int)index
{
  NSNumber *num = [NSNumber numberWithInt:index];
  FlowCoverRecord *fcr = [cache objectForKey:num];

  if(fcr == nil)
  {
    /* Object at index doesn't exist. Create a new texture */
    GLuint texture = [self imageToTexture:[self tileImage:index]];
    fcr = [[[FlowCoverRecord alloc] initWithTexture:texture] autorelease];
    [cache setObject:fcr forKey:num];
  }

  return fcr;
}  /* getTileAtIndex */

- (void)invalidateImageAtIndex:(int)index
{
  [cache removeObjectForKey:[NSNumber numberWithInt:index]];
}

- (void)invalidateAllImages
{
  [cache removeAllObjects];
}


#pragma mark - Drawing

/**
 * @brief Draws the specified tile.
 * @param[in] index Index of the tile to be drawn.
 * @param[in] off Offset from the center tile.
 */
- (void)drawTile:(int)index atOffset:(double)off
{
  FlowCoverRecord *fcr = [self getTileAtIndex:index];
  double f = off * imageRotation;
  
  if(f < -imageRotation) f = -imageRotation;
  else if(f > imageRotation) f = imageRotation;

  float alpha = MAX(0, 1 - alphaSpread * fabs(off));

  /* transformation (translate and rotate) matrix */
  GLfloat m[16];
  memset(m, 0, sizeof(m));
  if(FlowCoverSwipeHorizontal == direction)
  {
    m[10] = 1;
    m[15] = 1;
    m[5]  = 1;
    if(FlowCoverFaceInward == facing)
    {
      m[3] = -f;
      m[0] = 1 - fabs(f);
    }
    else if(FlowCoverFaceOutward == facing)
    {
      m[3] = f;
      m[0] = 1 - fabs(f);
    }
    else
    {
      m[0] = 1;
    }
  }
  else
  {
    m[10] = 1;
    m[15] = 1;
    m[0]  = 1;
    if(FlowCoverFaceInward == facing)
    {
      m[7] = -f;
      m[5] = 1 - fabs(f);
    }
    else if(FlowCoverFaceOutward == facing)
    {
      m[7] = f;
      m[5] = 1 - fabs(f);
    }
    else
    {
      m[5] = 1;
    }
  }
  double sc    = 0.45 * (1 - fabs(f)) * MAX(0, 1 - depthSpread * fabs(off));
  double trans = off * imageSpread + f;

  glPushMatrix();
  glBindTexture(GL_TEXTURE_2D, fcr.texture);
  glColor4f(1, 1, 1, alpha);
  FlowCoverSwipeHorizontal ==
  direction ?  glTranslatef(trans, 0, 0) : glTranslatef(0, trans, 0);
  glScalef(sc, sc, 1.0);
  glMultMatrixf(m);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

  // reflections
  GLfloat reflectionColorPointer[16];
  if(reflection & FlowCoverReflectOnBottom)
  {
    glPushMatrix();
    glTranslatef(0, tileOriginY * 2, 0);
    glScalef(1, -1, 1);
    memcpy(reflectionColorPointer, GReflectionBottom,
      sizeof(reflectionColorPointer));
    reflectionColorPointer[3]  = reflectionColorPointer[3] * alpha;
    reflectionColorPointer[7]  = reflectionColorPointer[7] * alpha;
    reflectionColorPointer[11] = reflectionColorPointer[11] * alpha;
    reflectionColorPointer[15] = reflectionColorPointer[15] * alpha;
    glColorPointer(4, GL_FLOAT, 0, reflectionColorPointer);
    glEnableClientState(GL_COLOR_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableClientState(GL_COLOR_ARRAY);
    glColor4f(1, 1, 1, 1);
    glPopMatrix();
  }
  if(reflection & FlowCoverReflectOnLeft)
  {
    glPushMatrix();
    glTranslatef(tileOriginX * 2, 0, 0);
    glScalef(-1, 1, 1);
    memcpy(reflectionColorPointer, GReflectionLeft,
      sizeof(reflectionColorPointer));
    reflectionColorPointer[3]  = reflectionColorPointer[3] * alpha;
    reflectionColorPointer[7]  = reflectionColorPointer[7] * alpha;
    reflectionColorPointer[11] = reflectionColorPointer[11] * alpha;
    reflectionColorPointer[15] = reflectionColorPointer[15] * alpha;
    glColorPointer(4, GL_FLOAT, 0, reflectionColorPointer);
    glEnableClientState(GL_COLOR_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableClientState(GL_COLOR_ARRAY);
    glColor4f(1, 1, 1, 1);
    glPopMatrix();
  }
  if(reflection & FlowCoverReflectOnTop)
  {
    glPushMatrix();
    glTranslatef(0, -tileOriginY * 2, 0);
    glScalef(1, -1, 1);
    memcpy(reflectionColorPointer, GReflectionTop,
      sizeof(reflectionColorPointer));
    reflectionColorPointer[3]  = reflectionColorPointer[3] * alpha;
    reflectionColorPointer[7]  = reflectionColorPointer[7] * alpha;
    reflectionColorPointer[11] = reflectionColorPointer[11] * alpha;
    reflectionColorPointer[15] = reflectionColorPointer[15] * alpha;
    glColorPointer(4, GL_FLOAT, 0, reflectionColorPointer);
    glEnableClientState(GL_COLOR_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableClientState(GL_COLOR_ARRAY);
    glColor4f(1, 1, 1, 1);
    glPopMatrix();
  }
  if(reflection & FlowCoverReflectOnRight)
  {
    glPushMatrix();
    glTranslatef(-tileOriginX * 2, 0, 0);
    glScalef(-1, 1, 1);
    memcpy(reflectionColorPointer, GReflectionRight,
      sizeof(reflectionColorPointer));
    reflectionColorPointer[3]  = reflectionColorPointer[3] * alpha;
    reflectionColorPointer[7]  = reflectionColorPointer[7] * alpha;
    reflectionColorPointer[11] = reflectionColorPointer[11] * alpha;
    reflectionColorPointer[15] = reflectionColorPointer[15] * alpha;
    glColorPointer(4, GL_FLOAT, 0, reflectionColorPointer);
    glEnableClientState(GL_COLOR_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableClientState(GL_COLOR_ARRAY);
    glColor4f(1, 1, 1, 1);
    glPopMatrix();
  }

  glPopMatrix();
  if((0 == off) && delegate &&
    [delegate respondsToSelector:@selector(flowCoverGL:didFocus:)])
    [delegate flowCoverGL:self didFocus:index];
}  /* drawTile */

- (void)redraw
{
  /* Get the current aspect ratio and initialize the viewport */
  double aspect = ((double)backingWidth) / backingHeight;

  glViewport(0, 0, backingWidth, backingHeight);
  glDisable(GL_DEPTH_TEST);        /* using painters algorithm */

  glClearColor(0, 0, 0, 0);
  glVertexPointer(3, GL_FLOAT, 0, vertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glTexCoordPointer(2, GL_SHORT, 0, GTextures);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glEnable(GL_TEXTURE_2D);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);

  /* Setup for clear */
  [EAGLContext setCurrentContext:context];

  glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
  glClear(GL_COLOR_BUFFER_BIT);

  /* Set up the basic coordinate system */
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glScalef(1, aspect, 1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glScalef(screenDisplayRatio / aspect, screenDisplayRatio / aspect, screenDisplayRatio);

  /*
   * Change from Alesandro Tagliati <alessandro.tagliati@gmail.com>:
   * We don't need to draw all the tiles, just the visible ones.
   */
  int i, len = [self numTiles];
  int mid = (int)floor(offset + 0.5);
  int iStartPos = mid - numVisibleTile / 2;
  if(iStartPos < 0) iStartPos = 0;
  for(i = iStartPos; i < mid; i++) [self drawTile:i atOffset:i - offset];

  int iEndPos = mid + numVisibleTile / 2;
  if(iEndPos >= len) iEndPos = len - 1;
  for(i = iEndPos; i >= mid; i--) [self drawTile:i atOffset:i - offset];

  glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
  [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}  /* redraw */


#pragma mark - Animation

/**
 * @brief Updates the view content and render it.
 * @param[in] elapsed Time elapsed since last rendered frame.
 */
- (void)updateAnimationAtTime:(double)elapsed
{
  int max = [self numTiles] - 1;

  if(elapsed > runDelta) elapsed = runDelta;
  double delta = fabs(startSpeed) * elapsed - FRICTION * elapsed * elapsed / 2;
  if(startSpeed < 0) delta = -delta;
  offset = startOff + delta;

  if(offset > max) offset = max;
  if(offset < 0) offset = 0;

  [self redraw];
}  /* updateAnimationAtTime */

/**
 * @brief Stops animation.
 */
- (void)endAnimation
{
  if(timer)
  {
    int max = [self numTiles] - 1;
    offset = floor(offset + 0.5);
    if(offset > max) offset = max;
    if(offset < 0) offset = 0;
    [self redraw];

    [timer invalidate];
    timer = nil;
  }
  if(beganRolling)
  {
    if(delegate && [delegate respondsToSelector:@selector(flowCoverGLWillEndRolling:)])
      [delegate flowCoverGLWillEndRolling:self];
    beganRolling = NO;
  }
}  /* endAnimation */

/**
 * @brief Drives animation forward.
 */
- (void)driveAnimation
{
  double elapsed = CACurrentMediaTime() - startTime;

  if(elapsed >= runDelta) [self endAnimation];

  else [self updateAnimationAtTime:elapsed];
}

/**
 * @brief Starts animating the view.
 * @param[in] speed Initial speed of movement.
 */
- (void)startAnimation:(double)speed
{
  if(timer) [self endAnimation];

  // Adjust speed to make this land on an even location
  double delta = speed * speed / (FRICTION * 2);
  if(speed < 0) delta = -delta;
  double nearest = startOff + delta;
  nearest    = floor(nearest + 0.5);
  startSpeed = sqrt(fabs(nearest - startOff) * FRICTION * 2);
  if(nearest < startOff) startSpeed = -startSpeed;

  runDelta  = fabs(startSpeed / FRICTION);
  startTime = CACurrentMediaTime();

  timer = [NSTimer scheduledTimerWithTimeInterval:0.03
    target:self
    selector:@selector(driveAnimation)
    userInfo:nil
    repeats:YES];
}  /* startAnimation */


#pragma mark - Touch

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
  CGRect r      = self.bounds;
  UITouch *t    = [touches anyObject];
  CGPoint where = [t locationInView:self];

  if(FlowCoverSwipeHorizontal == direction)
    startPos =
      (where.x / r.size.width) * 10 - 5;
  else startPos = -((where.y / r.size.height) * 10 - 5);
  startOff = offset;

  touchFlag  = YES;
  startTouch = where;

  startTime = CACurrentMediaTime();
  lastPos   = startPos;

  [self endAnimation];
}  /* touchesBegan */

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
  CGRect r      = self.bounds;
  UITouch *t    = [touches anyObject];
  CGPoint where = [t locationInView:self];
  double pos    = 0;

  if(FlowCoverSwipeHorizontal == direction)
    pos =
      (where.x / r.size.width) * 10 - 5;
  else pos = -((where.y / r.size.height) * 10 - 5);

  if(touchFlag == YES)
  {
    /* Touched location; only accept on touching inner 256x256 area */
    r.origin.x   += (r.size.width - 256) / 2;
    r.origin.y   += (r.size.height - 256) / 2;
    r.size.width  = 256;
    r.size.height = 256;

    if(CGRectContainsPoint(r,
        where)) [self touchAtIndex:(int)floor(offset + 0.01)];  /* make sure .99 is 1 */
  }
  else
  {
    /* Start animation to nearest */
    startOff += (startPos - pos);
    offset    = startOff;

    double time  = CACurrentMediaTime();
    double speed = (lastPos - pos) / (time - startTime);
    if(speed > MAXSPEED) speed = MAXSPEED;
    if(speed < -MAXSPEED) speed = -MAXSPEED;

    [self startAnimation:speed];
  }
}  /* touchesEnded */

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
  if(!beganRolling)
  {
    if(delegate && [delegate respondsToSelector:@selector(flowCoverGLWillBeginRolling:)])
      [delegate flowCoverGLWillBeginRolling:self];
    beganRolling = YES;
  }
  CGRect r      = self.bounds;
  UITouch *t    = [touches anyObject];
  CGPoint where = [t locationInView:self];
  double pos    = 0;
  if(FlowCoverSwipeHorizontal == direction)
    pos =
      (where.x / r.size.width) * 10 - 5;
  else pos = -((where.y / r.size.height) * 10 - 5);

  if(touchFlag)
  {
    /* determine if the user is dragging or not */
    int dx = fabs(where.x - startTouch.x);
    int dy = fabs(where.y - startTouch.y);
    if((dx < 3) && (dy < 3)) return;

    touchFlag = NO;
  }

  int max = [self numTiles] - 1;

  offset = startOff + (startPos - pos);
  if(offset > max) offset = max;
  if(offset < 0) offset = 0;
  [self redraw];

  double time = CACurrentMediaTime();
  if(time - startTime > 0.2)
  {
    startTime = time;
    lastPos   = pos;
  }
}  /* touchesMoved */

@end
