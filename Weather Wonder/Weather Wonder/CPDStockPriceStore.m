//
//  CPDStockPriceStore.m
//  CorePlotDemo
//
//  NB: Price data obtained from Yahoo! Finance:
//  http://finance.yahoo.com/q/hp?s=AAPL
//  http://finance.yahoo.com/q/hp?s=GOOG
//  http://finance.yahoo.com/q/hp?s=MSFT
//
//  Created by Steve Baranski on 5/4/12.
//  Copyright (c) 2012 komorka technology, llc. All rights reserved.
//

#import "CPDStockPriceStore.h"

@interface CPDStockPriceStore ()


@end

@implementation CPDStockPriceStore

#pragma mark - Class methods

+ (CPDStockPriceStore *)sharedInstance
{
    static CPDStockPriceStore *sharedInstance;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];      
    });
    
    return sharedInstance;
}

#pragma mark - API methods

- (NSArray *)tickerSymbols
{
    static NSArray *symbols = nil;
    if (!symbols)
    {
        symbols = [NSArray arrayWithObjects:
                   @"AAPL", 
                   @"GOOG", 
                   @"MSFT", 
                   nil];
    }
    return symbols;
}

- (NSArray *)dailyPortfolioPrices
{
    static NSArray *prices = nil;
    if (!prices)
    {
        prices = [NSArray arrayWithObjects:
                  [NSDecimalNumber numberWithFloat:582.13], 
                  [NSDecimalNumber numberWithFloat:604.43], 
                  [NSDecimalNumber numberWithFloat:32.01], 
                  nil];
    }
    return prices;
}

- (NSArray *)datesInWeek
{
    static NSArray *dates = nil;
    if (!dates)
    {
        dates = [NSArray arrayWithObjects:
                 @"4/23", 
                 @"4/24", 
                 @"4/25",
                 @"4/26", 
                 @"4/27",                   
                 nil];
    }
    return dates;
}

- (NSArray *)weeklyPrices:(NSString *)tickerSymbol
{
    if ([CPDTickerSymbolAAPL isEqualToString:[tickerSymbol uppercaseString]] == YES)
    {
        return [self weeklyAaplPrices];
    }
    else if ([CPDTickerSymbolGOOG isEqualToString:[tickerSymbol uppercaseString]] == YES)
    {
        return [self weeklyGoogPrices];
    }
    else if ([CPDTickerSymbolMSFT isEqualToString:[tickerSymbol uppercaseString]] == YES)
    {
        return [self weeklyMsftPrices];
    }
    return [NSArray array];
}

- (NSArray *)combineTimeArrays:(int)time
{
    NSMutableArray *combindedArrays = [[NSMutableArray alloc]init];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //iPad
        switch (time) {
            case 1:
                [combindedArrays addObjectsFromArray:[self sixHourEvening]];
                break;
            case 2:
                [combindedArrays addObjectsFromArray:[self sixHourAfternoon]];
                [combindedArrays addObjectsFromArray:[self sixHourEvening]];
                break;
            case 3:
                [combindedArrays addObjectsFromArray:[self sixHourMorning]];
                [combindedArrays addObjectsFromArray:[self sixHourAfternoon]];
                [combindedArrays addObjectsFromArray:[self sixHourEvening]];
                break;
            case 4:
                [combindedArrays addObjectsFromArray:[self sixHourNight]];
                [combindedArrays addObjectsFromArray:[self sixHourMorning]];
                [combindedArrays addObjectsFromArray:[self sixHourAfternoon]];
                [combindedArrays addObjectsFromArray:[self sixHourEvening]];
                break;
            case 5:
                [combindedArrays addObjectsFromArray:[self sixHourNight]];
                [combindedArrays addObjectsFromArray:[self sixHourMorning]];
                [combindedArrays addObjectsFromArray:[self sixHourAfternoon]];
                break;
            case 6:
                [combindedArrays addObjectsFromArray:[self sixHourNight]];
                [combindedArrays addObjectsFromArray:[self sixHourMorning]];
                break;
            case 7:
                [combindedArrays addObjectsFromArray:[self sixHourNight]];
                break;
            default:
                break;
        }
        
    } else {
        //iPhone
        switch (time) {
            case 1:
                [combindedArrays addObjectsFromArray:[self sixHourEveningiPhone]];
                break;
            case 2:
                [combindedArrays addObjectsFromArray:[self sixHourAfternooniPhone]];
                [combindedArrays addObjectsFromArray:[self sixHourEveningiPhone]];
                break;
            case 3:
                [combindedArrays addObjectsFromArray:[self sixHourMorningiPhone]];
                [combindedArrays addObjectsFromArray:[self sixHourAfternooniPhone]];
                [combindedArrays addObjectsFromArray:[self sixHourEveningiPhone]];
                break;
            case 4:
                [combindedArrays addObjectsFromArray:[self sixHourNightiPhone]];
                [combindedArrays addObjectsFromArray:[self sixHourMorningiPhone]];
                [combindedArrays addObjectsFromArray:[self sixHourAfternooniPhone]];
                [combindedArrays addObjectsFromArray:[self sixHourEveningiPhone]];
                break;
            case 5:
                [combindedArrays addObjectsFromArray:[self sixHourNightiPhone]];
                [combindedArrays addObjectsFromArray:[self sixHourMorningiPhone]];
                [combindedArrays addObjectsFromArray:[self sixHourAfternooniPhone]];
                break;
            case 6:
                [combindedArrays addObjectsFromArray:[self sixHourNightiPhone]];
                [combindedArrays addObjectsFromArray:[self sixHourMorningiPhone]];
                break;
            case 7:
                [combindedArrays addObjectsFromArray:[self sixHourNightiPhone]];
                break;
            default:
                break;
        }

    }
    
    
    return [[NSArray alloc]initWithArray:combindedArrays];
}

- (NSArray *)sixHourEvening
{
    static NSArray *hours = nil;
    if (!hours)
    {
        hours = [NSArray arrayWithObjects:
                 @"6 PM",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"Evening",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"11 AM",
                 nil];
    }
    return hours;
}

- (NSArray *)sixHourAfternoon
{
    static NSArray *hours = nil;
    if (!hours)
    {
        hours = [NSArray arrayWithObjects:
                 @"12 PM",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"Afternoon",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 nil];
    }
    return hours;
}


- (NSArray *)sixHourMorning
{
    static NSArray *hours = nil;
    if (!hours)
    {
        hours = [NSArray arrayWithObjects:
                 @"6 AM",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"Monrning",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 nil];
    }
    return hours;
}


- (NSArray *)sixHourNight
{
    static NSArray *hours = nil;
    if (!hours)
    {
        hours = [NSArray arrayWithObjects:
                 @"12 AM",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"Night",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 nil];
    }
    return hours;
}

- (NSArray *)sixHourEveningiPhone
{
    static NSArray *hours = nil;
    if (!hours)
    {
        hours = [NSArray arrayWithObjects:
                 @"6 PM",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"11 AM",
                 nil];
    }
    return hours;
}

- (NSArray *)sixHourAfternooniPhone
{
    static NSArray *hours = nil;
    if (!hours)
    {
        hours = [NSArray arrayWithObjects:
                 @"12 PM",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 nil];
    }
    return hours;
}

- (NSArray *)sixHourMorningiPhone
{
    static NSArray *hours = nil;
    if (!hours)
    {
        hours = [NSArray arrayWithObjects:
                 @"6 AM",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 nil];
    }
    return hours;
}


- (NSArray *)sixHourNightiPhone
{
    static NSArray *hours = nil;
    if (!hours)
    {
        hours = [NSArray arrayWithObjects:
                 @"12 AM",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 @"",
                 nil];
    }
    return hours;
}



- (NSArray *)datesInMonth
{
    static NSArray *dates = nil;
    if (!dates)
    {
        dates = [NSArray arrayWithObjects:
                 @"2", 
                 @"3", 
                 @"4",
                 @"5",
                 @"9", 
                 @"10", 
                 @"11",
                 @"12", 
                 @"13",
                 @"16", 
                 @"17", 
                 @"18",
                 @"19", 
                 @"20", 
                 @"23", 
                 @"24", 
                 @"25",
                 @"26", 
                 @"27",
                 @"30",                   
                 nil];
    }
    return dates;
}


- (NSArray *)monthlyPrices:(NSString *)tickerSymbol
{
    if ([CPDTickerSymbolAAPL isEqualToString:[tickerSymbol uppercaseString]] == YES)
    {
        return [self monthlyAaplPrices];
    }
    else if ([CPDTickerSymbolGOOG isEqualToString:[tickerSymbol uppercaseString]] == YES)
    {
        return [self monthlyGoogPrices];
    }
    else if ([CPDTickerSymbolMSFT isEqualToString:[tickerSymbol uppercaseString]] == YES)
    {
        return [self monthlyMsftPrices];
    }
    return [NSArray array];
}

#pragma mark - Private behavior

- (NSArray *)weeklyAaplPrices
{
    static NSArray *prices = nil;
    if (!prices)
    {
        prices = [NSArray arrayWithObjects:
                  [NSDecimalNumber numberWithFloat:571.70], 
                  [NSDecimalNumber numberWithFloat:560.28], 
                  [NSDecimalNumber numberWithFloat:610.00], 
                  [NSDecimalNumber numberWithFloat:607.70], 
                  [NSDecimalNumber numberWithFloat:603.00],                   
                  nil];
    }
    return prices;
}

- (NSArray *)weeklyGoogPrices
{
    static NSArray *prices = nil;
    if (!prices)
    {
        prices = [NSArray arrayWithObjects:
                  [NSDecimalNumber numberWithFloat:597.60], 
                  [NSDecimalNumber numberWithFloat:601.27], 
                  [NSDecimalNumber numberWithFloat:609.72], 
                  [NSDecimalNumber numberWithFloat:615.47], 
                  [NSDecimalNumber numberWithFloat:614.98],                   
                  nil];
    }
    return prices;
}

- (NSArray *)weeklyMsftPrices
{
    static NSArray *prices = nil;
    if (!prices)
    {
        prices = [NSArray arrayWithObjects:
                  [NSDecimalNumber numberWithFloat:32.12], 
                  [NSDecimalNumber numberWithFloat:31.92], 
                  [NSDecimalNumber numberWithFloat:32.20], 
                  [NSDecimalNumber numberWithFloat:32.11], 
                  [NSDecimalNumber numberWithFloat:31.98],                   
                  nil];
    }
    return prices;
}

- (NSArray *)monthlyAaplPrices
{
    static NSArray *prices = nil;
    if (!prices)
    {
        prices = [NSArray arrayWithObjects:
                  [NSDecimalNumber numberWithFloat:618.63], 
                  [NSDecimalNumber numberWithFloat:629.32], 
                  [NSDecimalNumber numberWithFloat:624.31], 
                  [NSDecimalNumber numberWithFloat:633.68], 
                  [NSDecimalNumber numberWithFloat:636.23], 
                  [NSDecimalNumber numberWithFloat:628.44], 
                  [NSDecimalNumber numberWithFloat:626.20], 
                  [NSDecimalNumber numberWithFloat:622.77], 
                  [NSDecimalNumber numberWithFloat:605.23],
                  [NSDecimalNumber numberWithFloat:580.13], 
                  [NSDecimalNumber numberWithFloat:609.70], 
                  [NSDecimalNumber numberWithFloat:608.34], 
                  [NSDecimalNumber numberWithFloat:587.44], 
                  [NSDecimalNumber numberWithFloat:572.98],
                  [NSDecimalNumber numberWithFloat:571.70], 
                  [NSDecimalNumber numberWithFloat:560.28], 
                  [NSDecimalNumber numberWithFloat:610.00], 
                  [NSDecimalNumber numberWithFloat:607.70], 
                  [NSDecimalNumber numberWithFloat:603.00],
                  [NSDecimalNumber numberWithFloat:583.98],                  
                  nil];
    }
    return prices;
}

- (NSArray *)monthlyGoogPrices
{
    static NSArray *prices = nil;
    if (!prices)
    {
        prices = [NSArray arrayWithObjects:
                  [NSDecimalNumber numberWithFloat:646.92], 
                  [NSDecimalNumber numberWithFloat:642.62], 
                  [NSDecimalNumber numberWithFloat:635.15], 
                  [NSDecimalNumber numberWithFloat:632.32], 
                  [NSDecimalNumber numberWithFloat:630.84], 
                  [NSDecimalNumber numberWithFloat:626.86], 
                  [NSDecimalNumber numberWithFloat:635.96], 
                  [NSDecimalNumber numberWithFloat:651.01], 
                  [NSDecimalNumber numberWithFloat:624.60], 
                  [NSDecimalNumber numberWithFloat:606.07], 
                  [NSDecimalNumber numberWithFloat:609.57], 
                  [NSDecimalNumber numberWithFloat:607.45], 
                  [NSDecimalNumber numberWithFloat:599.30], 
                  [NSDecimalNumber numberWithFloat:596.06], 
                  [NSDecimalNumber numberWithFloat:597.60], 
                  [NSDecimalNumber numberWithFloat:601.27], 
                  [NSDecimalNumber numberWithFloat:609.72], 
                  [NSDecimalNumber numberWithFloat:615.47], 
                  [NSDecimalNumber numberWithFloat:614.98], 
                  [NSDecimalNumber numberWithFloat:604.85],                  
                  nil];
    }
    return prices;
}

- (NSArray *)monthlyMsftPrices
{
    static NSArray *prices = nil;
    if (!prices)
    {
        prices = [NSArray arrayWithObjects:
                  [NSDecimalNumber numberWithFloat:32.29], 
                  [NSDecimalNumber numberWithFloat:31.94], 
                  [NSDecimalNumber numberWithFloat:31.21], 
                  [NSDecimalNumber numberWithFloat:31.52], 
                  [NSDecimalNumber numberWithFloat:31.10], 
                  [NSDecimalNumber numberWithFloat:30.47], 
                  [NSDecimalNumber numberWithFloat:30.35], 
                  [NSDecimalNumber numberWithFloat:30.98], 
                  [NSDecimalNumber numberWithFloat:30.81],
                  [NSDecimalNumber numberWithFloat:31.08], 
                  [NSDecimalNumber numberWithFloat:31.44], 
                  [NSDecimalNumber numberWithFloat:31.14], 
                  [NSDecimalNumber numberWithFloat:31.01], 
                  [NSDecimalNumber numberWithFloat:32.42],
                  [NSDecimalNumber numberWithFloat:32.12], 
                  [NSDecimalNumber numberWithFloat:31.92], 
                  [NSDecimalNumber numberWithFloat:32.20], 
                  [NSDecimalNumber numberWithFloat:32.11], 
                  [NSDecimalNumber numberWithFloat:31.98],  
                  [NSDecimalNumber numberWithFloat:32.02],                  
                  nil];
    }
    return prices;
}


@end
