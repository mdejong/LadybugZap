//
//  ViewController.m
//  LadybugZap
//
//  Created by Moses DeJong on 6/17/13.
//  Copyright (c) 2013 HelpURock. All rights reserved.
//

#import "ViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

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
  
  CALayer *ladybugLayer = [CALayer layer];
  CGRect frame = self.ladybugImageView.frame;
  ladybugLayer.frame = frame;
  UIImage *image = self.ladybugImageView.image;
  ladybugLayer.contents = (id) image.CGImage;
  
  [self.view.layer addSublayer:ladybugLayer];
  
  self.ladybugImageView.hidden = TRUE;

  return;
}

@end
