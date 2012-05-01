//
//  v002CrossHatch.h
//  v002 Half Tones
//
//  Created by vade on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "v002MasterPluginInterface.h"

@interface v002CrossHatchPlugIn : v002MasterPluginInterface
{
}

@property (readwrite, assign) id<QCPlugInInputImageSource> inputImage;
@property (readwrite, assign) CGColorRef inputColorFront;
@property (readwrite, assign) CGColorRef inputColorBack;
@property (readwrite, assign) NSUInteger inputThickness;
@property (readwrite, assign) NSUInteger inputSeparation;
//@property (readwrite, assign) NSUInteger inputHatchCount;
@property (readwrite, assign) BOOL inputGreyscale;
@property (readwrite, assign) BOOL inputInvert;
@property (readwrite, assign) id<QCPlugInOutputImageProvider> outputImage;

@end

@interface v002CrossHatchPlugIn (Execution)
- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx bounds:(NSRect)bounds texture:(GLuint)texture thickness:(double)thickness separation:(double)separation hatchCount:(NSUInteger)hatchCount frontColor:(CGColorRef)front backColor:(CGColorRef)back greyscale:(BOOL)gscale invert:(BOOL)invert;
@end

