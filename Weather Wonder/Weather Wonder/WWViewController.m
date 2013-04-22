//
//  WWViewController.m
//  Weather Wonder
//
//  Created by Chad Marmon on 3/15/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "WWViewController.h"
#import "WWGraphViewController.h"

@interface WWViewController ()
{
    __weak IBOutlet UIActivityIndicatorView *spinner;
}

@end

#define crainsfc 0
#define csnowsfc 1
#define sunsdsfc 2
#define tmax2m   3
#define tmin2m   4
#define apcpsfc  5

#define Sunday 1
#define Monday 2
#define Tuesday 3
#define Wedensday 4
#define Thursday 5
#define Friday 6
#define Saturday 7

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

//-(double)getDayInfo:(int)type onDay:(NSString*)day //doubt this is needed anymore but it might be useful
//{
//    NSMutableArray *numbers = [[NSMutableArray alloc] init];;
//    int total = 0;
//    double dayAverage = 0;
//    
//    NSString *currentDate;
//    currentDate = [NSString stringWithFormat: @"%@",day];
//    NSDictionary *variable = [collections objectAtIndex:type];
//    NSDictionary *values = [variable objectForKey:@"values"];
//    NSString *checkingDate;
//    for (NSDictionary *date in values)
//    {
//        checkingDate = [date[@"date"] substringWithRange:NSMakeRange(0,10)];
//        if ([checkingDate isEqualToString:currentDate])
//        {
//            for (NSArray *prediction in date[@"predictions"])
//            {
//                //NSLog(@"%@ ", prediction);
//                [numbers addObject:prediction];
//            }
//        }
//    }
//    for (NSArray *printTest in numbers)
//    {
//        total = total + [[NSString stringWithFormat:@"%@", printTest] integerValue];
//    }
//    dayAverage = (double)total/64.0; //64.0 is the number of elements in the array
//    //NSLog(@"%d", dayAverage);
//    return dayAverage;
//}

-(double)kelvinTofahrenheit:(double)kelvin
{
    return ((9/5)*(kelvin - 273))+32;
}

-(NSArray*)convertArrayToFahrenheit:(NSArray*)kelvinArray
{
    NSMutableArray *fahrenheitAray = [[NSMutableArray alloc] init];
    for (NSNumber *kelvin in kelvinArray)
    {
        [fahrenheitAray addObject:[NSNumber numberWithDouble:[self kelvinTofahrenheit:kelvin.doubleValue]]];
    }
    return [[NSArray alloc] initWithArray:fahrenheitAray];
}

-(NSDate*)indexToDate:(NSIndexPath*)indexPath
{
    NSDictionary *variableDay;
    variableDay   = [crainsfcDaily objectAtIndex:indexPath.section]; //arbituarly picked crainsfcDaily
    return variableDay[@"date"];
}

-(NSArray*)getHourSetInfoOnType:(NSString*)type onDay:(NSString*)day atTime:(int)time
{
    NSString *currentDate;
    currentDate = [NSString stringWithFormat: @"%@T%02d", day, time];
    //NSLog(@"The Asked Date is : %@\n", currentDate);
    
    NSDictionary *variable = [self getData:type];
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

-(NSDictionary*)getData:(NSString*)type
{
    for (NSDictionary *variable in collections)
    {
        if ([variable[@"variable"] isEqualToString:type])
        {
            return variable;
        }
    }
    return nil;
}

-(int)getStartingTime:(NSIndexPath*)indexPath //used only for getting the start of that day for formating the graph
{
    NSDictionary *variable = [self getData:@"csnowsfc"];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *value in values)
    {
        NSString *dateFromIndex = [NSString stringWithFormat:@"%@",[self indexToDate:indexPath]];
        if ([value[@"date"] isEqualToString:dateFromIndex]) {
            NSString *time = [self getTimeOfDay:value[@"date"]];
            if ([time isEqualToString:@"Night"])
            {
                return 4;
            } else if ([time isEqualToString:@"Morning"])
            {
                return 3;
            } else if ([time isEqualToString:@"Afternoon"])
            {
                return 2;
            } else {
                return 1;
            }
        }
    }
    return 0;
}

-(NSArray*)apcpsfcCompoundArrayInfoWithArray:(NSArray*)array
{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    double total = 0.0;
    for (NSNumber *value in array)
    {
        total += [value doubleValue];
        [resultArray addObject:[NSNumber numberWithDouble:total]];
    }
    return [[NSArray alloc]initWithArray:resultArray];
}

-(void)csnowsfcStats //average snowfall over 6 hours
{
    int total = 0;
    int i = 0;
    double hourAverage = 0;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [self getData:@"csnowsfc"];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *date in values)
    {
        dict = [[NSMutableDictionary alloc] init];
        total = 0;
        for (NSArray *prediction in date[@"predictions"])
        {
            total = total + [[NSString stringWithFormat:@"%@", prediction] integerValue];
        }
        hourAverage = (double)total/21.0; //21.0 is the number of elements in the array
        [dict setObject:date[@"date"] forKey:@"date"];
        [dict setObject:[NSNumber numberWithDouble:hourAverage] forKey:@"average"];
        [newValues setObject:dict atIndexedSubscript:i++];
    }
    csnowsfcHourly = [[NSArray alloc] initWithArray:newValues];
}

-(void)crainsfcStats //average rain fall over 6 hours
{
    int i = 0;
    int total = 0;
    double hourAverage = 0;
    
    NSMutableDictionary *dict;
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [self getData:@"crainsfc"];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *date in values)
    {
        dict = [[NSMutableDictionary alloc] init];
        total = 0;
        for (NSArray *prediction in date[@"predictions"])
        {
            total = total + [[NSString stringWithFormat:@"%@", prediction] integerValue];
        }
        hourAverage = (double)total/21.0; //21.0 is the number of elements in the array
        [dict setObject:date[@"date"] forKey:@"date"];
        [dict setObject:[NSNumber numberWithDouble:hourAverage] forKey:@"average"];
        [newValues setObject:dict atIndexedSubscript:i++];
    }
    crainsfcHourly = [[NSArray alloc] initWithArray:newValues];
}

-(void)tmax2mStats //max average temp
{
    int i = 0;
    double total = 0.0;
    double hourAverage = 0.0;
    
    NSMutableDictionary *dict;
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [self getData:@"tmax2m"];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *date in values)
    {
        dict = [[NSMutableDictionary alloc] init];
        total = 0;
        for (NSArray *prediction in date[@"predictions"])
        {
            double kelvin = [[NSString stringWithFormat:@"%@", prediction] doubleValue];
            double fahrenheit = [self kelvinTofahrenheit:kelvin];
            total = total + fahrenheit;
        }
        hourAverage = total/21.0; //21.0 is the number of elements in the array
        [dict setObject:date[@"date"] forKey:@"date"];
        [dict setObject:[NSNumber numberWithDouble:hourAverage] forKey:@"average"];
        [newValues setObject:dict atIndexedSubscript:i++];
        //add min and max possiblitys over the 6 hours?
    }
    tmax2mHourly = [[NSArray alloc] initWithArray:newValues];
}

-(void)tmin2mStats //min average temp
{
    int i = 0;
    double total = 0.0;
    double hourAverage = 0.0;
    
    NSMutableDictionary *dict;
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [self getData:@"tmin2m"];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *date in values)
    {
        dict = [[NSMutableDictionary alloc] init];
        total = 0;
        for (NSArray *prediction in date[@"predictions"])
        {
            double kelvin = [[NSString stringWithFormat:@"%@", prediction] doubleValue];
            double fahrenheit = [self kelvinTofahrenheit:kelvin];
            total = total + fahrenheit;
        }
        hourAverage = total/21.0; //21.0 is the number of elements in the array
        [dict setObject:date[@"date"] forKey:@"date"];
        [dict setObject:[NSNumber numberWithDouble:hourAverage] forKey:@"average"];
        [newValues setObject:dict atIndexedSubscript:i++];
    }
    tmin2mHourly = [[NSArray alloc] initWithArray:newValues];
}

-(void)apcosfcStats //accumulated rain over 6 hours
{
    int i = 0;
    double total = 0;
    //double dayAverage = 0;
    
    NSMutableDictionary *dict;
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [self getData:@"apcpsfc"];
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
        [dict setObject:[NSNumber numberWithDouble:total] forKey:@"average"];
        [newValues setObject:dict atIndexedSubscript:i++];
    }
    apcpsfcHourly = [[NSArray alloc] initWithArray:newValues];
}

-(void)sunsdsfcStats
{
    int i = 0;
    int total = 0;
    double hourAverage = 0;
    
    NSMutableDictionary *dict;
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSDictionary *variable = [self getData:@"sunsdsfc"];
    NSDictionary *values = [variable objectForKey:@"values"];
    for (NSDictionary *date in values)
    {
        dict = [[NSMutableDictionary alloc] init];
        total = 0;
        for (NSArray *prediction in date[@"predictions"])
        {
            total = total + [[NSString stringWithFormat:@"%@", prediction] intValue];
        }
        hourAverage = (double)total/21.0; //21.0 is the number of elements in the array
        [dict setObject:date[@"date"] forKey:@"date"];
        [dict setObject:[NSNumber numberWithDouble:hourAverage] forKey:@"average"];
        [newValues setObject:dict atIndexedSubscript:i++];
    }
    sunsdsfcHourly = [[NSArray alloc] initWithArray:newValues]; //array(dictionary)
}

-(NSArray*)generateDailyWithInput:(NSArray*)imputArray
{
    double total;
    int i = 0;
    int counter = 0;
    double dayAverage = 0.0;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *newValues = [[NSMutableArray alloc]init];
    NSMutableArray *hasValues = [[NSMutableArray alloc] init];
    NSString *checkingDate;
    NSString *newestDate;
    for (NSDictionary *date in imputArray)
    {
        checkingDate = [date[@"date"] substringWithRange:NSMakeRange(0, 10)];
        if ([hasValues containsObject:checkingDate] == FALSE) {
            dict = [[NSMutableDictionary alloc] init];
            total = 0;
            counter = 0;
            for (NSDictionary *date2 in imputArray)
            {
                newestDate = [date2[@"date"] substringWithRange:NSMakeRange(0, 10)];
                if ([newestDate isEqualToString:checkingDate])
                {
                    NSNumber *temp = date2[@"average"];
                    total = total + temp.doubleValue;
                    counter++;
                }
            }
            dayAverage = total/(double)counter;
            [dict setObject:date[@"date"] forKey:@"date"];
            [dict setObject:[NSNumber numberWithDouble:dayAverage] forKey:@"average"];
            [hasValues setObject:checkingDate atIndexedSubscript:i];
            [newValues setObject:dict atIndexedSubscript:i++];
        }
    }
    return newValues;
}

-(void)generateStats
{
    [self csnowsfcStats];
    [self crainsfcStats];
    [self tmax2mStats];
    [self apcosfcStats];
    [self tmin2mStats];
    [self sunsdsfcStats];
    
    csnowsfcDaily = [[NSArray alloc] initWithArray:[self generateDailyWithInput:csnowsfcHourly]];
    crainsfcDaily = [[NSArray alloc] initWithArray:[self generateDailyWithInput:crainsfcHourly]];
    tmax2mDaily   = [[NSArray alloc] initWithArray:[self generateDailyWithInput:tmax2mHourly]];
    tmin2mDaily   = [[NSArray alloc] initWithArray:[self generateDailyWithInput:tmin2mHourly]];
    apcpsfcDaily  = [[NSArray alloc] initWithArray:[self generateDailyWithInput:apcpsfcHourly]];
    sunsdsfcDaily = [[NSArray alloc] initWithArray:[self generateDailyWithInput:sunsdsfcHourly]];
}

#pragma mark - Time

-(NSString*)dayStringFromIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary *variableRain = [crainsfcDaily objectAtIndex:indexPath.section];
    NSString *dateString = variableRain[@"date"];
    NSString *newDate;
    NSDate   *date = [self dateFromString:dateString];
    NSDate   *correctedDate = [self correctTimeZone:date];
    newDate = [NSString stringWithFormat:@"%@ %@", [self getCalendarDay:correctedDate],
               [[NSString stringWithFormat:@"%@",correctedDate] substringWithRange:NSMakeRange(8, 2)]];
    return newDate;
}

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

-(NSString*)getCalendarDay:(NSDate*)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger weekday = [weekdayComponents weekday];
    // weekday 1 = Sunday for Gregorian calendar
    switch (weekday) {
        case Sunday:
            return [NSString stringWithFormat:@"Sunday"];
            break;
        case Monday:
            return [NSString stringWithFormat:@"Monday"];
            break;
        case Tuesday:
            return [NSString stringWithFormat:@"Tuesday"];
            break;
        case Wedensday:
            return [NSString stringWithFormat:@"Wedensday"];
            break;
        case Thursday:
            return [NSString stringWithFormat:@"Thursday"];
            break;
        case Friday:
            return [NSString stringWithFormat:@"Friday"];
            break;
        case Saturday:
            return [NSString stringWithFormat:@"Saturday"];
            break;
        default:
            return [NSString stringWithFormat:@"Not A Date"]; //should not reach
            break;
    }
}

-(NSString*)getTimeOfDay:(NSString*)date
{
    NSString *newDate = [date substringWithRange:NSMakeRange(11, 2)];
    
    if ([newDate integerValue] < 6)
    {
        return @"Night";
    } else if ([newDate integerValue] < 12)
    {
        return @"Morning";
    } else if ([newDate integerValue] < 18)
    {
        return @"Afternoon";
    } else {
        return @"Evening";
    }
}

-(NSDate*) dateFromString:(NSString*)date
{
    NSString *newDate = [date substringWithRange:NSMakeRange(0, 10)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *myDate = [dateFormatter dateFromString: newDate];
    return myDate;
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
        WWGraphViewController *myVC = (WWGraphViewController *)[storyboard instantiateViewControllerWithIdentifier:@"GraphViewController"];
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
