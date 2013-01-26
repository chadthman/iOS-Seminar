//
//  AOViewController.m
//  AssignmentOne
//
//  Created by Chad Marmon on 1/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "AOViewController.h"

@interface AOViewController ()

@end

@implementation AOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    flipped = true;
	label.text = @"Press the Button";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onButtonDown
{
    flipped = false;
    [self changeText];
}

-(IBAction)onButtonUp
{
    flipped = true;
    [self changeText];
}

-(void)changeText
{
    if (flipped)
    {
        label.text = @"Press the Button";
    } else {
        label.text = @"Release the Button";
    }
}

@end
