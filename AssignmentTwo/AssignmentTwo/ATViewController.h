//
//  ATViewController.h
//  AssignmentTwo
//
//  Created by Chad Marmon on 1/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ATChildView;
@interface ATViewController : UIViewController
@property IBOutlet UIView *childView;
@property (nonatomic, retain) ATChildView *drawViewContainer;
@property (nonatomic, retain) UIViewController* currentChild;

-(IBAction)onButtonDown:(id)sender;


@end
