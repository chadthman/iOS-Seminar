//
//  WWViewController.m
//  Weather Wonder
//
//  Created by Chad Marmon on 3/15/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "WWViewController.h"
#import "WWTabBarController.h"

@interface WWViewController ()
{
    __weak IBOutlet UIActivityIndicatorView *spinner;
    
}

@end

#define csnowsfc 0
#define crainsfc 1
#define tmax2m   2
#define tmin2m   3
#define apcpsfc  4

static NSString* const kServerAddress = @"https://weatherparser.herokuapp.com";

@implementation WWViewController

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

#pragma mark - Parse Data Functions

//-(void) populateInfo
//{
//    csnowsfcInfo = [collections objectAtIndex:csnowsfc];
//    crainsfcInfo = [collections objectAtIndex:crainsfc];
//    tmax2mInfo   = [collections objectAtIndex:tmax2m];
//    apcpsfcInfo  = [collections objectAtIndex:apcpsfc];
//    tmin2mInfo   = [collections objectAtIndex:tmin2m];
//}

-(double)getDayInfo:(int)type onDay:(NSString*)day //doubt this is needed anymore but it might be useful
{
    NSMutableArray *numbers = [[NSMutableArray alloc] init];;
    int total = 0;
    double dayAverage = 0;
    
    NSString *currentDate;
    currentDate = [NSString stringWithFormat: @"%@",day];
    NSDictionary *variable = [collections objectAtIndex:type];
    NSDictionary *values = [variable objectForKey:@"values"];
    NSString *checkingDate;
    for (NSDictionary *date in values)
    {
        checkingDate = [date[@"date"] substringWithRange:NSMakeRange(0,10)];
        if ([checkingDate isEqualToString:currentDate])
        {
            for (NSArray *prediction in date[@"predictions"])
            {
                //NSLog(@"%@ ", prediction);
                [numbers addObject:prediction];
            }
        }
    }
    for (NSArray *printTest in numbers)
    {
        total = total + [[NSString stringWithFormat:@"%@", printTest] integerValue];
    }
    dayAverage = (double)total/64.0; //64.0 is the number of elements in the array
    //NSLog(@"%d", dayAverage);
    return dayAverage;
}

-(NSString*)getHourSetInfo:(int)type onDay:(NSString*)day atTime:(int)time //doubt this is needed anymore but it might be useful
{
    NSString *currentDate;
    currentDate = [NSString stringWithFormat: @"%@T%02d", day, time];
    //NSLog(@"The Asked Date is : %@\n", currentDate);
    
    NSDictionary *variable = [collections objectAtIndex:type];
    NSDictionary *values = [variable objectForKey:@"values"];
    NSString *checkingDate;
    for (NSDictionary *date in values)
    {
        checkingDate = [date[@"date"] substringWithRange:NSMakeRange(0,13)];
        //NSLog(@"The Checked Date is: %@\n", checkingDate);
        if ([checkingDate isEqualToString:currentDate])
        {
            return date[@"predictions"];
        }
    }
    return NULL;
}

-(void)csnowsfcStats //average snowfall over 6 hours
{
    int total = 0;
    int i = 0;
    double dayAverage = 0;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [collections objectAtIndex:csnowsfc];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *date in values)
    {
        dict = [[NSMutableDictionary alloc] init];
        total = 0;
        for (NSArray *prediction in date[@"predictions"])
        {
            total = total + [[NSString stringWithFormat:@"%@", prediction] integerValue];
        }
        dayAverage = (double)total/21.0; //21.0 is the number of elements in the array
        [dict setObject:date[@"date"] forKey:@"date"];
        [dict setObject:[NSNumber numberWithDouble:dayAverage] forKey:@"average"];
        [newValues setObject:dict atIndexedSubscript:i++];
    }
    csnowsfcInfo = [[NSArray alloc] initWithArray:newValues];
}

-(void)crainsfcStats //average rain fall over 6 hours
{
    int i = 0;
    int total = 0;
    double dayAverage = 0;
    
    NSMutableDictionary *dict;
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [collections objectAtIndex:crainsfc];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *date in values)
    {
        dict = [[NSMutableDictionary alloc] init];
        total = 0;
        for (NSArray *prediction in date[@"predictions"])
        {
            total = total + [[NSString stringWithFormat:@"%@", prediction] integerValue];
        }
        dayAverage = (double)total/21.0; //21.0 is the number of elements in the array
        [dict setObject:date[@"date"] forKey:@"date"];
        [dict setObject:[NSNumber numberWithDouble:dayAverage] forKey:@"average"];
        [newValues setObject:dict atIndexedSubscript:i++];
    }
    crainsfcInfo = [[NSArray alloc] initWithArray:newValues];
}

-(void)tmax2mStats //max average temp
{
    int i = 0;
    double total = 0.0;
    double dayAverage = 0.0;
    
    NSMutableDictionary *dict;
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [collections objectAtIndex:tmax2m];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *date in values)
    {
        dict = [[NSMutableDictionary alloc] init];
        total = 0;
        for (NSArray *prediction in date[@"predictions"])
        {
            total = total + [[NSString stringWithFormat:@"%@", prediction] doubleValue];
        }
        dayAverage = total/21.0; //21.0 is the number of elements in the array
        [dict setObject:date[@"date"] forKey:@"date"];
        [dict setObject:[NSNumber numberWithDouble:dayAverage] forKey:@"average"];
        [newValues setObject:dict atIndexedSubscript:i++];
        //add min and max possiblitys over the 6 hours?
    }
    tmax2mInfo = [[NSArray alloc] initWithArray:newValues];
}

-(void)tmin2mStats //min average temp
{
    int i = 0;
    double total = 0.0;
    double dayAverage = 0.0;
    
    NSMutableDictionary *dict;
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [collections objectAtIndex:tmin2m];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *date in values)
    {
        dict = [[NSMutableDictionary alloc] init];
        total = 0;
        for (NSArray *prediction in date[@"predictions"])
        {
            total = total + [[NSString stringWithFormat:@"%@", prediction] doubleValue];
        }
        dayAverage = total/21.0; //21.0 is the number of elements in the array
        [dict setObject:date[@"date"] forKey:@"date"];
        [dict setObject:[NSNumber numberWithDouble:dayAverage] forKey:@"average"];
        [newValues setObject:dict atIndexedSubscript:i++];
    }
    tmin2mInfo = [[NSArray alloc] initWithArray:newValues];
}

-(void)apcosfcStats //accumulated rain over 6 hours
{
    int i = 0;
    double total = 0;
    //double dayAverage = 0;
    
    NSMutableDictionary *dict;
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [collections objectAtIndex:apcpsfc];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *date in values)
    {
        dict = [[NSMutableDictionary alloc] init];
        total = 0;
        for (NSArray *prediction in date[@"predictions"])
        {
            total = total + [[NSString stringWithFormat:@"%@", prediction] doubleValue];
        }
        //dayAverage = total/21.0; //21.0 is the number of elements in the array
        [dict setObject:date[@"date"] forKey:@"date"];
        [dict setObject:[NSNumber numberWithDouble:total] forKey:@"total"];
        [newValues setObject:dict atIndexedSubscript:i++];
    }
    apcpsfcInfo = [[NSArray alloc] initWithArray:newValues];
}

-(void)generateStats
{
    [self csnowsfcStats];
    [self crainsfcStats];
    [self tmax2mStats];
    [self apcosfcStats];
    [self tmin2mStats];
}

#pragma mark - Time

-(NSDate*) correctTimeZone:(NSDate*) imputdate
{
    NSDate* sourceDate = imputdate;
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    return destinationDate;
}

-(NSString*) getTodaysDate
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    return dateString;
}

-(NSString*) generateDate:(int) year month:(int) month day:(int) day
{
    return [NSString stringWithFormat:@"%i-%02i-%02i", year, month, day];
}

-(int) getCurrentDay //gets the first day of the data
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"dd"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    return dateString.intValue;
}

-(int) getCurrentYear //gets the year of the first day of the data
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"YYYY"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    return dateString.intValue;
}

-(int) getCurrentMonth //gets the month of the first day of the data
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"MM"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    return dateString.intValue;
}

-(int) getTommorow
{
    int day = [self getCurrentDay];
    return day + 1;
}

#pragma mark - Refresh Data Functions

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
        [self generateStats];
        UIStoryboard *storyboard;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        } else {
            storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        }

        //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        WWTabBarController *myVC = (WWTabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        [self performSegueWithIdentifier:@"Next" sender:self];
        [self presentViewController:myVC animated:YES completion:nil];
    });
    //NSLog(@"%f",[self getDayInfo:csnowsfc onDay:[self generateDate:[self getCurrentYear] month:[self getCurrentMonth] day:[self getTommorow]]]);
    //NSLog(@"%@\n", self.getTodaysDate);
    //NSLog(@"%@", [self getInfo:csnowsfc onDay:[self generateDate:[self getCurrentYear] month:[self getCurrentMonth] day:[self getTommorow]] atTime:0]);
    //[self getDay];
    
}

-(void) weatherRefreshed:(NSNotification*)note
{
    [spinner stopAnimating];
    [self nextView];
    
}


@end
