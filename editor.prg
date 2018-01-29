/* =============================================================================
 * Faust 2 Level Editor by Casper
 * (c) 2017 altsrc
 * ========================================================================== */

COMPILER_OPTIONS _case_sensitive;

program Faust2LevelEditor;

/* -----------------------------------------------------------------------------
 * Constants
 * ---------------------------------------------------------------------------*/
const
// **** COMMON ****
    // DIV command enums
    REGION_FULL_SCREEN = 0;
    SCROLL_FOREGROUND_HORIZONTAL = 1;
    SCROLL_FOREGROUND_VERTICAL   = 2;
    SCROLL_BACKGROUND_HORIZONTAL = 4;
    SCROLL_BACKGROUND_VERTICAL   = 8;
    FONT_ANCHOR_TOP_LEFT      = 0;
    FONT_ANCHOR_TOP_CENTER    = 1;
    FONT_ANCHOR_TOP_RIGHT     = 2;
    FONT_ANCHOR_CENTER_LEFT   = 3;
    FONT_ANCHOR_CENTERED      = 4;
    FONT_ANCHOR_CENTER_RIGHT  = 5;
    FONT_ANCHOR_BOTTOM_LEFT   = 6;
    FONT_ANCHOR_BOTTOM_CENTER = 7;
    FONT_ANCHOR_BOTTOM_RIGHT  = 8;
    SOUND_PLAYBACK_ONCE    = 0;
    SOUND_PLAYBACK_LOOPING = 1;
    DRAW_LINE           = 1;
    DRAW_RECTANGLE      = 2;
    DRAW_RECTANGLE_FILL = 3;
    DRAW_ELLIPSE        = 4;
    DRAW_ELLIPSE_FILL   = 5;
    OPACITY_TRANSPARENT = 0;
    OPACITY_50_PERCENT  = 7;
    OPACITY_SOLID       = 15;
    COLOR_BLACK = 0;
    COLOR_GREY  = 7;
    COLOR_WHITE = 15;
    COLOR_RED   = 22;
    COLOR_GREEN = 41;
    COLOR_BLUE  = 54;

    // null index
    NULL = -1;

    // resource indices
    GFX_MAIN    = 0;
    GFX_ACTORS  = 1;
    GFX_ITEMS   = 2;
    GFX_OBJECTS = 3;
    FONT_SYSTEM = 0;
    FONT_MENU   = 1;
    SOUND_MP40_SHOT       = 0;
    SOUND_SHELL_DROPPED_1 = 1;
    SOUND_SHELL_DROPPED_2 = 2;
    SOUND_SHELL_DROPPED_3 = 3;
    SOUND_KAR98K_SHOT     = 4;

    // resource counts
    GFX_COUNT   = 4;
    FONT_COUNT  = 2;
    SOUND_COUNT = 5;

    // file paths
    DATA_OBJECTS_PATH = "assets/data/objects/";

    // graphics settings
    SCREEN_MODE        = m640x400;
    SCREEN_WIDTH       = 640;
    SCREEN_HEIGHT      = 400;
    HALF_SCREEN_WIDTH  = SCREEN_WIDTH / 2;
    HALF_SCREEN_HEIGHT = SCREEN_HEIGHT / 2;

    // game process resolution
    GPR = 10;

    // timing
    MAX_DELAYS = 32;

    // logging
    MAX_GLOBAL_LOGS = 32;
    MAX_LOCAL_LOGS = 8;

    // debug mode
    DEBUG_MODE = true;

    // ui
    MAX_UI_GROUPS = 8;
    MAX_UI_GROUP_BUTTONS  = 32;
    MAX_UI_GROUP_DRAWINGS = 32;
    MAX_UI_GROUP_TEXTS    = 32;
    MAX_UI_GROUP_IMAGES   = 32;
    MAX_UI_GROUP_SEGMENTS = 32;

// **** UNIQUE ****
    // ui colors
    COLOR_B_NORMAL = COLOR_BLUE;
    COLOR_B_HOVER = COLOR_BLUE + 3;
    COLOR_B_PRESSED = COLOR_BLUE - 1;
    COLOR_B_DISABLED = COLOR_GREY;

    // ui options
    OPT_NEW_LEVEL           = 0;
    OPT_LOAD_LEVEL          = 1;
    OPT_MAIN_MENU           = 2;
    OPT_EXIT                = 3;
    OPT_NEW_LEVEL_FILE_NAME = 4;
    OPT_SAVE_LEVEL          = 5;
    OPT_PALETTE_OBJECTS     = 6;
    OPT_PALETTE_ENTITIES    = 7;
    OPT_SCROLL_UP           = 8;
    OPT_SCROLL_DOWN         = 9;
    UI_OPTION_COUNT = 10;

    // ui groups
    GROUP_MAIN_BG              = 0;
    GROUP_MAIN_MENU            = 1;
    GROUP_STRING_PROMPT_DIALOG = 2;
    GROUP_EDITOR_BG            = 3;

/* -----------------------------------------------------------------------------
 * Global variables
 * ---------------------------------------------------------------------------*/
global
// **** COMMON ****
    // resources
    struct __graphics[GFX_COUNT - 1]
        handle;
        string path;
        count;
    end =
    //  handle  path                           count
        NULL,   "assets/graphics/main.fpg",    NULL,
        NULL,   "assets/graphics/actors.fpg",  NULL,
        NULL,   "assets/graphics/items.fpg",   NULL,
        NULL,   "assets/graphics/objects.fpg", NULL;

    struct __fonts[FONT_COUNT - 1]
        handle;
        path;
        avgCharWidth;
        lineHeight;
    end =
    //  handle  path                               avgCharWidth  lineHeight
        NULL,   NULL,                              7,            8,
        NULL,   "assets/fonts/16x16-w-arcade.fnt", 10,           16;

    struct __sounds[SOUND_COUNT - 1]
        handle;
        path;
        volume;
        frequency;
        playback;
    end =
    //  handle  path                               volume  frequency  playback
        NULL,   "assets/audio/test-shot5.wav",     128,    256,       SOUND_PLAYBACK_ONCE,
        NULL,   "assets/audio/shell-dropped1.wav", 128,    256,       SOUND_PLAYBACK_ONCE,
        NULL,   "assets/audio/shell-dropped2.wav", 128,    256,       SOUND_PLAYBACK_ONCE,
        NULL,   "assets/audio/shell-dropped3.wav", 128,    256,       SOUND_PLAYBACK_ONCE,
        NULL,   "assets/audio/test-shot7.wav",     128,    256,       SOUND_PLAYBACK_ONCE;

    // math
    struct __physics
        // TODO: Consider turning into table.
        struct lineIntersectionData
            ix, iy;
        end
    end

    // timing
    struct __timing
        deltaTime;
        delayCount = 0;
        struct delays[MAX_DELAYS - 1]
            processId;
            startTime;
            delayLength;
        end
    end

    // logging
    struct __logging
        x, y;
        yOffset;
        logCount;
        struct logs[MAX_GLOBAL_LOGS - 1]
            logId;
            txtLabel;
            txtVal;
        end
    end

    // ui
    struct __ui
        buttonHeldDown;
        buttonClicked;
    end

    __uiGroupsCount;
    struct __uiGroups[MAX_UI_GROUPS - 1]
        visible;
        active;
        processId;
        buttonsCount;
        struct buttons[MAX_UI_GROUP_BUTTONS - 1]
            x, y, width, height;
            colorNormal, colorHover, colorPressed, colorDisabled;
            opacityNormal, opacityHover, opacityPressed, opacityDisabled;
            fontIndex, option;
            string text;
        end
        drawingsCount;
        struct drawings[MAX_UI_GROUP_DRAWINGS - 1]
           x0, y0, x1, y1;
           drawType, color, opacity;
        end
        textsCount;
        struct texts[MAX_UI_GROUP_TEXTS - 1]
            x, y;
            fontIndex, anchor;
            string text;
        end
        textFieldsCount;
        struct textFields[MAX_UI_GROUP_TEXTS - 1]
            x, y;
            fontIndex, anchor, option;
            string text;
        end
        imagesCount;
        struct images[MAX_UI_GROUP_IMAGES - 1]
            x, y, z;
            fileIndex, gfxIndex, angle, size;
        end
        segmentsCount;
        struct segments[MAX_UI_GROUP_SEGMENTS - 1]
            x0, y0, x1, y1;
            lineColor, lineOpacity;
            pointColor, pointOpacity, pointRadius;
        end
    end

    struct __uiOptions[UI_OPTION_COUNT - 1]
        string label;
        index;
    end =
    //  label         index
        "NEW LEVEL",  OPT_NEW_LEVEL,
        "LOAD LEVEL", OPT_LOAD_LEVEL,
        "CANCEL",     OPT_MAIN_MENU,
        "EXIT",       OPT_EXIT,
        "SUBMIT",     OPT_NEW_LEVEL_FILE_NAME,
        "SAVE LEVEL", OPT_SAVE_LEVEL,
        "OBJECTS",    OPT_PALETTE_OBJECTS,
        "ENTITIES",   OPT_PALETTE_ENTITIES,
        "^",          OPT_SCROLL_UP,
        "v",          OPT_SCROLL_DOWN;

// **** UNIQUE ****
// ...



/* -----------------------------------------------------------------------------
 * Local variables (every process gets these)
 * ---------------------------------------------------------------------------*/
local
// **** COMMON ****
    // general purpose
    alive;
    i;

    // logging
    struct logging
        logCount;
        struct logs[MAX_LOCAL_LOGS - 1]
            logId;
            txtLabel;
            txtVal;
        end
    end

// **** UNIQUE ****
// ...



                              /***************\
                              |* UNIQUE CODE *|
                              \***************/

/* -----------------------------------------------------------------------------
 * Main program
 * ---------------------------------------------------------------------------*/
begin
    // setup
    InitGraphics();
    LoadResources();

    // ui config
    ConfigureUI();

    // ui processes
    ButtonHandler();
    UIRenderer();
    MouseCursor();

    // ui main menu
    ShowUIGroup(GROUP_MAIN_BG);
    ShowUIGroup(GROUP_MAIN_MENU);
end



/* -----------------------------------------------------------------------------
 * UI
 * ---------------------------------------------------------------------------*/
function ConfigureUI()
private
    unit = 4;
    w = SCREEN_WIDTH / 4;
    h = SCREEN_HEIGHT / 3;
    pbsize = 64; // palette box size
    uiGroupIndex = 0;
begin
    // MAIN BG
    uiGroupIndex = GROUP_MAIN_BG;
    AddImageToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT, 0,
        GFX_MAIN, 2, 0, 100);

    // MAIN MENU
    uiGroupIndex = GROUP_MAIN_MENU;
    AddTextToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT - 20,
        FONT_MENU, FONT_ANCHOR_CENTERED, "LEVEL EDITOR");
    AddButtonToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 20, 200, 40,
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_MENU, OPT_NEW_LEVEL);
    AddButtonToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 70, 200, 40,
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_MENU, OPT_LOAD_LEVEL);
    AddButtonToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 120, 200, 40,
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_MENU, OPT_EXIT);

    // STRING PROMPT DIALOG
    uiGroupIndex = GROUP_STRING_PROMPT_DIALOG;
    AddTextToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT,
        FONT_MENU, FONT_ANCHOR_CENTERED, "Enter file name:");
    AddDrawingToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH - 150, HALF_SCREEN_HEIGHT + 20, HALF_SCREEN_WIDTH + 150, HALF_SCREEN_HEIGHT + 50, 
        DRAW_RECTANGLE_FILL, COLOR_BLACK, OPACITY_SOLID);
    AddDrawingToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH - 150, HALF_SCREEN_HEIGHT + 20, HALF_SCREEN_WIDTH + 150, HALF_SCREEN_HEIGHT + 50, 
        DRAW_RECTANGLE, COLOR_WHITE, OPACITY_SOLID);
    AddTextFieldToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT + 35,
        FONT_SYSTEM, FONT_ANCHOR_CENTERED, "", OPT_NEW_LEVEL_FILE_NAME);
    AddButtonToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 70, 200, 40,
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_MENU, OPT_NEW_LEVEL_FILE_NAME);
    AddButtonToUIGroup(uiGroupIndex,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 120, 200, 40,
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_MENU, OPT_MAIN_MENU);

    // EDITOR BG
    uiGroupIndex = GROUP_EDITOR_BG;
    AddDrawingToUIGroup(uiGroupIndex,
        0, 0, SCREEN_WIDTH - w - 1, unit * 5,
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 5, OPACITY_SOLID);
    AddDrawingToUIGroup(uiGroupIndex,
        SCREEN_WIDTH - w - 1, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 4, OPACITY_SOLID);
    // TOP BAR
    AddButtonToUIGroup(uiGroupIndex,
        unit / 2, unit / 2, (unit * 16), unit * 4,
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_SYSTEM, OPT_SAVE_LEVEL);
    AddButtonToUIGroup(uiGroupIndex,
        (unit * 17), unit / 2, (unit * 16), unit * 4,
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_SYSTEM, OPT_LOAD_LEVEL);
    AddButtonToUIGroup(uiGroupIndex,
        (unit / 2) + (unit * 33), unit / 2, (unit * 16), unit * 4,
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_SYSTEM, OPT_PALETTE_OBJECTS);
    AddButtonToUIGroup(uiGroupIndex,
        (unit * 50), unit / 2, (unit * 16), unit * 4,
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_SYSTEM, OPT_PALETTE_ENTITIES);
    // SIDE PANEL
    AddDrawingToUIGroup(uiGroupIndex,
        SCREEN_WIDTH - (w) - 1 + (unit / 2), (unit / 2), SCREEN_WIDTH - (unit / 2) - 1, h + (unit / 2), 
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 5, OPACITY_SOLID);
    AddDrawingToUIGroup(uiGroupIndex,
        SCREEN_WIDTH - (w) - 1 + (unit / 2), h + (unit) + (unit / 2), SCREEN_WIDTH - (unit / 2) - 1, SCREEN_HEIGHT - (unit / 2) - 1,
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 5, OPACITY_SOLID);
    // PALETTE
    AddDrawingToUIGroup(uiGroupIndex,
        SCREEN_WIDTH - (w / 2) - (unit * 2) + 1, h + (unit) + (unit / 2), SCREEN_WIDTH - (w / 2) - (unit * 2) + 1, SCREEN_HEIGHT - (unit / 2) - 1,
        DRAW_LINE, COLOR_BLUE - 6, OPACITY_SOLID);
    for (i = 1; i <= 3; ++i)
        AddDrawingToUIGroup(uiGroupIndex,
            SCREEN_WIDTH - (w) - 1 + (unit / 2), h + (unit) + (unit / 2) + (pbsize * i), SCREEN_WIDTH - (unit / 2) - 1, h + (unit) + (unit / 2) + (pbsize * i),
            DRAW_LINE, COLOR_BLUE - 6, OPACITY_SOLID);
    end
    // SCROLL BAR
    AddDrawingToUIGroup(uiGroupIndex,
        SCREEN_WIDTH - (unit * 4) - (unit / 2) - 1, h + (unit) + (unit / 2), SCREEN_WIDTH - (unit / 2) - 1, SCREEN_HEIGHT - (unit / 2) - 1,
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 6, OPACITY_SOLID);
    AddButtonToUIGroup(uiGroupIndex,
        SCREEN_WIDTH - (unit * 4) - (unit / 2) - 1, h + (unit) + (unit / 2), (unit * 4), (unit * 4),
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_SYSTEM, OPT_SCROLL_UP);
    AddButtonToUIGroup(uiGroupIndex,
        SCREEN_WIDTH - (unit * 4) - (unit / 2) - 1, SCREEN_HEIGHT - (unit * 4) - (unit / 2) - 1, (unit * 4), (unit * 4),
        COLOR_B_NORMAL, COLOR_B_HOVER, COLOR_B_PRESSED, COLOR_B_DISABLED,
        OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        FONT_SYSTEM, OPT_SCROLL_DOWN);
    // TODO: Split these out into their own UI groups.

    __uiGroupsCount = uiGroupIndex + 1;
end

process ButtonHandler()
begin
    alive = true;
    __ui.buttonClicked = NULL;
    __ui.buttonHeldDown = NULL;
    repeat
        if (__ui.buttonClicked != NULL)
            switch (__ui.buttonClicked)
                case OPT_NEW_LEVEL:
                    HideUIGroup(GROUP_MAIN_MENU);
                    ShowUIGroup(GROUP_STRING_PROMPT_DIALOG);
                end
                case OPT_MAIN_MENU:
                    HideUIGroup(GROUP_STRING_PROMPT_DIALOG);
                    ShowUIGroup(GROUP_MAIN_MENU);
                end
                case OPT_EXIT:
                    exit("", 0);
                end
                case OPT_NEW_LEVEL_FILE_NAME:
                    // TODO:
                    HideAllUIGroups();
                    ShowUIGroup(GROUP_EDITOR_BG);
                end
            end
            __ui.buttonClicked = NULL;
        end
        frame;
    until (alive == false)
end



                              /***************\
                              |* COMMON CODE *|
                              \***************/

/* -----------------------------------------------------------------------------
 * UI
 * ---------------------------------------------------------------------------*/
process UIRenderer()
begin
    alive = true;
    repeat
        RenderUIDrawings();
        RenderUITexts();
        RenderUITextFields();
        RenderUIImages();
        RenderUIButtons();
        frame;
        // TODO: Don't delete all, logging e.g. uses text that shouldn't be deleted.
        delete_draw(all_drawing);
        delete_text(all_text);
    until (alive == false)
end

function RenderUIDrawings()
private
    d;
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (d = 0; d < __uiGroups[i].drawingsCount; ++d)
            draw(
                __uiGroups[i].drawings[d].drawType,
                __uiGroups[i].drawings[d].color,
                __uiGroups[i].drawings[d].opacity,
                REGION_FULL_SCREEN,
                __uiGroups[i].drawings[d].x0,
                __uiGroups[i].drawings[d].y0,
                __uiGroups[i].drawings[d].x1,
                __uiGroups[i].drawings[d].y1);
        end
    end
end

function RenderUITexts()
private
    t;
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (t = 0; t < __uiGroups[i].textsCount; ++t)
            write(
                __fonts[__uiGroups[i].texts[t].fontIndex].handle,
                __uiGroups[i].texts[t].x,
                __uiGroups[i].texts[t].y,
                __uiGroups[i].texts[t].anchor,
                __uiGroups[i].texts[t].text);
        end
    end
end

function RenderUITextFields()
private
    t;
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (t = 0; t < __uiGroups[i].textFieldsCount; ++t)
            __uiGroups[i].textFields[t].text = UpdateTextField(__uiGroups[i].textFields[t].text);
            if (__uiGroups[i].textFields[t].text == "")
                write(
                    __fonts[__uiGroups[i].textFields[t].fontIndex].handle,
                    __uiGroups[i].textFields[t].x,
                    __uiGroups[i].textFields[t].y,
                    __uiGroups[i].textFields[t].anchor,
                    "...");
            else
                write(
                    __fonts[__uiGroups[i].textFields[t].fontIndex].handle,
                    __uiGroups[i].textFields[t].x,
                    __uiGroups[i].textFields[t].y,
                    __uiGroups[i].textFields[t].anchor,
                    __uiGroups[i].textFields[t].text);
                if (scan_code == _enter)
                    __ui.buttonClicked = __uiGroups[i].textFields[t].option;
                end
            end
        end
    end
end

function UpdateTextField(string text)
private
    code;
begin
    code = ValidateAsciiCode(ascii);    
    if (code != 0)
        strcat(text, ascii);
    end
    if (text != "")
        if (scan_code == _backspace)
            strdel(text, 0, 1);
        end
    end
    return (text);
end

function RenderUIImages()
private
    j;
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (j = 0; j < __uiGroups[i].imagesCount; ++j)
            RenderImageOneFrame(
                __uiGroups[i].images[j].x,
                __uiGroups[i].images[j].y,
                __uiGroups[i].images[j].z,
                __uiGroups[i].images[j].fileIndex,
                __uiGroups[i].images[j].gfxIndex,
                __uiGroups[i].images[j].angle,
                __uiGroups[i].images[j].size);
        end
    end
end

process RenderImageOneFrame(x, y, z, fileIndex, gfxIndex, angle, size)
begin
    SetGraphic(fileIndex, gfxIndex);
    frame;
end

function RenderUIButtons()
private
    b;
    w, h;
    c, o;
    hover = false;
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (b = 0; b < __uiGroups[i].buttonsCount; ++b)
            x = __uiGroups[i].buttons[b].x;
            y = __uiGroups[i].buttons[b].y;
            w = __uiGroups[i].buttons[b].width;
            h = __uiGroups[i].buttons[b].height;
            c = __uiGroups[i].buttons[b].colorNormal;
            o = __uiGroups[i].buttons[b].opacityNormal;

            if (RectangleContainsPoint(x, y, x + w, y + h, mouse.x, mouse.y))
                if (hover == false)
                    c = __uiGroups[i].buttons[b].colorHover;
                    o = __uiGroups[i].buttons[b].opacityHover;
                    hover = true;
                end
            else
                if (hover == true)
                    c = __uiGroups[i].buttons[b].colorNormal;
                    o = __uiGroups[i].buttons[b].opacityNormal;
                    hover = false;
                end
            end

            if (hover)
                if (mouse.left)
                    c = __uiGroups[i].buttons[b].colorPressed;
                    o = __uiGroups[i].buttons[b].opacityPressed;
                    __ui.buttonHeldDown = __uiGroups[i].buttons[b].option;
                end
                if (!mouse.left && __ui.buttonHeldDown == __uiGroups[i].buttons[b].option)
                    c = __uiGroups[i].buttons[b].colorHover;
                    o = __uiGroups[i].buttons[b].opacityHover;
                    __ui.buttonHeldDown = NULL;
                    __ui.buttonClicked = __uiGroups[i].buttons[b].option;
                end
            else
                if (__ui.buttonHeldDown == __uiGroups[i].buttons[b].option)
                    __ui.buttonHeldDown = NULL;
                end
            end

            draw(DRAW_RECTANGLE_FILL, c, o, REGION_FULL_SCREEN, x, y, x + w, y + h);

            if (__uiGroups[i].buttons[b].option == NULL)
                __uiGroups[i].buttons[b].text = "[NULL]";
            else
                __uiGroups[i].buttons[b].text = __uiOptions[__uiGroups[i].buttons[b].option].label;
            end

            write(
                __fonts[__uiGroups[i].buttons[b].fontIndex].handle,
                x + (w / 2),
                y + (h / 2),
                FONT_ANCHOR_CENTERED,
                __uiGroups[i].buttons[b].text);
        end
    end
end

function AddDrawingToUIGroup(ui, x0, y0, x1, y1, drawType, color, opacity)
begin
    i = __uiGroups[ui].drawingsCount;
    __uiGroups[ui].drawings[i].x0 = x0;
    __uiGroups[ui].drawings[i].y0 = y0;
    __uiGroups[ui].drawings[i].x1 = x1;
    __uiGroups[ui].drawings[i].y1 = y1;
    __uiGroups[ui].drawings[i].drawType = drawType;
    __uiGroups[ui].drawings[i].color = color;
    __uiGroups[ui].drawings[i].opacity = opacity;
    __uiGroups[ui].drawingsCount++;
end

function AddTextToUIGroup(ui, x, y, fontIndex, anchor, text)
begin
    i = __uiGroups[ui].textsCount;
    __uiGroups[ui].texts[i].x = x;
    __uiGroups[ui].texts[i].y = y;
    __uiGroups[ui].texts[i].fontIndex = fontIndex;
    __uiGroups[ui].texts[i].anchor = anchor;
    __uiGroups[ui].texts[i].text = text;
    __uiGroups[ui].textsCount++;
end

function AddTextFieldToUIGroup(ui, x, y, fontIndex, anchor, text, option)
begin
    i = __uiGroups[ui].textFieldsCount;
    __uiGroups[ui].textFields[i].x = x;
    __uiGroups[ui].textFields[i].y = y;
    __uiGroups[ui].textFields[i].fontIndex = fontIndex;
    __uiGroups[ui].textFields[i].anchor = anchor;
    __uiGroups[ui].textFields[i].text = text;
    __uiGroups[ui].textFields[i].option = option;
    __uiGroups[ui].textFieldsCount++;
end

function AddImageToUIGroup(ui, x, y, z, fileIndex, gfxIndex, angle, size)
begin
    i = __uiGroups[ui].imagesCount;
    __uiGroups[ui].images[i].x = x;
    __uiGroups[ui].images[i].y = y;
    __uiGroups[ui].images[i].z = z;
    __uiGroups[ui].images[i].fileIndex = fileIndex;
    __uiGroups[ui].images[i].gfxIndex = gfxIndex;
    __uiGroups[ui].images[i].angle = angle;
    __uiGroups[ui].images[i].size = size;
    __uiGroups[ui].imagesCount++;
end

function AddButtonToUIGroup(ui, x, y, width, height,
    colorNormal, colorHover, colorPressed, colorDisabled,
    opacityNormal, opacityHover, opacityPressed, opacityDisabled,
    fontIndex, option)
begin
    i = __uiGroups[ui].buttonsCount;
    __uiGroups[ui].buttons[i].x = x;
    __uiGroups[ui].buttons[i].y = y;
    __uiGroups[ui].buttons[i].width = width;
    __uiGroups[ui].buttons[i].height = height;
    __uiGroups[ui].buttons[i].colorNormal = colorNormal;
    __uiGroups[ui].buttons[i].colorHover = colorHover;
    __uiGroups[ui].buttons[i].colorPressed = colorPressed;
    __uiGroups[ui].buttons[i].colorDisabled = colorDisabled;
    __uiGroups[ui].buttons[i].opacityNormal = opacityNormal;
    __uiGroups[ui].buttons[i].opacityHover = opacityHover;
    __uiGroups[ui].buttons[i].opacityPressed = opacityPressed;
    __uiGroups[ui].buttons[i].opacityDisabled = opacityDisabled;
    __uiGroups[ui].buttons[i].fontIndex = fontIndex;
    __uiGroups[ui].buttons[i].option = option;
    __uiGroups[ui].buttonsCount++;
end

function ShowUIGroup(uiGroupIndex)
begin
    __uiGroups[uiGroupIndex].visible = true;
end

function HideUIGroup(uiGroupIndex)
begin
    // reset text fields
    for (i = 0; i < __uiGroups[uiGroupIndex].textFieldsCount; ++i)
        __uiGroups[uiGroupIndex].textFields[i].text = "";
    end
    __uiGroups[uiGroupIndex].visible = false;
end

function HideAllUIGroups()
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        HideUIGroup(i);
    end
end

function GetNextFreeUIGroupIndex()
begin
    for (i = 0; i < MAX_UI_GROUPS; i++)
        if (__uiGroups[i].processId <= 0)
            return (i);
        end
    end
    return (NULL);
end

process MouseCursor()
begin
    // initialization
    resolution = GPR;
    SetGraphic(GFX_MAIN, 303);
    z = -1000;
    loop
        x = mouse.x * GPR;
        y = mouse.y * GPR;
        frame;
    end
end

// TODO: Remove old code.
/*
process SegmentRenderer(x0, y0, x1, y1, lineColor, lineOpacity, pointColor, pointOpacity, pointRadius)
private
    drawLine = NULL;
    drawPoint0 = NULL;
    drawPoint1 = NULL;
begin
    // initialization
    alive = true;

    // ui
    drawLine = DrawRenderer(
        x0, y0, x1, y1, DRAW_LINE, lineColor, lineOpacity);
    drawPoint0 = DrawRenderer(
        x0 - pointRadius, y0 - pointRadius, x0 + pointRadius, y0 + pointRadius, DRAW_ELLIPSE, pointColor, pointOpacity);
    drawPoint1 = DrawRenderer(
        x1 - pointRadius, y1 - pointRadius, x1 + pointRadius, y1 + pointRadius, DRAW_ELLIPSE, pointColor, pointOpacity);

    repeat
        if (ui.needsUpdate == true)
            drawLine.ui.needsUpdate = true;
            drawPoint0.ui.needsUpdate = true;
            drawPoint1.ui.needsUpdate = true;
            ui.needsUpdate = false;
        end
        frame;
    until (alive == false)

    drawLine.alive = false;
    drawPoint0.alive = false;
    drawPoint1.alive = false;
end
*/



/* -----------------------------------------------------------------------------
 * Initialization
 * ---------------------------------------------------------------------------*/
function InitGraphics()
begin
    set_mode(SCREEN_MODE);
    set_fps(60, 1);
end

function LoadResources()
begin
    for (i = 0; i < GFX_COUNT; ++i)
        __graphics[i].handle = load_fpg(__graphics[i].path);
    end

    for (i = 0; i < FONT_COUNT; ++i)
        if (__fonts[i].path != NULL)
            __fonts[i].handle = load_fnt(__fonts[i].path);
        else
            __fonts[i].handle = 0;
        end
    end

    for (i = 0; i < SOUND_COUNT; ++i)
        __sounds[i].handle = load_sound(__sounds[i].path, __sounds[i].playback);
    end
end



/* -----------------------------------------------------------------------------
 * Process functions
 * ---------------------------------------------------------------------------*/
function SetGraphic(fileIndex, gfxIndex)
begin
    father.file = __graphics[GFX_MAIN].handle;
    father.graph = gfxIndex;
end



/* -----------------------------------------------------------------------------
 * Math functions
 * ---------------------------------------------------------------------------*/
function RectangleContainsPoint(x0, y0, x1, y1, pointX, pointY)
begin
    return (pointX >= x0 && pointX <= x1 && pointY >= y0 && pointY <= y1);
end

// TODO: Write CircleContainsPoint().

function VectorNormalize(pointer vX, pointer vY, multiplier)
private
    magnitude;
begin
    x = *vX;
    y = *vY;

    magnitude = VectorMagnitude(*vX, *vY);

    if (magnitude == 0)
        return;
    end

    *vX = (*vX * multiplier) / magnitude;
    *vY = (*vY * multiplier) / magnitude;
end

function VectorMagnitude(vX, vY)
begin
    return (sqrt((vX * vX) + (vY * vY)));
end

function WrapAngle360(val)
begin
    return (((val % 360000) + 360000) % 360000);
end

function WrapAngle180(val)
begin
    val = val % 360000;
    if (val < -180000)
        val += 360000;
    else
        if (val > 180000)
            val -= 360000;
        end
    end
    return (val);
end

function Min(a, b)
begin
    if (a > b)
        return (b);
    end
    return (a);
end

function Max(a, b)
begin
    if (a >= b)
        return (a);
    end
    return (b);
end

function LineIntersection(x0, y0, x1, y1, x2, y2, x3, y3)
private
    rx, ry;
    sx, sy;
    qx, qy;
    qxr;
    qxs;
    rxs;
    u, t;
    precision = 100;
begin
    rx = x1 - x0;
    ry = y1 - y0;
    sx = x3 - x2;
    sy = y3 - y2;
    qx = x2 - x0;
    qy = y2 - y0;
    qxr = PerpProduct(qx, qy, rx, ry);
    rxs = PerpProduct(rx, ry, sx, sy);

    // Collinear cases.
    if (qxr == 0 && rxs == 0)
        // Equal points = touching end of line segment.
        if ((x0 == x2 && y0 == y2) 
            || (x0 == x3 && y0 == y3) 
            || (x1 == x2 && y1 == y2) 
            || (x1 == x3 && y1 == y3))
            return (true);
        end

        return (!((x2 - x0 < 0) == (x2 - x1 < 0) == (x3 - x0 < 0) == (x3 - x1 < 0)) 
            || !((y2 - y0 < 0) == (y2 - y1 < 0) == (y3 - y0 < 0) == (y3 - y1 < 0)));
    end

    // Parallel case.
    if (rxs == 0)
        return (false);
    end

    // Skew cases.
    qxs = PerpProduct(qx, qy, sx, sy);
    u = (qxr * precision) / rxs;
    t = (qxs * precision) / rxs;

    // Intersecting.
    if ((t >= 0) && (t <= precision) && (u >= 0) && (u <= precision))
        // Intersection point.
        __physics.lineIntersectionData.ix = x0 + ((t * rx) / precision);
        __physics.lineIntersectionData.iy = y0 + ((t * ry) / precision);
        return (true);
    end

    // Non-intersecting.
    __physics.lineIntersectionData.ix = 0;
    __physics.lineIntersectionData.iy = 0;
    return (false);
end

function PerpProduct(x0, y0, x1, y1)
begin
    return ((x0 * y1) - (y0 * x1));
end

function CycleValue(val, min, max)
begin
    val++;
    if (val > max)
        return (min);
    end
    return (val);
end

function WrapValue(val, min, max)
begin
    return (Max(Min(val, min), max));
end



/* -----------------------------------------------------------------------------
 * Logging
 * ---------------------------------------------------------------------------*/
function LogValue(string label, val)
begin
    LogValueBase(father, label, val, false);
end

function LogValueFollow(processId, string label, val)
begin
    return (LogValueFollowOffset(processId, label, val, 1, 0));
end

process LogValueFollowOffset(processId, string label, val, xOffset, yOffset)
begin
    i = GetNextLocalLogIndex(processId);
    LogValueBase(processId, label, val, true);
    loop
        x = (processId.x / GPR) + xOffset;
        y = (processId.y / GPR) + (i * __logging.yOffset) + yOffset;
        if (processId.ctype == c_scroll)
            x -= scroll[0].x0;
            y -= scroll[0].y0;
        end
        move_text(processId.logging.logs[i].txtLabel, x, y);
        move_text(processId.logging.logs[i].txtVal, x, y);
        frame;
    end
end

process LogValueBase(processId, string label, val, follow)
private
    txtLabel;
    txtVal;
begin
    if (follow)
        i = GetNextLocalLogIndex(processId);
        processId.logging.logs[i].logId = father;
        processId.logging.logCount++;
    else
        x = __logging.x;
        y = __logging.y + (__logging.logCount * __logging.yOffset);
        i = GetNextGlobalLogIndex();
        __logging.logs[i].logId = id;
        __logging.logCount++;
    end

    label = label + ": ";
    txtLabel = write(
        __fonts[FONT_SYSTEM].handle,
        x,
        y,
        FONT_ANCHOR_TOP_RIGHT,
        label);
    txtVal = write_int(
        __fonts[FONT_SYSTEM].handle,
        x,
        y,
        FONT_ANCHOR_TOP_LEFT,
        val);

    if (follow)
        processId.logging.logs[i].txtLabel = txtLabel;
        processId.logging.logs[i].txtVal = txtVal;
    else
        __logging.logs[i].txtLabel = txtLabel;
        __logging.logs[i].txtVal = txtVal;
    end
    loop
        frame;
    end
end

function DeleteGlobalLog()
begin
    __logging.logCount--;
    delete_text(__logging.logs[__logging.logCount].txtLabel);
    delete_text(__logging.logs[__logging.logCount].txtVal);
    signal(__logging.logs[__logging.logCount].logId, s_kill_tree);
end

function DeleteLocalLog(processId)
begin
    i = --processId.logging.logCount;
    delete_text(processId.logging.logs[i].txtLabel);
    delete_text(processId.logging.logs[i].txtVal);
    signal(processId.logging.logs[i].logId, s_kill_tree);
end

function GetNextGlobalLogIndex()
begin
    for (i = 0; i < MAX_GLOBAL_LOGS; i++)
        if (__logging.logs[i].logId <= 0)
            return (i);
        end
    end
    return (NULL);
end

function GetNextLocalLogIndex(processId)
begin
    for (i = 0; i < MAX_LOCAL_LOGS; i++)
        if (processId.logging.logs[i].logId <= 0)
            return (i);
        end
    end
    return (NULL);
end

function CleanUpLocalLogs(processId)
begin
    for (i = 0; i < processId.logging.logCount; ++i)
        DeleteLocalLog(processId);
    end
end



/* -----------------------------------------------------------------------------
 * Timing
 * ---------------------------------------------------------------------------*/
process DeltaTimer()
private
    t0;
    t1;
begin
    LogValue("__timing.deltaTime", &__timing.deltaTime);
    loop
        t0 = timer[0];
        frame;
        t1 = timer[0];
        __timing.deltaTime = Max(t1 - t0, 1); // NOTE: timing.deltaTime can never be 0, hence Max()
    end
end

process LifeTimer(lifeDuration)
private
    lifeStartTime;
begin
    lifeStartTime = timer[0];
    repeat
        frame;
    until (timer[0] > lifeStartTime + lifeDuration)
    signal(father, s_kill);
end

function Delay(processId, delayLength)
begin
    i = GetDelayIndex(processId);
    if (i == NULL)
        i = FindFreeTableIndex(&__timing.delays, MAX_DELAYS - 1);
        __timing.delays[i].processId = processId;
        __timing.delays[i].startTime = timer[0];
        __timing.delays[i].delayLength = delayLength;
        __timing.delayCount++;
    end
    if (timer[0] > __timing.delays[i].startTime + __timing.delays[i].delayLength)
        __timing.delayCount--;
        __timing.delays[i].processId = NULL;
        __timing.delays[i].startTime = NULL;
        __timing.delays[i].delayLength = NULL;
        return (false);
    end
    return (true);
end

function GetDelayIndex(processId)
begin
    // TODO: This might be a performance problem... need a hash map.
    for (i = 0; i < MAX_DELAYS; i++)
        if (__timing.delays[i].processId == processId)
            return (i);
        end
    end
    return (NULL);
end

function GetNextFreeDelayIndex()
begin
    for (i = 0; i < MAX_DELAYS; i++)
        if (__timing.delays[i].processId <= 0)
            return (i);
        end
    end
    return (NULL);
end



/* -----------------------------------------------------------------------------
 * Audio
 * ---------------------------------------------------------------------------*/
process PlaySound(soundIndex, volume, frequency)
begin
    sound(__sounds[soundIndex], volume, frequency);
end

process PlaySoundWithDelay(soundIndex, volume, frequency, delay)
begin
    while (Delay(id, delay))
        frame;
    end
    PlaySound(soundIndex, volume, frequency);
end



/* -----------------------------------------------------------------------------
 * Tables
 * ---------------------------------------------------------------------------*/
function InitializeTable(pointer tablePtr, tableSize, initialValue)
begin
    for (i = 0; i < tableSize; ++i)
        tablePtr[i] = initialValue;
    end
end

function FindFreeTableIndex(pointer tablePtr, tableSize)
begin
    for (i = 0; i < tableSize; ++i)
        if (tablePtr[i] == NULL)
            return (i);
        end
    end
    return (NULL);
end



/* -----------------------------------------------------------------------------
 * Strings and text
 * ---------------------------------------------------------------------------*/
function ValidateAsciiCode(code)
begin
    // 0-9
    if (code >= 48 && code <= 57)
        return (code);
    end
    // A-Z
    if (code >= 65 && code <= 90)
        return (code);
    end
    // a-z
    if (code >= 97 && code <= 122)
        return (code);
    end
    // -._
    if (code == 45 || code == 46 || code == 95)
        return (code);
    end
    return (0);
end


