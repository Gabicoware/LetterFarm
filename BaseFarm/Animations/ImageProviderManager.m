//
//  ImageProviderManager.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/21/13.
//
//

#import "ImageProviderManager.h"
#import "TileImageProvider.h"
#import <QuartzCore/QuartzCore.h>

CGImageRef CGCreateScaledImageFromImage(CGImageRef image, float scale);

NSString* DefaultTextureName = @"sheep";

#define resolution_small 21.6

#ifdef COLOR_WORD
#define resolution_iphone 30
#else
#define resolution_iphone 21.6
#endif

#define resolution_ipad 36

#define resolution_base 144

#define COLOR_PREFIX @"color_mask_"

@interface TextureAtlasFactory : NSObject<NSXMLParserDelegate>

@property (nonatomic) NSMutableDictionary* rects;

-(void)createTextureAtlasWithXMLURLString:(NSString*)URLString;

@end


@interface ImageProviderManager()

@property (nonatomic) NSMutableDictionary* textureAtlases;
@property (nonatomic) NSMutableDictionary* images;
@property (nonatomic) NSMutableDictionary* subimages;
@property (nonatomic) NSMutableSet* imageProviders;
@property (nonatomic) NSTimer* timer;


@end

@implementation ImageProviderManager

+(id)sharedImageProviderManager{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

+(CGSize)smallFormatSizeWithSize:(CGSize)size{
    CGSize result = size;
    
    CGFloat scale = 1.0;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        scale = resolution_small/resolution_ipad;
    }else{
        scale = resolution_small/resolution_iphone;
    }
    
    result.width = size.width*scale;
    result.height = size.height*scale;
    
    return result;
}

-(id)init{
    if ((self = [super init])) {
        
        
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateWithDisplayLink:)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        self.imageProviders = [NSMutableSet set];
        self.images = [NSMutableDictionary dictionary];
        self.textureAtlases = [NSMutableDictionary dictionary];
        self.subimages = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)updateWithDisplayLink:(id)link{
    NSMutableSet* providersToRemove = [NSMutableSet set];
    for (TileImageProvider* provider in self.imageProviders) {
        if ([provider consumerView] != nil) {
            [provider updateFrame];
        }else{
            [providersToRemove addObject:provider];
        }
    }
    if (0 < providersToRemove.count) {
        [self.imageProviders minusSet:providersToRemove];
    }

}

-(id)newImageProviderWithName:(NSString*)name{
    
    NSDictionary* images = [self subimagesWithName:name];
    
    TileImageProvider* result = [[TileImageProvider alloc] init];
    
    [result setName:name];
    [result setImages:images];
    
    [self.imageProviders addObject:result];
    
    return result;
}

-(NSDictionary*)subimagesWithName:(NSString*)name{
    NSDictionary* result = nil;
    
    if (name != nil) {
        result = [self.subimages objectForKey:name];;
        if ( result == nil ) {
            NSDictionary* textureAtlas = [self.textureAtlases objectForKey:name];
            UIImage* image = [self.images objectForKey:name];
            
#ifdef COLOR_WORD
            NSString* colorName = [COLOR_PREFIX stringByAppendingString:name];
            UIImage* colorImage = [self.images objectForKey:colorName];
#endif
            if (textureAtlas == nil) {
                NSString* URLString = [self pathWithBaseName:name type:@"xml"];
                
                TextureAtlasFactory* factory = [[TextureAtlasFactory alloc] init];
                [factory createTextureAtlasWithXMLURLString:URLString];
                textureAtlas = [NSDictionary dictionaryWithDictionary:[factory rects]];
                [[self textureAtlases] setObject:textureAtlas forKey:name];
            }
            
            if (image == nil) {
                NSString* URLString = [self pathWithBaseName:name type:@"png"];
                image = [UIImage imageWithContentsOfFile:URLString];
                [self.images setObject:image forKey:name];
            }
            
#ifdef COLOR_WORD
            if (colorImage == nil) {
                NSString* URLString = [self pathWithBaseName:colorName type:@"png"];
                colorImage = [UIImage imageWithContentsOfFile:URLString];
                [self.images setObject:colorImage forKey:colorName];
            }
#endif
            
            
            NSString* staticKey = [NSString stringWithFormat:@"%@_static0000",name];
            
            UIImage* staticimage = [self subImageWithImage:image key:staticKey atlas:textureAtlas];
            
            
#ifdef COLOR_WORD
            
            NSString* colorStaticKey = [COLOR_PREFIX stringByAppendingString:staticKey];

            UIImage* colorStaticImage = [self subImageWithImage:colorImage key:staticKey atlas:textureAtlas];
            
            result = [NSDictionary dictionaryWithObjectsAndKeys:staticimage,staticKey,colorStaticImage,colorStaticKey,nil];
            
#else
            result = [NSDictionary dictionaryWithObject:staticimage forKey:staticKey];
            
#endif
            
            [[self subimages] setObject:result forKey:name];
            
            //do this in the background
            
            dispatch_queue_t textureQueue = dispatch_queue_create("com.yourdomain.basefarm.TextureQueue", DISPATCH_QUEUE_SERIAL);

            dispatch_async(textureQueue, ^{
                NSMutableDictionary* images = [NSMutableDictionary dictionaryWithDictionary:result];
                
                for (NSString* key in [textureAtlas allKeys]) {
                    
                    UIImage* subimage = [self subImageWithImage:image key:key atlas:textureAtlas];
                    
                    [images setObject:subimage forKey:key];
                    
#ifdef COLOR_WORD
                    NSString* colorKey = [COLOR_PREFIX stringByAppendingString:key];
                    
                    UIImage* colorSubimage = [self subImageWithImage:colorImage key:key atlas:textureAtlas];
                    
                    [images setObject:colorSubimage forKey:colorKey];
                    
#endif
                }
                
                
                NSDictionary* allSubImages = [NSDictionary dictionaryWithDictionary:images];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setSubimages:allSubImages forName:name];
                });
                
            });
            
        }
    }
    
    return result;
}

-(void)setSubimages:(NSDictionary *)subimages forName:(NSString*)name{
    [[self subimages] setObject:subimages forKey:name];

    for (TileImageProvider* provider in self.imageProviders) {
        if ([[provider name] isEqualToString:name]) {
            [provider setImages:subimages];
        }
    }

    
}

-(UIImage*)subImageWithImage:(UIImage*)sheetImage key:(NSString*)key atlas:(NSDictionary*)textureAtlas{
    
    NSValue* value = [textureAtlas objectForKey:key];
    CGRect rect = [value CGRectValue];
    
    CGImageRef subImage = CGImageCreateWithImageInRect([sheetImage CGImage], rect);
    
    CGFloat scale = [[UIScreen mainScreen] scale] == 1.0 ? 1.0 : 2.0;
    
    CGFloat resizeScale = 1.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        resizeScale = scale * resolution_ipad / resolution_base;
    }else{
        resizeScale = scale * resolution_iphone / resolution_base;
    }
    
    CGImageRef scaledImage = CGCreateScaledImageFromImage(subImage,resizeScale);
    
    CGImageRelease(subImage);
    
    UIImage* result = [UIImage imageWithCGImage:scaledImage scale:scale orientation:UIImageOrientationUp];
    
    CGImageRelease(scaledImage);
    
    return result;
}

-(NSString*)pathWithBaseName:(NSString*)name type:(NSString*)type{
    NSString* resourceName = [NSString stringWithFormat:@"%@_animation", name];
    NSString* result = nil;
    if (resourceName != nil) {
        result = [[NSBundle bundleForClass:[self class]] pathForResource:resourceName ofType:type];
    }
    return result;
}

@end

@implementation TextureAtlasFactory

-(void)createTextureAtlasWithXMLURLString:(NSString*)URLString{
    self.rects = [NSMutableDictionary dictionary];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:URLString]];
    [parser setDelegate:self];
    BOOL success = [parser parse];
    NSLog(@"Parsing success:%d %@",success, URLString);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    if ([elementName isEqualToString:@"SubTexture"]) {
        //	<SubTexture name="sheep_panicking0000" x="0" y="0" width="281" height="243"/>
        NSString* key = [attributeDict objectForKey:@"name"];
        
        CGFloat x = [[attributeDict objectForKey:@"x"] floatValue];
        CGFloat y = [[attributeDict objectForKey:@"y"] floatValue];
        CGFloat width = [[attributeDict objectForKey:@"width"] floatValue];
        CGFloat height = [[attributeDict objectForKey:@"height"] floatValue];
        
        NSValue* object = [NSValue valueWithCGRect:CGRectMake(x, y, width, height)];
        
        [[self rects] setObject:object forKey:key];
    }
    
}

@end


CGImageRef CGCreateScaledImageFromImage(CGImageRef image, float scale)
{
    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    int width = CGImageGetWidth(image) * scale;
    int height = CGImageGetHeight(image) * scale;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * height);
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
    context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,
                                     colorspace,kCGImageAlphaPremultipliedFirst);
    
    if (context == NULL)
        // error creating context
        return nil;
    
    
    CGRect a=CGRectMake(0,0,width, height);
    
    CGContextClearRect(context, a);
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, a, image);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    
    return imgRef;
}