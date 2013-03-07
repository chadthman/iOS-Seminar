//
//  ATMasterViewController.m
//  AssignmentThree
//
//  Created by Chad Marmon on 2/2/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

// Meets requirements, 100%.

#import "ATMasterViewController.h"

#import "ATDetailViewController.h"

@interface ATMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation ATMasterViewController

@synthesize redViewController;


//None of this IBAction stuff works below:
-(IBAction)toRedButton
{
    //[self.redViewController setDetailDescriptionLabel:@"this is a label i created"];
    //NSString * viewControllerID = @"ViewID";
    //[self.splitViewController.navigationController performSegueWithIdentifier:@"toRed" sender:self.splitViewController.navigationController];
}
//UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];


-(IBAction)toBlueButton
{
    //UIStoryboard *storyboard = self.storyboard;
//    NSLog(@"something");
//    [self.splitViewController.navigationController performSegueWithIdentifier:@"toBlue" sender:self];
    //[self.splitViewController.navigationController set]
    
    //[storyboard instantiateViewController];
    //[self.splitViewController.navigationController pushViewController: animated:<#(BOOL)#>:@"toBlue" sender: storyboard];
    
}

-(IBAction)toGreenButton
{
    //[self.splitViewController.navigationController performSegueWithIdentifier:@"toGreen" sender:self.splitViewController];
}

- (void)awakeFromNib
{
    //self.clearsSelectionOnViewWillAppear = NO;
    
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.redViewController = (ATDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

@end
