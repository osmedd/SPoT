//
//  SPoTPhotoDB.m
//  SPoT
//
//  Created by Owen Medd on 3/12/13.
//  Copyright (c) 2013 InterGuide Communications, Inc. All rights reserved.
//

#import "SPoTPhotoDB.h"
#import "FlickrFetcher.h"

#define MAX_RECENT_PHOTO_COUNT 10
#define RECENT_PHOTO_KEY_IN_USER_DEFAULT @"RECENT_PHOTO"

@interface SPoTPhotoDB()
@property (strong, nonatomic) NSCache *photoCache;
@property (strong, nonatomic) NSArray *photos;
@property (strong, readwrite, nonatomic) NSMutableDictionary *categories;
@end

@implementation SPoTPhotoDB

- (NSCache *)photoCache
{
    if (_photoCache == nil) {
        _photoCache = [[NSCache alloc] init];
        [_photoCache setCountLimit:5];
    }
    return _photoCache;
}

- (NSDictionary *)categories
{
    if (_categories == nil) _categories = [[NSMutableDictionary alloc] init];
    return _categories;
}

- (NSArray *)photos
{
    if (_photos == nil) _photos = [[NSArray alloc] init];
    return _photos;
}

- (void)loadStanfordPhotos
{
    NSSet *ignoreCategories = [[NSSet alloc] initWithObjects:@"cs193pspot", @"portrait", @"landscape", nil];
    self.photos = [FlickrFetcher stanfordPhotos];
    self.categories = nil;
    
    for (int i = 0; i < [self.photos count]; i++) {
        NSArray *tags = [self.photos[i][FLICKR_TAGS] componentsSeparatedByString:@" "];
        for (int j = 0; j < [tags count]; j++) {
            if ([ignoreCategories containsObject:tags[j]]) {
                continue;
            }
            
            if ([self.categories objectForKey:tags[j]] == nil) {
                [self.categories setValue:[[NSMutableArray alloc] init] forKey:tags[j]];
            }
            
            NSMutableArray *photosForTags = self.categories[tags[j]];
            [photosForTags addObject:@(i)];
        }
    }
}

- (NSDictionary *)getPhotoData:(int)photoIdx
{
    NSDictionary *photoData = nil;
    
    if (photoIdx < [self.photos count]) {
        photoData = self.photos[photoIdx];
    }
    
    return photoData;
}

+ (void)registerRecentPhoto:(NSDictionary *)photo
{
    NSMutableArray *recenPhotoList = [[[self class] recentPhotos] mutableCopy];
    if (![recenPhotoList containsObject:photo]) { // don't put duplicated picture
        if ([recenPhotoList count] >= MAX_RECENT_PHOTO_COUNT) { // limit number of photo in store
            [recenPhotoList removeObject:[recenPhotoList lastObject]];
        }
    } else { // if already exist put photo to top of list
        [recenPhotoList removeObject:photo];
    }
    
    [recenPhotoList insertObject:photo atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:[recenPhotoList copy] forKey:RECENT_PHOTO_KEY_IN_USER_DEFAULT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *) recentPhotos
{
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSArray *result = [[NSUserDefaults standardUserDefaults] valueForKey:RECENT_PHOTO_KEY_IN_USER_DEFAULT];
    if (!result) {
        result =  [[NSArray alloc] init];
    }
    return result;
}

@end
