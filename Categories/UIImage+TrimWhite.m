//
//  UIImage+TrimWhite.m
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

//
//  UIImage+TrimWhite.m
//
//  Created by Rick Pastoor on 26-09-12.
//  Based on gist:3549921 ( https://gist.github.com/3549921/8abea8ac9e2450f6a38540de9724d3bf850a62df )
//
//  Copyright (c) 2012 Wrep - http://www.wrep.nl/
//

#import "UIImage+TrimWhite.h"

@implementation UIImage (Trim)

/*
 * Calculates the insets of transparency around all sides of the image
 *
 * @param fullyOpaque
 *        Whether the algorithm should consider pixels with an alpha value of something other than 255 as being transparent. Otherwise a non-zero value would be considered opaque.
 */
- (UIEdgeInsets)whiteInsetsRequiringFullOpacity:(BOOL)fullyOpaque
{
    // Draw our image on that context
    NSInteger width  = (NSInteger)CGImageGetWidth([self CGImage]);
    NSInteger height = (NSInteger)CGImageGetHeight([self CGImage]);
    NSInteger bytesPerRow = width * (NSInteger)sizeof(uint32_t);
    
    // Allocate array to hold alpha channel
    uint32_t* bitmapData = calloc((size_t)(width * height), sizeof(uint32_t));
    
    // Create alpha-only bitmap context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(bitmapData, (NSUInteger)width, (NSUInteger)height, 8, (NSUInteger)bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);    // kCGImageAlphaLast);    // kCGImageAlphaOnly);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef cgImage = self.CGImage;
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(contextRef, rect, cgImage);
    
    // Sum all non-transparent pixels in every row and every column
    uint16_t* rowSum = calloc((size_t)height, sizeof(uint16_t));
    uint16_t* colSum = calloc((size_t)width,  sizeof(uint16_t));
    
    // Enumerate through all pixels
    for (NSInteger row = 0; row < height; row++)
    {
        for (NSInteger col = 0; col < width; col++)
        {
            NSUInteger  pixelOffset = (NSUInteger)(row * width + col);

            if (fullyOpaque)
            {
                // Found non-white pixel
                if (bitmapData[pixelOffset] != UINT32_MAX)
                {
                    rowSum[row]++;
                    colSum[col]++;
                }
            }
            else
            {
                // Found non-white pixel
                if ((bitmapData[pixelOffset] != UINT32_MAX))
                {
                    rowSum[row]++;
                    colSum[col]++;
                }
            }
        }
    }
    
    // Initialize crop insets and enumerate cols/rows arrays until we find non-empty columns or row
    UIEdgeInsets crop = UIEdgeInsetsZero;
    
    // Top
    for (NSInteger i = 0; i < height; i++)
    {
        if (rowSum[i] > 0)
        {
            crop.top = i;
            break;
        }
    }
    
    // Bottom
    for (NSInteger i = height - 1; i >= 0; i--)
    {
        if (rowSum[i] > 0)
        {
            crop.bottom = MAX(0, height - i - 1);
            break;
        }
    }
    
    // Left
    for (NSInteger i = 0; i < width; i++)
    {
        if (colSum[i] > 0)
        {
            crop.left = i;
            break;
        }
    }
    
    // Right
    for (NSInteger i = width - 1; i >= 0; i--)
    {
        if (colSum[i] > 0)
        {
            crop.right = MAX(0, width - i - 1);
            break;
        }
    }
    
    free(bitmapData);
    free(colSum);
    free(rowSum);
    
    CGContextRelease(contextRef);
    
    return crop;
}

/*
 * Original method signature; behavior should be identical.
 */
- (UIImage*)imageByTrimmingWhitePixels
{
    return [self imageByTrimmingWhitePixelsRequiringFullOpacity:NO];
}

/*
 * Alternative method signature allowing for the use of cropping based on semi-transparency.
 */
- (UIImage*)imageByTrimmingWhitePixelsRequiringFullOpacity:(BOOL)fullyOpaque
{
    if (self.size.height < 2 || self.size.width < 2)
    {
        return self;
    }
    
    CGRect rect = CGRectMake(0, 0, self.size.width * self.scale, self.size.height * self.scale);
    UIEdgeInsets crop = [self whiteInsetsRequiringFullOpacity:fullyOpaque];
    
    UIImage* img = self;
    
    if ((crop.top == 0.0f) && (crop.bottom == 0.0f) && (crop.left == 0.0f) && (crop.right == 0.0f))
    {
        // No cropping needed
    }
    else
    {
        // Calculate new crop bounds
        rect.origin.x += crop.left;
        rect.origin.y += crop.top;
        rect.size.width -= crop.left + crop.right;
        rect.size.height -= crop.top + crop.bottom;
        
        // Crop it
        CGImageRef newImage = CGImageCreateWithImageInRect([self CGImage], rect);
        
        // Convert back to UIImage
        img = [UIImage imageWithCGImage:newImage scale:self.scale orientation:self.imageOrientation];
        
        CGImageRelease(newImage);
    }
    
    return img;
}

@end
