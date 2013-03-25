//
//  PhotosTVC.h
//  SPoT
//
//  Created by Owen Medd on 3/14/13.
//  Copyright (c) 2013 InterGuide Communications, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosTVC : UITableViewController

@property (strong, nonatomic) NSArray *photos;
@property (readonly, nonatomic) NSString *reuseID; // abstract
@property (readonly, nonatomic) NSString *segueID; // abstract
@property (readonly, nonatomic) BOOL registerSelectionInRecents; // abstract
@property (readonly, nonatomic) BOOL sortPhotos; // abstract

- (NSString *)titleForRow:(NSUInteger)row;
- (NSString *)subtitleForRow:(NSUInteger)row;
@end
