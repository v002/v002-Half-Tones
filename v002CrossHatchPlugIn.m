//
//  v002CrossHatch.m
//  v002 Half Tones
//
//  Created by vade on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "v002CrossHatchPlugIn.h"

#define	kQCPlugIn_Name				@"v002 Cross Hatch"
#define	kQCPlugIn_Description		@"v002 Cross Hatch"


#pragma mark -
#pragma mark Static Functions


static void _TextureReleaseCallback(CGLContextObj cgl_ctx, GLuint name, void* info)
{
	glDeleteTextures(1, &name);
}


@implementation v002CrossHatchPlugIn

@dynamic inputImage;
@dynamic inputColorFront;
@dynamic inputColorBack;
@dynamic inputInvert;
//@dynamic inputHatchCount;
@dynamic inputThickness;
@dynamic inputSeparation;
@dynamic inputGreyscale;
@dynamic outputImage;

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey,
            [kQCPlugIn_Description stringByAppendingString:kv002DescriptionAddOnText], QCPlugInAttributeDescriptionKey,
            kQCPlugIn_Category, QCPlugInAttributeCategoriesKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
    if([key isEqualToString:@"inputImage"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey, nil];
    }
    
    if([key isEqualToString:@"inputSeparation"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Separation",QCPortAttributeNameKey,
				[NSNumber numberWithInt:10], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithInt:100], QCPortAttributeMaximumValueKey,
				[NSNumber numberWithInt:0], QCPortAttributeMinimumValueKey,
				nil];

    if([key isEqualToString:@"inputThickness"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Thickness",QCPortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithInt:100], QCPortAttributeMaximumValueKey,
				[NSNumber numberWithInt:1], QCPortAttributeMinimumValueKey,
				nil];
    
    
    if([key isEqualToString:@"inputInvert"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Invert", QCPortAttributeNameKey, nil];
    }
    
    if([key isEqualToString:@"inputColorFront"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Front Color", QCPortAttributeNameKey, nil];
    }
    
    if([key isEqualToString:@"inputColorBack"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Back Color", QCPortAttributeNameKey, nil];
    }
        
    if([key isEqualToString:@"inputGreyscale"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Greyscale", QCPortAttributeNameKey, nil];
    }
    
    if([key isEqualToString:@"outputImage"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey, nil];
    }
    return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
	return [NSArray arrayWithObjects:@"inputImage", @"inputThickness", @"inputSeparation", @"inputColorFront", @"inputColorBack", @"inputInvert", @"inputGreyscale", nil];
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
        self.pluginShaderName = @"v002.crosshatch";
	}
	
	return self;
}

- (void) finalize
{
	[super finalize];
}

- (void) dealloc
{
	[super dealloc];
}

@end

@implementation v002CrossHatchPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
    //CGLContextObj cgl_ctx = [context CGLContextObj];    

    return [super startExecution:context];
}

- (void) stopExecution:(id<QCPlugInContext>)context
{    
    [super stopExecution:context];
}

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
        
        finalOutput = [self renderToFBO:cgl_ctx bounds:[image imageBounds] texture:[image textureName] thickness:self.inputThickness separation:self.inputSeparation hatchCount:0 frontColor:self.inputColorFront backColor:self.inputColorBack greyscale:self.inputGreyscale invert:self.inputInvert];
        
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

- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx bounds:(NSRect)bounds texture:(GLuint)texture thickness:(double)thickness separation:(double)separation hatchCount:(NSUInteger)hatchCount frontColor:(CGColorRef)front backColor:(CGColorRef)back greyscale:(BOOL)gscale invert:(BOOL)invert
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
    glUniform1fARB([pluginShader getUniformLocation:"greyscale"], gscale);
    glUniform1f([pluginShader getUniformLocation:"invert"], invert);            
    glUniform1f([pluginShader getUniformLocation:"separation"], separation);    // (separation < thickness) ? thickness + 1 : separation);            
    glUniform1f([pluginShader getUniformLocation:"thickness"], (thickness <= separation) ? (abs(thickness - separation) + thickness + 1) : thickness);            
    //glUniform1i([pluginShader getUniformLocation:"hatchcount"], hatchCount);            
    
    const CGFloat* frontc;
    const CGFloat* backc;
    
    frontc = CGColorGetComponents(front);
    backc = CGColorGetComponents(back);
    
    glUniform4f([pluginShader getUniformLocation:"front"], frontc[0], frontc[1], frontc[2], frontc[3]);            
    glUniform4f([pluginShader getUniformLocation:"back"], backc[0], backc[1], backc[2], backc[3]);            

    
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
