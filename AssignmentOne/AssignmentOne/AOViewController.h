//
//  AOViewController.h
//  AssignmentOne
//
//  Created by Chad Marmon on 1/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AOViewController : UIViewController
{
    @private
    IBOutlet UILabel *label;
    IBOutlet UIButton *button;
    BOOL flipped;
}

-(void)changeText;

-(IBAction)onButtonDown;
-(IBAction)onButtonUp;

@end
