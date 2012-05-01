//
//  v002_Half_TonesPlugIn.h
//  v002 Half Tones
//
//  Created by vade on 4/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "v002MasterPluginInterface.h"

@interface v002DitherPlugIn : v002MasterPluginInterface
{
    v002Shader* dither4;
    v002Shader* dither2;
}

@property (readwrite, assign) id<QCPlugInInputImageSource> inputImage;
@property (readwrite, assign) NSUInteger inputType;
@property (readwrite, assign) double inputScale;
@property (readwrite, assign) BOOL inputGreyscale;
@property (readwrite, assign) id<QCPlugInOutputImageProvider> outputImage;

@end

@interface v002DitherPlugIn (Execution)
- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx bounds:(NSRect)bounds texture:(GLuint)texture type:(NSUInteger)type scale:(double)scale greyscale:(BOOL)gscale;
@end

