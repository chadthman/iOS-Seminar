//
//  ATDetailViewController.m
//  AssignmentThree
//
//  Created by Chad Marmon on 2/2/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//
#import "ATTabBar.h"
#import "ATDetailViewController.h"

@interface ATDetailViewController ()
{
    ATDetailViewController *detailViewController;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation ATDetailViewController

#pragma mark - Managing the detail item

//Why isnt there a constuctor in this language. Would have been usefull to have for what i was trying below
- (IBAction) onAdvance
{
    //UIStoryboard*  story = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    //ATDetailViewController *detailViewController = [_story instantiateInitialViewController];
    //detailViewController = [_story instantiateInitialViewController];
    
    // Pass the selected object to the new view controller.
    
    //[self incrementByOne];
    //[self.navigationController pushViewController:detailViewController animated:YES];
    //[self.navigationController pushViewController:detailViewController animated:YES];
}

//- (void) incrementByOne
//{
//    count++;
//    self.detailDescriptionLabel.text = [NSString stringWithFormat:@"The page number is: %i", count];
//}

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.
    NSString *number = [NSString stringWithFormat:@"Page Number is: %i", count];
    
    if (self.detailItem) {
        self.detailDescriptionLabel.text = number;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _story = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
