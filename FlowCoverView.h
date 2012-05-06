/*	FlowCoverView.h
 *
 *		FlowCover view engine; emulates CoverFlow.
 */


/***
 
 Copyright 2008 William Woody, All Rights Reserved.
 
 Redistribution and use in source and binary forms, with or without 
 modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this 
 list of conditions and the following disclaimer.
 
 Neither the name of Chaos In Motion nor the names of its contributors may be 
 used to endorse or promote products derived from this software without 
 specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
 THE POSSIBILITY OF SUCH DAMAGE.
 
 Contact William Woody at woody@alumni.caltech.edu or at 
 woody@chaosinmotion.com. Chaos In Motion is at http://www.chaosinmotion.com
 
 ***/


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "DataCache.h"

typedef enum
{
  FlowCoverSwipeHorizontal = 0,
  FlowCoverSwipeVertical
}FlowCoverSwipeDirection;

typedef enum
{
  FlowCoverFaceInward = 0,
  FlowCoverFaceOutward,
  FlowCoverFaceForward
}FlowCoverFacing;

typedef enum
{
  FlowCoverReflectionNone = 0,
  FlowCoverReflectOnBottom = 1,
  FlowCoverReflectOnLeft = 2,
  FlowCoverReflectOnTop = 4,
  FlowCoverReflectOnRight = 8,
  FlowCoverReflectOnBothHorizontalSides = 10,
  FlowCoverReflectOnBothVerticalSides = 5,
  FlowCoverReflectOnAllSides = 15
}FlowCoverReflection;


@protocol FlowCoverViewDelegate;

/*	FlowCoverView
 *
 *		The flow cover view class; this is a drop-in view which calls into
 *	a delegate callback which controls the contents. This emulates the CoverFlow
 *	thingy from Apple.
 */

@interface FlowCoverView : UIView 
{
	// Current state support
	double offset;
  
  // screen display ratio reference, for scaling objects to fit viewport
  double screenDisplayRatio;
  // spread between images (screen measured from -1 to 1)
	double imageSpread;
  // this is how much an image is rotated (= arccos(±imageRotation))
  double imageRotation;
  // how image moved backward as they spread, not used yet.
  // TODO: can use scaling to simulate perspective depth, instead of using GLUT
  double depthSpread;
  // tiles becoming transparent as the spread.
  float alphaSpread;
  
	NSTimer *timer;
	double startTime;
	double startOff;
	double startPos;
	double startSpeed;
	double runDelta;
	BOOL touchFlag;
	CGPoint startTouch;
	
	double lastPos;
	
	// Delegate
	IBOutlet id<FlowCoverViewDelegate> delegate;
	
	DataCache *cache;
	
	// OpenGL ES support
  GLint backingWidth;
  GLint backingHeight;
  EAGLContext *context;
  GLuint viewRenderbuffer, viewFramebuffer;
  GLuint depthRenderbuffer;
  
  // attributess
  FlowCoverFacing facing;
  FlowCoverSwipeDirection direction;
  FlowCoverReflection reflection;
  CGSize textureSize;
  int textureRange;
  BOOL beganRolling;
}

@property (nonatomic, assign) id<FlowCoverViewDelegate> delegate;
@property (nonatomic, assign) FlowCoverSwipeDirection direction;
@property (nonatomic, assign) FlowCoverFacing facing;
@property (nonatomic, assign) FlowCoverReflection reflection;
@property (nonatomic, assign) double screenDisplayRatio;
@property (nonatomic, assign) double imageSpread;
@property (nonatomic, assign) double imageRotation;
@property (nonatomic, assign) double depthSpread;
@property (nonatomic, assign) float alphaSpread;
@property (nonatomic, assign) CGSize textureSize;


- (void)draw;					// Draw the FlowCover view with current state

@end

/*	FlowCoverViewDelegate
 *
 *		Provides the interface for the delegate used by my flow cover. This
 *	provides a way for me to get the image, to get the total number of images,
 *	and to send a select message
 */

@protocol FlowCoverViewDelegate <NSObject>
- (int)flowCoverNumberImages:(FlowCoverView *)view;
- (UIImage *)flowCover:(FlowCoverView *)view cover:(int)cover;
- (void)flowCover:(FlowCoverView *)view didSelect:(int)cover;
@optional
- (void)flowCover:(FlowCoverView*)view didFocus:(int)cover;
- (void)flowCoverWillBeginRolling:(FlowCoverView*)view;
- (void)flowCoverWillEndRolling:(FlowCoverView*)view;
@end
