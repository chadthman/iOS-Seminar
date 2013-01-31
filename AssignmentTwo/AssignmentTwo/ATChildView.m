//
//  ATChildView.m
//  AssignmentTwo
//
//  Created by Chad Marmon on 1/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "ATChildView.h"
#import "ATDrawingView.h"

@interface ATChildView ()

@end

@implementation ATChildView

@synthesize top;
@synthesize mid;
@synthesize bottom;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateState];
}

- (void) changeState
{
    switch (state) {
        case 0:
            state = 1;
            break;
        case 1:
            state = 2;
            break;
        case 2:
            state = 0;
            break;
        default:
            break;
    }
    [self updateState];
    [self.view setNeedsDisplay];
}

- (void) updateState
{
    switch (state) {
        case 0:
            [top setBackgroundColor:[UIColor orangeColor]]; //I change the background colors
            [mid setBackgroundColor:[UIColor blackColor]];
            [bottom setBackgroundColor:[UIColor redColor]];
            
            [top setColor:[UIColor blackColor]];            //also change what is being drawn
            [mid setColor:[UIColor redColor]];
            [bottom setColor:[UIColor orangeColor]];
            
            [top firstDrawing];                             //sets what shapes are drawn in this state
            [mid firstDrawing];
            [bottom firstDrawing];
            break;
        case 1:
            [top setBackgroundColor:[UIColor whiteColor]];
            [mid setBackgroundColor:[UIColor purpleColor]];
            [bottom setBackgroundColor:[UIColor yellowColor]];

            [top setColor:[UIColor blueColor]];
            [mid setColor:[UIColor greenColor]];
            [bottom setColor:[UIColor purpleColor]];
            
            [top secondDrawing];
            [mid secondDrawing];
            [bottom secondDrawing];
            break;
        case 2:
            [top setBackgroundColor:[UIColor grayColor]];
            [mid setBackgroundColor:[UIColor greenColor]];
            [bottom setBackgroundColor:[UIColor blueColor]];

            [top setColor:[UIColor redColor]];
            [mid setColor:[UIColor blackColor]];
            [bottom setColor:[UIColor yellowColor]];
            
            [top thirdDrawing];
            [mid thirdDrawing];
            [bottom thirdDrawing];
            break;
        default:
            break;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
