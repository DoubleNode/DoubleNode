//
//  DNTheme.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNThemeManager.h"

#import "ADVDefaultTheme.h"

#import "DNLabel.h"

#import "UIFont+Custom.h"

#pragma mark - Attribute Macros

// ie: Font
// functionName  = [NSString stringWithFormat:@"%@", attribute];
#define DNThemeMethod_BackgroundColor()         - (UIColor*) BackgroundColor
#define DNThemeMethod_BorderColor()             - (UIColor*) BorderColor
#define DNThemeMethod_BorderStyle()             - (NSNumber*) BorderStyle
#define DNThemeMethod_BorderWidth()             - (NSNumber*) BorderWidth
#define DNThemeMethod_Color()                   - (UIColor*) Color
#define DNThemeMethod_Font()                    - (UIFont*) Font
#define DNThemeMethod_HighlightedColor()        - (UIColor*) HighlightedColor
#define DNThemeMethod_HorizontalPadding()       - (NSNumber*) HorizontalPadding
#define DNThemeMethod_Kerning()                 - (NSNumber*) Kerning
#define DNThemeMethod_LineHeightMultiple()      - (NSNumber*) LineHeightMultiple
#define DNThemeMethod_LineSpacing()             - (NSNumber*) LineSpacing
#define DNThemeMethod_Name()                    - (NSString*) Name
#define DNThemeMethod_OnTintColor()             - (UIColor*) OnTintColor
#define DNThemeMethod_PlaceholderColor()        - (UIColor*) PlaceholderColor
#define DNThemeMethod_SelectedBackgroundColor() - (UIColor*) SelectedBackgroundColor
#define DNThemeMethod_SelectedColor()           - (UIColor*) SelectedColor
#define DNThemeMethod_SelectedFont()            - (UIFont*) SelectedFont
#define DNThemeMethod_SelectedKerning()         - (NSNumber*) SelectedKerning
#define DNThemeMethod_ShowSuggestions()         - (NSNumber*) ShowSuggestions
#define DNThemeMethod_TextAlignment()           - (NSNumber*) TextAlignment
#define DNThemeMethod_ThumbTintColor()          - (UIColor*) ThumbTintColor
#define DNThemeMethod_TintColor()               - (UIColor*) TintColor
#define DNThemeMethod_UnhighlightedColor()      - (UIColor*) UnhighlightedColor
#define DNThemeMethod_VerticalAlignment()       - (NSNumber*) VerticalAlignment
#define DNThemeMethod_VerticalPadding()         - (NSNumber*) VerticalPadding

#pragma mark - Type/Attribute Macros

// ie: Button Font
// functionName  = [NSString stringWithFormat:@"%@%@", type, attribute];
#define DNThemeMethod_Type_BackgroundColor(type)            - (UIColor*) type##BackgroundColor
#define DNThemeMethod_Type_BorderColor(type)                - (UIColor*) type##BorderColor
#define DNThemeMethod_Type_BorderStyle(type)                - (NSNumber*) type##BorderStyle
#define DNThemeMethod_Type_BorderWidth(type)                - (NSNumber*) type##BorderWidth
#define DNThemeMethod_Type_Color(type)                      - (UIColor*) type##Color
#define DNThemeMethod_Type_Font(type)                       - (UIFont*) type##Font
#define DNThemeMethod_Type_HighlightedColor(type)           - (UIColor*) type##HighlightedColor
#define DNThemeMethod_Type_HorizontalPadding(type)          - (NSNumber*) type##HorizontalPadding
#define DNThemeMethod_Type_Kerning(type)                    - (NSNumber*) type##Kerning
#define DNThemeMethod_Type_LineHeightMultiple(type)         - (NSNumber*) type##LineHeightMultiple
#define DNThemeMethod_Type_LineSpacing(type)                - (NSNumber*) type##LineSpacing
#define DNThemeMethod_Type_Name(type)                       - (NSString*) type##Name
#define DNThemeMethod_Type_OnTintColor(type)                - (UIColor*) type##OnTintColor
#define DNThemeMethod_Type_PlaceholderColor(type)           - (UIColor*) type##PlaceholderColor
#define DNThemeMethod_Type_SelectedBackgroundColor(type)    - (UIColor*) type##SelectedBackgroundColor
#define DNThemeMethod_Type_SelectedColor(type)              - (UIColor*) type##SelectedColor
#define DNThemeMethod_Type_SelectedFont(type)               - (UIFont*) type##SelectedFont
#define DNThemeMethod_Type_SelectedKerning(type)            - (NSNumber*) type##SelectedKerning
#define DNThemeMethod_Type_ShowSuggestions(type)            - (NSNumber*) type##ShowSuggestions
#define DNThemeMethod_Type_TextAlignment(type)              - (NSNumber*) type##TextAlignment
#define DNThemeMethod_Type_ThumbTintColor(type)             - (UIColor*) type##ThumbTintColor
#define DNThemeMethod_Type_TintColor(type)                  - (UIColor*) type##TintColor
#define DNThemeMethod_Type_UnhighlightedColor(type)         - (UIColor*) type##UnhighlightedColor
#define DNThemeMethod_Type_VerticalAlignment(type)          - (NSNumber*) type##VerticalAlignment
#define DNThemeMethod_Type_VerticalPadding(type)            - (NSNumber*) type##VerticalPadding

#pragma mark - Type/Attribute/ControlState Macros

// ie: Button Font Normal
// functionName  = [NSString stringWithFormat:@"%@%@%@", type, attribute, controlStateString];
#define DNThemeMethod_TypeControlState_BackgroundColor(type,controlState)           - (UIColor*) type##BackgroundColor##controlState
#define DNThemeMethod_TypeControlState_BorderColor(type,controlState)               - (UIColor*) type##BorderColor##controlState
#define DNThemeMethod_TypeControlState_BorderStyle(type,controlState)               - (NSNumber*) type##BorderStyle##controlState
#define DNThemeMethod_TypeControlState_BorderWidth(type,controlState)               - (NSNumber*) type##BorderWidth##controlState
#define DNThemeMethod_TypeControlState_Color(type,controlState)                     - (UIColor*) type##Color##controlState
#define DNThemeMethod_TypeControlState_Font(type,controlState)                      - (UIFont*) type##Font##controlState
#define DNThemeMethod_TypeControlState_HighlightedColor(type,controlState)          - (UIColor*) type##HighlightedColor##controlState
#define DNThemeMethod_TypeControlState_HorizontalPadding(type,controlState)         - (NSNumber*) type##HorizontalPadding##controlState
#define DNThemeMethod_TypeControlState_Kerning(type,controlState)                   - (NSNumber*) type##Kerning##controlState
#define DNThemeMethod_TypeControlState_LineHeightMultiple(type,controlState)        - (NSNumber*) type##LineHeightMultiple##controlState
#define DNThemeMethod_TypeControlState_LineSpacing(type,controlState)               - (NSNumber*) type##LineSpacing##controlState
#define DNThemeMethod_TypeControlState_Name(type,controlState)                      - (NSString*) type##Name##controlState
#define DNThemeMethod_TypeControlState_OnTintColor(type,controlState)               - (UIColor*) type##OnTintColor##controlState
#define DNThemeMethod_TypeControlState_PlaceholderColor(type,controlState)          - (UIColor*) type##PlaceholderColor##controlState
#define DNThemeMethod_TypeControlState_SelectedBackgroundColor(type,controlState)   - (UIColor*) type##SelectedBackgroundColor##controlState
#define DNThemeMethod_TypeControlState_SelectedColor(type,controlState)             - (UIColor*) type##SelectedColor##controlState
#define DNThemeMethod_TypeControlState_SelectedFont(type,controlState)              - (UIFont*) type##SelectedFont##controlState
#define DNThemeMethod_TypeControlState_SelectedKerning(type,controlState)           - (NSNumber*) type##SelectedKerning##controlState
#define DNThemeMethod_TypeControlState_ShowSuggestions(type,controlState)           - (NSNumber*) type##ShowSuggestions##controlState
#define DNThemeMethod_TypeControlState_TextAlignment(type,controlState)             - (NSNumber*) type##TextAlignment##controlState
#define DNThemeMethod_TypeControlState_ThumbTintColor(type,controlState)            - (UIColor*) type##ThumbTintColor##controlState
#define DNThemeMethod_TypeControlState_TintColor(type,controlState)                 - (UIColor*) type##TintColor##controlState
#define DNThemeMethod_TypeControlState_UnhighlightedColor(type,controlState)        - (UIColor*) type##UnhighlightedColor##controlState
#define DNThemeMethod_TypeControlState_VerticalAlignment(type,controlState)         - (NSNumber*) type##VerticalAlignment##controlState
#define DNThemeMethod_TypeControlState_VerticalPadding(type,controlState)           - (NSNumber*) type##VerticalPadding##controlState

#pragma mark - Group/Type/Attribute Macros

// ie: LOG Button Font
// functionName  = [NSString stringWithFormat:@"%@%@%@", group, type, attribute];
#define DNThemeMethod_GroupType_BackgroundColor(group,type)             - (UIColor*) group##type##BackgroundColor
#define DNThemeMethod_GroupType_BorderColor(group,type)                 - (UIColor*) group##type##BorderColor
#define DNThemeMethod_GroupType_BorderStyle(group,type)                 - (NSNumber*) group##type##BorderStyle
#define DNThemeMethod_GroupType_BorderWidth(group,type)                 - (NSNumber*) group##type##BorderWidth
#define DNThemeMethod_GroupType_Color(group,type)                       - (UIColor*) group##type##Color
#define DNThemeMethod_GroupType_Font(group,type)                        - (UIFont*) group##type##Font
#define DNThemeMethod_GroupType_HighlightedColor(group,type)            - (UIColor*) group##type##HighlightedColor
#define DNThemeMethod_GroupType_HorizontalPadding(group,type)           - (NSNumber*) group##type##HorizontalPadding
#define DNThemeMethod_GroupType_Kerning(group,type)                     - (NSNumber*) group##type##Kerning
#define DNThemeMethod_GroupType_LineHeightMultiple(group,type)          - (NSNumber*) group##type##LineHeightMultiple
#define DNThemeMethod_GroupType_LineSpacing(group,type)                 - (NSNumber*) group##type##LineSpacing
#define DNThemeMethod_GroupType_Name(group,type)                        - (NSString*) group##type##Name
#define DNThemeMethod_GroupType_OnTintColor(group,type)                 - (UIColor*) group##type##OnTintColor
#define DNThemeMethod_GroupType_PlaceholderColor(group,type)            - (UIColor*) group##type##PlaceholderColor
#define DNThemeMethod_GroupType_SelectedBackgroundColor(group,type)     - (UIColor*) group##type##SelectedBackgroundColor
#define DNThemeMethod_GroupType_SelectedColor(group,type)               - (UIColor*) group##type##SelectedColor
#define DNThemeMethod_GroupType_SelectedFont(group,type)                - (UIFont*) group##type##SelectedFont
#define DNThemeMethod_GroupType_SelectedKerning(group,type)             - (NSNumber*) group##type##SelectedKerning
#define DNThemeMethod_GroupType_ShowSuggestions(group,type)             - (NSNumber*) group##type##ShowSuggestions
#define DNThemeMethod_GroupType_TextAlignment(group,type)               - (NSNumber*) group##type##TextAlignment
#define DNThemeMethod_GroupType_ThumbTintColor(group,type)              - (UIColor*) group##type##ThumbTintColor
#define DNThemeMethod_GroupType_TintColor(group,type)                   - (UIColor*) group##type##TintColor
#define DNThemeMethod_GroupType_UnhighlightedColor(group,type)          - (UIColor*) group##type##UnhighlightedColor
#define DNThemeMethod_GroupType_VerticalAlignment(group,type)           - (NSNumber*) group##type##VerticalAlignment
#define DNThemeMethod_GroupType_VerticalPadding(group,type)             - (NSNumber*) group##type##VerticalPadding

#pragma mark - Group/Type/Attribute/ControlState Macros

// ie: LOG Button Font Normal
// functionName  = [NSString stringWithFormat:@"%@%@%@%@", group, type, attribute, controlStateString];
#define DNThemeMethod_GroupTypeControlState_BackgroundColor(group,type,controlState)            - (UIColor*) group##type##BackgroundColor##controlState
#define DNThemeMethod_GroupTypeControlState_BorderColor(group,type,controlState)                - (UIColor*) group##type##BorderColor##controlState
#define DNThemeMethod_GroupTypeControlState_BorderStyle(group,type,controlState)                - (NSNumber*) group##type##BorderStyle##controlState
#define DNThemeMethod_GroupTypeControlState_BorderWidth(group,type,controlState)                - (NSNumber*) group##type##BorderWidth##controlState
#define DNThemeMethod_GroupTypeControlState_Color(group,type,controlState)                      - (UIColor*) group##type##Color##controlState
#define DNThemeMethod_GroupTypeControlState_Font(group,type,controlState)                       - (UIFont*) group##type##Font##controlState
#define DNThemeMethod_GroupTypeControlState_HighlightedColor(group,type,controlState)           - (UIColor*) group##type##HighlightedColor##controlState
#define DNThemeMethod_GroupTypeControlState_HorizontalPadding(group,type,controlState)          - (NSNumber*) group##type##HorizontalPadding##controlState
#define DNThemeMethod_GroupTypeControlState_Kerning(group,type,controlState)                    - (NSNumber*) group##type##Kerning##controlState
#define DNThemeMethod_GroupTypeControlState_LineHeightMultiple(group,type,controlState)         - (NSNumber*) group##type##LineHeightMultiple##controlState
#define DNThemeMethod_GroupTypeControlState_LineSpacing(group,type,controlState)                - (NSNumber*) group##type##LineSpacing##controlState
#define DNThemeMethod_GroupTypeControlState_Name(group,type,controlState)                       - (NSString*) group##type##Name##controlState
#define DNThemeMethod_GroupTypeControlState_OnTintColor(group,type,controlState)                - (UIColor*) group##type##OnTintColor##controlState
#define DNThemeMethod_GroupTypeControlState_PlaceholderColor(group,type,controlState)           - (UIColor*) group##type##PlaceholderColor##controlState
#define DNThemeMethod_GroupTypeControlState_SelectedBackgroundColor(group,type,controlState)    - (UIColor*) group##type##SelectedBackgroundColor##controlState
#define DNThemeMethod_GroupTypeControlState_SelectedColor(group,type,controlState)              - (UIColor*) group##type##SelectedColor##controlState
#define DNThemeMethod_GroupTypeControlState_SelectedFont(group,type,controlState)               - (UIFont*) group##type##SelectedFont##controlState
#define DNThemeMethod_GroupTypeControlState_SelectedKerning(group,type,controlState)            - (NSNumber*) group##type##SelectedKerning##controlState
#define DNThemeMethod_GroupTypeControlState_ShowSuggestions(group,type,controlState)            - (NSNumber*) group##type##ShowSuggestions##controlState
#define DNThemeMethod_GroupTypeControlState_TextAlignment(group,type,controlState)              - (NSNumber*) group##type##TextAlignment##controlState
#define DNThemeMethod_GroupTypeControlState_ThumbTintColor(group,type,controlState)             - (UIColor*) group##type##ThumbTintColor##controlState
#define DNThemeMethod_GroupTypeControlState_TintColor(group,type,controlState)                  - (UIColor*) group##type##TintColor##controlState
#define DNThemeMethod_GroupTypeControlState_UnhighlightedColor(group,type,controlState)         - (UIColor*) group##type##UnhighlightedColor##controlState
#define DNThemeMethod_GroupTypeControlState_VerticalAlignment(group,type,controlState)          - (NSNumber*) group##type##VerticalAlignment##controlState
#define DNThemeMethod_GroupTypeControlState_VerticalPadding(group,type,controlState)            - (NSNumber*) group##type##VerticalPadding##controlState

#pragma mark - Group/Screen/Type/Attribute Macros

// ie: ie: LOG WelcomeView Button Font
// functionName  = [NSString stringWithFormat:@"%@%@%@%@", group, screen, type, attribute];
#define DNThemeMethod_GroupScreenType_BackgroundColor(group,screen,type)            - (UIColor*) group##screen##type##BackgroundColor
#define DNThemeMethod_GroupScreenType_BorderColor(group,screen,type)                - (UIColor*) group##screen##type##BorderColor
#define DNThemeMethod_GroupScreenType_BorderStyle(group,screen,type)                - (NSNumber*) group##screen##type##BorderStyle
#define DNThemeMethod_GroupScreenType_BorderWidth(group,screen,type)                - (NSNumber*) group##screen##type##BorderWidth
#define DNThemeMethod_GroupScreenType_Color(group,screen,type)                      - (UIColor*) group##screen##type##Color
#define DNThemeMethod_GroupScreenType_Font(group,screen,type)                       - (UIFont*) group##screen##type##Font
#define DNThemeMethod_GroupScreenType_HighlightedColor(group,screen,type)           - (UIColor*) group##screen##type##HighlightedColor
#define DNThemeMethod_GroupScreenType_HorizontalPadding(group,screen,type)          - (NSNumber*) group##screen##type##HorizontalPadding
#define DNThemeMethod_GroupScreenType_Kerning(group,screen,type)                    - (NSNumber*) group##screen##type##Kerning
#define DNThemeMethod_GroupScreenType_LineHeightMultiple(group,screen,type)         - (NSNumber*) group##screen##type##LineHeightMultiple
#define DNThemeMethod_GroupScreenType_LineSpacing(group,screen,type)                - (NSNumber*) group##screen##type##LineSpacing
#define DNThemeMethod_GroupScreenType_Name(group,screen,type)                       - (NSString*) group##screen##type##Name
#define DNThemeMethod_GroupScreenType_OnTintColor(group,screen,type)                - (UIColor*) group##screen##type##OnTintColor
#define DNThemeMethod_GroupScreenType_PlaceholderColor(group,screen,type)           - (UIColor*) group##screen##type##PlaceholderColor
#define DNThemeMethod_GroupScreenType_SelectedBackgroundColor(group,screen,type)    - (UIColor*) group##screen##type##SelectedBackgroundColor
#define DNThemeMethod_GroupScreenType_SelectedColor(group,screen,type)              - (UIColor*) group##screen##type##SelectedColor
#define DNThemeMethod_GroupScreenType_SelectedFont(group,screen,type)               - (UIFont*) group##screen##type##SelectedFont
#define DNThemeMethod_GroupScreenType_SelectedKerning(group,screen,type)            - (NSNumber*) group##screen##type##SelectedKerning
#define DNThemeMethod_GroupScreenType_ShowSuggestions(group,screen,type)            - (NSNumber*) group##screen##type##ShowSuggestions
#define DNThemeMethod_GroupScreenType_TextAlignment(group,screen,type)              - (NSNumber*) group##screen##type##TextAlignment
#define DNThemeMethod_GroupScreenType_ThumbTintColor(group,screen,type)             - (UIColor*) group##screen##type##ThumbTintColor
#define DNThemeMethod_GroupScreenType_TintColor(group,screen,type)                  - (UIColor*) group##screen##type##TintColor
#define DNThemeMethod_GroupScreenType_UnhighlightedColor(group,screen,type)         - (UIColor*) group##screen##type##UnhighlightedColor
#define DNThemeMethod_GroupScreenType_VerticalAlignment(group,screen,type)          - (NSNumber*) group##screen##type##VerticalAlignment
#define DNThemeMethod_GroupScreenType_VerticalPadding(group,screen,type)            - (NSNumber*) group##screen##type##VerticalPadding

#pragma mark - Group/Screen/Type/Attribute/ControlState Macros

// ie: LOG WelcomeView Button Font Normal
// functionName  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, type, attribute, controlStateString];
#define DNThemeMethod_GroupScreenTypeControlState_BackgroundColor(group,screen,type,controlState)           - (UIColor*) group##screen##type##BackgroundColor##controlState
#define DNThemeMethod_GroupScreenTypeControlState_BorderColor(group,screen,type,controlState)               - (UIColor*) group##screen##type##BorderColor##controlState
#define DNThemeMethod_GroupScreenTypeControlState_BorderStyle(group,screen,type,controlState)               - (NSNumber*) group##screen##type##BorderStyle##controlState
#define DNThemeMethod_GroupScreenTypeControlState_BorderWidth(group,screen,type,controlState)               - (NSNumber*) group##screen##type##BorderWidth##controlState
#define DNThemeMethod_GroupScreenTypeControlState_Color(group,screen,type,controlState)                     - (UIColor*) group##screen##type##Color##controlState
#define DNThemeMethod_GroupScreenTypeControlState_Font(group,screen,type,controlState)                      - (UIFont*) group##screen##type##Font##controlState
#define DNThemeMethod_GroupScreenTypeControlState_HighlightedColor(group,screen,type,controlState)          - (UIColor*) group##screen##type##HighlightedColor##controlState
#define DNThemeMethod_GroupScreenTypeControlState_HorizontalPadding(group,screen,type,controlState)         - (NSNumber*) group##screen##type##HorizontalPadding##controlState
#define DNThemeMethod_GroupScreenTypeControlState_Kerning(group,screen,type,controlState)                   - (NSNumber*) group##screen##type##Kerning##controlState
#define DNThemeMethod_GroupScreenTypeControlState_LineHeightMultiple(group,screen,type,controlState)        - (NSNumber*) group##screen##type##LineHeightMultiple##controlState
#define DNThemeMethod_GroupScreenTypeControlState_LineSpacing(group,screen,type,controlState)               - (NSNumber*) group##screen##type##LineSpacing##controlState
#define DNThemeMethod_GroupScreenTypeControlState_Name(group,screen,type,controlState)                      - (NSString*) group##screen##type##Name##controlState
#define DNThemeMethod_GroupScreenTypeControlState_OnTintColor(group,screen,type,controlState)               - (UIColor*) group##screen##type##OnTintColor##controlState
#define DNThemeMethod_GroupScreenTypeControlState_PlaceholderColor(group,screen,type,controlState)          - (UIColor*) group##screen##type##PlaceholderColor##controlState
#define DNThemeMethod_GroupScreenTypeControlState_SelectedBackgroundColor(group,screen,type,controlState)   - (UIColor*) group##screen##type##SelectedBackgroundColor##controlState
#define DNThemeMethod_GroupScreenTypeControlState_SelectedColor(group,screen,type,controlState)             - (UIColor*) group##screen##type##SelectedColor##controlState
#define DNThemeMethod_GroupScreenTypeControlState_SelectedFont(group,screen,type,controlState)              - (UIFont*) group##screen##type##SelectedFont##controlState
#define DNThemeMethod_GroupScreenTypeControlState_SelectedKerning(group,screen,type,controlState)           - (NSNumber*) group##screen##type##SelectedKerning##controlState
#define DNThemeMethod_GroupScreenTypeControlState_ShowSuggestions(group,screen,type,controlState)           - (NSNumber*) group##screen##type##ShowSuggestions##controlState
#define DNThemeMethod_GroupScreenTypeControlState_TextAlignment(group,screen,type,controlState)             - (NSNumber*) group##screen##type##TextAlignment##controlState
#define DNThemeMethod_GroupScreenTypeControlState_ThumbTintColor(group,screen,type,controlState)            - (UIColor*) group##screen##type##ThumbTintColor##controlState
#define DNThemeMethod_GroupScreenTypeControlState_TintColor(group,screen,type,controlState)                 - (UIColor*) group##screen##type##TintColor##controlState
#define DNThemeMethod_GroupScreenTypeControlState_UnhighlightedColor(group,screen,type,controlState)        - (UIColor*) group##screen##type##UnhighlightedColor##controlState
#define DNThemeMethod_GroupScreenTypeControlState_VerticalAlignment(group,screen,type,controlState)         - (NSNumber*) group##screen##type##VerticalAlignment##controlState
#define DNThemeMethod_GroupScreenTypeControlState_VerticalPadding(group,screen,type,controlState)           - (NSNumber*) group##screen##type##VerticalPadding##controlState

#pragma mark - Group/Screen/ViewState/Type/Attribute Macros

// ie: LOG WelcomeView SignInWithKeyboard Button Font
// functionName  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, viewState, type, attribute];
#define DNThemeMethod_GroupScreenViewStateType_BackgroundColor(group,screen,viewstate,type)             - (UIColor*) group##screen##viewstate##type##BackgroundColor
#define DNThemeMethod_GroupScreenViewStateType_BorderColor(group,screen,viewstate,type)                 - (UIColor*) group##screen##viewstate##type##BorderColor
#define DNThemeMethod_GroupScreenViewStateType_BorderStyle(group,screen,viewstate,type)                 - (NSNumber*) group##screen##viewstate##type##BorderStyle
#define DNThemeMethod_GroupScreenViewStateType_BorderWidth(group,screen,viewstate,type)                 - (NSNumber*) group##screen##viewstate##type##BorderWidth
#define DNThemeMethod_GroupScreenViewStateType_Color(group,screen,viewstate,type)                       - (UIColor*) group##screen##viewstate##type##Color
#define DNThemeMethod_GroupScreenViewStateType_Font(group,screen,viewstate,type)                        - (UIFont*) group##screen##viewstate##type##Font
#define DNThemeMethod_GroupScreenViewStateType_HighlightedColor(group,screen,viewstate,type)            - (UIColor*) group##screen##viewstate##type##HighlightedColor
#define DNThemeMethod_GroupScreenViewStateType_HorizontalPadding(group,screen,viewstate,type)           - (NSNumber*) group##screen##viewstate##type##HorizontalPadding
#define DNThemeMethod_GroupScreenViewStateType_Kerning(group,screen,viewstate,type)                     - (NSNumber*) group##screen##viewstate##type##Kerning
#define DNThemeMethod_GroupScreenViewStateType_LineHeightMultiple(group,screen,viewstate,type)          - (NSNumber*) group##screen##viewstate##type##LineHeightMultiple
#define DNThemeMethod_GroupScreenViewStateType_LineSpacing(group,screen,viewstate,type)                 - (NSNumber*) group##screen##viewstate##type##LineSpacing
#define DNThemeMethod_GroupScreenViewStateType_Name(group,screen,viewstate,type)                        - (NSString*) group##screen##viewstate##type##Name
#define DNThemeMethod_GroupScreenViewStateType_OnTintColor(group,screen,viewstate,type)                 - (UIColor*) group##screen##viewstate##type##OnTintColor
#define DNThemeMethod_GroupScreenViewStateType_PlaceholderColor(group,screen,viewstate,type)            - (UIColor*) group##screen##viewstate##type##PlaceholderColor
#define DNThemeMethod_GroupScreenViewStateType_SelectedBackgroundColor(group,screen,viewstate,type)     - (UIColor*) group##screen##viewstate##type##SelectedBackgroundColor
#define DNThemeMethod_GroupScreenViewStateType_SelectedColor(group,screen,viewstate,type)               - (UIColor*) group##screen##viewstate##type##SelectedColor
#define DNThemeMethod_GroupScreenViewStateType_SelectedFont(group,screen,viewstate,type)                - (UIFont*) group##screen##viewstate##type##SelectedFont
#define DNThemeMethod_GroupScreenViewStateType_SelectedKerning(group,screen,viewstate,type)             - (NSNumber*) group##screen##viewstate##type##SelectedKerning
#define DNThemeMethod_GroupScreenViewStateType_ShowSuggestions(group,screen,viewstate,type)             - (NSNumber*) group##screen##viewstate##type##ShowSuggestions
#define DNThemeMethod_GroupScreenViewStateType_TextAlignment(group,screen,viewstate,type)               - (NSNumber*) group##screen##viewstate##type##TextAlignment
#define DNThemeMethod_GroupScreenViewStateType_ThumbTintColor(group,screen,viewstate,type)              - (UIColor*) group##screen##viewstate##type##ThumbTintColor
#define DNThemeMethod_GroupScreenViewStateType_TintColor(group,screen,viewstate,type)                   - (UIColor*) group##screen##viewstate##type##TintColor
#define DNThemeMethod_GroupScreenViewStateType_UnhighlightedColor(group,screen,viewstate,type)          - (UIColor*) group##screen##viewstate##type##UnhighlightedColor
#define DNThemeMethod_GroupScreenViewStateType_VerticalAlignment(group,screen,viewstate,type)           - (NSNumber*) group##screen##viewstate##type##VerticalAlignment
#define DNThemeMethod_GroupScreenViewStateType_VerticalPadding(group,screen,viewstate,type)             - (NSNumber*) group##screen##viewstate##type##VerticalPadding

#pragma mark - Group/Screen/ViewState/Type/Attribute/ControlState Macros

// ie: LOG WelcomeView SignInWithKeyboard Button Font Normal
// functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, viewState, type, attribute, controlStateString];
#define DNThemeMethod_GroupScreenViewStateTypeControlState_BackgroundColor(group,screen,viewstate,type,controlState)            - (UIColor*) group##screen##viewstate##type##BackgroundColor##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_BorderColor(group,screen,viewstate,type,controlState)                - (UIColor*) group##screen##viewstate##type##BorderColor##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_BorderStyle(group,screen,viewstate,type,controlState)                - (NSNumber*) group##screen##viewstate##type##BorderStyle##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_BorderWidth(group,screen,viewstate,type,controlState)                - (NSNumber*) group##screen##viewstate##type##BorderWidth##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_Color(group,screen,viewstate,type,controlState)                      - (UIColor*) group##screen##viewstate##type##Color##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_Font(group,screen,viewstate,type,controlState)                       - (UIFont*) group##screen##viewstate##type##Font##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_HighlightedColor(group,screen,viewstate,type,controlState)           - (UIColor*) group##screen##viewstate##type##HighlightedColor##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_HorizontalPadding(group,screen,viewstate,type,controlState)          - (NSNumber*) group##screen##viewstate##type##HorizontalPadding##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_Kerning(group,screen,viewstate,type,controlState)                    - (NSNumber*) group##screen##viewstate##type##Kerning##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_LineHeightMultiple(group,screen,viewstate,type,controlState)         - (NSNumber*) group##screen##viewstate##type##LineHeightMultiple##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_LineSpacing(group,screen,viewstate,type,controlState)                - (NSNumber*) group##screen##viewstate##type##LineSpacing##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_Name(group,screen,viewstate,type,controlState)                       - (NSString*) group##screen##viewstate##type##Name##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_OnTintColor(group,screen,viewstate,type,controlState)                - (UIColor*) group##screen##viewstate##type##OnTintColor##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_PlaceholderColor(group,screen,viewstate,type,controlState)           - (UIColor*) group##screen##viewstate##type##PlaceholderColor##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_SelectedBackgroundColor(group,screen,viewstate,type,controlState)    - (UIColor*) group##screen##viewstate##type##SelectedBackgroundColor##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_SelectedColor(group,screen,viewstate,type,controlState)              - (UIColor*) group##screen##viewstate##type##SelectedColor##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_SelectedFont(group,screen,viewstate,type,controlState)               - (UIFont*) group##screen##viewstate##type##SelectedFont##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_SelectedKerning(group,screen,viewstate,type,controlState)            - (NSNumber*) group##screen##viewstate##type##SelectedKerning##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_ShowSuggestions(group,screen,viewstate,type,controlState)            - (NSNumber*) group##screen##viewstate##type##ShowSuggestions##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_TextAlignment(group,screen,viewstate,type,controlState)              - (NSNumber*) group##screen##viewstate##type##TextAlignment##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_ThumbTintColor(group,screen,viewstate,type,controlState)             - (UIColor*) group##screen##viewstate##type##ThumbTintColor##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_TintColor(group,screen,viewstate,type,controlState)                  - (UIColor*) group##screen##viewstate##type##TintColor##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_UnhighlightedColor(group,screen,viewstate,type,controlState)         - (UIColor*) group##screen##viewstate##type##UnhighlightedColor##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_VerticalAlignment(group,screen,viewstate,type,controlState)          - (NSNumber*) group##screen##viewstate##type##VerticalAlignment##controlState
#define DNThemeMethod_GroupScreenViewStateTypeControlState_VerticalPadding(group,screen,viewstate,type,controlState)            - (NSNumber*) group##screen##viewstate##type##VerticalPadding##controlState

#pragma mark - Group/Screen/Item/Type/Attribute Macros

// ie: LOG WelcomeView SignIn Button Font
// functionName  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, item, type, attribute];
#define DNThemeMethod_GroupScreenItemType_BackgroundColor(group,screen,item,type)               - (UIColor*) group##screen##item##type##BackgroundColor
#define DNThemeMethod_GroupScreenItemType_BorderColor(group,screen,item,type)                   - (UIColor*) group##screen##item##type##BorderColor
#define DNThemeMethod_GroupScreenItemType_BorderStyle(group,screen,item,type)                   - (NSNumber*) group##screen##item##type##BorderStyle
#define DNThemeMethod_GroupScreenItemType_BorderWidth(group,screen,item,type)                   - (NSNumber*) group##screen##item##type##BorderWidth
#define DNThemeMethod_GroupScreenItemType_Color(group,screen,item,type)                         - (UIColor*) group##screen##item##type##Color
#define DNThemeMethod_GroupScreenItemType_Font(group,screen,item,type)                          - (UIFont*) group##screen##item##type##Font
#define DNThemeMethod_GroupScreenItemType_HighlightedColor(group,screen,item,type)              - (UIColor*) group##screen##item##type##HighlightedColor
#define DNThemeMethod_GroupScreenItemType_HorizontalPadding(group,screen,item,type)             - (NSNumber*) group##screen##item##type##HorizontalPadding
#define DNThemeMethod_GroupScreenItemType_Kerning(group,screen,item,type)                       - (NSNumber*) group##screen##item##type##Kerning
#define DNThemeMethod_GroupScreenItemType_LineHeightMultiple(group,screen,item,type)            - (NSNumber*) group##screen##item##type##LineHeightMultiple
#define DNThemeMethod_GroupScreenItemType_LineSpacing(group,screen,item,type)                   - (NSNumber*) group##screen##item##type##LineSpacing
#define DNThemeMethod_GroupScreenItemType_Name(group,screen,item,type)                          - (NSString*) group##screen##item##type##Name
#define DNThemeMethod_GroupScreenItemType_OnTintColor(group,screen,item,type)                   - (UIColor*) group##screen##item##type##OnTintColor
#define DNThemeMethod_GroupScreenItemType_PlaceholderColor(group,screen,item,type)              - (UIColor*) group##screen##item##type##PlaceholderColor
#define DNThemeMethod_GroupScreenItemType_SelectedBackgroundColor(group,screen,item,type)       - (UIColor*) group##screen##item##type##SelectedBackgroundColor
#define DNThemeMethod_GroupScreenItemType_SelectedColor(group,screen,item,type)                 - (UIColor*) group##screen##item##type##SelectedColor
#define DNThemeMethod_GroupScreenItemType_SelectedFont(group,screen,item,type)                  - (UIFont*) group##screen##item##type##SelectedFont
#define DNThemeMethod_GroupScreenItemType_SelectedKerning(group,screen,item,type)               - (NSNumber*) group##screen##item##type##SelectedKerning
#define DNThemeMethod_GroupScreenItemType_ShowSuggestions(group,screen,item,type)               - (NSNumber*) group##screen##item##type##ShowSuggestions
#define DNThemeMethod_GroupScreenItemType_TextAlignment(group,screen,item,type)                 - (NSNumber*) group##screen##item##type##TextAlignment
#define DNThemeMethod_GroupScreenItemType_ThumbTintColor(group,screen,item,type)                - (UIColor*) group##screen##item##type##ThumbTintColor
#define DNThemeMethod_GroupScreenItemType_TintColor(group,screen,item,type)                     - (UIColor*) group##screen##item##type##TintColor
#define DNThemeMethod_GroupScreenItemType_UnhighlightedColor(group,screen,item,type)            - (UIColor*) group##screen##item##type##UnhighlightedColor
#define DNThemeMethod_GroupScreenItemType_VerticalAlignment(group,screen,item,type)             - (NSNumber*) group##screen##item##type##VerticalAlignment
#define DNThemeMethod_GroupScreenItemType_VerticalPadding(group,screen,item,type)               - (NSNumber*) group##screen##item##type##VerticalPadding

#pragma mark - Group/Screen/ViewState/Item/Type/Attribute Macros

// ie: LOG WelcomeView SignInWithKeyboard SignIn Button Font
// functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, viewState, item, type, attribute];
#define DNThemeMethod_GroupScreenViewStateItemType_BackgroundColor(group,screen,viewstate,item,type)            - (UIColor*) group##screen##viewstate##item##type##BackgroundColor
#define DNThemeMethod_GroupScreenViewStateItemType_BorderColor(group,screen,viewstate,item,type)                - (UIColor*) group##screen##viewstate##item##type##BorderColor
#define DNThemeMethod_GroupScreenViewStateItemType_BorderStyle(group,screen,viewstate,item,type)                - (NSNumber*) group##screen##viewstate##item##type##BorderStyle
#define DNThemeMethod_GroupScreenViewStateItemType_BorderWidth(group,screen,viewstate,item,type)                - (NSNumber*) group##screen##viewstate##item##type##BorderWidth
#define DNThemeMethod_GroupScreenViewStateItemType_Color(group,screen,viewstate,item,type)                      - (UIColor*) group##screen##viewstate##item##type##Color
#define DNThemeMethod_GroupScreenViewStateItemType_Font(group,screen,viewstate,item,type)                       - (UIFont*) group##screen##viewstate##item##type##Font
#define DNThemeMethod_GroupScreenViewStateItemType_HighlightedColor(group,screen,viewstate,item,type)           - (UIColor*) group##screen##viewstate##item##type##HighlightedColor
#define DNThemeMethod_GroupScreenViewStateItemType_HorizontalPadding(group,screen,viewstate,item,type)          - (NSNumber*) group##screen##viewstate##item##type##HorizontalPadding
#define DNThemeMethod_GroupScreenViewStateItemType_Kerning(group,screen,viewstate,item,type)                    - (NSNumber*) group##screen##viewstate##item##type##Kerning
#define DNThemeMethod_GroupScreenViewStateItemType_LineHeightMultiple(group,screen,viewstate,item,type)         - (NSNumber*) group##screen##viewstate##item##type##LineHeightMultiple
#define DNThemeMethod_GroupScreenViewStateItemType_LineSpacing(group,screen,viewstate,item,type)                - (NSNumber*) group##screen##viewstate##item##type##LineSpacing
#define DNThemeMethod_GroupScreenViewStateItemType_Name(group,screen,viewstate,item,type)                       - (NSString*) group##screen##viewstate##item##type##Name
#define DNThemeMethod_GroupScreenViewStateItemType_OnTintColor(group,screen,viewstate,item,type)                - (UIColor*) group##screen##viewstate##item##type##OnTintColor
#define DNThemeMethod_GroupScreenViewStateItemType_PlaceholderColor(group,screen,viewstate,item,type)           - (UIColor*) group##screen##viewstate##item##type##PlaceholderColor
#define DNThemeMethod_GroupScreenViewStateItemType_SelectedBackgroundColor(group,screen,viewstate,item,type)    - (UIColor*) group##screen##viewstate##item##type##SelectedBackgroundColor
#define DNThemeMethod_GroupScreenViewStateItemType_SelectedColor(group,screen,viewstate,item,type)              - (UIColor*) group##screen##viewstate##item##type##SelectedColor
#define DNThemeMethod_GroupScreenViewStateItemType_SelectedFont(group,screen,viewstate,item,type)               - (UIFont*) group##screen##viewstate##item##type##SelectedFont
#define DNThemeMethod_GroupScreenViewStateItemType_SelectedKerning(group,screen,viewstate,item,type)            - (NSNumber*) group##screen##viewstate##item##type##SelectedKerning
#define DNThemeMethod_GroupScreenViewStateItemType_ShowSuggestions(group,screen,viewstate,item,type)            - (NSNumber*) group##screen##viewstate##item##type##ShowSuggestions
#define DNThemeMethod_GroupScreenViewStateItemType_TextAlignment(group,screen,viewstate,item,type)              - (NSNumber*) group##screen##viewstate##item##type##TextAlignment
#define DNThemeMethod_GroupScreenViewStateItemType_ThumbTintColor(group,screen,viewstate,item,type)             - (UIColor*) group##screen##viewstate##item##type##ThumbTintColor
#define DNThemeMethod_GroupScreenViewStateItemType_TintColor(group,screen,viewstate,item,type)                  - (UIColor*) group##screen##viewstate##item##type##TintColor
#define DNThemeMethod_GroupScreenViewStateItemType_UnhighlightedColor(group,screen,viewstate,item,type)         - (UIColor*) group##screen##viewstate##item##type##UnhighlightedColor
#define DNThemeMethod_GroupScreenViewStateItemType_VerticalAlignment(group,screen,viewstate,item,type)          - (NSNumber*) group##screen##viewstate##item##type##VerticalAlignment
#define DNThemeMethod_GroupScreenViewStateItemType_VerticalPadding(group,screen,viewstate,item,type)            - (NSNumber*) group##screen##viewstate##item##type##VerticalPadding

#pragma mark - Group/Screen/Item/Type/Attribute/ControlState Macros

// ie: LOG WelcomeView SignIn Button Font Normal
// functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, item, type, attribute, controlStateString];
#define DNThemeMethod_GroupScreenItemTypeControlState_BackgroundColor(group,screen,item,type,controlState)              - (UIColor*) group##screen##item##type##BackgroundColor##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_BorderColor(group,screen,item,type,controlState)                  - (UIColor*) group##screen##item##type##BorderColor##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_BorderStyle(group,screen,item,type,controlState)                  - (NSNumber*) group##screen##item##type##BorderStyle##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_BorderWidth(group,screen,item,type,controlState)                  - (NSNumber*) group##screen##item##type##BorderWidth##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_Color(group,screen,item,type,controlState)                        - (UIColor*) group##screen##item##type##Color##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_Font(group,screen,item,type,controlState)                         - (UIFont*) group##screen##item##type##Font##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_HighlightedColor(group,screen,item,type,controlState)             - (UIColor*) group##screen##item##type##HighlightedColor##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_HorizontalPadding(group,screen,item,type,controlState)            - (NSNumber*) group##screen##item##type##HorizontalPadding##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_Kerning(group,screen,item,type,controlState)                      - (NSNumber*) group##screen##item##type##Kerning##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_LineHeightMultiple(group,screen,item,type,controlState)           - (NSNumber*) group##screen##item##type##LineHeightMultiple##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_LineSpacing(group,screen,item,type,controlState)                  - (NSNumber*) group##screen##item##type##LineSpacing##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_Name(group,screen,item,type,controlState)                         - (NSString*) group##screen##item##type##Name##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_OnTintColor(group,screen,item,type,controlState)                  - (UIColor*) group##screen##item##type##OnTintColor##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_PlaceholderColor(group,screen,item,type,controlState)             - (UIColor*) group##screen##item##type##PlaceholderColor##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_SelectedBackgroundColor(group,screen,item,type,controlState)      - (UIColor*) group##screen##item##type##SelectedBackgroundColor##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_SelectedColor(group,screen,item,type,controlState)                - (UIColor*) group##screen##item##type##SelectedColor##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_SelectedFont(group,screen,item,type,controlState)                 - (UIFont*) group##screen##item##type##SelectedFont##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_SelectedKerning(group,screen,item,type,controlState)              - (NSNumber*) group##screen##item##type##SelectedKerning##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_ShowSuggestions(group,screen,item,type,controlState)              - (NSNumber*) group##screen##item##type##ShowSuggestions##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_TextAlignment(group,screen,item,type,controlState)                - (NSNumber*) group##screen##item##type##TextAlignment##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_ThumbTintColor(group,screen,item,type,controlState)               - (UIColor*) group##screen##item##type##ThumbTintColor##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_TintColor(group,screen,item,type,controlState)                    - (UIColor*) group##screen##item##type##TintColor##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_UnhighlightedColor(group,screen,item,type,controlState)           - (UIColor*) group##screen##item##type##UnhighlightedColor##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_VerticalAlignment(group,screen,item,type,controlState)            - (NSNumber*) group##screen##item##type##VerticalAlignment##controlState
#define DNThemeMethod_GroupScreenItemTypeControlState_VerticalPadding(group,screen,item,type,controlState)              - (NSNumber*) group##screen##item##type##VerticalPadding##controlState

#pragma mark - Group/Screen/ViewState/Item/Type/Attribute/ControlState Macros

// ie: LOG WelcomeView SignInWithKeyboard SignIn Button Font Normal
// functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", group, screen, viewState, item, type, attribute, controlStateString];
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_BackgroundColor(group,screen,viewstate,item,type,controlState)           - (UIColor*) group##screen##viewstate##item##type##BackgroundColor##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_BorderColor(group,screen,viewstate,item,type,controlState)               - (UIColor*) group##screen##viewstate##item##type##BorderColor##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_BorderStyle(group,screen,viewstate,item,type,controlState)               - (NSNumber*) group##screen##viewstate##item##type##BorderStyle##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_BorderWidth(group,screen,viewstate,item,type,controlState)               - (NSNumber*) group##screen##viewstate##item##type##BorderWidth##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_Color(group,screen,viewstate,item,type,controlState)                     - (UIColor*) group##screen##viewstate##item##type##Color##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_Font(group,screen,viewstate,item,type,controlState)                      - (UIFont*) group##screen##viewstate##item##type##Font##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_HighlightedColor(group,screen,viewstate,item,type,controlState)          - (UIColor*) group##screen##viewstate##item##type##HighlightedColor##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_HorizontalPadding(group,screen,viewstate,item,type,controlState)         - (NSNumber*) group##screen##viewstate##item##type##HorizontalPadding##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_Kerning(group,screen,viewstate,item,type,controlState)                   - (NSNumber*) group##screen##viewstate##item##type##Kerning##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_LineHeightMultiple(group,screen,viewstate,item,type,controlState)        - (NSNumber*) group##screen##viewstate##item##type##LineHeightMultiple##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_LineSpacing(group,screen,viewstate,item,type,controlState)               - (NSNumber*) group##screen##viewstate##item##type##LineSpacing##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_Name(group,screen,viewstate,item,type,controlState)                      - (NSString*) group##screen##viewstate##item##type##Name##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_OnTintColor(group,screen,viewstate,item,type,controlState)               - (UIColor*) group##screen##viewstate##item##type##OnTintColor##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_PlaceholderColor(group,screen,viewstate,item,type,controlState)          - (UIColor*) group##screen##viewstate##item##type##PlaceholderColor##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_SelectedBackgroundColor(group,screen,viewstate,item,type,controlState)   - (UIColor*) group##screen##viewstate##item##type##SelectedBackgroundColor##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_SelectedColor(group,screen,viewstate,item,type,controlState)             - (UIColor*) group##screen##viewstate##item##type##SelectedColor##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_SelectedFont(group,screen,viewstate,item,type,controlState)              - (UIFont*) group##screen##viewstate##item##type##SelectedFont##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_SelectedKerning(group,screen,viewstate,item,type,controlState)           - (NSNumber*) group##screen##viewstate##item##type##SelectedKerning##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_ShowSuggestions(group,screen,viewstate,item,type,controlState)           - (NSNumber*) group##screen##viewstate##item##type##ShowSuggestions##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_TextAlignment(group,screen,viewstate,item,type,controlState)             - (NSNumber*) group##screen##viewstate##item##type##TextAlignment##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_ThumbTintColor(group,screen,viewstate,item,type,controlState)            - (UIColor*) group##screen##viewstate##item##type##ThumbTintColor##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_TintColor(group,screen,viewstate,item,type,controlState)                 - (UIColor*) group##screen##viewstate##item##type##TintColor##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_UnhighlightedColor(group,screen,viewstate,item,type,controlState)        - (UIColor*) group##screen##viewstate##item##type##UnhighlightedColor##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_VerticalAlignment(group,screen,viewstate,item,type,controlState)         - (NSNumber*) group##screen##viewstate##item##type##VerticalAlignment##controlState
#define DNThemeMethod_GroupScreenViewStateItemTypeControlState_VerticalPadding(group,screen,viewstate,item,type,controlState)           - (NSNumber*) group##screen##viewstate##item##type##VerticalPadding##controlState

@interface DNTheme : ADVDefaultTheme <DNThemeProtocol>

@end
