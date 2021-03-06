/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ResolutionSetting.h"

@implementation ResolutionSetting

@synthesize enabled;
@synthesize name;
@synthesize width;
@synthesize height;
@synthesize ext;
@synthesize resourceScale;
@synthesize mainScale;
@synthesize additionalScale;
@synthesize centeredOrigin;
@synthesize exts;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    enabled = NO;
    self.name = @"Custom";
    self.width = 1000;
    self.height = 1000;
    self.ext = @" ";
    self.resourceScale = 1;
    self.mainScale = 1;
    self.additionalScale = 1;
    
    return self;
}

- (id) initWithSerialization:(id)serialization
{
    self = [self init];
    if (!self) return NULL;
    
    self.enabled = YES;
    self.name = [serialization objectForKey:@"name"];
    self.width = [[serialization objectForKey:@"width"] intValue];
    self.height = [[serialization objectForKey:@"height"] intValue];
    self.ext = [serialization objectForKey:@"ext"];
		// TODO should store separate values for these.
    //float scale = [[serialization objectForKey:@"scale"] floatValue];
    self.resourceScale = [[serialization objectForKey:@"resourceScale"] floatValue];
    self.mainScale = [[serialization objectForKey:@"mainScale"] floatValue];
    self.additionalScale = [[serialization objectForKey:@"additionalScale"] floatValue];
    self.centeredOrigin = [[serialization objectForKey:@"centeredOrigin"] boolValue];
    if(self.resourceScale == 0)
    {
        float scale = [[serialization objectForKey:@"scale"] floatValue];
        self.resourceScale = scale;
        self.mainScale = scale;
        self.additionalScale = scale;
    }
    
    return self;
}

-(void)setresourceScale:(float)_scale
{
	NSAssert(_scale > 0.0, @"scale must be positive.");
	
//	if(_scale <= 0.0){
//		NSLog(@"WARNING: scale must be positive. (1.0 was substituted for %f)", _scale);
//		_scale = 1.0;
//	}
	
	resourceScale = _scale;
}

- (id) serialize
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    [dict setObject:name forKey:@"name"];
    [dict setObject:[NSNumber numberWithInt:width] forKey:@"width"];
    [dict setObject:[NSNumber numberWithInt:height] forKey:@"height"];
    [dict setObject:ext forKey:@"ext"];
    [dict setObject:[NSNumber numberWithFloat:resourceScale] forKey:@"resourceScale"];
    [dict setObject:[NSNumber numberWithFloat:mainScale] forKey:@"mainScale"];
    [dict setObject:[NSNumber numberWithFloat:additionalScale] forKey:@"additionalScale"];
    [dict setObject:[NSNumber numberWithBool:centeredOrigin] forKey:@"centeredOrigin"];
    
    return dict;
}

- (void) setExt:(NSString *)e
{
    
    ext = [e copy];
    
    if (!e || [e isEqualToString:@" "] || [e isEqualToString:@""])
    {
        exts = [[NSArray alloc] init];
    }
    else
    {
        exts = [e componentsSeparatedByString:@" "];
    }
}

- (void) dealloc
{
    self.ext = NULL;
    
}

+ (ResolutionSetting*) settingPhone
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"Phone";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phone";
    setting.resourceScale = 1;
    
    return setting;
}
+ (ResolutionSetting*) settingPhoneHd
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"PhoneHd";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phonehd phone";
    setting.resourceScale = 2;
    
    return setting;
}
+ (ResolutionSetting*) settingTabletHd
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"TabletHd";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"tablethd tablet phonehd phone";
    setting.resourceScale = 4;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhone
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"iPhone";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phone";
    setting.resourceScale = 1;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhoneLandscape
{
    ResolutionSetting* setting = [self settingIPhone];
    
    setting.name = @"iPhone Landscape (short)";
    setting.width = 480;
    setting.height = 320;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhonePortrait
{
    ResolutionSetting* setting = [self settingIPhone];
    
    setting.name = @"iPhone Portrait (short)";
    setting.width = 320;
    setting.height = 480;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhoneRetina
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"iPhone";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phonehd phone";
    setting.resourceScale = 2;
    
    return setting;
}
+ (ResolutionSetting*) settingIPhoneRetinaLandscape
{
    ResolutionSetting* setting = [self settingIPhoneRetina];
    
    setting.name = @"iPhone 4S Landscape";
    setting.width = 960;
    setting.height = 640;
    
    return setting;
}
+ (ResolutionSetting*) settingIPhoneRetinaPortrait
{
    ResolutionSetting* setting = [self settingIPhoneRetina];
    
    setting.name = @"iPhone 4S Portrait";
    setting.width = 640;
    setting.height = 960;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhone5Landscape
{
    ResolutionSetting* setting = [self settingIPhoneRetina];
    
    setting.name = @"iPhone 5 Landscape";
    setting.width = 1136;
    setting.height = 640;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhone5Portrait
{
    ResolutionSetting* setting = [self settingIPhoneRetina];
    
    setting.name = @"iPhone 5 Portrait";
    setting.width = 640;
    setting.height = 1136;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhone6
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"iPhone 6";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phonehd phone";
    setting.resourceScale = 2;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhone6Landscape
{
    ResolutionSetting* setting = [self settingIPhone6];
    
    setting.name = @"iPhone 6 Landscape";
    setting.width = 1334;
    setting.height = 750;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhone6Portrait
{
    ResolutionSetting* setting = [self settingIPhone6];
    
    setting.name = @"iPhone 6 Portrait";
    setting.width = 750;
    setting.height = 1334;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhone6Plus
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"iPhone 6+";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"tablethd tablet phonehd phone";
    setting.resourceScale = 4;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhone6PlusLandscape
{
    ResolutionSetting* setting = [self settingIPhone6Plus];
    
    setting.name = @"iPhone 6+ Landscape";
    setting.width = 1920;
    setting.height = 1080;
    
    return setting;
}

+ (ResolutionSetting*) settingIPhone6PlusPortrait
{
    ResolutionSetting* setting = [self settingIPhone6Plus];
    
    setting.name = @"iPhone 6+ Portrait";
    setting.width = 1080;
    setting.height = 1920;
    
    return setting;
}

+ (ResolutionSetting*) settingIPad
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"iPad";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phonehd phone";
    setting.resourceScale = 2;
    
    return setting;
}

+ (ResolutionSetting*) settingIPadLandscape
{
    ResolutionSetting* setting = [self settingIPad];
    
    setting.name = @"iPad Landscape";
    setting.width = 1024;
    setting.height = 768;
    
    return setting;
}

+ (ResolutionSetting*) settingIPadPortrait
{
    ResolutionSetting* setting = [self settingIPad];
    
    setting.name = @"iPad Portrait";
    setting.width = 768;
    setting.height = 1024;
    
    return setting;
}

+ (ResolutionSetting*) settingIPadRetina
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"iPad Retina";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"tablethd phonehd phone";
    setting.resourceScale = 4;
    
    return setting;
}

+ (ResolutionSetting*) settingIPadRetinaLandscape
{
    ResolutionSetting* setting = [self settingIPadRetina];
    
    setting.name = @"iPad Retina Landscape";
    setting.width = 2048;
    setting.height = 1536;
    
    return setting;
}

+ (ResolutionSetting*) settingIPadRetinaPortrait
{
    ResolutionSetting* setting = [self settingIPadRetina];
    
    setting.name = @"iPad Retina Portrait";
    setting.width = 1536;
    setting.height = 2048;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidXSmall
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"Android X-Small";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phone";
    setting.resourceScale = 0.5;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidXSmallLandscape
{
    ResolutionSetting* setting = [self settingAndroidXSmall];
    
    setting.name = @"Android X-Small Landscape";
    setting.width = 320;
    setting.height = 240;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidXSmallPortrait
{
    ResolutionSetting* setting = [self settingAndroidXSmall];
    
    setting.name = @"Android X-Small Portrait";
    setting.width = 240;
    setting.height = 320;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidSmall
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"Android Small";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phone";
    setting.resourceScale = 1;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidSmallLandscape
{
    ResolutionSetting* setting = [self settingAndroidSmall];
    
    setting.name = @"Android Small Landscape";
    setting.width = 480;
    setting.height = 340;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidSmallPortrait
{
    ResolutionSetting* setting = [self settingAndroidSmall];
    
    setting.name = @"Android Small Portrait";
    setting.width = 340;
    setting.height = 480;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidMedium
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"Android Medium";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phone";
    setting.resourceScale = 1.5;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidMediumLandscape
{
    ResolutionSetting* setting = [self settingAndroidMedium];
    
    setting.name = @"Android Medium Landscape";
    setting.width = 800;
    setting.height = 480;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidMediumPortrait
{
    ResolutionSetting* setting = [self settingAndroidMedium];
    
    setting.name = @"Android Medium Portrait";
    setting.width = 480;
    setting.height = 800;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidLarge
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"Android Large";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"phonehd phone";
    setting.resourceScale = 2;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidLargeLandscape
{
    ResolutionSetting* setting = [self settingAndroidLarge];
    
    setting.name = @"Android Large Landscape";
    setting.width = 1280;
    setting.height = 800;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidLargePortrait
{
    ResolutionSetting* setting = [self settingAndroidLarge];
    
    setting.name = @"Android Large Portrait";
    setting.width = 800;
    setting.height = 1280;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidXLarge
{
    ResolutionSetting* setting = [[ResolutionSetting alloc] init];
    
    setting.name = @"Android X-Large";
    setting.width = 0;
    setting.height = 0;
    setting.ext = @"tablethd phonehd phone";
    setting.resourceScale = 4;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidXLargeLandscape
{
    ResolutionSetting* setting = [self settingAndroidXLarge];
    
    setting.name = @"Android X-Large Landscape";
    setting.width = 2048;
    setting.height = 1536;
    
    return setting;
}

+ (ResolutionSetting*) settingAndroidXLargePortrait
{
    ResolutionSetting* setting = [self settingAndroidXLarge];
    
    setting.name = @"Android X-Large Portrait";
    setting.width = 1536;
    setting.height = 2048;
    
    return setting;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ <0x%x> (%d x %d)", NSStringFromClass([self class]), (unsigned int)self, width, height];
}

- (id) copyWithZone:(NSZone*)zone
{
    ResolutionSetting* copy = [[ResolutionSetting alloc] init];
    
    copy.enabled = enabled;
    copy.name = name;
    copy.width = width;
    copy.height = height;
    copy.ext = ext;
    copy.resourceScale = resourceScale;
    copy.mainScale = mainScale;
    copy.additionalScale = additionalScale;
    copy.centeredOrigin = centeredOrigin;
    
    return copy;
}

@end
