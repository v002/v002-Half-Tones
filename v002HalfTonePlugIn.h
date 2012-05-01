//
//  v002HalfTonePlugIn.h
//  v002 Half Tones
//
//  Created by vade on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Quartz/Quartz.h>
#import "v002MasterPluginInterface.h"

@interface v002HalfTonePlugIn : v002MasterPluginInterface
{
}

@property (readwrite, assign) id<QCPlugInInputImageSource> inputImage;
@property (readwrite, assign) CGColorRef inputPaperColor;
//@property (readwrite, assign) double inputDotSize;
@property (readwrite, assign) double inputCSize; 
@property (readwrite, assign) double inputCAngle;
@property (readwrite, assign) CGColorRef inputCColor;
@property (readwrite, assign) double inputMSize; 
@property (readwrite, assign) double inputMAngle;
@property (readwrite, assign) CGColorRef inputMColor;
@property (readwrite, assign) double inputYSize; 
@property (readwrite, assign) double inputYAngle;
@property (readwrite, assign) CGColorRef inputYColor;
@property (readwrite, assign) double inputKSize; 
@property (readwrite, assign) double inputKAngle;
@property (readwrite, assign) CGColorRef inputKColor;
@property (readwrite, assign) double inputSharpness;

@property (readwrite, assign) id<QCPlugInOutputImageProvider> outputImage;

@end

@interface v002HalfTonePlugIn (Execution)
- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx bounds:(NSRect)bounds texture:(GLuint)texture csize:(double)csize msize:(double)msize ysize:(double)ysize ksize:(double)ksize pcolor:(CGColorRef)pcolor sharpness:(double)sharpness cangle:(double)cangle mangle:(double)mangle yangle:(double)yangle kangle:(double)kangle ccolor:(CGColorRef)ccolor mcolor:(CGColorRef)mcolor ycolor:(CGColorRef)ycolor kcolor:(CGColorRef)kcolor;
@end

