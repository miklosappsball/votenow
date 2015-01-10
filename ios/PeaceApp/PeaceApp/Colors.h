//
//  Colors.h
//  Peepapp
//
//  Created by Andris Konfar on 24/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#ifndef Peaceapp_Colors_h
#define Peaceapp_Colors_h


#define SHUTTER NO

#define BUTTON_HEIGHT 45
#define LEFT_MARGIN 20
#define RIGHT_MARGIN LEFT_MARGIN
#define DEFAULT_GAP 20
#define FONT_SIZE 16
#define FONT_TEXTFIELD 20
#define TEXT_FIELD_HEIGHT 40
#define ANIMATION_DEFAULT_TIME 0.25

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f]

#define COLOR_BACKGROUND_1 RGB(255,255,255)
#define TEXT_COLOR_1 RGB(58,115,255)

#define BORDER_COLOR RGBA(58,115,255,127)
#define ITEM_BG_COLOR RGBA(58,115,255,51)

#define BUTTON_BG_COLOR RGBA(112,255,175,127)
#define BUTTON_BORDER_COLOR RGBA(0,195,0,255)


#define COLOR_LOADING_INDICATOR_BG  RGBA(0,0,0,175)
#define COLOR_LOADING_INDICATOR_MID_BG RGBA(0,0,0,0)


#endif
