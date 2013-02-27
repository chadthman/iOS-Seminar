//
//  AFLoadingScreen.m
//  AssignmentFive
//
//  Created by Chad Marmon on 2/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "AFLoadingScreen.h"
#import "AFViewController.h"

@interface AFLoadingScreen ()
{
    __weak IBOutlet UIActivityIndicatorView *spinner;
}

@end

static NSString* const kServerAddress = @"https://weatherparser.herokuapp.com";

@implementation AFLoadingScreen

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherRefreshed:) name:@"weatherRefreshed" object:nil];
    
    [self performSelectorInBackground:@selector(refreshWeather) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) refreshWeather
{
    NSData *json = [NSData dataWithContentsOfURL:[NSURL URLWithString:kServerAddress]];
    if( [json length] == 0 ) {
#if DEBUG
        NSLog( @"using fake data..." );
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"fake-data" ofType:@"json"];
        json = [NSData dataWithContentsOfFile:filePath];
#else
        NSLog( @"server returned nothing" );
        return;
#endif
    }
    
    NSError* error = nil;
    collections = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:&error];
    
    if (error)
    {
        NSLog(@"Error parsing JSON %@: %@", [[NSString alloc] initWithData:json encoding:NSASCIIStringEncoding], [error localizedDescription]);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"weatherRefreshed" object:json];
}

-(void) nextView
{
    dispatch_async( dispatch_get_main_queue(), ^{ //I hope this magic will keep it on the main thread and work. no guarantees.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AFViewController *myVC = (AFViewController *)[storyboard instantiateViewControllerWithIdentifier:@"afview"];
    [self performSegueWithIdentifier:@"Next" sender:self];
    [self presentViewController:myVC animated:YES completion:nil];
    });
}

-(void) weatherRefreshed:(NSNotification*)note
{
    [spinner stopAnimating];
    [self nextView];

}

@end
