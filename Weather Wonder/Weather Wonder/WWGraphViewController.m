//
//  WWGraphViewController.m
//  Weather Wonder
//
//  Created by Chad Marmon on 3/15/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "WWGraphViewController.h"
#import "WWCollectionViewController.h"

@interface WWGraphViewController ()
{
    __weak IBOutlet UIButton *weatherButton;
}

@end

@implementation WWGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    weatherDisplay = [[NSUserDefaults standardUserDefaults] boolForKey:@"weatherDisplay"];
    if (weatherDisplay)
    {
        [weatherButton setTitle:@"Switch to Day View" forState:UIControlStateNormal];
    } else {
        [weatherButton setTitle:@"Switch to Hour View" forState:UIControlStateNormal];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)weatherDisplayButton:(id)sender
{
    WWCollectionViewController *newController = [[WWCollectionViewController alloc] init];
    if (weatherDisplay)
    {
        [weatherButton setTitle:@"Switch to Day View" forState:UIControlStateNormal];
        weatherDisplay = false;
    } else {
        [weatherButton setTitle:@"Switch to Hour View" forState:UIControlStateNormal];
        weatherDisplay = true;
    }
    [newController refresh];
    [[NSUserDefaults standardUserDefaults] setBool:weatherDisplay forKey:@"weatherDisplay"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
