//
//  v002HalfTonePlugIn.m
//  v002 Half Tones
//
//  Created by vade on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "v002HalfTonePlugIn.h"

#define	kQCPlugIn_Name				@"v002 Half Tone"
#define	kQCPlugIn_Description		@"v002 Half Tone"


#pragma mark -
#pragma mark Static Functions


static void _TextureReleaseCallback(CGLContextObj cgl_ctx, GLuint name, void* info)
{
	glDeleteTextures(1, &name);
}


@implementation v002HalfTonePlugIn

@dynamic inputImage;
@dynamic inputPaperColor;
//@dynamic inputDotSize;
@dynamic inputCSize;
@dynamic inputCAngle; 
@dynamic inputCColor;
@dynamic inputMSize;
@dynamic inputMAngle; 
@dynamic inputMColor;
@dynamic inputYSize;
@dynamic inputYAngle;
@dynamic inputYColor;
@dynamic inputKSize;
@dynamic inputKAngle; 
@dynamic inputKColor;
@dynamic inputSharpness; 
@dynamic outputImage;

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey,
            [kQCPlugIn_Description stringByAppendingString:kv002DescriptionAddOnText], QCPlugInAttributeDescriptionKey,
            kQCPlugIn_Category, QCPlugInAttributeCategoriesKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	CGColorRef pColor = CGColorCreateGenericRGB(0, 0, 0, 1);
	CGColorRef cColor = CGColorCreateGenericRGB(0, 1, 1, 1);
	CGColorRef mColor = CGColorCreateGenericRGB(1, 0, 1, 1);
	CGColorRef yColor = CGColorCreateGenericRGB(1, 1, 0, 1);
	CGColorRef kColor = CGColorCreateGenericRGB(0, 0, 0, 1);
	
	//[cColor autorelease];
	//[mColor autorelease];
	//[yColor autorelease];
	//[kColor autorelease];
	
    if([key isEqualToString:@"inputImage"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey, nil];
    }

	if([key isEqualToString:@"inputPaperColor"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Background Color", QCPortAttributeNameKey, 
				pColor, QCPortAttributeDefaultValueKey, nil];
    }
	
    if([key isEqualToString:@"inputCSize"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Cyan Pitch", QCPortAttributeNameKey, 
				[NSNumber numberWithFloat:50.0], QCPortAttributeDefaultValueKey, nil];
    }

	if([key isEqualToString:@"inputMSize"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Magenta Pitch", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:50.0], QCPortAttributeDefaultValueKey, nil];
    }
   
	if([key isEqualToString:@"inputYSize"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Yellow Pitch", QCPortAttributeNameKey, 
				[NSNumber numberWithFloat:50.0], QCPortAttributeDefaultValueKey, nil];
    }
    
	if([key isEqualToString:@"inputKSize"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Key Pitch", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:50.0], QCPortAttributeDefaultValueKey, nil];
    }
	
    if([key isEqualToString:@"inputCAngle"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Cyan Angle", QCPortAttributeNameKey, 
				[NSNumber numberWithFloat:100.0], QCPortAttributeDefaultValueKey, nil];
    }

    if([key isEqualToString:@"inputMAngle"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Magenta Angle", QCPortAttributeNameKey, 
				[NSNumber numberWithFloat:15.0], QCPortAttributeDefaultValueKey, nil];
    }

    if([key isEqualToString:@"inputYAngle"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Yellow Angle", QCPortAttributeNameKey, 
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey, nil];
    }

    if([key isEqualToString:@"inputKAngle"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Key Angle", QCPortAttributeNameKey, 
				[NSNumber numberWithFloat:45.0], QCPortAttributeDefaultValueKey, nil];
    }

	if([key isEqualToString:@"inputCColor"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Cyan Color", QCPortAttributeNameKey,
				cColor, QCPortAttributeDefaultValueKey, nil];

	if([key isEqualToString:@"inputMColor"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Magenta Color", QCPortAttributeNameKey,
				mColor, QCPortAttributeDefaultValueKey, nil];
	
	if([key isEqualToString:@"inputYColor"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Yellow Color", QCPortAttributeNameKey,
				yColor, QCPortAttributeDefaultValueKey, nil];
	
	if([key isEqualToString:@"inputKColor"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Key Color", QCPortAttributeNameKey,
				kColor, QCPortAttributeDefaultValueKey, nil];
	
	
    if([key isEqualToString:@"inputSharpness"])
    {
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Smoothing",QCPortAttributeNameKey,
				[NSNumber numberWithDouble:0.1], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithDouble:1], QCPortAttributeMaximumValueKey,
				[NSNumber numberWithDouble:0], QCPortAttributeMinimumValueKey,
				nil];
    }
    
    
    if([key isEqualToString:@"outputImage"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey, nil];
    }
    return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
	return [NSArray arrayWithObjects:@"inputImage",
			@"inputPaperColor",
            @"inputSharpness",
            @"inputCSize",
			@"inputCColor",
            @"inputCAngle",
            @"inputMSize",
			@"inputMColor",
            @"inputMAngle",
			@"inputYSize",
            @"inputYColor",
			@"inputYAngle",
			@"inputKSize",
			@"inputKColor",
            @"inputKAngle",nil];
}

+ (QCPlugInExecutionMode) executionMode
{
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode
{
	return kQCPlugInTimeModeNone;
}

- (id) init
{
	if(self = [super init])
    {
        self.pluginShaderName = @"v002.halftone";
	}
	
	return self;
}

@end

@implementation v002HalfTonePlugIn (Execution)

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
    CGLContextObj cgl_ctx = [context CGLContextObj];
    
	id<QCPlugInInputImageSource>   image = self.inputImage;
	
	CGColorSpaceRef cspace = ([image shouldColorMatch]) ? [context colorSpace] : [image imageColorSpace];
	if(image && [image lockTextureRepresentationWithColorSpace:cspace forBounds:[image imageBounds]])
	{	
        [image bindTextureRepresentationToCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0 normalizeCoordinates:YES];
        
        // save/restore state once
		glPushAttrib(GL_ALL_ATTRIB_BITS);
		glPushClientAttrib(GL_CLIENT_VERTEX_ARRAY_BIT);
        
        // set up clear color and blending once
        glClearColor(0.0, 0.0, 0.0, 0.0);
        
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
		// this must be called before any other FBO stuff can happen for 10.6
		[pluginFBO pushFBO:cgl_ctx];
		
		GLuint finalOutput;
        
        finalOutput = [self renderToFBO:cgl_ctx
								 bounds:[image imageBounds]
								texture:[image textureName]
								   csize:self.inputCSize
								  msize:self.inputMSize
								  ysize:self.inputYSize
								  ksize:self.inputKSize
								 pcolor:self.inputPaperColor
							  sharpness:self.inputSharpness
								 cangle:self.inputCAngle
								 mangle:self.inputMAngle 
								 yangle:self.inputYAngle
								 kangle:self.inputKAngle
								 ccolor:self.inputCColor
								 mcolor:self.inputMColor
								 ycolor:self.inputYColor
								 kcolor:self.inputKColor];
        
		[pluginFBO popFBO:cgl_ctx];
        
		glPopClientAttrib();
		glPopAttrib();
		
		id provider = nil;	
        
		if(finalOutput != 0)
		{
			
#if __BIG_ENDIAN__
#define v002QCPluginPixelFormat QCPlugInPixelFormatARGB8
#else
#define v002QCPluginPixelFormat QCPlugInPixelFormatBGRA8			
#endif
			// we have to use a 4 channel output format, I8 does not support alpha at fucking all, so if we want text with alpha, we need to use this and waste space. Ugh.
			provider = [context outputImageProviderFromTextureWithPixelFormat:v002QCPluginPixelFormat pixelsWide:[image imageBounds].size.width pixelsHigh:[image imageBounds].size.height name:finalOutput flipped:NO releaseCallback:_TextureReleaseCallback releaseContext:NULL colorSpace:[context colorSpace] shouldColorMatch:[image shouldColorMatch]];
            
			self.outputImage = provider;
		}
		
		[image unbindTextureRepresentationFromCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0];
		[image unlockTextureRepresentation];
		
	}	
	else
		self.outputImage = nil;
    
	return YES;
}

- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx bounds:(NSRect)bounds texture:(GLuint)texture csize:(double)csize msize:(double)msize ysize:(double)ysize ksize:(double)ksize pcolor:(CGColorRef)pcolor sharpness:(double)sharpness cangle:(double)cangle mangle:(double)mangle yangle:(double)yangle kangle:(double)kangle ccolor:(CGColorRef)ccolor mcolor:(CGColorRef)mcolor ycolor:(CGColorRef)ycolor kcolor:(CGColorRef)kcolor
{
	GLsizei width = bounds.size.width,	height = bounds.size.height;
    
    // new texture
    GLuint fboTex = 0;
    glGenTextures(1, &fboTex);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, fboTex);
    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    [pluginFBO attachFBO:cgl_ctx withTexture:fboTex width:width height:height];
    
    glClear(GL_COLOR_BUFFER_BIT);
    
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, texture);
    
    // bind our shader program
    glUseProgramObjectARB([pluginShader programObject]);
    // set program vars
    glUniform1iARB([pluginShader getUniformLocation:"tex0"], 0); 
    glUniform2fARB([pluginShader getUniformLocation:"imageSize"], width, height); 
    glUniform1fARB([pluginShader getUniformLocation:"sharpness"], sharpness); 
    glUniform4fARB([pluginShader getUniformLocation:"cmykangles"], cangle, mangle, yangle, kangle); 
    glUniform4fARB([pluginShader getUniformLocation:"dotSize"], csize, msize, ysize, ksize); 
       
	const CGFloat* cc;
	const CGFloat* mc;
	const CGFloat* yc;
	const CGFloat* kc;

	const CGFloat* pc;

	pc = CGColorGetComponents(pcolor);
	cc = CGColorGetComponents(ccolor);
	mc = CGColorGetComponents(mcolor);
	yc = CGColorGetComponents(ycolor);
	kc = CGColorGetComponents(kcolor);
	
	GLfloat colors[16];
	//c
	colors[0]  = (cc[0] * cc[3]) - cc[3]; 
	colors[1]  = (cc[1] * cc[3]) - cc[3]; 
	colors[2]  = (cc[2] * cc[3]) - cc[3]; 
	colors[3]  = (cc[3]) - 1.0; 
	//m
	colors[4]  = (mc[0] * mc[3]) - mc[3]; 
	colors[5]  = (mc[1] * mc[3]) - mc[3]; 
	colors[6]  = (mc[2] * mc[3]) - mc[3]; 
	colors[7]  = (mc[3]) - 1.0; 
	//y
	colors[8]  = (yc[0] * yc[3]) - yc[3]; 
	colors[9]  = (yc[1] * yc[3]) - yc[3]; 
	colors[10] = (yc[2] * yc[3]) - yc[3]; 
	colors[11] = (yc[3]) - 1.0; 
	//k
	colors[12] = 1.0 - (kc[0] ); 
	colors[13] = 1.0 - (kc[1] ); 
	colors[14] = 1.0 - (kc[2] ); 
	colors[15] = 1.0 - (kc[3] ); 

//	glUniformMatrix4fv([pluginShader getUniformLocation:"CMYKmat"], 1, false, colors);
		
	glUniform4fARB([pluginShader getUniformLocation:"pColor"], pc[0], pc[1], pc[2], pc[3]);
	glUniform4fARB([pluginShader getUniformLocation:"cColor"], cc[0], cc[1], cc[2], cc[3]);
	glUniform4fARB([pluginShader getUniformLocation:"mColor"], mc[0], mc[1], mc[2], mc[3]);
	glUniform4fARB([pluginShader getUniformLocation:"yColor"], yc[0], yc[1], yc[2], yc[3]);
	glUniform4fARB([pluginShader getUniformLocation:"kColor"], kc[0], kc[1], kc[2], kc[3]);

    
	// move to VA for rendering
	GLfloat tex_coords[] = 
	{
		1.0,1.0,
		0.0,1.0,
		0.0,0.0,
		1.0,0.0
	};
	
	GLfloat verts[] = 
	{
		width,height,
		0.0,height,
		0.0,0.0,
		width,0.0
	};
	
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
	glEnableClientState(GL_VERTEX_ARRAY);		
	glVertexPointer(2, GL_FLOAT, 0, verts );
	glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );	// TODO: GL_QUADS or GL_TRIANGLE_FAN?
    
	// disable shader program
	glUseProgramObjectARB(NULL);
	
    [pluginFBO detachFBO:cgl_ctx]; // pops out and resets cached FBO state from above.
    
	return fboTex;
}

@end
