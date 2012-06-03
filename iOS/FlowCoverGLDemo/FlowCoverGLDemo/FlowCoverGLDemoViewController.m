//
//  FlowCoverGLDemoViewController.m
//  FlowCoverGLDemo
//
//  Created by Jackey Cheung on 2012-5-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FlowCoverGLDemoViewController.h"


#define IMAGE_PATH      @"images"


@implementation FlowCoverGLDemoViewController
@synthesize flowCover;
@synthesize valuesLabel;
@synthesize presets;
@synthesize hideSettings;
@synthesize settingsButton;
@synthesize settingsView;
@synthesize imageSpread;
@synthesize imageRotation;
@synthesize topRelfection;
@synthesize leftRelfection;
@synthesize bottomRelfection;
@synthesize rightRelfection;
@synthesize facing;
@synthesize depthSpread;
@synthesize alphaSpread;


#pragma mark - Flow Cover Related
- (int)flowCoverGLNumberOfImages:(FlowCoverViewGL*)view
{
  return [images count];
}

- (UIImage*)flowCoverGL:(FlowCoverViewGL*)view cover:(int)cover
{
  return [imageCache imageAtPath:[images objectAtIndex:cover] async:YES];
}

- (void)flowCoverGL:(FlowCoverViewGL*)view didSelect:(int)cover
{
  // nothing here yet.
}

- (void)flowCoverGL:(FlowCoverViewGL*)view didFocus:(int)cover
{
  // nothing here yet.
}

- (void)flowCoverGLWillBeginRolling:(FlowCoverViewGL*)view
{
  settingsButton.hidden = presets.hidden = hideSettings.on;
}

- (void)flowCoverGLWillEndRolling:(FlowCoverViewGL*)view
{
  settingsButton.hidden = presets.hidden = NO;
}

- (void)rotateRelection:(int)preset
{
  switch(preset)
  {
    case 0:
      if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
      {
        self.topRelfection.on = self.leftRelfection.on = self.bottomRelfection.on = NO;
        self.rightRelfection.on = YES;
        flowCover.reflection = FlowCoverReflectOnRight;
      }
      else
      {
        self.topRelfection.on = self.leftRelfection.on = self.rightRelfection.on = NO;
        self.bottomRelfection.on = YES;
        flowCover.reflection = FlowCoverReflectOnBottom;
      }
      break;
      
    case 1:
      if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
      {
        self.topRelfection.on = self.leftRelfection.on = self.bottomRelfection.on = NO;
        self.rightRelfection.on = YES;
        flowCover.reflection = FlowCoverReflectOnRight;
      }
      else
      {
        self.topRelfection.on = self.leftRelfection.on = self.rightRelfection.on = NO;
        self.bottomRelfection.on = YES;
        flowCover.reflection = FlowCoverReflectOnBottom;
      }
      break;
      
    case 2:
      if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
      {
        self.topRelfection.on = self.leftRelfection.on = self.bottomRelfection.on = NO;
        self.rightRelfection.on = YES;
        flowCover.reflection = FlowCoverReflectOnRight;
      }
      else
      {
        self.topRelfection.on = self.leftRelfection.on = self.rightRelfection.on = NO;
        self.bottomRelfection.on = YES;
        flowCover.reflection = FlowCoverReflectOnBottom;
      }
      break;
      
    case 3:
      break;
      
    default:
      break;
  }
}

- (void)loadPreset:(int)preset
{
  switch(preset)
  {
    case 0:
      self.alphaSpread.value = 0;
      self.depthSpread.value = 0;
      self.imageSpread.value = .1;
      self.imageRotation.value = .4;
      self.facing.selectedSegmentIndex = 0;
      flowCover.alphaSpread = 0;
      flowCover.depthSpread = 0;
      flowCover.imageSpread = .1;
      flowCover.imageRotation = .4;
      flowCover.facing = FlowCoverFaceInward;
      break;
      
    case 1:
      self.alphaSpread.value = .1;
      self.depthSpread.value = .07;
      self.imageSpread.value = .3;
      self.imageRotation.value = .2;
      self.facing.selectedSegmentIndex = 0;
      flowCover.alphaSpread = .1;
      flowCover.depthSpread = .07;
      flowCover.imageSpread = .3;
      flowCover.imageRotation = .2;
      flowCover.facing = FlowCoverFaceInward;
      break;
      
    case 2:
      self.alphaSpread.value = .1;
      self.depthSpread.value = .07;
      self.imageSpread.value = .3;
      self.imageRotation.value = .2;
      self.facing.selectedSegmentIndex = 2;
      flowCover.alphaSpread = .1;
      flowCover.depthSpread = .07;
      flowCover.imageSpread = .3;
      flowCover.imageRotation = .2;
      flowCover.facing = FlowCoverFaceForward;
      break;
      
    case 3:
      self.alphaSpread.value = 0;
      self.depthSpread.value = 1;
      self.imageSpread.value = .5;
      self.imageRotation.value = .2;
      self.facing.selectedSegmentIndex = 0;
      flowCover.alphaSpread = 0;
      flowCover.depthSpread = 1;
      flowCover.imageSpread = .5;
      flowCover.imageRotation = .2;
      flowCover.facing = FlowCoverFaceInward;
      self.topRelfection.on = self.leftRelfection.on = self.rightRelfection.on = self.bottomRelfection.on = YES;
      flowCover.reflection = FlowCoverReflectOnAllSides;
      break;
     
    default:
      break;
  }
  [self rotateRelection:preset];
  [flowCover redraw];
}

- (void)imageCache:(FCImageCache*)cache didLoadImage:(UIImage*)image fromPath:(NSString*)path
{
  [flowCover invalidateImageAtIndex:[images indexOfObject:path]];
  [flowCover redraw];
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
  [super viewDidLoad];

  // create image cache
  imageCache = [[FCImageCache alloc] initWithCapacity:10 imageNamed:@"loading.jpg"];
  imageCache.delegate = self;

  // prepare images
  images = [[NSMutableArray arrayWithCapacity:10] retain];
  NSString *path = [[NSBundle mainBundle] resourcePath];
  for(int i = 0; i < 10; i++)
    [images addObject:[NSString stringWithFormat:@"%@/%d.jpg", path, i]];

  // initialize Flow Cover
  flowCover.focusedIndex = [images count] / 2;
  flowCover.imageSize = CGSizeMake(390, 450);
}

- (void)viewDidUnload
{
  [self setFlowCover:nil];
  [self setSettingsView:nil];
  [self setImageSpread:nil];
  [self setImageRotation:nil];
  [self setDepthSpread:nil];
  [self setAlphaSpread:nil];
  [self setSettingsButton:nil];
  [self setHideSettings:nil];
  [self setFacing:nil];
  [self setTopRelfection:nil];
  [self setLeftRelfection:nil];
  [self setBottomRelfection:nil];
  [self setRightRelfection:nil];
  [self setValuesLabel:nil];
  [self setPresets:nil];
  [self setPresets:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  [images release];
  images = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    flowCover.direction = FlowCoverSwipeVertical;
  else
    flowCover.direction = FlowCoverSwipeHorizontal;
  flowCover.screenDisplayRatio = self.view.bounds.size.width / self.view.bounds.size.height;
  [self rotateRelection:presets.selectedSegmentIndex];
  [flowCover redraw];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return YES;
}

- (void)dealloc
{
  [flowCover release];
  [settingsView release];
  [imageSpread release];
  [imageRotation release];
  [depthSpread release];
  [alphaSpread release];
  [images release];
  [settingsButton release];
  [hideSettings release];
  [facing release];
  [topRelfection release];
  [leftRelfection release];
  [bottomRelfection release];
  [rightRelfection release];
  [valuesLabel release];
  [presets release];
  [super dealloc];
}


#pragma mark - Event handling
- (IBAction)didPressTry:(id)sender
{
  flowCover.alphaSpread = alphaSpread.value;
  flowCover.depthSpread = depthSpread.value;
  flowCover.imageSpread = imageSpread.value;
  flowCover.imageRotation = imageRotation.value;
  flowCover.facing = facing.selectedSegmentIndex;
  flowCover.reflection = (int)bottomRelfection.on | (int)leftRelfection.on << 1 | (int)topRelfection.on << 2 | (int)rightRelfection.on << 3;
  [flowCover redraw];
  settingsView.hidden = YES;
  settingsButton.hidden = NO;
}

- (IBAction)didPressSettings:(id)sender
{
  settingsView.hidden = NO;
  settingsButton.hidden = YES;
}

- (IBAction)didSelectPreset:(id)sender
{
  [self loadPreset:[(UISegmentedControl*)sender selectedSegmentIndex]];
}

- (IBAction)sliderValueDidChange:(id)sender
{
  valuesLabel.text = [NSString stringWithFormat:@"spreads(alpha:%f, depth:%f, image:%f), image rotation:%f", alphaSpread.value, depthSpread.value, imageSpread.value, imageRotation.value];
  presets.selectedSegmentIndex = UISegmentedControlNoSegment;
}

- (IBAction)didSelectReflection:(id)sender
{
  presets.selectedSegmentIndex = UISegmentedControlNoSegment;
}


@end
