//
//  WWCollectionViewController.m
//  Weather Wonder
//
//  Created by Chad Marmon on 3/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "WWCollectionViewController.h"
#import "WWCollectionViewCell.h"
#import "WWViewController.h"
#import "WWGraphViewController.h"

@interface WWCollectionViewController ()
{
    UIImage *sunnyImage;
    UIImage *cloudyImage;
    UIImage *rainImage;
    UIImage *snowImage;
    WWViewController *controller;
}
@end

@implementation WWCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self
               forKeyPath:@"weatherDisplay"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    NSInteger row = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedIndexRow"];
    NSInteger section = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedIndexSection"];
    selectedIndex = [NSIndexPath indexPathForRow:row inSection:section];
    controller  = [[WWViewController alloc] init];
    sunnyImage  = [UIImage imageNamed:@"WeatherIconSun"];
    cloudyImage = [UIImage imageNamed:@"WeatherIconCloudy"];
    rainImage   = [UIImage imageNamed:@"WeatherIconRain"];
    snowImage   = [UIImage imageNamed:@"WeatherIconSnow"];
    
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    NSIndexPath *indexPath;
    if (selectedIndex == nil)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else {
        indexPath = selectedIndex;
    }
    dispatch_async( dispatch_get_main_queue(), ^{
    [self didSelectItemHelperAtIndexPath:indexPath];
    });
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //NSLog(@"KVO: %@ changed property %@ to value %@", object, keyPath, change);
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)colView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectItemHelperAtIndexPath:indexPath];
}

-(void)didSelectItemHelperAtIndexPath:(NSIndexPath*)indexPath
{
    //change the view of my statistics here to the day that is selected
    NSDictionary *variableDay;
    variableDay   = [crainsfcDaily objectAtIndex:indexPath.section]; //arbituarly picked crainsfcDaily
    NSDate *date  =  variableDay[@"date"];
    selectedIndex = indexPath;
    nightViewImage = nil;
    morningViewImage = nil;
    afternoonViewImage = nil;
    eveningViewImgage = nil;
    
    for (NSDictionary *newIndex in crainsfcHourly)
    {
        NSString *tempDate = [newIndex[@"date"] substringWithRange:NSMakeRange(0,10)];
        NSString *tempDate2 = [[NSString stringWithFormat:@"%@", date] substringWithRange:NSMakeRange(0,10)];
        if ([tempDate isEqualToString:tempDate2]) {
            NSString *timeOfDay = [controller getTimeOfDay:[NSString stringWithFormat:@"%@",newIndex[@"date"]]];
            if ([timeOfDay isEqualToString: @"Night"])
            {
                nightViewImage = [self imageForHour:newIndex[@"date"]];
            } else if ([timeOfDay isEqualToString:@"Morning"])
            {
                morningViewImage = [self imageForHour:newIndex[@"date"]];
            } else if ([timeOfDay isEqualToString:@"Afternoon"])
            {
                afternoonViewImage = [self imageForHour:newIndex[@"date"]];
            } else {
                eveningViewImgage = [self imageForHour:newIndex[@"date"]];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex.row forKey:@"selectedIndexRow"];
    [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex.section forKey:@"selectedIndexSection"];
    [[NSUserDefaults standardUserDefaults] setBool:weatherDisplay forKey:@"reloadImages"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(UIImage*)imageForHour:(NSDate*)date
{
    NSNumber *averageRain;
    NSNumber *averageSnow;
    NSNumber *averageCloudy;
    
    for (NSDictionary *variableRain in crainsfcHourly)
    {
        if (variableRain[@"date"] == date) {
            averageRain = variableRain[@"average"];
        }
    }
    for (NSDictionary *variableSnow in csnowsfcHourly)
    {
        if (variableSnow[@"date"] == date) {
            averageSnow = variableSnow[@"average"];
        }
    }
    for (NSDictionary *variableCloudy in sunsdsfcHourly)
    {
        if (variableCloudy[@"date"] == date) {
            averageCloudy = variableCloudy[@"average"];
        }
    }
    
    if(averageRain.doubleValue >= 0.5)
    {
        if(averageRain.doubleValue >= averageSnow.doubleValue)
        {
            return rainImage;
        } else {
            return snowImage;
        }
    } else if (averageSnow.doubleValue >= 0.5)
    {
        return snowImage;
    } else {
        if (averageCloudy.doubleValue >= 10800)
        {
            return cloudyImage;
        } else {
            return sunnyImage;
        }
    }
}



-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //NSLog(@"%lu", (unsigned long)[csnowsfcHourly count]);
    if (weatherDisplay)
    {
        return [csnowsfcHourly count];
    } else {
        return [csnowsfcDaily count];
    }
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //NSLog(@"%i",section);
    return 1; //only one row
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WWCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    
    NSDictionary *variableRain;
    NSDictionary *variableSnow;
    NSDictionary *variableCloudy;
    
    if (weatherDisplay)
    {
        variableRain   = [crainsfcHourly objectAtIndex:indexPath.section];
        variableSnow   = [csnowsfcHourly objectAtIndex:indexPath.section];
        variableCloudy = [sunsdsfcHourly objectAtIndex:indexPath.section];
    } else {
        variableRain   = [crainsfcDaily objectAtIndex:indexPath.section];
        variableSnow   = [csnowsfcDaily objectAtIndex:indexPath.section];
        variableCloudy = [sunsdsfcDaily objectAtIndex:indexPath.section];
    }
    
    NSNumber *averageRain   = variableRain[@"average"];
    NSNumber *averageSnow   = variableSnow[@"average"];
    NSNumber *averageCloudy = variableCloudy[@"average"];
    NSString *dateString    = variableRain[@"date"];
    
    //NSLog(@"dateString: %@", dateString);
    
    NSString *newDate;
    NSDate   *date = [controller dateFromString:dateString];
    NSDate   *correctedDate = [controller correctTimeZone:date];

    if (weatherDisplay)
    {
        //NSLog(@"correctedDate: %@", correctedDate);
        newDate = [NSString stringWithFormat:@"%@ %@",[controller getTimeOfDay:dateString],
                   [[NSString stringWithFormat:@"%@",correctedDate] substringWithRange:NSMakeRange(8, 2)]];
    } else {
        newDate = [NSString stringWithFormat:@"%@ %@", [controller getCalendarDay:correctedDate],
                   [[NSString stringWithFormat:@"%@",correctedDate] substringWithRange:NSMakeRange(8, 2)]];
    }
    
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textView.text = newDate;
    
    if(averageRain.doubleValue >= 0.5)
    {
        if(averageRain.doubleValue >= averageSnow.doubleValue)
        {
            cell.imageView.image = rainImage;
        } else {
            cell.imageView.image = snowImage;
        }
    } else if (averageSnow.doubleValue >= 0.5)
    {
        cell.imageView.image = snowImage;
    } else {
        if (averageCloudy.doubleValue >= 10800)
        {
            cell.imageView.image = cloudyImage;
        } else {
            cell.imageView.image = sunnyImage;
        }
    }
    return cell;
}

@end
