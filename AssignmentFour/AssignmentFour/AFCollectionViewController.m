//
//  AFCollectionViewController.m
//  AssignmentFour
//
//  Created by Chad Marmon on 2/17/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

// Good job, 100%.

#import "AFCollectionViewController.h"

@interface AFCollectionViewController ()
{
    NSInteger sectionNumber[10];
}
@end

@implementation AFCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    int i = 0;
    while (i < sizeof(sectionNumber)/sizeof(int)) {
        sectionNumber[i++] = -1; //so no sections are colored at first
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //NSLog(@"The Number of sections are : %li", sizeof(sectionNumber)/sizeof(int));
    return sizeof(sectionNumber)/sizeof(int);
}

- (void)collectionView:(UICollectionView *)colView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int i = 0;
    UICollectionViewCell* cell;
    NSIndexPath *path;
    while (i != 6) { //hardcoded for now the row number is based on the location so i cant just use that. set to iPhone 5.
        path = [NSIndexPath indexPathForRow:i inSection:indexPath.section]; //Loops through and clears them out
        cell = [colView cellForItemAtIndexPath:path];
        cell.backgroundColor = [UIColor blueColor];
        i++;
    }
    sectionNumber[indexPath.section] = indexPath.row; //what row is active in that section
    cell = [colView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor]; //set the activated cell to the new color
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //NSLog(@"%i",section);
    return 6;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    //NSLog(@"%@", indexPath); for debuging
    if (sectionNumber[indexPath.section] == indexPath.row) //colors the active box in that section row has the same row #
    {
        cell.backgroundColor = [UIColor redColor];
    } else {
        cell.backgroundColor = [UIColor blueColor];
    }
    return cell;
}

@end
