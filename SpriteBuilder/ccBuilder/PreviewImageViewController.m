//
//  PreviewImageViewController.m
//  SpriteBuilder
//
//  Created by Nicky Weber on 26.08.14.
//
//

#import "PreviewImageViewController.h"
#import "MiscConstants.h"
#import "ProjectSettings.h"
#import "CCBImageView.h"
#import "ResourcePropertyKeys.h"
#import "ImageFormatAndPropertiesHelper.h"
#import "FCFormatConverter.h"
#import "RMResource.h"
#import "NotificationNames.h"
#import "ResourceManager.h"
#import "NSAlert+Convenience.h"

@interface PreviewImageViewController ()

@property (nonatomic,strong) NSImage* imgMain;
@property (nonatomic,strong) NSImage* imgPhone;
@property (nonatomic,strong) NSImage* imgPhonehd;
@property (nonatomic,strong) NSImage* imgTablet;
@property (nonatomic,strong) NSImage* imgTablethd;

@end


@implementation PreviewImageViewController

- (void)setPreviewedResource:(RMResource *)previewedResource projectSettings:(ProjectSettings *)projectSettings
{
    self.projectSettings = projectSettings;
    self.previewedResource = previewedResource;

    [_previewMain setAllowsCutCopyPaste:NO];
    [_previewPhone setAllowsCutCopyPaste:NO];
    [_previewPhonehd setAllowsCutCopyPaste:NO];
    [_previewTablet setAllowsCutCopyPaste:NO];
    [_previewTablethd setAllowsCutCopyPaste:NO];

    [self populateInitialValues];
}

- (void)populateInitialValues
{
    // TODO: necessary?
    NSImage* universalImage = [_previewedResource previewForResolution:RESOLUTION_UNIVERSAL];
    if(universalImage)
    {
        self.imgMain = universalImage;
        self.imgPhone = universalImage;
        self.imgPhonehd = universalImage;
        self.imgTablet = universalImage;
        self.imgTablethd = universalImage;
    }
    else
    {
        self.imgMain = [_previewedResource previewForResolution:RESOLUTION_AUTO];
        self.imgPhone = [_previewedResource previewForResolution:RESOLUTION_PHONE];
        self.imgPhonehd = [_previewedResource previewForResolution:RESOLUTION_PHONE_HD];
        self.imgTablet = [_previewedResource previewForResolution:RESOLUTION_TABLET];
        self.imgTablethd = [_previewedResource previewForResolution:RESOLUTION_TABLET_HD];
    }

    [_previewMain setImage:self.imgMain];
    [_previewPhone setImage:self.imgPhone];
    [_previewPhonehd setImage:self.imgPhonehd];
    [_previewTablet setImage:self.imgTablet];
    [_previewTablethd setImage:self.imgTablethd];

    __weak PreviewImageViewController *weakSelf = self;
    [self setInitialValues:^{
        weakSelf.scaleFrom = [[weakSelf.projectSettings propertyForResource:weakSelf.previewedResource andKey:RESOURCE_PROPERTY_IMAGE_SCALE_FROM] intValue];

        weakSelf.format = [[weakSelf.projectSettings propertyForResource:weakSelf.previewedResource andKey:RESOURCE_PROPERTY_IMAGE_FORMAT] intValue];


        int tabletScale = [[weakSelf.projectSettings propertyForResource:weakSelf.previewedResource andKey:RESOURCE_PROPERTY_IMAGE_TABLET_SCALE] intValue];
        if (!tabletScale)
        {
            tabletScale = 2;
        }
        weakSelf.tabletScale = tabletScale;
    }];
}

- (BOOL)format_supportsPVRTC
{
    if (_previewedResource.type != kCCBResTypeImage)
    {
        return YES;
    }

    NSBitmapImageRep *bitmapRep = self.imgMain.representations[0];
    if (bitmapRep == nil)
    {
        return YES;
    }

    if (bitmapRep.pixelsHigh != bitmapRep.pixelsWide)
    {
        return NO;
    }

    return [ImageFormatAndPropertiesHelper isValueAPowerOfTwo:bitmapRep.pixelsHigh];
}

- (void)setScaleFrom:(int)scaleFrom
{
    _scaleFrom = scaleFrom;
    [self setValue:@(scaleFrom) withName:RESOURCE_PROPERTY_IMAGE_SCALE_FROM isAudio:NO];
}

- (void) setFormat:(int)format
{
    _format = format;
    [self setValue:@(format) withName:RESOURCE_PROPERTY_IMAGE_FORMAT isAudio:NO];
}

- (void) setTabletScale:(int)tabletScale
{
    _tabletScale = tabletScale;

    if (self.initialUpdate)
    {
        return;
    }

    // Return if tabletScale hasn't changed
    int oldTabletScale = [[_projectSettings propertyForResource:_previewedResource andKey:RESOURCE_PROPERTY_IMAGE_TABLET_SCALE] intValue];
    if (tabletScale == 2 && !oldTabletScale) return;

    // Update value and reload assets
    if (tabletScale != 2)
    {
        [_projectSettings setProperty:@(tabletScale) forResource:_previewedResource andKey:RESOURCE_PROPERTY_IMAGE_TABLET_SCALE];
    }
    else
    {
        [_projectSettings removePropertyForResource:_previewedResource andKey:RESOURCE_PROPERTY_IMAGE_TABLET_SCALE];
    }

    [ResourceManager touchResource:_previewedResource];
    [[NSNotificationCenter defaultCenter] postNotificationName:RESOURCES_CHANGED object:nil];
}

- (IBAction)actionRemoveFile:(id)sender
{
    if (!_previewedResource)
    {
        return;
    }

    CCBImageView *imgView = NULL;
    int tag = [sender tag];
    if (tag == 0)
    {
        imgView = _previewPhone;
    }
    else if (tag == 1)
    {
        imgView = _previewPhonehd;
    }
    else if (tag == 2)
    {
        imgView = _previewTablet;
    }
    else if (tag == 3)
    {
        imgView = _previewTablethd;
    }

    if (!imgView)
    {
        return;
    }

    NSString *resolution = [self resolutionDirectoryForImageView:imgView];
    if (!resolution)
    {
        return;
    }

    NSString *dir = [_previewedResource.filePath stringByDeletingLastPathComponent];
    NSString *file = [_previewedResource.filePath lastPathComponent];

    NSString *rmFile = [[dir stringByAppendingPathComponent:resolution] stringByAppendingPathComponent:file];

    // Remove file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:rmFile error:NULL];

    // Remove from view
    imgView.image = NULL;

    // Reload open document
    [[NSNotificationCenter defaultCenter] postNotificationName:RESOURCES_CHANGED object:nil];
}

- (NSString*) resolutionDirectoryForImageView:(NSImageView*) imgView
{
    NSString *resolution = NULL;
    if (imgView == _previewMain)
    {
        resolution = RESOLUTION_AUTO;
    }
    else if (imgView == _previewPhone)
    {
        resolution = RESOLUTION_PHONE;
    }
    else if (imgView == _previewPhonehd)
    {
        resolution = RESOLUTION_PHONE_HD;
    }
    else if (imgView == _previewTablet)
    {
        resolution = RESOLUTION_TABLET;
    }
    else if (imgView == _previewTablethd)
    {
        resolution = RESOLUTION_TABLET_HD;
    }

    if (!resolution)
    {
        return NULL;
    }

    return [@"resources-" stringByAppendingString:resolution];
}

- (IBAction)droppedFile:(id)sender
{
    if (!_projectSettings
        || !_previewedResource)
    {
        return;
    }

    CCBImageView *imgView = sender;
    NSString *srcImagePath = imgView.imagePath;

    if (![[[srcImagePath pathExtension] lowercaseString] isEqualToString:@"png"])
    {
        [NSAlert showModalDialogWithTitle:@"Unsupported Format"
                                  message:@"Sorry, only png images are supported as source images."];
        return;
    }

    NSString *resolution = [self resolutionDirectoryForImageView:imgView];
    if (!resolution)
    {
        return;
    }

    // Calc dst path
    NSString *dir = [_previewedResource.filePath stringByDeletingLastPathComponent];
    NSString *file = [_previewedResource.filePath lastPathComponent];

    NSString *dstFile = [[dir stringByAppendingPathComponent:resolution] stringByAppendingPathComponent:file];

    // Create directory if it doesn't exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:[dstFile stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:NULL error:NULL];

    // Copy file
    [fileManager removeItemAtPath:dstFile error:NULL];
    [fileManager copyItemAtPath:srcImagePath toPath:dstFile error:NULL];

    // Reload open document
    [[NSNotificationCenter defaultCenter] postNotificationName:RESOURCES_CHANGED object:nil];
}

@end
