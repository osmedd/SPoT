//
//  ImageViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic) BOOL isZooming;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic) unsigned long long int maxCacheSize;
@end

@implementation ImageViewController

- (unsigned long long int)maxCacheSize
{
    return 10 * 1024 * 1024; // 10MB
}

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

// resets the image whenever the URL changes

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (unsigned long long int)folderSize:(NSString *)folderPath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *filesArray = [fileManager subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    NSError *attrError;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:&attrError];
        fileSize += [fileDictionary fileSize];
    }
    
    NSLog(@"cache folder size: %lld", fileSize);
    return fileSize;
}

- (void)pruneCacheDirectory:(NSURL *)cacheDirectoryURL
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *infoKeys = [NSArray arrayWithObjects:NSURLIsRegularFileKey, nil];
    NSError *attrError;
        
    while ([self folderSize:cacheDirectoryURL.path] > self.maxCacheSize) {
        NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:cacheDirectoryURL includingPropertiesForKeys:infoKeys options:(NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:^BOOL(NSURL *url, NSError *error) {
            return YES;
        }];
        
        NSDictionary *oldestFileAttr = nil;
        NSURL *oldestFileURL = nil;
        for (NSURL *url in enumerator) {
            NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:url.path error:&attrError];
            
            if (oldestFileAttr == nil) {
                oldestFileURL = url;
                oldestFileAttr = fileAttr;
            } else {
                if (fileAttr[NSFileModificationDate] < oldestFileAttr[NSFileModificationDate]) {
                    oldestFileAttr = fileAttr;
                    oldestFileURL = url;
                }
            }
        }
        
        if (oldestFileURL) {
            NSLog(@"removing cache file: %@", oldestFileURL.path);
            [fileManager removeItemAtURL:oldestFileURL error:&attrError];
        }
    }
}

- (NSData *)getData:(NSURL *)imageURL
{
    NSData *imageData = nil;
    NSURL *cacheDirectory = nil;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *urls = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    if ([urls count] > 0) {
        cacheDirectory = urls[0];
    }
    NSURL *spotCacheDirectory = [cacheDirectory URLByAppendingPathComponent:@"SPoT"];
    NSError *createErr;
    if (![fileManager fileExistsAtPath:spotCacheDirectory.path]) {
        if (![fileManager createDirectoryAtURL:spotCacheDirectory withIntermediateDirectories:YES attributes:nil error:&createErr]) {
            NSLog(@"SPoT cache directory create failed: %@", createErr.localizedDescription);
        }
    }
    
    NSString *cacheFileName = [imageURL lastPathComponent];
    NSLog(@"imageURL lastPathComponent: %@", cacheFileName);
    NSURL *cacheFileURL = [spotCacheDirectory URLByAppendingPathComponent:cacheFileName];
    
    if (![fileManager fileExistsAtPath:cacheFileURL.path]) {
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
        app.networkActivityIndicatorVisible = NO;
        [imageData writeToURL:cacheFileURL atomically:YES];
        NSLog(@"fetched image from %@", cacheFileURL.path);
    } else {
        imageData = [NSData dataWithContentsOfURL:cacheFileURL];
        NSLog(@"used existing cache entry %@", cacheFileURL.path);
    }
    
    // prune cache directory if necessary
    if ([self folderSize:spotCacheDirectory.path] > self.maxCacheSize) {
        [self pruneCacheDirectory:spotCacheDirectory];
    }

    return imageData;
}

// fetches the data from the URL
// turns it into an image
// adjusts the scroll view's content size to fit the image
// sets the image as the image view's image

- (void)resetImage
{
    if (self.scrollView && self.imageURL) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        [self.spinner startAnimating];
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSData *imageData = [self getData:self.imageURL];
            if (imageData) {
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        [self makeImageFitInScrollView];
                    }
                    [self.spinner stopAnimating];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.spinner stopAnimating];
                });
            }
        });
    }
}

- (void)makeImageFitInScrollView
{
    if (self.imageView.image) {
        // make image fill whole screen
        //NSLog(@"image width %f height %f", self.imageView.image.size.width, self.imageView.image.size.height);
        //NSLog(@"scrollview set? %@", (self.scrollView ? @"YES" : @"NO"));
        //NSLog(@"scrollView bounds width %f height %f", self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        self.scrollView.zoomScale = 1.0;
        self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
        float xScale = self.scrollView.bounds.size.width / self.imageView.image.size.width;
        float yScale = self.scrollView.bounds.size.height / self.imageView.image.size.height;
        //NSLog(@"xScale %f yScale %f", xScale, yScale);
        CGRect zoomToRect;
        float xOffset = 0;
        float yOffset = 0;
        if (yScale > xScale) {
            xOffset = (self.imageView.bounds.size.width * yScale - self.scrollView.bounds.size.width) / 2.0;
            zoomToRect = CGRectMake(0, 0, 0, self.imageView.image.size.height);
        } else {
            yOffset = (self.imageView.bounds.size.height * xScale - self.scrollView.bounds.size.height) / 2.0;
            zoomToRect = CGRectMake(0, 0, self.imageView.image.size.width, 0);
        }
        [self.scrollView zoomToRect:zoomToRect animated:false];
        self.scrollView.contentOffset = CGPointMake(xOffset , yOffset );
    }
}

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

// returns the view which will be zoomed when the user pinches
// in this case, it is the image view, obviously
// (there are no other subviews of the scroll view in its content area)

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.isZooming = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    self.isZooming = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!self.isZooming) {
        [self makeImageFitInScrollView];
    }
}

// add the image view to the scroll view's content area
// setup zooming by setting min and max zoom scale
//   and setting self to be the scroll view's delegate
// resets the image in case URL was set before outlets (e.g. scroll view) were set

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
    self.titleBarButtonItem.title = self.title;
    [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    UIToolbar *tb = [self toolbar];
    NSMutableArray *toolbarItems = [tb.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (barButtonItem) [toolbarItems insertObject:barButtonItem atIndex:0];
    tb.items = toolbarItems;
    _splitViewBarButtonItem = barButtonItem;
}

@end
