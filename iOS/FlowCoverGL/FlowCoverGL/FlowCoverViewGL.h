/**
 * @brief Header file of the  interface.
 * @author Jackey Cheung
 */
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "FCDataCache.h"

/**
 * @brief Determines whether tiles are arranged horizontally or vertically.
 */
typedef enum
{
  /**
   * @brief Tiles are arranged horizontally.
   */
  FlowCoverSwipeHorizontal = 0,
  /**
   * @brief Tiles are arranged vertically.
   */
  FlowCoverSwipeVertical
}FlowCoverSwipeDirection;

/**
 * @brief Determines the facing direction of tiles.
 */
typedef enum
{
  /**
   * @brief Tiles are rotated and face towards the center of the view.
   */
  FlowCoverFaceInward = 0,
  /**
   * @brief Tiles are rotated and face away from the center of the view.
   */
  FlowCoverFaceOutward,
  /**
   * @brief Tiles are not rotated.
   */
  FlowCoverFaceForward
}FlowCoverFacing;

/**
 * @brief Determines reflections of tiles.
 */
typedef enum
{
  /**
   * @brief No reflection
   */
  FlowCoverReflectNone                  = 0,
  /**
   * @brief Tiles are reflected to the bottom.
   */
  FlowCoverReflectOnBottom              = 1,
  /**
   * @brief Tiles are reflected to the left.
   */
  FlowCoverReflectOnLeft                = 2,
  /**
   * @brief Tiles are reflected to the top.
   */
  FlowCoverReflectOnTop                 = 4,
  /**
   * @brief Tiles are reflected to the right.
   */
  FlowCoverReflectOnRight               = 8,
  /**
   * @brief Tiles are reflected to both left and right.
   */
  FlowCoverReflectOnBothHorizontalSides = 10,
  /**
   * @brief Tiles are reflected to both top and bottom.
   */
  FlowCoverReflectOnBothVerticalSides   = 5,
  /**
   * @brief Tiles are reflected to all 4 directions.
   */
  FlowCoverReflectOnAllSides            = 15
}FlowCoverReflection;


@protocol FlowCoverViewGLDelegate;


/**
 * @brief Works like the Apple's Cover Flow.
 
 * @details
 * The flow cover view class; this is a drop-in view which calls into
 * a delegate callback which controls the contents. This emulates the CoverFlow
 * thingy from Apple, using OpenGL ES. It uses the DataCache interface
 * internally, for caching textures being used. It provides some parameters to
 * customize the view.
 */
@interface FlowCoverViewGL : UIView
{
  /**
   * @brief Pointer to the image buffer.
   */
  void *cgData;
  
  /**
   * @brief Tile vertex coordinates.
   */
  GLfloat vertices[12];
  /**
   * @brief Index of the focused tile.
   */
  double offset;
  /**
   * @brief Number of visible tiles.
   */
  int numVisibleTile;
  /**
   * @brief
   * Screen display ratio reference, for scaling objects to fit viewport.
   */
  double screenDisplayRatio;
  /**
   * @brief Spread between images (between -1 ~ 1).
   */
  double imageSpread;
  /**
   * @brief This is how much an image is rotated
   * @remark rotation = arccos(±imageRotation).
   */
  double imageRotation;
  /**
   * @brief How image moved backward as they spread (between 0 ~ 1).
   * @remark
   * Scaling is used to simulate perspective depth, instead of using GLUT.
   */
  double depthSpread;
  /**
   * @brief Tiles becoming transparent as they spread (between 0 ~ 1).
   */
  float alphaSpread;

  /**
   * @brief The timer that drives animation.
   */
  NSTimer *timer;
  /**
   * @brief Time measurement variable used in animation. 
   */
  double startTime;
  /**
   * @brief Position measurement variable used in animation. 
   */
  double startOff;
  /**
   * @brief Position measurement variable used in animation. 
   */
  double startPos;
  /**
   * @brief Position measurement variable used in animation. 
   */
  double lastPos;
  /**
   * @brief Speed measurement variable used in animation. 
   */
  double startSpeed;
  /**
   * @brief Speed measurement variable used in animation. 
   */
  double runDelta;
  /**
   * @brief Flags user touch event. 
   */
  BOOL touchFlag;
  /**
   * @brief Stores the touch position. 
   */
  CGPoint startTouch;

  /**
   * @brief Stores the delgate object.
   */
  IBOutlet id<FlowCoverViewGLDelegate> delegate;

  /**
   * @brief The texture reference cache.
   */
  FCDataCache *cache;

  /**
   * @brief OpenGL ES render buffer width.
   */
  GLint backingWidth;
  /**
   * @brief OpenGL ES render buffer height.
   */
  GLint backingHeight;
  /**
   * @brief The OpenGL ES context.
   */
  EAGLContext *context;
  /**
   * @brief The OpenGL ES render buffer.
   */
  GLuint viewRenderbuffer;
  
  /**
   * @brief The OpenGL ES frame buffer.
   */
  GLuint viewFramebuffer;
  /**
   * @brief The OpenGL ES depth buffer.
   */
  GLuint depthRenderbuffer;

  /**
   * @brief Stores the tile facing setting.
   */
  FlowCoverFacing facing;
  /**
   * @brief Stores the tile arrangement setting.
   */
  FlowCoverSwipeDirection direction;
  /**
   * @brief Stores the tile refleciton setting.
   */
  FlowCoverReflection reflection;
  /**
   * @brief Size tile images.
   */
  CGSize imageSize;
  /**
   * @brief The smallest number that is power of 2 and larger than image size.
   * @details
   * This number is the number that is larger than the larger one of image's
   * size, and is power of 2. It is used in memory allocation.
   * @remark
   * This variable is deprecated, since the texture size is not required to be
   * power of 2 now. It may be removed in future version.
   */
  int textureRange;
  /**
   * @brief A flag that denotes if the view is rolling.
   */
  BOOL beganRolling;
  /**
   * @brief X of tiles' modeled origin.
   * @details
   * Tiles are rectangle plain models, which are quads. Their dimension are
   * (-tileOriginX, -tileOriginY, 0) - (tileOriginX, tileOriginY, 0)
   */
  float tileOriginX;
  /**
   * @brief Y of tiles' modeled origin.
   * @details
   * Tiles are rectangle plain models, which are quads. Their dimension are
   * (-tileOriginX, -tileOriginY, 0) - (tileOriginX, tileOriginY, 0)
   */
  float tileOriginY;
}

/**
 * @brief Number of visible tiles.
 */
@property (nonatomic, assign, setter = setNumVisibleTile:) int numVisibleTile;
/**
 * @brief Stores the delgate object.
 */
@property (nonatomic, assign) id<FlowCoverViewGLDelegate> delegate;
/**
 * @brief Stores the tile arrangement setting.
 */
@property (nonatomic, assign) FlowCoverSwipeDirection direction;
/**
 * @brief Stores the tile facing setting.
 */
@property (nonatomic, assign) FlowCoverFacing facing;
/**
 * @brief Stores the tile refleciton setting.
 */
@property (nonatomic, assign) FlowCoverReflection reflection;
/**
 * @brief
 * Screen display ratio reference, for scaling objects to fit viewport.
 */
@property (nonatomic, assign) double screenDisplayRatio;
/**
 * @brief Spread between images (between -1 ~ 1).
 */
@property (nonatomic, assign) double imageSpread;
/**
 * @brief This is how much an image is rotated
 * @remark rotation = arccos(±imageRotation).
 */
@property (nonatomic, assign) double imageRotation;
/**
 * @brief How image moved backward as they spread (between 0 ~ 1).
 * @remark
 * Scaling is used to simulate perspective depth, instead of using GLUT.
 */
@property (nonatomic, assign) double depthSpread;
/**
 * @brief Tiles becoming transparent as they spread (between 0 ~ 1).
 */
@property (nonatomic, assign) float alphaSpread;
/**
 * @brief Size tile images.
 */
@property (nonatomic, assign, setter = setImageSize :) CGSize imageSize;
/**
 * @brief Index of the focused tile.
 */
@property (nonatomic, assign, getter = getFocusedIndex, setter = setFocusedIndex :) int focusedIndex;


/**
 * @brief Draws the FlowCover view with current state.
 */
- (void)redraw;

/**
 * @brief Force reloading of an image by removing it from the cache.
 * @param[in] index Index to the image to be invalidated.
 */
- (void)invalidateImageAtIndex:(int)index;

/**
 * @brief Force reloading of all images by clearing the cache.
 */
- (void)invalidateAllImages;

@end


/**
 * @brief The delegate gets called by the .
 * @details
 * Provides the interface for the delegate used by FlowCoverGL. This provides
 * a way for the view to get images, to get the total number of images, and to
 * send messages.
 */
@protocol FlowCoverViewGLDelegate<NSObject>
/**
 * @brief Returns the number of images to be shown in the view.
 * @param[in] view Pointer to the hosting .
 * @returns The number of images to be shown in the view.
 */
- (int)flowCoverGLNumberOfImages:(FlowCoverViewGL*)view;
/**
 * @brief Returns the image at the given position.
 * @param[in] view Pointer to the hosting .
 * @param[in] cover The 0-based index the image to be retrieved.
 * @returns Pointer to the images retrieved.
 */
- (UIImage*)flowCoverGL:(FlowCoverViewGL*)view cover:(int)cover;
@optional
/**
 * @brief This is called when use press a tile in the view.
 * @param[in] view Pointer to the hosting .
 * @param[in] cover The 0-based index the pressed tile.
 */
- (void)flowCoverGL:(FlowCoverViewGL*)view didSelect:(int)cover;
/**
 * @brief This is called when use a tile becomes focused.
 *
 * @details
 * The focused tile is the largest one at the center of the view, which will
 * always face forward despite of settings.
 *
 * @param[in] view Pointer to the hosting .
 * @param[in] cover The 0-based index the focused tile.
 */
- (void)flowCoverGL:(FlowCoverViewGL*)view didFocus:(int)cover;
/**
 * @brief This is called when the view is dragged by user and starts rolling.
 * @param[in] view Pointer to the  that starts rolling.
 */
- (void)flowCoverGLWillBeginRolling:(FlowCoverViewGL*)view;
/**
 * @brief This is called when the view is dragged by user and stops rolling.
 * @param[in] view Pointer to the  that stops rolling.
 */
- (void)flowCoverGLWillEndRolling:(FlowCoverViewGL*)view;
@end

