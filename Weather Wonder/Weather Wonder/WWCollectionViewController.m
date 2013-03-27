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

@interface WWCollectionViewController ()
{
    UIImage *sunnyImage;
    UIImage *rainImage;
    UIImage *snowImage;
}
@end

@implementation WWCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    sunnyImage = [UIImage imageNamed:@"WeatherIconSun"];
    rainImage = [UIImage imageNamed:@"WeatherIconRain"];
    snowImage = [UIImage imageNamed:@"WeatherIconSnow"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)collectionView:(UICollectionView *)colView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //change the view of my statistics here to the day that is selected
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"%lu", (unsigned long)[csnowsfcInfo count]);
    return [csnowsfcInfo count];
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //NSLog(@"%i",section);
    return 1; //only one row
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UIImage *sunnyImage =[UIImage imageNamed:@"WeatherIconSun.png"];
    WWCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    NSLog(@"%d",indexPath.section);
    
    NSDictionary *variableRain = [crainsfcInfo objectAtIndex:indexPath.section];
    NSDictionary *variableSnow = [csnowsfcInfo objectAtIndex:indexPath.section];
    
    NSNumber *averageRain = variableRain[@"average"];
    NSNumber *averageSnow = variableSnow[@"average"];
    
    if(averageRain.doubleValue >= 0.5)
    {
        cell.imageView.image = rainImage;
    } else if (averageSnow.doubleValue >= 0.5)
    {
        cell.imageView.image = snowImage;
    } else {
        cell.imageView.image = sunnyImage;
    }
    return cell;
}

@end
