//
//  ATViewController.m
//  AssignmentTwo
//
//  Created by Chad Marmon on 1/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "ATViewController.h"
#import "ATChildView.h"

@interface ATViewController ()

@end

@implementation ATViewController
@synthesize childView;
@synthesize currentChild;
@synthesize drawViewContainer;


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle: nil];
    currentChild = [self.childViewControllers lastObject];
    drawViewContainer = (ATChildView*)[mainStoryboard instantiateViewControllerWithIdentifier: @"child"];
    drawViewContainer.view.frame = childView.frame;
    [childView addSubview:drawViewContainer.view];
    
	// Do any aditional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onButtonDown:(id)sender
{
    [drawViewContainer  changeState];
}

@end
