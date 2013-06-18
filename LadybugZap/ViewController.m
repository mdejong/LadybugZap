//
//  ViewController.m
//  LadybugZap
//
//  Created by Moses DeJong on 6/17/13.
//  Copyright (c) 2013 HelpURock. All rights reserved.
//

#import "ViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AVFileUtil.h"

#import "AVAnimatorView.h"
#import "AVAnimatorLayer.h"
#import "AVAnimatorMedia.h"
#import "AVMvidFrameDecoder.h"

#import "AVGIF89A2MvidResourceLoader.h"
#import "AV7zAppResourceLoader.h"

@interface ViewController ()

@property (nonatomic, retain) NSTimer *startupTimer;

// Will replace backgroundImageView once media is loaded and ready to play

@property (nonatomic, retain) AVAnimatorView *backgroundAnimatorView;

@property (nonatomic, retain) AVAnimatorMedia *backgroundAnimatorMedia;

@property (nonatomic, retain) CALayer *ladybugLayer;

@property (nonatomic, retain) AVAnimatorLayer *ladybugAnimatorLayer;

@property (nonatomic, retain) AVAnimatorMedia *ladybugAnimatorMedia;

@property (nonatomic, retain) AVAnimatorMedia *ladybugZapAnimatorMedia;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
 
  // Explicitly force autolayout to complete so that frame for views inside
  // the main is defined.
  
  [super.view layoutIfNeeded];
  
  // Create ladybug CALayer and place it in the parent container
  
  NSAssert(self.ladybugImageView, @"ladybugImageView");
  NSAssert(self.backgroundImageView, @"backgroundImageView");
  
  // Add layer so that it appears above the background layer
  
  CALayer *ladybugLayer = [CALayer layer];
  CGRect frame = self.ladybugImageView.frame;
  ladybugLayer.frame = frame;
  UIImage *image = self.ladybugImageView.image;
  ladybugLayer.contents = (id) image.CGImage;
  
  self.ladybugLayer = ladybugLayer;
  
  [self.view.layer addSublayer:ladybugLayer];
  
  self.ladybugImageView.hidden = TRUE;

  // Note that setupMedia is not invoked here since views have not actually been
  // added to the parent views yet. Instead, do the minimal setup at init time so that
  // the initial screen appears quickly. Then, start media loading once the app
  // start time goes off.
  
  self.startupTimer = [NSTimer timerWithTimeInterval: 0.1
                                              target: self
                                            selector: @selector(startupTimer:)
                                            userInfo: NULL
                                             repeats: FALSE];
  
  [[NSRunLoop currentRunLoop] addTimer:self.startupTimer forMode: NSDefaultRunLoopMode];
  
  return;
}

// Invoked just a bit after app is loaded, it is better to init things outside of the
// window init path for a number of reasons.

- (void) startupTimer:(NSTimer*)timer
{
  self.startupTimer = nil;
  
  [self setupMedia];
}

// This method is invoked when the window is loaded, it will kick off media loading in the
// background and deliver a notification when the animations are ready

- (void) setupMedia
{
  NSString *resFilename;
  NSString *tmpFilename;
  NSString *tmpPath;
  AVAnimatorMedia *media;
  
  // Kick off background loading of the Animated GIF that shows a radar animation over a map.
  // A media object controls timing and playback while the load decodes the .gif to .mvid.
  // Once the media is loaded, it will loop forever automatically.
  
  {
    resFilename = @"RadarLoop.gif";
    tmpFilename = @"RadarLoop.mvid";
    tmpPath = [AVFileUtil getTmpDirPath:tmpFilename];
    
    AVGIF89A2MvidResourceLoader *resLoader = [AVGIF89A2MvidResourceLoader aVGIF89A2MvidResourceLoader];
    
    resLoader.movieFilename = resFilename;
    resLoader.outPath = tmpPath;
    
    // Create Media object
    
    media = [AVAnimatorMedia aVAnimatorMedia];
    media.resourceLoader = resLoader;
    media.frameDecoder = [AVMvidFrameDecoder aVMvidFrameDecoder];
    
    media.animatorFrameDuration = 0.1;
   
    media.animatorRepeatCount = INT_MAX;
    
    self.backgroundAnimatorMedia = media;
    
    // Create backgroundAnimatorView the exact same size as existing self.backgroundImageView
    // and replace it in the view tree.
    
    CGRect frame = self.backgroundImageView.frame;
    
    self.backgroundAnimatorView = [AVAnimatorView aVAnimatorViewWithFrame:frame];
    
    self.backgroundAnimatorView.backgroundColor = self.backgroundImageView.backgroundColor;
    
    self.backgroundAnimatorView.image = self.backgroundImageView.image;
    
    [self.view insertSubview:self.backgroundAnimatorView aboveSubview:self.backgroundImageView];
    
    [self.backgroundImageView removeFromSuperview];
    
    self.backgroundImageView = nil;
    
    // This media object will simply loop in the background, it does not need to sync with UI
    // elements of other code, so invoke play to indicate that media should play as soon as it
    // is ready.
    
    [self.backgroundAnimatorView attachMedia:media];
    
    [media startAnimator];
  }
  
  // Load media that show the ladybug walking in a loop, it will play in a loop when ready
  
  {
    resFilename = @"LadybugGray.mvid.7z";
    tmpFilename = @"LadybugGray.mvid";
    tmpPath = [AVFileUtil getTmpDirPath:tmpFilename];
    
    AV7zAppResourceLoader *resLoader = [AV7zAppResourceLoader aV7zAppResourceLoader];
    resLoader.archiveFilename = resFilename;
    resLoader.movieFilename = tmpFilename;
    resLoader.outPath = tmpPath;
    
    // Create Media object
    
    media = [AVAnimatorMedia aVAnimatorMedia];
    media.resourceLoader = resLoader;
    media.frameDecoder = [AVMvidFrameDecoder aVMvidFrameDecoder];
    
    media.animatorFrameDuration = 0.1;
    
    media.animatorRepeatCount = INT_MAX;
    
    self.ladybugAnimatorMedia = media;
    
    // Create AVAnimatorLayer object, this object acts as a bridge between the AVAnimator
    // media object and the CALayer which exists in the view heir. This object must retain
    // the ladybugAnimatorLayer since there is no direct ref held by the CALayer.
    
    self.ladybugAnimatorLayer = [AVAnimatorLayer aVAnimatorLayer:self.ladybugLayer];
    
    // This media starts to animate right away, to show the bug walking.
    
    [self.ladybugAnimatorLayer attachMedia:media];
    
    [media startAnimator];
  }
  
  // The Zap animation loop will be displayed when the bug is hit by the radar. It does not
  // play automatically, simply wait until it is ready before actually showing the zap animation.
  // Since the zap animation will make use of the self.ladybugAnimatorLayer to render, we
  // only need to attach it to the existing object.
 
  {
    resFilename = @"LadybugGrayGlow.mvid.7z";
    tmpFilename = @"LadybugGrayGlow.mvid";
    tmpPath = [AVFileUtil getTmpDirPath:tmpFilename];
    
    AV7zAppResourceLoader *resLoader = [AV7zAppResourceLoader aV7zAppResourceLoader];
    resLoader.archiveFilename = resFilename;
    resLoader.movieFilename = tmpFilename;
    resLoader.outPath = tmpPath;
    
    // Create Media object
    
    media = [AVAnimatorMedia aVAnimatorMedia];
    media.resourceLoader = resLoader;
    media.frameDecoder = [AVMvidFrameDecoder aVMvidFrameDecoder];
    
    media.animatorFrameDuration = 0.1;
    
    // The Zap animation does not loop, it plays once and then the normal loop is played again
    
    self.ladybugZapAnimatorMedia = media;
    
    [media prepareToAnimate];
    
    // Setup callback that will be invoked once media is ready
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animatorPreparedLadybugZapNotification:)
                                                 name:AVAnimatorPreparedToAnimateNotification
                                               object:media];

  }
  
  return;
}

- (void) animatorPreparedLadybugZapNotification:(NSNotification*)notification
{
  return;
}

@end
