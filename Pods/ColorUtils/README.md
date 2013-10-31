Purpose
--------------

ColorUtils is a category on UIColor that extends it with some commonly needed features that were left out of the standard API.

UIColor is a thin wrapper around CGColor, which supports a wide variety of different formats, making it very flexible. This flexibility seems to come at a bit of a cost to usability for common tasks however. For example, it's non-trivial to access the red, green and blue components of an RGB color, and it is difficult to compare colors because `[UIColor blackColor]` is treated as different from `[UIColor colorWithRed:0 green:0 blue:0 alpha:1]` even though they are identical on screen. ColorUtils makes this tasks easy.

Another common problem is that RGBA UIColors are specified using four floating point values in the range 0 to 1, but virtually all graphics software treats colors as having integer components in the range 0 - 255, often represented as a hexadecimal string. ColorUtils lets you specify colors as hexadecimals so you can copy and paste values directly from PhotoShop.


Supported iOS & SDK Versions
-----------------------------

* Supported build target - iOS 6.0 / Mac OS 10.8 (Xcode 4.5.1, Apple LLVM compiler 4.1)
* Earliest supported deployment target - iOS 5.0 / Mac OS 10.7
* Earliest compatible deployment target - iOS 4.3

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this iOS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

ColorUtils automatically works with both ARC and non-ARC projects through conditional compilation. There is no need to exclude ColorUtils files from the ARC validation process, or to convert ColorUtils using the ARC conversion tool.


Installation
--------------

To use ColorUtils in an app, just drag the UIColor.h and .m files into your project.


Properties
------------

@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;
@property (nonatomic, readonly) CGFloat alpha;

These properties give you direct (read only) access to the red, green, blue and alpha color components. Now of course, not all UIColors have these attributes, so for monochromatic colors the red, green and blue values will all be the same value, and for non-RGB colors such as CMYK, patterned or indexed colors, these values will log a warning when accessed and return zero. To avoid generating these warnings, call the `isMonochromeOrRGB` method before attempting to access the components.


Methods
------------

+ (UIColor *)colorWithString:(NSString *)string;
- (UIColor *)initWithString:(NSString *)string;

These methods create a color object by parsing the supplied string. The string is first checked to see if it matches any standard color constants names (the check is case insensitive) and if not, an attempt is made to parse the string as a hexadecimal value.

Hexadecimal strings can be prefixed with #, 0x or nothing and can have 3, 6 or 8 digits. 6 digits is the standard rrggbb format, 8 is the same but with an alpha component, 3 is a shorthand used commonly in CSS, where each hex digit is repeated, so #29f becomes #2299ff, for example.

+ (UIColor *)colorWithRGBValue:(int32_t)rgb;
- (UIColor *)initWithRGBValue:(int32_t)rgb;

These methods create a color using a single RGB value encoded as an integer. This may seem rather obscure until you realise that such a value can be created easily using a hexadecimal constant, e.g 0xff0000 for red. This is more efficient than using a hex string as it requires less logic to parse it.

+ (UIColor *)colorWithRGBAValue:(uint32_t)rgba;
- (UIColor *)initWithRGBAValue:(uint32_t)rgba;

This method is the same as `colorWithRGBValue` except that the input value includes an alpha component, e.g 0xff00007f for 50% transparent red. Do not mix up the `colorWithRGBValue` and `colorWithRGBAValue` methods as RGB integer values and RGBA integer values are not interchangeable.

- (int32_t)RGBValue;

This returns the color's RGB components as single integer value. This is useful for saving color values to disk, and can be used as the input to the `colorWithRGBValue` method to re-create the UIColor later. This value can be hard to interpret, but you can convert it to a more readable hex value using `NSLog(@"color: %.6x", intColorValue)`. Note that this method only works for monochrome or RGB(A) colors. Any other format (e.g. pattern) will log a warning and return 0 (black).

- (uint32_t)RGBAValue;

This method is the same as `RGBValue` except that the returned value includes an alpha component. You can convert this to a hex string using `NSLog(@"color: %.8x", intColorValue)`. As above, this only works with monochrome or RGB(A) colors.

- (NSString *)stringValue;

This method converts the color to a string by first matching it against known color constants, and returning their name if there's a match, and then by converting it to a 6 or 8 digit hex string, depending on whether the color has an alpha component. This value is useful if you want to log or display the color, and can also be used to save and re-create the color by passing the string to the `colorWithString` method.


- (BOOL)isMonochromeOrRGB;

This method returns `YES` if the color is a monochrome or RGB-formatted color. Many of the ColorUtils methods only work correctly on these color types, so this can be useful to check.

- (BOOL)isEquivalent:(id)object;

The standard UIColor isEqual method returns NO if two colors have the same appearance but a different number of components. This means that `[UIColor blackColor]` is treated as different from `[UIColor colorWithRed:0 green:0 blue:0 alpha:1]` even though they are identical on screen. The `isEquivalent` method compares the RGBAValue values of the colors instead, and so is a more convenient way to compare colors for equality. If the colors are not monochrom or RGB, this returns the result of `isEqual:` instead.

- (BOOL)isEquivalentToColor:(UIColor *)color;

Same as `isEquivalent`, but slightly more efficient if you already know that the object being compared is a UIColor.


Color Constant Names
---------------------

The list of standard color constants can be found in the UIColor documentation, but is repeated here for convenience. Using color constants where possible reduces memory and improves performance by avoiding creating multiple identical UIColor objects in memory.

	black -  Equivalent to 0.0 white
	darkgray -  Equivalent to 0.333 white
	lightgray -  Equivalent to 0.667 white
	white -  Equivalent to 1.0 white
	gray -  Equivalent to 0.5 white
	red -  Equivalent to 1.0, 0.0, 0.0 RGB
	green -  Equivalent to 0.0, 1.0, 0.0 RGB
	blue -  Equivalent to 0.0, 0.0, 1.0 RGB
	cyan -  Equivalent to 0.0, 1.0, 1.0 RGB
	yellow -  Equivalent to 1.0, 1.0, 0.0 RGB
	magenta -  Equivalent to 1.0, 0.0, 1.0 RGB
	orange -  Equivalent to 1.0, 0.5, 0.0 RGB
	purple -  Equivalent to 0.5, 0.0, 0.5 RGB
	brown -  Equivalent to 0.6, 0.4, 0.2 RGB
	clear -  Equivalent to 0.0 white, 0.0 alpha


Example
--------

Most of the methods and properties are fairly self-explanatory, but there is an example included that shows how to set colors by name or with hexadecimal strings.