//
//  WWGraphViewController.m
//  Weather Wonder
//
//  Created by Chad Marmon on 3/15/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "WWGraphViewController.h"
#import "WWCollectionViewController.h"
#import "WWViewController.h"

@interface WWGraphViewController ()
{
    //__weak IBOutlet UIButton *weatherButton;
}

@property (nonatomic) IBOutlet UIButton *weatherButton;
@property (nonatomic, strong) CPTGraphHostingView *hostView;

@end

#define crainsfc 0 //temporary
#define csnowsfc 1
#define sunsdsfc 2
#define tmax2m   3
#define tmin2m   4
#define apcpsfc  5

NSString *  const tickerSymbolCRAINSFC   = @"CRAINSFC";
NSString *  const tickerSymbolCSNOWSFC   = @"CSNOWSFC";
NSString *  const tickerSymbolAPCPSFC    = @"APCPSFC";

@implementation WWGraphViewController

@synthesize hostView = hostView_;

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initPlot];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    weatherDisplay = [[NSUserDefaults standardUserDefaults] boolForKey:@"weatherDisplay"];
    if (weatherDisplay)
    {
        [_weatherButton setTitle:@"Switch to Day View" forState:UIControlStateNormal];
    } else {
        [_weatherButton setTitle:@"Switch to Hour View" forState:UIControlStateNormal];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark IBActions

-(IBAction)weatherDisplayButton:(id)sender
{
    //WWCollectionViewController *newController = [[WWCollectionViewController alloc] init];
    if (weatherDisplay)
    {
        [_weatherButton setTitle:@"Switch to Day View" forState:UIControlStateNormal];
        weatherDisplay = false;
    } else {
        [_weatherButton setTitle:@"Switch to Hour View" forState:UIControlStateNormal];
        weatherDisplay = true;
    }
    [[NSUserDefaults standardUserDefaults] setBool:weatherDisplay forKey:@"weatherDisplay"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - CPTPlotDataSource methods 
//Stick in all the infos here
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSInteger valueCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < valueCount) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
            if ([plot.identifier isEqual:tickerSymbolCSNOWSFC] == YES) {
                NSDictionary *csnowsfcDict = [[self monthlyPrices:tickerSymbolCSNOWSFC] objectAtIndex:index];
                NSNumber *temp = csnowsfcDict[@"average"];
                NSNumber *csnowsfcNumber = [NSNumber numberWithDouble:temp.doubleValue * 100.00]; //convert to precentage
                return  csnowsfcNumber;
            } else if ([plot.identifier isEqual:tickerSymbolCRAINSFC] == YES) {
                NSDictionary *crainsfcDict = [[self monthlyPrices:tickerSymbolCRAINSFC] objectAtIndex:index];
                NSNumber *temp = crainsfcDict[@"average"];
                NSNumber *crainsfcNumber = [NSNumber numberWithDouble:temp.doubleValue * 100.00];
                return  crainsfcNumber;

            } else if ([plot.identifier isEqual:tickerSymbolAPCPSFC] == YES) {
                NSDictionary *apcpsftDict = [[self monthlyPrices:tickerSymbolAPCPSFC] objectAtIndex:index];
                NSNumber *temp = apcpsftDict[@"average"];
                NSNumber *apcpsfcNumber = [NSNumber numberWithDouble:temp.doubleValue];
                return  apcpsfcNumber;
            }
            break;
    }
    return [NSDecimalNumber zero];
}

- (NSArray *)monthlyPrices:(NSString *)tickerSymbol
{
    if ([tickerSymbolCSNOWSFC isEqualToString:[tickerSymbol uppercaseString]] == YES)
    {
        return crainsfcHourly;
    }
    else if ([tickerSymbolCRAINSFC isEqualToString:[tickerSymbol uppercaseString]] == YES)
    {
        return crainsfcHourly;
    }
    else if ([tickerSymbolAPCPSFC isEqualToString:[tickerSymbol uppercaseString]] == YES)
    {
        return apcpsfcHourly;
    }
    return [NSArray array];
}


#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
    // 1 - Set up view frame
    CGRect parentRect = self.view.bounds;
    CGSize weatherButtonSize = self.weatherButton.bounds.size;
    parentRect = CGRectMake(parentRect.origin.x,
                            (parentRect.origin.y + weatherButtonSize.height + 130),
                            parentRect.size.width,
                            (parentRect.size.height - weatherButtonSize.height - 130)); //need to get correct dynamic spaceing
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = YES;
    [self.view addSubview:self.hostView];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = @"Snow at Surface";       //going to need to be dynamically changed later
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:00.1f];
    [graph.plotAreaFrame setPaddingBottom:00.1f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
}

-(void)configurePlots {
    
    //split into three parts
    
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the three plots
    CPTScatterPlot *apcpsfcPlot = [[CPTScatterPlot alloc] init];
    apcpsfcPlot.dataSource = self;
    apcpsfcPlot.identifier = tickerSymbolAPCPSFC;
    CPTColor *apcpsfcColor = [CPTColor whiteColor];
    [graph addPlot:apcpsfcPlot toPlotSpace:plotSpace];
//    CPTScatterPlot *googPlot = [[CPTScatterPlot alloc] init];
//    googPlot.dataSource = self;
//    googPlot.identifier = CPDTickerSymbolGOOG;
//    CPTColor *googColor = [CPTColor greenColor];
//    [graph addPlot:googPlot toPlotSpace:plotSpace];
//    CPTScatterPlot *msftPlot = [[CPTScatterPlot alloc] init];
//    msftPlot.dataSource = self;
//    msftPlot.identifier = CPDTickerSymbolMSFT;
//    CPTColor *msftColor = [CPTColor blueColor];
//    [graph addPlot:msftPlot toPlotSpace:plotSpace];
    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:apcpsfcPlot, nil]]; //googPlot, msftPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    // 4 - Create styles and symbols
    CPTMutableLineStyle *apcpsfcLineStyle = [apcpsfcPlot.dataLineStyle mutableCopy];
    apcpsfcLineStyle.lineWidth = 2.5;
    apcpsfcLineStyle.lineColor = apcpsfcColor;
    apcpsfcPlot.dataLineStyle = apcpsfcLineStyle;
    CPTMutableLineStyle *apcpsfcSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    apcpsfcSymbolLineStyle.lineColor = apcpsfcColor;
    CPTPlotSymbol *apcpsfcSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    apcpsfcSymbol.fill = [CPTFill fillWithColor:apcpsfcColor];
    apcpsfcSymbol.lineStyle = apcpsfcSymbolLineStyle;
    apcpsfcSymbol.size = CGSizeMake(6.0f, 6.0f);
    apcpsfcPlot.plotSymbol = apcpsfcSymbol;
//    CPTMutableLineStyle *googLineStyle = [googPlot.dataLineStyle mutableCopy];
//    googLineStyle.lineWidth = 1.0;
//    googLineStyle.lineColor = googColor;
//    googPlot.dataLineStyle = googLineStyle;
//    CPTMutableLineStyle *googSymbolLineStyle = [CPTMutableLineStyle lineStyle];
//    googSymbolLineStyle.lineColor = googColor;
//    CPTPlotSymbol *googSymbol = [CPTPlotSymbol starPlotSymbol];
//    googSymbol.fill = [CPTFill fillWithColor:googColor];
//    googSymbol.lineStyle = googSymbolLineStyle;
//    googSymbol.size = CGSizeMake(6.0f, 6.0f);
//    googPlot.plotSymbol = googSymbol;
//    CPTMutableLineStyle *msftLineStyle = [msftPlot.dataLineStyle mutableCopy];
//    msftLineStyle.lineWidth = 2.0;
//    msftLineStyle.lineColor = msftColor;
//    msftPlot.dataLineStyle = msftLineStyle;
//    CPTMutableLineStyle *msftSymbolLineStyle = [CPTMutableLineStyle lineStyle];
//    msftSymbolLineStyle.lineColor = msftColor;
//    CPTPlotSymbol *msftSymbol = [CPTPlotSymbol diamondPlotSymbol];
//    msftSymbol.fill = [CPTFill fillWithColor:msftColor];
//    msftSymbol.lineStyle = msftSymbolLineStyle;
//    msftSymbol.size = CGSizeMake(6.0f, 6.0f);
//    msftPlot.plotSymbol = msftSymbol;
}

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Day of Month";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    for (NSString *date in [[CPDStockPriceStore sharedInstance] datesInMonth]) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Precentage \%";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -30.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 10;
    NSInteger minorIncrement = 5;
    CGFloat yMax = 700.0f;  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}


@end
