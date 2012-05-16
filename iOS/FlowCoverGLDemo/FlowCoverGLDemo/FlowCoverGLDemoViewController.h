//
//  FlowCoverGLDemoViewController.h
//  FlowCoverGLDemo
//
//  Created by Jackey Cheung on 2012-5-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FlowCoverViewGL.h"


@interface FlowCoverGLDemoViewController : UIViewController<FlowCoverViewDelegate>
{
  NSMutableArray *images;
  
  UIView *settingsView;
  UISlider *imageSpread;
  UISlider *depthSpread;
  UISlider *alphaSpread;
  UISwitch *hideSettings;
  UISlider *imageRotation;
  UISwitch *topRelfection;
  UISwitch *leftRelfection;
  UISwitch *bottomRelfection;
  UISwitch *rightRelfection;
  UISegmentedControl *facing;
  UIButton *settingsButton;
  FlowCoverViewGL *flowCover;
  UILabel *valuesLabel;
  UISegmentedControl *presets;
}

@property (nonatomic, retain) IBOutlet UIView *settingsView;
@property (nonatomic, retain) IBOutlet UISlider *imageSpread;
@property (nonatomic, retain) IBOutlet UISlider *depthSpread;
@property (nonatomic, retain) IBOutlet UISlider *alphaSpread;
@property (nonatomic, retain) IBOutlet UISwitch *hideSettings;
@property (nonatomic, retain) IBOutlet UISlider *imageRotation;
@property (nonatomic, retain) IBOutlet UISwitch *topRelfection;
@property (nonatomic, retain) IBOutlet UISwitch *leftRelfection;
@property (nonatomic, retain) IBOutlet UISwitch *bottomRelfection;
@property (nonatomic, retain) IBOutlet UISwitch *rightRelfection;
@property (nonatomic, retain) IBOutlet UISegmentedControl *facing;
@property (nonatomic, retain) IBOutlet UIButton *settingsButton;
@property (nonatomic, retain) IBOutlet FlowCoverViewGL *flowCover;
@property (nonatomic, retain) IBOutlet UILabel *valuesLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *presets;


- (IBAction)didPressTry:(id)sender;
- (IBAction)didPressSettings:(id)sender;
- (IBAction)didSelectPreset:(id)sender;
- (IBAction)sliderValueDidChange:(id)sender;
- (IBAction)didSelectReflection:(id)sender;


@end
