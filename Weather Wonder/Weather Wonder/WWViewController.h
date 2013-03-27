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
-(NSDate*) dateFromString:(NSString*)date;
-(NSString*)getCalendarDay:(NSDate*)date;
-(NSString*) getTodaysDate;
-(NSString*) generateDate:(int) year month:(int) month day:(int) day;


@end

id collections;

NSArray *csnowsfcInfo;
NSArray *crainsfcInfo;
NSArray *tmax2mInfo;
NSArray *apcpsfcInfo;
NSArray *tmin2mInfo;