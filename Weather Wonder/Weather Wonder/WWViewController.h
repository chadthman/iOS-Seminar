//
//  WWViewController.h
//  Weather Wonder
//
//  Created by Chad Marmon on 3/15/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WWViewController : UIViewController

-(void)generateStats;
-(int) getCurrentDay;
-(int) getCurrentMonth;
-(int) getCurrentYear;
-(NSDate*) correctTimeZone:(NSDate*) imputdate;
-(NSDate*) dateFromString:(NSString*)date;
-(NSString*)getCalendarDay:(NSDate*)date;
-(NSString*)getTimeOfDay:(NSString*)date;
-(NSString*) getTodaysDate;
-(NSString*) generateDate:(int) year month:(int) month day:(int) day;


@end

id collections;

NSArray *csnowsfcHourly;
NSArray *crainsfcHourly;
NSArray *tmax2mHourly;
NSArray *apcpsfcHourly;
NSArray *tmin2mHourly;
NSArray *sunsdsfcHourly;

NSArray *csnowsfcDaily;
NSArray *crainsfcDaily;
NSArray *tmax2mDaily;
NSArray *apcpsfcDaily;
NSArray *tmin2mDaily;
NSArray *sunsdsfcDaily;