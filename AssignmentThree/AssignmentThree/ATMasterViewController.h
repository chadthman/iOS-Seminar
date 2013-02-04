//
//  ATMasterViewController.h
//  AssignmentThree
//
//  Created by Chad Marmon on 2/2/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ATDetailViewController;
@class ATBlueViewController;
@class ATGreenViewController;

@interface ATMasterViewController : UIViewController

@property (strong, nonatomic) ATDetailViewController *redViewController;
@property (strong, nonatomic) ATBlueViewController *blueViewController;
@property (strong, nonatomic) ATGreenViewController *greenViewController;

-(IBAction)toRedButton;
-(IBAction)toBlueButton;
-(IBAction)toGreenButton;


@end
