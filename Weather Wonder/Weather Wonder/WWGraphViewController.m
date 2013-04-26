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
    UIImage *sunnyImage;
    UIImage *cloudyImage;
    UIImage *rainImage;
    UIImage *snowImage;
    WWViewController *controller;
}

@property (nonatomic) IBOutlet UIButton *weatherButton;
@property (nonatomic) IBOutlet UIImageView *nightView;
@property (nonatomic) IBOutlet UIImageView *morningView;
@property (nonatomic) IBOutlet UIImageView *afternoonView;
@property (nonatomic) IBOutlet UIImageView *eveningView;
@property (nonatomic, strong) CPTGraphHostingView *apcpsfcView;
@property (nonatomic, strong) CPTGraphHostingView *tmax2mView;
@property (nonatomic, strong) CPTGraphHostingView *tmin2mView;

@end

//#define crainsfc 0 //temporary
//#define csnowsfc 1
//#define sunsdsfc 2
//#define tmax2m   3
//#define tmin2m   4
//#define apcpsfc  5

static const NSInteger kNumberOfPages = 2;

int numberOfTimesOfDay;
NSInteger page;

NSString *  const tickerSymbolTMAX2M   = @"TMAX2M";
NSString *  const tickerSymbolTMIN2M   = @"TMIN2M";
NSString *  const tickerSymbolAPCPSFC    = @"APCPSFC";

@implementation WWGraphViewController

@synthesize apcpsfcView = apcpsfcView_;
@synthesize tmax2mView  = tmax2mView_;
@synthesize tmin2mView  = tmin2mView_;
@synthesize nightView;
@synthesize morningView;
@synthesize afternoonView;
@synthesize eveningView;

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    scrollView.contentSize = CGSizeMake( kNumberOfPages*scrollView.frame.size.width, 0. );    
    pageControl.currentPage = 0;
    pageControl.numberOfPages = kNumberOfPages;

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
    
    controller  = [[WWViewController alloc] init];
    sunnyImage  = [UIImage imageNamed:@"WeatherIconSun"];
    cloudyImage = [UIImage imageNamed:@"WeatherIconCloudy"];
    rainImage   = [UIImage imageNamed:@"WeatherIconRain"];
    snowImage   = [UIImage imageNamed:@"WeatherIconSnow"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self
               forKeyPath:@"reloadImages"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) scrollViewDidScroll:(UIScrollView *)sv
{
    CGFloat pageWidth = scrollView.frame.size.width;
    page = (NSInteger)floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)sv
{
    // This function is required to make zooming work.
    // However, returning the first subview is wrong and zooming only partially works.
    // The real fix is more involved.
    return sv.subviews[0];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //NSLog(@"KVO: %@ changed property %@ to value %@", object, keyPath, change);
    
    [nightView setImage:nightViewImage];
    [morningView setImage:morningViewImage];
    [afternoonView setImage:afternoonViewImage];
    [eveningView setImage:eveningViewImgage];
    
    [self initPlot];
    [scrollView setNeedsDisplay];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    scrollView.contentSize = CGSizeMake( kNumberOfPages*scrollView.frame.size.width, 0.);
    scrollView.contentOffset = CGPointMake( scrollView.frame.size.width*pageControl.currentPage, 0. );
    [self.view updateConstraints];
    [scrollView updateConstraints];
    [self initPlot];
    [scrollView setNeedsDisplay];
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

- (IBAction)pageChanged
{
    scrollView.contentOffset = CGPointMake( scrollView.frame.size.width*pageControl.currentPage, 0. );
}

#pragma mark - CPTPlotDataSource methods 
//Stick in all the infos here
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    numberOfTimesOfDay = [controller getStartingTime:selectedIndex];;
    return [[[CPDStockPriceStore sharedInstance] combineTimeArrays:numberOfTimesOfDay] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSInteger valueCount = [[[CPDStockPriceStore sharedInstance] combineTimeArrays:[controller getStartingTime:selectedIndex]] count];
    NSArray *info;
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < valueCount) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
            if ([plot.identifier isEqual:tickerSymbolTMAX2M] == YES) {
                info = [controller convertArrayToFahrenheit:[self allDayBreakdownOfType:@"tmax2m" onDate:[self indexToDate:selectedIndex]]];
                return [info objectAtIndex:index];
            } else if ([plot.identifier isEqual:tickerSymbolTMIN2M] == YES) {
                info = [controller convertArrayToFahrenheit:[self allDayBreakdownOfType:@"tmin2m" onDate:[self indexToDate:selectedIndex]]];
                return [info objectAtIndex:index];
            } else if ([plot.identifier isEqual:tickerSymbolAPCPSFC] == YES) {
                info = [controller apcpsfcCompoundArrayInfoWithArray:[self allDayBreakdownOfType:@"apcpsfc" onDate:[self indexToDate:selectedIndex]]];
                return [info objectAtIndex:index];
            }
            break;
    }
    return [NSDecimalNumber zero];
}

-(NSDate*)indexToDate:(NSIndexPath*)indexPath
{
    NSDictionary *variableDay;
    variableDay   = [crainsfcDaily objectAtIndex:indexPath.section]; //arbituarly picked crainsfcDaily
    return variableDay[@"date"];
}
                                 
-(NSArray*)allDayBreakdownOfType:(NSString*)type onDate:(NSDate*)date
{
    NSMutableArray *combinedArray = [[NSMutableArray alloc]init];
    NSString *day;
    int time;
    for (NSDictionary *newIndex in crainsfcHourly)
    {
        NSString *tempDate = [newIndex[@"date"] substringWithRange:NSMakeRange(0,10)];
        NSString *tempDate2 = [[NSString stringWithFormat:@"%@", date] substringWithRange:NSMakeRange(0,10)];
        if ([tempDate isEqualToString:tempDate2]) {
            day = [newIndex[@"date"] substringWithRange:NSMakeRange(0, 10)];
            time = [[newIndex[@"date"] substringWithRange:NSMakeRange(11, 2)] integerValue];
            [combinedArray addObjectsFromArray:[controller getHourSetInfoOnType:type onDay:day atTime:time]];
        }
    }
    return [NSArray arrayWithArray:combinedArray];
}

#pragma mark - Chart behavior
-(void)initPlot {
    for(UIView *subview in [scrollView subviews]) {
        [subview removeFromSuperview];
    }
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
    if (page == 0)
    {
        // 1 - Set up view frame for first view
        CGRect parentRect = scrollView.bounds;
        parentRect = CGRectMake(parentRect.origin.x,
                                (parentRect.origin.y),
                                parentRect.size.width,
                                (parentRect.size.height));
        
        //Add the three graphviews
        self.apcpsfcView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
        self.apcpsfcView.allowPinchScaling = YES;
        [scrollView addSubview:self.apcpsfcView];
        
        parentRect = CGRectMake((parentRect.origin.x + parentRect.size.width),
                                parentRect.origin.y,
                                (parentRect.size.width),
                                parentRect.size.height);
        self.tmax2mView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
        self.tmax2mView.allowPinchScaling = YES;
        [scrollView addSubview:tmax2mView_];
    } else {
        // 1 - Set up view frame for first view
        CGRect parentRect = scrollView.bounds;
        parentRect = CGRectMake(parentRect.origin.x,
                                (parentRect.origin.y),
                                parentRect.size.width,
                                (parentRect.size.height));
        
        //Add the three graphviews
        self.tmax2mView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
        self.tmax2mView.allowPinchScaling = YES;
        [scrollView addSubview:tmax2mView_];
        
        parentRect = CGRectMake((parentRect.origin.x - parentRect.size.width),
                                parentRect.origin.y,
                                (parentRect.size.width),
                                parentRect.size.height);
        self.apcpsfcView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
        self.apcpsfcView.allowPinchScaling = YES;
        [scrollView addSubview:self.apcpsfcView];
    }
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.apcpsfcView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.apcpsfcView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = [NSString stringWithFormat:@"Accumulated Rain at Surface on %@", [controller dayStringFromIndexPath:selectedIndex]];
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"HelveticaNeue-Light";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:00.1f];
    [graph.plotAreaFrame setPaddingBottom:00.1f];
    [graph.plotAreaFrame setPaddingTop:125.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    
    CPTGraph *tempGraph = [[CPTXYGraph alloc] initWithFrame:self.tmax2mView.bounds];
    [tempGraph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.tmax2mView.hostedGraph = tempGraph;
    // 2 - Set graph title
    NSString *tempTitle = [NSString stringWithFormat:@"Temperature at Surface on %@", [controller dayStringFromIndexPath:selectedIndex]];
    tempGraph.title = tempTitle;
    // 3 - Create and set text style
    CPTMutableTextStyle *tempTitleStyle = [CPTMutableTextStyle textStyle];
    tempTitleStyle.color = [CPTColor whiteColor];
    tempTitleStyle.fontName = @"HelveticaNeue-Light";
    tempTitleStyle.fontSize = 16.0f;
    tempGraph.titleTextStyle = tempTitleStyle;
    tempGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    tempGraph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [tempGraph.plotAreaFrame setPaddingLeft:00.1f];
    [tempGraph.plotAreaFrame setPaddingBottom:00.1f];
    [tempGraph.plotAreaFrame setPaddingTop:125.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *tempPlotSpace = (CPTXYPlotSpace *) tempGraph.defaultPlotSpace;
    tempPlotSpace.allowsUserInteraction = NO;
}

-(void)configurePlots {
    //split into three parts
    
    // 1 - Get graph and plot space
    CPTGraph *apcpsfcGraph = self.apcpsfcView.hostedGraph;
    CPTGraph *temperatureGraph = self.tmax2mView.hostedGraph;
    CPTXYPlotSpace *apcpsfcPlotSpace = (CPTXYPlotSpace *) apcpsfcGraph.defaultPlotSpace;
    CPTXYPlotSpace *temperaturePlotSpace = (CPTXYPlotSpace *) temperatureGraph.defaultPlotSpace;
    // 2 - Create the three plots
    CPTScatterPlot *apcpsfcPlot = [[CPTScatterPlot alloc] init];
    apcpsfcPlot.dataSource = self;
    apcpsfcPlot.identifier = tickerSymbolAPCPSFC;
    CPTColor *apcpsfcColor = [CPTColor colorWithComponentRed:0.0f/255.0f green:129.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
    [apcpsfcGraph addPlot:apcpsfcPlot toPlotSpace:apcpsfcPlotSpace];
    
    CPTScatterPlot *tmax2mPlot = [[CPTScatterPlot alloc] init];
    tmax2mPlot.dataSource = self;
    tmax2mPlot.identifier = tickerSymbolTMAX2M;
    CPTColor *tmax2mColor = [CPTColor greenColor];//[CPTColor colorWithComponentRed:168.0f/255.0f green:28.0f/255.0f blue:39.0f/255.0f alpha:1.0f];
    [temperatureGraph addPlot:tmax2mPlot toPlotSpace:temperaturePlotSpace];
    
    CPTScatterPlot *tmin2mPlot = [[CPTScatterPlot alloc] init];
    tmin2mPlot.dataSource = self;
    tmin2mPlot.identifier = tickerSymbolTMIN2M;
    CPTColor *tmin2mColor = [CPTColor colorWithComponentRed:0.0f/255.0f green:129.0f/255.0f blue:205.0f/255.0f alpha:1.0f]; //rgba(0, 129, 205, 1.0000)
    [temperatureGraph addPlot:tmin2mPlot toPlotSpace:temperaturePlotSpace];
    
    // 3 - Set up plot space
    [apcpsfcPlotSpace scaleToFitPlots:[NSArray arrayWithObjects:apcpsfcPlot, nil]];
    CPTMutablePlotRange *xRange = [apcpsfcPlotSpace.xRange mutableCopy];
    //[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    [xRange setLocation:[NSDecimalNumber decimalNumberWithDecimal:xRange.minLimit * NSDecimalNumber numberWithFloat:1.1f]];
    //xRange.minLimit =     apcpsfcPlotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(0.0f) length:CPTDecimalFromCGFloat(apcpsfcPlotSpace.yRange.maxLimitDouble)];
    //[yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    apcpsfcPlotSpace.yRange = yRange;
        
    [temperaturePlotSpace scaleToFitPlots:[NSArray arrayWithObjects:tmax2mPlot, tmin2mPlot, nil]];
    xRange = [temperaturePlotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    temperaturePlotSpace.xRange = xRange;
    yRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(0.0f) length:CPTDecimalFromCGFloat(temperaturePlotSpace.yRange.maxLimitDouble)];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    temperaturePlotSpace.yRange = yRange;
    
    // Creates a drop gradient on the graphs
    CPTColor *areaColorBlue = [CPTColor colorWithComponentRed:0.0f/255.0f green:129.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColorBlue
                                                          endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    apcpsfcPlot.areaFill = areaGradientFill;
    apcpsfcPlot.areaBaseValue = CPTDecimalFromString(@"0.0");
    tmin2mPlot.areaFill = areaGradientFill;
    tmin2mPlot.areaBaseValue = CPTDecimalFromString(@"1.75");
    
    CPTColor *areaColorGreen = [CPTColor greenColor];
    areaGradient = [CPTGradient gradientWithBeginningColor:areaColorGreen
                                               endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    tmax2mPlot.areaFill = areaGradientFill;
    tmax2mPlot.areaBaseValue = CPTDecimalFromString(@"1.75");
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *apcpsfcLineStyle = [apcpsfcPlot.dataLineStyle mutableCopy];
    apcpsfcLineStyle.lineWidth = 2.5;
    apcpsfcLineStyle.lineColor = apcpsfcColor;
    apcpsfcPlot.dataLineStyle = apcpsfcLineStyle;
    CPTMutableLineStyle *apcpsfcSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    apcpsfcSymbolLineStyle.lineColor = apcpsfcColor;
//    CPTPlotSymbol *apcpsfcSymbol = [CPTPlotSymbol ellipsePlotSymbol]; //Use for adding symbols to mark the spots
//    apcpsfcSymbol.fill = [CPTFill fillWithColor:apcpsfcColor];
//    apcpsfcSymbol.lineStyle = apcpsfcSymbolLineStyle;
//    apcpsfcSymbol.size = CGSizeMake(6.0f, 6.0f);
//    apcpsfcPlot.plotSymbol = apcpsfcSymbol;
    
    CPTMutableLineStyle *tmax2mLineStyle = [tmax2mPlot.dataLineStyle mutableCopy];
    tmax2mLineStyle.lineWidth = 1.0;
    tmax2mLineStyle.lineColor = tmax2mColor;
    tmax2mPlot.dataLineStyle = tmax2mLineStyle;
    CPTMutableLineStyle *tmax2mSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    tmax2mSymbolLineStyle.lineColor = tmax2mColor;
//    CPTPlotSymbol *tmax2mSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    tmax2mSymbol.fill = [CPTFill fillWithColor:tmax2mColor];
//    tmax2mSymbol.lineStyle = tmax2mSymbolLineStyle;
//    tmax2mSymbol.size = CGSizeMake(6.0f, 6.0f);
//    tmax2mPlot.plotSymbol = tmax2mSymbol;
    
    CPTMutableLineStyle *tmin2mLineStyle = [tmin2mPlot.dataLineStyle mutableCopy];
    tmin2mLineStyle.lineWidth = 2.0;
    tmin2mLineStyle.lineColor = tmin2mColor;
    tmin2mPlot.dataLineStyle = tmin2mLineStyle;
    CPTMutableLineStyle *tmin2mSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    tmin2mSymbolLineStyle.lineColor = tmin2mColor;
//    CPTPlotSymbol *tmin2mSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    tmin2mSymbol.fill = [CPTFill fillWithColor:tmin2mColor];
//    tmin2mSymbol.lineStyle = tmin2mSymbolLineStyle;
//    tmin2mSymbol.size = CGSizeMake(6.0f, 6.0f);
//    tmin2mPlot.plotSymbol = tmin2mSymbol;
}

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"HelveticaNeue-Light";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"HelveticaNeue-Light";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    
    // 2 - Get axis set
    CPTXYAxisSet *apcpsfcAxisSet = (CPTXYAxisSet *) self.apcpsfcView.hostedGraph.axisSet;
    CPTXYAxisSet *temperatureAxisSet = (CPTXYAxisSet *) self.tmax2mView.hostedGraph.axisSet;
    
    // 3 - Configure x-axis
    
    // apcpsfc x-axis info
    CPTAxis *x = apcpsfcAxisSet.xAxis;
    x.title = @"Time of Day";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [[[CPDStockPriceStore sharedInstance] combineTimeArrays:numberOfTimesOfDay] count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    for (NSString *date in [[CPDStockPriceStore sharedInstance] combineTimeArrays:numberOfTimesOfDay]) {
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
    
    // temperature x-axis info
    CPTAxis *xx = temperatureAxisSet.xAxis;
    xx.title = @"Time of Day";
    xx.titleTextStyle = axisTitleStyle;
    xx.titleOffset = 15.0f;
    xx.axisLineStyle = axisLineStyle;
    xx.labelingPolicy = CPTAxisLabelingPolicyNone;
    xx.labelTextStyle = axisTextStyle;
    xx.majorTickLineStyle = axisLineStyle;
    xx.majorTickLength = 4.0f;
    xx.tickDirection = CPTSignNegative;
    CGFloat tempDateCount = [[[CPDStockPriceStore sharedInstance] combineTimeArrays:numberOfTimesOfDay] count];
    NSMutableSet *xxLabels = [NSMutableSet setWithCapacity:tempDateCount];
    NSMutableSet *xxLocations = [NSMutableSet setWithCapacity:tempDateCount];
    i = 0;
    for (NSString *date in [[CPDStockPriceStore sharedInstance] combineTimeArrays:numberOfTimesOfDay]) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:xx.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = xx.majorTickLength;
        if (label) {
            [xxLabels addObject:label];
            [xxLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    xx.axisLabels = xxLabels;
    xx.majorTickLocations = xxLocations;
    
    // 4 - Configure y-axis
    
    // apcpsfc y-axis info
    CPTAxis *y = apcpsfcAxisSet.yAxis;
    y.title = @"Amount in mm"; //also will need to be dynamically changed
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -30.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;//CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 0.1f;
    y.minorTickLength = 0.01f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 5;
    NSInteger minorIncrement = 1;
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
    
    // temperature y-axis info
    CPTAxis *yy = temperatureAxisSet.yAxis;
    yy.title = @"Degrees in Fahrenheit"; //also will need to be dynamically changed
    yy.titleTextStyle = axisTitleStyle;
    yy.titleOffset = -30.0f;
    yy.axisLineStyle = axisLineStyle;
    yy.majorGridLineStyle = gridLineStyle;
    yy.labelingPolicy = CPTAxisLabelingPolicyNone;
    yy.labelTextStyle = axisTextStyle;
    yy.labelOffset = 16.0f;
    yy.majorTickLineStyle = axisLineStyle;
    yy.majorTickLength = 4.0f;
    yy.minorTickLength = 2.0f;
    yy.tickDirection = CPTSignPositive;
    NSInteger tempMajorIncrement = 10;
    NSInteger tempMinorIncrement = 5;
    CGFloat yyMax = 700.0f;  // should determine dynamically based on max size
    NSMutableSet *yyLabels = [NSMutableSet set];
    NSMutableSet *yyMajorLocations = [NSMutableSet set];
    NSMutableSet *yyMinorLocations = [NSMutableSet set];
    for (NSInteger j = tempMinorIncrement; j <= yyMax; j += tempMinorIncrement) {
        NSUInteger mod = j % tempMajorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:yy.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -yy.majorTickLength - yy.labelOffset;
            if (label) {
                [yyLabels addObject:label];
            }
            [yyMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yyMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    yy.axisLabels = yyLabels;
    yy.majorTickLocations = yyMajorLocations;
    yy.minorTickLocations = yyMinorLocations;

}


@end
