//
//  v002_Half_TonesPlugIn.m
//  v002 Half Tones
//
//  Created by vade on 4/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "v002DitherPlugIn.h"

#define	kQCPlugIn_Name				@"v002 Dither"
#define	kQCPlugIn_Description		@"v002 Dither"


#pragma mark -
#pragma mark Static Functions


static void _TextureReleaseCallback(CGLContextObj cgl_ctx, GLuint name, void* info)
{
	glDeleteTextures(1, &name);
}

#pragma mark -
#pragma mark Dither patterns
const GLint d8[64] = 
{   0, 32,  8, 40,  2, 34, 10, 42,
    48, 16, 56, 24, 50, 18, 58, 26,   
    12, 44,  4, 36, 14, 46,  6, 38,   
    60, 28, 52, 20, 62, 30, 54, 22,   
    3, 35, 11, 43,  1, 33,  9, 41,  
    51, 19, 59, 27, 49, 17, 57, 25,   
    15, 47,  7, 39, 13, 45,  5, 37,   
    63, 31, 55, 23, 61, 29, 53, 21
};   

const GLint d4[16] = 
{   
    0, 32,  8, 40, 
    48, 16, 56, 24,  
    12, 44,  4, 36,  
    60, 28, 52, 20,
};   

const GLint d2[4] = 
{   
    0, 32,   
    48, 16
};   


@implementation v002DitherPlugIn

@dynamic inputImage;
@dynamic inputType;
@dynamic inputScale;
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

    if([key isEqualToString:@"inputScale"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Scale",QCPortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithInt:1], QCPortAttributeMaximumValueKey,
				[NSNumber numberWithInt:0], QCPortAttributeMinimumValueKey,
				nil];
    
	if([key isEqualToString:@"inputType"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Type",QCPortAttributeNameKey,
				[NSArray arrayWithObjects:@"2x2", @"4x4", @"8x8", nil], QCPortAttributeMenuItemsKey,
				[NSNumber numberWithInt:0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithInt:2], QCPortAttributeMaximumValueKey,
				nil];
    
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
	return [NSArray arrayWithObjects:@"inputImage", @"inputScale", @"inputType", @"inputGreyscale", nil];
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
        self.pluginShaderName = @"v002.dither8";
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

@implementation v002DitherPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
    CGLContextObj cgl_ctx = [context CGLContextObj];

    NSBundle *pluginBundle =[NSBundle bundleForClass:[self class]];	
    
    dither4 = [[v002Shader alloc] initWithShadersInBundle:pluginBundle withName:@"v002.dither4" forContext:cgl_ctx];
    if(dither4 == nil)
    {
        [context logMessage:@"Cannot compile GLSL shader."];
        return NO;
    }

    dither2 = [[v002Shader alloc] initWithShadersInBundle:pluginBundle withName:@"v002.dither2" forContext:cgl_ctx];
    if(dither2 == nil)
    {
        [context logMessage:@"Cannot compile GLSL shader."];
        return NO;
    }
    
    
    return [super startExecution:context];
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
	[dither4 release];
	dither4 = nil;

    [dither2 release];
	dither2 = nil;

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

        finalOutput = [self renderToFBO:cgl_ctx bounds:[image imageBounds] texture:[image textureName] type:self.inputType scale:self.inputScale greyscale:self.inputGreyscale];
        
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

- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx bounds:(NSRect)bounds texture:(GLuint)texture type:(NSUInteger)type scale:(double)scale greyscale:(BOOL)gscale
{
	GLsizei width = bounds.size.width,	height = bounds.size.height;
    
    // new texture
    GLuint fboTex = 0;
    glGenTextures(1, &fboTex);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, fboTex);
    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameterf(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    [pluginFBO attachFBO:cgl_ctx withTexture:fboTex width:width height:height];
    
    glClear(GL_COLOR_BUFFER_BIT);
    
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, texture);
	
    switch (type) {
        case 0:
            // bind our shader program
            glUseProgramObjectARB([dither2 programObject]);
            // set program vars
            glUniform1iARB([dither2 getUniformLocation:"tex0"], 0); 
            glUniform1fARB([dither2 getUniformLocation:"greyscale"], gscale);
            glUniform1iv([dither2 getUniformLocation:"dither"], 4, d2);            
            glUniform1f([dither2 getUniformLocation:"scale"], scale);            
            break;
        case 1:
            // bind our shader program
            glUseProgramObjectARB([dither4 programObject]);
            // set program vars
            glUniform1iARB([dither4 getUniformLocation:"tex0"], 0); 
            glUniform1fARB([dither4 getUniformLocation:"greyscale"], gscale);
            glUniform1iv([dither4 getUniformLocation:"dither"], 16, d4); 
            glUniform1f([dither4 getUniformLocation:"scale"], scale);            
            break;
        case 2:
            // bind our shader program
            glUseProgramObjectARB([pluginShader programObject]);
            // set program vars
            glUniform1iARB([pluginShader getUniformLocation:"tex0"], 0); 
            glUniform1fARB([pluginShader getUniformLocation:"greyscale"], gscale);
            glUniform1iv([pluginShader getUniformLocation:"dither"], 64, d8);
            glUniform1f([pluginShader getUniformLocation:"scale"], scale);            
            break;
        default:
            break;
    }
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
