//
//  ViewController.h
//  LadybugZap
//
//  Created by Moses DeJong on 6/17/13.
//  Copyright (c) 2013 HelpURock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

// backgroundImageView will be set in the NIB, it will be replaced with
// a AVAnimatorView once background media is finished loading just to
// keep things simple.

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, retain) IBOutlet UIImageView *ladybugImageView;

@end
