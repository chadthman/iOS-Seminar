//
//  AFViewController.m
//  AssignmentFive
//
//  Created by Chad Marmon on 2/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "AFViewController.h"

@interface AFViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UIPickerView *picker;
    __weak IBOutlet UITextView *textBox;
}

-(IBAction) getInfoButton;

@end

@implementation AFViewController

-(IBAction) getInfoButton
{
    NSString *currentDate = [[NSString stringWithFormat: @"%@",[self correctTimeZone:[datePicker date]]] substringWithRange:NSMakeRange(0,10)];
    
    NSLog(@"The Date is : %@\n", currentDate);
    NSLog(@"The selector is : %d", [picker selectedRowInComponent:0]);
    
    NSDictionary *variable = [collections objectAtIndex:[picker selectedRowInComponent:0]];
    
    NSString *variableText = variable[@"variable"];
    
    NSDictionary *values = [variable objectForKey:@"values"];
    NSString *checkingDate;
    for (NSDictionary *date in values)
    {
        checkingDate = [date[@"date"] substringWithRange:NSMakeRange(0,10)];
        NSLog(@"The Checked Date is: %@\n", checkingDate);
        if ([checkingDate isEqualToString:currentDate])
        {
            //NSArray *predictions = date[@"predictions"];
            textBox.text = [textBox.text stringByAppendingFormat:@"\nAt time %@ the weather for %@ is:\n", date[@"date"], variableText];
            for (NSArray *prediction in date[@"predictions"])
            {
                textBox.text = [textBox.text stringByAppendingFormat:@"%@ ", prediction];
            }
        }
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [textBox setText:@"Information:"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}

-(UIView*) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSLog(@" %ld", (long)row);
    
    NSDictionary *variable = [collections objectAtIndex:row];
    
    NSString *variableText = variable[@"variable"];
    
    UILabel *v = [[UILabel alloc] initWithFrame:CGRectMake( 0., 0., 250., 37. )];
    v.text = [NSString stringWithString:variableText];
    v.textAlignment = UITextAlignmentCenter;
    v.backgroundColor = [UIColor clearColor];
    return v;
}

-(void) weatherRefreshed:(NSNotification*)note
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
