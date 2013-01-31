//
//  ATChildView.h
//  AssignmentTwo
//
//  Created by Chad Marmon on 1/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATDrawingView.h"
@class ATDrawingView;
@interface ATChildView : UIViewController
{
    int state;
}

@property IBOutlet ATDrawingView* top;
@property IBOutlet ATDrawingView* mid;
@property IBOutlet ATDrawingView* bottom;

-(void)changeState;

@end
