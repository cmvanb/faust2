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
    // DIV constants
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
    FLAG_NORMAL               = 0;
    FLAG_FLIP_X               = 1;
    FLAG_FLIP_Y               = 2;
    FLAG_FLIP_X_Y             = 3;
    FLAG_TRANSPARENT          = 4;
    FLAG_TRANSPARENT_FLIP_X   = 5;
    FLAG_TRANSPARENT_FLIP_Y   = 6;
    FLAG_TRANSPARENT_FLIP_X_Y = 7;
    MAX_GFX_POINTS = 1000;

    // common values
    NULL = -1;
    DISABLED = false;
    ENABLED  = true;
    INACTIVE = false;
    ACTIVE   = true;

    // resource indices
    GFX_MAIN    = 0;
    GFX_ACTORS  = 1;
    GFX_ITEMS   = 2;
    GFX_OBJECTS = 3;
    GFX_UI      = 4;
    FONT_SYSTEM = 0;
    FONT_MENU   = 1;
    SOUND_MP40_SHOT       = 0;
    SOUND_SHELL_DROPPED_1 = 1;
    SOUND_SHELL_DROPPED_2 = 2;
    SOUND_SHELL_DROPPED_3 = 3;
    SOUND_KAR98K_SHOT     = 4;

    // resource counts
    GFX_COUNT   = 5;
    FONT_COUNT  = 2;
    SOUND_COUNT = 5;

    // file paths
    DATA_OBJECTS_PATH = "assets/data/objects/";
    DATA_LEVELS_PATH  = "assets/data/levels/";
    MAX_OBJECT_DATA = 256;
    MAX_LEVEL_FILES = 18;

    // graphics settings
    SCREEN_MODE        = m640x400;
    SCREEN_WIDTH       = 640;
    SCREEN_HEIGHT      = 400;
    HALF_SCREEN_WIDTH  = SCREEN_WIDTH / 2;
    HALF_SCREEN_HEIGHT = SCREEN_HEIGHT / 2;

    // game process resolution
    GPR = 10;

    // regions
    REGION_FULL_SCREEN     = 0;
    REGION_EDITOR_VIEWPORT = 1;
    REGION_COUNT           = 2;

    // camera
    CAMERA_MOVE_FREE_LOOK   = 0;
    CAMERA_MOVE_PLAYER_LOOK = 1;
    CAMERA_FREE_LOOK_MAX_SPEED = 5 * GPR;

    // physics
    PHYSICS_MAX_MOVE_SPEED = 10 * GPR;

    // timing
    MAX_DELAYS = 32;

    // logging
    MAX_GLOBAL_LOGS = 32;
    MAX_LOCAL_LOGS = 8;

    // debug mode
    DEBUG_MODE = true;

    // ui
    MAX_UI_DRAWINGS = 128;
    MAX_UI_TEXTS    = 128;
    MAX_UI_GROUPS = 16;
    MAX_UI_GROUP_BUTTONS    = 32;
    MAX_UI_GROUP_CHECKBOXES = 8;
    MAX_UI_GROUP_DIALS      = 8;
    MAX_UI_GROUP_DRAWINGS   = 32;
    MAX_UI_GROUP_TEXTS      = 32;
    MAX_UI_GROUP_IMAGES     = 16;
    UI_Z_ABOVE = -512;
    UI_Z_UNDER = 0;

    // level
    MAX_LEVEL_OBJECTS  = 100;
    MATERIAL_CONCRETE = 0;
    MATERIAL_WOOD     = 1;
    MATERIAL_METAL    = 2;
    MATERIAL_COUNT = 3;

    // ui
    UI_UNIT = 4;
    UI_DIAL_DEAD_ZONE_WIDTH = UI_UNIT / 2;
    UI_DIAL_SLOW_ZONE_WIDTH = UI_UNIT * 8;

    // ui colors
    COLOR_SCHEME_BLUE  = 0;
    COLOR_SCHEME_BLACK = 1;
    COLOR_SCHEME_COUNT = 2;

    // EDITOR SPECIFIC ---------------------------------------------------------
    // editor ui
    UI_PW    = SCREEN_WIDTH / 4;
    UI_PX    = SCREEN_WIDTH - UI_PW;
    UI_PAL_Y = SCREEN_HEIGHT / 3;
    UI_EDITOR_PALETTE_SIZE = 8;
    UI_EDITOR_VIEW_MODE          = 0;
    UI_EDITOR_OBJECT_BRUSH_MODE  = 1;
    UI_EDITOR_ENTITY_BRUSH_MODE  = 2;
    UI_EDITOR_TERRAIN_BRUSH_MODE = 3;
    UI_EDITOR_OBJECT_EDIT_MODE   = 4;

    // ui actions
    ACT_GOTO_NEW_LEVEL          = 0;
    ACT_GOTO_LOAD_LEVEL         = 1;
    ACT_GOTO_MAIN_MENU          = 2;
    ACT_EXIT_APP                = 3;
    ACT_CREATE_NEW_LEVEL        = 4;
    ACT_SAVE_LEVEL              = 5;
    ACT_LOAD_LEVEL              = 6;
    ACT_GOTO_VIEW_MODE          = 7;
    ACT_GOTO_OBJECT_BRUSH_MODE  = 8;
    ACT_GOTO_ENTITY_BRUSH_MODE  = 9;
    ACT_GOTO_TERRAIN_BRUSH_MODE = 10;
    ACT_GOTO_OBJECT_EDITOR      = 11;
    ACT_SCROLL_PALETTE_UP       = 12;
    ACT_SCROLL_PALETTE_DOWN     = 13;
    ACT_SELECT_PALETTE          = 14; // 14 ~ 21 = 8
    ACT_SEARCH_PALETTE          = 22;
    ACT_SET_OBJECT_NAME         = 23;
    ACT_NEW_OBJECT              = 24;
    ACT_EDIT_OBJECT             = 25;
    ACT_SAVE_OBJECT             = 26;
    ACT_DISCARD_OBJECT          = 27;
    ACT_DELETE_OBJECT           = 28;
    ACT_SELECT_LEVEL            = 29; // 29 ~ 46 = 18
    UI_ACTION_COUNT = 47;

    // ui text fields
    TF_LEVEL_FILE_NAME  = 0;
    TF_OBJECT_FILE_NAME = 1;
    TF_PALETTE_SEARCH   = 2;
    UI_TEXTFIELD_COUNT = 3;

    // ui groups
    GROUP_MAIN_BG               = 0;
    GROUP_MAIN_MENU             = 1;
    GROUP_STRING_PROMPT_DIALOG  = 2;
    GROUP_LOAD_LEVEL_DIALOG     = 3;
    GROUP_EDITOR_BG             = 4;
    GROUP_EDITOR_PALETTE        = 5;
    GROUP_EDITOR_INFO           = 6;
    GROUP_OBJECT_EDITOR_BG      = 7;
    GROUP_OBJECT_EDITOR_BUTTONS = 8;
    GROUP_OBJECT_EDITOR_WIDGETS = 9;

/* -----------------------------------------------------------------------------
 * Global variables
 * ---------------------------------------------------------------------------*/
global
    // graphics
    struct __regions[REGION_COUNT - 1]
        x, y, width, height;
    end =
    //  x  y   width         height
        0, 0,  SCREEN_WIDTH, SCREEN_HEIGHT,
        0, 20, 480,          380;

    struct __gfxPoints[MAX_GFX_POINTS - 1]
        x, y;
    end

    // resources
    struct __graphics[GFX_COUNT - 1]
        handle;
        string path;
    end =
    //  handle  path
        NULL,   "assets/graphics/main.fpg",
        NULL,   "assets/graphics/actors.fpg",
        NULL,   "assets/graphics/items.fpg",
        NULL,   "assets/graphics/objects.fpg",
        NULL,   "assets/graphics/ui.fpg";

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

    // color schemes
    struct __colorSchemes[COLOR_SCHEME_COUNT - 1]
        struct color
            normal, hover, pressed, disabled, highlight;
        end
        struct opacity
            normal, hover, pressed, disabled, highlight;
        end
    end = 
    //  normal           hover            pressed          disabled        highlight    normal         hover          pressed        disabled       highlight
        COLOR_BLUE,      COLOR_BLUE + 3,  COLOR_BLUE - 1,  COLOR_GREY - 5, COLOR_WHITE, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID,
        COLOR_BLACK + 1, COLOR_BLACK + 4, COLOR_BLACK,     COLOR_GREY - 5, COLOR_WHITE, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID, OPACITY_SOLID;

    // camera
    struct __camera
        processId;
        targetId;
        moveMode;
    end =
    //  processId  targetId  moveMode
        NULL,      NULL,     CAMERA_MOVE_FREE_LOOK;

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
    end =
    //  x    y   yOffset
        320, 10, 15;

    // level
    __levelFileDataCount;
    struct __levelFileData[MAX_LEVEL_FILES - 1]
        string name;
    end

    struct __levelData
        string name;
        objectCount;
        struct objects[MAX_LEVEL_OBJECTS - 1]
            x, y, angle, size, z;
            objectDataFileName;
            objectDataIndex;
            processId;
        end
    end

    // object
    __objectDataCount;
    struct __objectData[MAX_OBJECT_DATA - 1]
        string name;
        angle, size, z;
        gfxIndex, material, collidable;
        pointsCount;
    end

    // mouse
    struct __mouse
        leftClicked;
        leftHeldDown;
        rightClicked;
        rightHeldDown;
    end

    // ui
    struct __ui
        action;
        actionParam0;
        buttonHeldDown;
        buttonClicked;
        activeTextFieldId;
        submittedTextFieldId;
        submittedText;
        struct dial
            active;
            state;
            uiGroupIndex;
            dialIndex;
            clickX;
        end
        drawingsCount;
        struct drawings[MAX_UI_DRAWINGS - 1]
            handle;
        end
        textsCount;
        struct texts[MAX_UI_TEXTS - 1]
            handle;
        end
    end

    __uiGroupsCount;
    struct __uiGroups[MAX_UI_GROUPS - 1]
        visible;
        buttonsCount;
        struct buttons[MAX_UI_GROUP_BUTTONS - 1]
            x, y, width, height;
            colorScheme;
            fontIndex, action;
            enabled;
            string text;
        end
        checkboxesCount;
        struct checkboxes[MAX_UI_GROUP_CHECKBOXES - 1]
            x, y;
            colorScheme;
            var;
            enabled;
        end
        dialsCount;
        struct dials[MAX_UI_GROUP_DIALS - 1]
            x, y;
            colorScheme;
            fontIndex;
            var;
            varMin;
            varMax;
            varWrapValue;
            delaySlow, delayFast;
            deltaSlow, deltaFast;
            enabled;
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
            isInteger;
            string text;
            var;
        end
        textFieldsCount;
        struct textFields[MAX_UI_GROUP_TEXTS - 1]
            textFieldId;
            x, y, width, height;
            colorScheme;
            fontIndex, anchor;
            active, enabled;
            string text;
        end
        imagesCount;
        struct images[MAX_UI_GROUP_IMAGES - 1]
            x, y, z;
            fileIndex, gfxIndex, angle, size, flags;
        end
    end

    // EDITOR SPECIFIC ---------------------------------------------------------
    struct __uiEditor
        palettePage;
        mode;
        struct brush
            dataIndex;
            angleOffset;
            sizeOffset;
            zOffset;
        end
        struct object
            dirty;
            struct edit
                string name;
                angle, size, z;
                gfxIndex, material, collidable;
            end
            struct saved
                string name;
                angle, size, z;
                gfxIndex, material, collidable;
            end
            struct hover
                processId;
            end
            struct selected
                processId;
                string name;
            end
        end
    end

    struct __uiButtons[UI_ACTION_COUNT - 1]
        action;
        string label;
    end =
    //  action                       label
        ACT_GOTO_NEW_LEVEL,          "NEW LEVEL",       
        ACT_GOTO_LOAD_LEVEL,         "LOAD LEVEL",      
        ACT_GOTO_MAIN_MENU,          "CANCEL",          
        ACT_EXIT_APP,                "EXIT",            
        ACT_CREATE_NEW_LEVEL,        "SUBMIT",          
        ACT_SAVE_LEVEL,              "SAVE LEVEL",      
        ACT_LOAD_LEVEL,              "LOAD LEVEL",      
        ACT_GOTO_VIEW_MODE,          "VIEW MODE",       
        ACT_GOTO_OBJECT_BRUSH_MODE,  "OBJECTS",         
        ACT_GOTO_ENTITY_BRUSH_MODE,  "ENTITIES",        
        ACT_GOTO_TERRAIN_BRUSH_MODE, "TERRAIN",         
        ACT_GOTO_OBJECT_EDITOR,      "OBJ EDITOR",      
        ACT_SCROLL_PALETTE_UP,       "^",               
        ACT_SCROLL_PALETTE_DOWN,     "v",               
        ACT_SELECT_PALETTE,          "",                
        ACT_SELECT_PALETTE + 1,      "",                
        ACT_SELECT_PALETTE + 2,      "",                
        ACT_SELECT_PALETTE + 3,      "",                
        ACT_SELECT_PALETTE + 4,      "",                
        ACT_SELECT_PALETTE + 5,      "",                
        ACT_SELECT_PALETTE + 6,      "",                
        ACT_SELECT_PALETTE + 7,      "",                
        ACT_SEARCH_PALETTE,          "SEARCH",          
        ACT_SET_OBJECT_NAME,         "",
        ACT_NEW_OBJECT,              "NEW OBJECT",            
        ACT_EDIT_OBJECT,             "EDIT",      
        ACT_SAVE_OBJECT,             "SAVE CHANGES",    
        ACT_DISCARD_OBJECT,          "DISCARD CHANGES",
        ACT_DELETE_OBJECT,           "DELETE",
        ACT_SELECT_LEVEL,            "0",
        ACT_SELECT_LEVEL + 1,        "1",
        ACT_SELECT_LEVEL + 2,        "2",
        ACT_SELECT_LEVEL + 3,        "3",
        ACT_SELECT_LEVEL + 4,        "4",
        ACT_SELECT_LEVEL + 5,        "5",
        ACT_SELECT_LEVEL + 6,        "6",
        ACT_SELECT_LEVEL + 7,        "7",
        ACT_SELECT_LEVEL + 8,        "8",
        ACT_SELECT_LEVEL + 9,        "9",
        ACT_SELECT_LEVEL + 10,       "10",
        ACT_SELECT_LEVEL + 11,       "11",
        ACT_SELECT_LEVEL + 12,       "12",
        ACT_SELECT_LEVEL + 13,       "13",
        ACT_SELECT_LEVEL + 14,       "14",
        ACT_SELECT_LEVEL + 15,       "15",
        ACT_SELECT_LEVEL + 16,       "16",
        ACT_SELECT_LEVEL + 17,       "17";

    struct __uiTextFields[UI_TEXTFIELD_COUNT - 1]
        textFieldId;
        action;
    end =
    //  textFieldId          action
        TF_LEVEL_FILE_NAME,  ACT_CREATE_NEW_LEVEL,
        TF_OBJECT_FILE_NAME, ACT_SET_OBJECT_NAME,
        TF_PALETTE_SEARCH,   ACT_SEARCH_PALETTE;



/* -----------------------------------------------------------------------------
 * Local variables (every process gets these)
 * ---------------------------------------------------------------------------*/
local
    // general purpose
    alive;
    i;

    // component references
    struct components
        animator;
        faction;
        health;
        input;
        inventory;
        physics;
    end
    value; // A value held by a component. What this holds is determined by the individual component.

    // actor input component
    struct input
        attackingPreviousFrame;
        attacking;
        reloading;
        struct move
            x, y;
            granularity;
            walk;
        end
        struct lookAt
            x, y;
        end
    end

    // actor physics component
    struct physics
        walkSpeed;
        runSpeed;
        targetMoveSpeed;
        struct velocity
            x, y;
        end
    end

    // logging
    struct logging
        logCount;
        struct logs[MAX_LOCAL_LOGS - 1]
            logId;
            txtLabel;
            txtVal;
        end
    end



/* -----------------------------------------------------------------------------
 * Main program
 * ---------------------------------------------------------------------------*/
begin
    // setup
    InitGraphics();
    LoadResources();
    LoadData();

    // ui vars
    __uiEditor.object.hover.processId = NULL;
    __uiEditor.object.selected.processId = NULL;

    // ui config
    ConfigureUI();

    // ui processes
    UIController();
    UIRenderer();
    MouseCursor();
    EditorActionHandler();

    // ui main menu
    ShowUIGroup(GROUP_MAIN_BG);
    ShowUIGroup(GROUP_MAIN_MENU);
end



    // EDITOR SPECIFIC ---------------------------------------------------------
/* -----------------------------------------------------------------------------
 * Level Editor functionality
 * ---------------------------------------------------------------------------*/
process EditorController()
private
    a, s;
begin
    // initialization
    alive = true;

    // controls editor camera
    CameraController(REGION_EDITOR_VIEWPORT);

    // ui setup
    HideAllUIGroups();
    ShowUIGroup(GROUP_EDITOR_BG);

    // editor mode
    ChangeEditorMode(UI_EDITOR_VIEW_MODE);
    repeat
        switch (__uiEditor.mode)
            case UI_EDITOR_VIEW_MODE:
            end
            case UI_EDITOR_OBJECT_BRUSH_MODE:
                if (__ui.activeTextFieldId != NULL)
                    __camera.moveMode = NULL;
                    __uiEditor.brush.dataIndex = NULL;
                else
                    __camera.moveMode = CAMERA_MOVE_FREE_LOOK;
                end
                if (__uiEditor.brush.dataIndex > NULL
                    || __uiEditor.object.selected.processId != NULL)
                    if (shift_status == 1 || shift_status == 2)
                        __camera.moveMode = NULL;
                        // manipulate angle
                        if (key(_a))
                            __uiEditor.brush.angleOffset = WrapAngle360(__uiEditor.brush.angleOffset + 4000);
                        end
                        if (key(_d))
                            __uiEditor.brush.angleOffset = WrapAngle360(__uiEditor.brush.angleOffset - 4000);
                        end
                        // manipulate size
                        if (key(_w))
                            __uiEditor.brush.sizeOffset += 1;
                        end
                        if (key(_s))
                            __uiEditor.brush.sizeOffset -= 1;
                        end
                        // manipulate z
                        if (key(_q))
                            __uiEditor.brush.zOffset += 1;
                        end
                        if (key(_e))
                            __uiEditor.brush.zOffset -= 1;
                        end
                    else
                        __camera.moveMode = CAMERA_MOVE_FREE_LOOK;
                    end
                end
                if (__uiEditor.brush.dataIndex > NULL)
                    // preview
                    RenderImageOneFrame(
                        mouse.x, 
                        mouse.y, 
                        __uiEditor.brush.zOffset,
                        GFX_OBJECTS,
                        __objectData[__uiEditor.brush.dataIndex].gfxIndex,
                        WrapAngle360(__uiEditor.brush.angleOffset),
                        __uiEditor.brush.sizeOffset,
                        FLAG_TRANSPARENT);
                    // LMB: place brush
                    if (__mouse.leftClicked
                        && RegionContainsPoint(REGION_EDITOR_VIEWPORT, mouse.x, mouse.y))
                        i = EditorObject(
                            (scroll[0].x0 + 0 + mouse.x) * GPR, 
                            (scroll[0].y0 - 20 + mouse.y) * GPR, 
                            WrapAngle360(__uiEditor.brush.angleOffset),
                            __uiEditor.brush.sizeOffset,
                            __uiEditor.brush.zOffset,
                            __uiEditor.brush.dataIndex);
                        LevelData_AddObject(
                            (scroll[0].x0 + 0 + mouse.x) * GPR, 
                            (scroll[0].y0 - 20 + mouse.y) * GPR, 
                            WrapAngle360(__uiEditor.brush.angleOffset),
                            __uiEditor.brush.sizeOffset,
                            __uiEditor.brush.zOffset,
                            __uiEditor.brush.dataIndex,
                            i);
                    end
                    // RMB: deselect
                    if (__mouse.rightClicked)
                        __uiEditor.brush.dataIndex = NULL;
                        ClearUIGroup(GROUP_EDITOR_INFO);
                        ConfigureUI_EditorInfo();
                        ShowUIGroup(GROUP_EDITOR_INFO);
                    end
                else
                    if (__uiEditor.object.hover.processId != NULL)
                        // LMB while hovering over EditorObject: select
                        if (__mouse.leftClicked)
                            __uiEditor.object.selected.processId = __uiEditor.object.hover.processId;
                            i = __uiEditor.object.selected.processId.value;
                            __uiEditor.object.selected.name = __objectData[i].name;
                            __uiEditor.brush.angleOffset = __uiEditor.object.selected.processId.angle;
                            __uiEditor.brush.sizeOffset  = __uiEditor.object.selected.processId.size;
                            __uiEditor.brush.zOffset     = __uiEditor.object.selected.processId.z;
                            ClearUIGroup(GROUP_EDITOR_INFO);
                            ConfigureUI_EditorInfo();
                            ShowUIGroup(GROUP_EDITOR_INFO);
                        end
                    end
                    if (__uiEditor.object.selected.processId != NULL)
                        __uiEditor.object.selected.processId.angle = WrapAngle360(__uiEditor.brush.angleOffset);
                        __uiEditor.object.selected.processId.size = __uiEditor.brush.sizeOffset;
                        __uiEditor.object.selected.processId.z = __uiEditor.brush.zOffset;
                        LevelData_UpdateObject(__uiEditor.object.selected.processId);
                        // RMB: deselect
                        if (__mouse.rightClicked)
                            __uiEditor.object.selected.processId = NULL;
                            __uiEditor.object.selected.name = "";
                            ClearUIGroup(GROUP_EDITOR_INFO);
                            ConfigureUI_EditorInfo();
                            ShowUIGroup(GROUP_EDITOR_INFO);
                        end
                        // F: center on selected object
                        if (key(_f))
                            __camera.processId.x = __uiEditor.object.selected.processId.x;
                            __camera.processId.y = __uiEditor.object.selected.processId.y;
                        end
                    end
                end
            end
            case UI_EDITOR_ENTITY_BRUSH_MODE:
                // TODO: implement.
            end
            case UI_EDITOR_TERRAIN_BRUSH_MODE:
                // TODO: implement.
            end
            case UI_EDITOR_OBJECT_EDIT_MODE:
                x = 240;
                y = 210;
                a = WrapAngle360(__uiEditor.object.edit.angle);
                s = __uiEditor.object.edit.size;
                RenderImageOneFrame(
                    x, y,
                    UI_Z_UNDER - 1,
                    GFX_OBJECTS,
                    __uiEditor.object.edit.gfxIndex,
                    a, s,
                    FLAG_NORMAL);
                if (__uiEditor.object.edit.collidable == true)
                    RenderGfxPointsOneFrame(
                        x * GPR, y * GPR, 
                        GFX_OBJECTS, 
                        __uiEditor.object.edit.gfxIndex,
                        a, s, GPR,
                        COLOR_BLUE, 
                        OPACITY_SOLID, 
                        REGION_FULL_SCREEN, false);
                end
                if (ObjectEditor_IsEditDirty())
                    ClearUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
                    ConfigureUI_ObjectEditorButtons();
                    ShowUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
                end
            end
        end
        frame;
    until (alive == false);
end

function ChangeEditorMode(mode)
begin
    if (__uiEditor.mode != mode)
        ExitEditorMode(__uiEditor.mode);
        __uiEditor.mode = mode;
        EnterEditorMode(__uiEditor.mode);
    end
end

function ExitEditorMode(mode)
begin
    switch (__uiEditor.mode)
        case UI_EDITOR_VIEW_MODE:
        end
        case UI_EDITOR_OBJECT_BRUSH_MODE:
            __uiEditor.brush.dataIndex = NULL;
            HideUIGroup(GROUP_EDITOR_PALETTE);
            HideUIGroup(GROUP_EDITOR_INFO);
        end
        case UI_EDITOR_ENTITY_BRUSH_MODE:
            // TODO: implement.
        end
        case UI_EDITOR_TERRAIN_BRUSH_MODE:
            // TODO: implement.
        end
        case UI_EDITOR_OBJECT_EDIT_MODE:
            HideUIGroup(GROUP_OBJECT_EDITOR_BG);
            HideUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
            HideUIGroup(GROUP_OBJECT_EDITOR_WIDGETS);
        end
    end
end

function EnterEditorMode(mode)
begin
    switch (__uiEditor.mode)
        case UI_EDITOR_VIEW_MODE:
            __camera.moveMode = CAMERA_MOVE_FREE_LOOK;
        end
        case UI_EDITOR_OBJECT_BRUSH_MODE:
            LoadObjectData();
            ClearUIGroup(GROUP_EDITOR_PALETTE);
            ConfigureUI_EditorPalette();
            ShowUIGroup(GROUP_EDITOR_PALETTE);
            __camera.moveMode = CAMERA_MOVE_FREE_LOOK;
            __uiEditor.brush.angleOffset = 0;
            __uiEditor.brush.sizeOffset = 0;
            __uiEditor.brush.zOffset = 0;
        end
        case UI_EDITOR_ENTITY_BRUSH_MODE:
            // TODO: implement.
        end
        case UI_EDITOR_TERRAIN_BRUSH_MODE:
            // TODO: implement.
        end
        case UI_EDITOR_OBJECT_EDIT_MODE:
            ClearUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
            ConfigureUI_ObjectEditorButtons();
            // Set the text field to the correct value.
            SetTextFieldValue(
                GROUP_OBJECT_EDITOR_WIDGETS, 
                TF_OBJECT_FILE_NAME, 
                __uiEditor.object.edit.name);
            ShowUIGroup(GROUP_OBJECT_EDITOR_BG);
            ShowUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
            ShowUIGroup(GROUP_OBJECT_EDITOR_WIDGETS);
            __camera.moveMode = NULL;
        end
    end
end

process EditorObject(x, y, angle, size, z, objectDataIndex)
private
    pointsCount;
    insideScrollWindow = false;
    mouseHover = false;
    isLogging = false;
    w, h;
    renderPoints;
    pointsColor;
    xd, yd;
    moving = false;
begin
    // initialization
    value = objectDataIndex;
    alive = true;
    resolution = GPR;
    ctype = c_scroll;
    SetGraphic(GFX_OBJECTS, __objectData[value].gfxIndex);
    pointsCount = __objectData[value].pointsCount;
    repeat
        insideScrollWindow = IsInsideScrollWindow(id, 0, REGION_EDITOR_VIEWPORT);
        mouseHover = collision(type MouseCursor) && insideScrollWindow;
        renderPoints = false;
        if (__uiEditor.mode == UI_EDITOR_OBJECT_BRUSH_MODE)
            if (__objectData[value].collidable 
                && insideScrollWindow)
                // render collision points
                renderPoints = true;
                pointsColor = COLOR_BLUE;
            end
            if (mouseHover)
                // log info
                if (!isLogging)
                    LogValueFollowOffset(id, __objectData[value].name, &value, 0, 0);
                    LogValueFollowOffset(id, "x", &x, 0, 0);
                    LogValueFollowOffset(id, "y", &y, 0, 0);
                    isLogging = true;
                end
                // this object is being hovered over
                if (__uiEditor.object.hover.processId == NULL)
                    __uiEditor.object.hover.processId = id;
                end
            end
            if (__uiEditor.object.hover.processId == id)
                // TODO: If an object has no points, render an alternative highlight widget. Red circle?
                // render selection widget
                renderPoints = true;
                pointsColor = COLOR_WHITE;
            end
            if (__uiEditor.object.selected.processId == id)
                renderPoints = true;
                pointsColor = COLOR_GREEN;
                if (mouseHover 
                    && __mouse.leftHeldDown
                    && !moving)
                    xd = ((mouse.x + scroll[0].x0) * GPR) - x;
                    yd = ((mouse.y + scroll[0].y0) * GPR) - y;
                    moving = true;
                end
                if (moving)
                    x = ((mouse.x + scroll[0].x0) * GPR) - xd;
                    y = ((mouse.y + scroll[0].y0) * GPR) - yd;
                    LevelData_UpdateObject(id);
                    if (!__mouse.leftHeldDown)
                        moving = false;
                    end
                end
            end
        end
        if (__uiEditor.mode != UI_EDITOR_OBJECT_BRUSH_MODE
            || !mouseHover)
            if (__uiEditor.object.hover.processId == id)
                __uiEditor.object.hover.processId = NULL;
            end
            if (isLogging)
                DeleteLocalLog(id);
                DeleteLocalLog(id);
                DeleteLocalLog(id);
                isLogging = false;
            end
            moving = false;
        end
        if (renderPoints)
            FindGfxPoints(id, pointsCount);
            DrawGfxPointsOneFrame(pointsCount, pointsColor, OPACITY_SOLID, REGION_EDITOR_VIEWPORT, true);
        end
        frame;
    until (alive == false)
    if (__uiEditor.object.hover.processId == id)
        __uiEditor.object.hover.processId = NULL;
    end
    if (isLogging)
        DeleteLocalLog(id);
        DeleteLocalLog(id);
        DeleteLocalLog(id);
        isLogging = false;
    end
end

process EditorActionHandler()
private
    string text;
begin
    alive = true;
    __ui.action = NULL;
    repeat
        if (__ui.action != NULL)
            switch (__ui.action)
                // MAIN MENU
                case ACT_GOTO_NEW_LEVEL:
                    HideUIGroup(GROUP_MAIN_MENU);
                    ShowUIGroup(GROUP_STRING_PROMPT_DIALOG);
                end
                case ACT_GOTO_LOAD_LEVEL:
                    HideUIGroup(GROUP_MAIN_MENU);
                    ShowUIGroup(GROUP_LOAD_LEVEL_DIALOG);
                end
                case ACT_GOTO_MAIN_MENU:
                    HideUIGroup(GROUP_STRING_PROMPT_DIALOG);
                    HideUIGroup(GROUP_LOAD_LEVEL_DIALOG);
                    ShowUIGroup(GROUP_MAIN_MENU);
                end
                case ACT_EXIT_APP:
                    exit("", 0);
                end
                case ACT_CREATE_NEW_LEVEL:
                    text = GetTextFieldValue(GROUP_STRING_PROMPT_DIALOG, TF_LEVEL_FILE_NAME);
                    if (text != "" 
                        && !ObjectFileExists(text))
                        __levelData.name = text;
                        EditorController();
                    end
                end
                case ACT_SAVE_LEVEL:
                    LevelData_Save(__levelData.name);
                end
                case ACT_LOAD_LEVEL:
                    // TODO: implement.
                end
                // TOP BAR
                case ACT_GOTO_VIEW_MODE:
                    ChangeEditorMode(UI_EDITOR_VIEW_MODE);
                end
                case ACT_GOTO_OBJECT_BRUSH_MODE:
                    ChangeEditorMode(UI_EDITOR_OBJECT_BRUSH_MODE);
                end
                case ACT_GOTO_ENTITY_BRUSH_MODE:
                    // TODO: implement.
                end
                case ACT_GOTO_TERRAIN_BRUSH_MODE:
                    // TODO: implement.
                end
                case ACT_GOTO_OBJECT_EDITOR:
                    ObjectEditor_ResetEdit();
                    ChangeEditorMode(UI_EDITOR_OBJECT_EDIT_MODE);
                end
                // INFO / PREVIEW BOX
                case ACT_EDIT_OBJECT:
                    ObjectEditor_SetEditFromData(__uiEditor.brush.dataIndex);
                    ChangeEditorMode(UI_EDITOR_OBJECT_EDIT_MODE);
                end
                case ACT_DELETE_OBJECT:
                    LevelData_RemoveObject(__uiEditor.object.selected.processId);
                    __uiEditor.object.selected.processId.alive = false;
                    __uiEditor.object.selected.processId = NULL;
                    __uiEditor.object.selected.name = "";
                    ClearUIGroup(GROUP_EDITOR_INFO);
                    ConfigureUI_EditorInfo();
                    ShowUIGroup(GROUP_EDITOR_INFO);
                end
                // PALETTE
                case ACT_SCROLL_PALETTE_UP:
                    if (__uiEditor.palettePage > 0)
                        __uiEditor.palettePage--;
                    end
                    ClearUIGroup(GROUP_EDITOR_PALETTE);
                    ConfigureUI_EditorPalette();
                    ShowUIGroup(GROUP_EDITOR_PALETTE);
                end
                case ACT_SCROLL_PALETTE_DOWN:
                    if (__uiEditor.palettePage < (__objectDataCount / UI_EDITOR_PALETTE_SIZE))
                        __uiEditor.palettePage++;
                    end
                    ClearUIGroup(GROUP_EDITOR_PALETTE);
                    ConfigureUI_EditorPalette();
                    ShowUIGroup(GROUP_EDITOR_PALETTE);
                end
                case ACT_SELECT_PALETTE..(ACT_SELECT_PALETTE + UI_EDITOR_PALETTE_SIZE - 1):
                    i = (__uiEditor.palettePage * UI_EDITOR_PALETTE_SIZE) 
                        + (__ui.action - ACT_SELECT_PALETTE);
                    if (i == __objectDataCount)
                        ObjectEditor_ResetEdit();
                        ChangeEditorMode(UI_EDITOR_OBJECT_EDIT_MODE);
                    else
                        if (__uiEditor.brush.dataIndex == i)
                            __uiEditor.brush.dataIndex = NULL;
                        else
                            __uiEditor.brush.dataIndex = i;
                            __uiEditor.brush.angleOffset = __objectData[i].angle;
                            __uiEditor.brush.sizeOffset  = __objectData[i].size;
                            __uiEditor.brush.zOffset     = __objectData[i].z;
                        end
                        __uiEditor.object.selected.processId = NULL;
                        __uiEditor.object.selected.name = "";
                        ClearUIGroup(GROUP_EDITOR_INFO);
                        ConfigureUI_EditorInfo();
                        ShowUIGroup(GROUP_EDITOR_INFO);
                    end
                end
                case ACT_SEARCH_PALETTE:
                    // TODO: implement.
                end
                // OBJECT EDITOR
                case ACT_SET_OBJECT_NAME:
                    // TODO: Validate file name doesn't already exist.
                    text = GetTextFieldValue(GROUP_OBJECT_EDITOR_WIDGETS, TF_OBJECT_FILE_NAME);
                    if (text != "" 
                        && !ObjectFileExists(text))
                        __uiEditor.object.edit.name = text;
                        ClearUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
                        ConfigureUI_ObjectEditorButtons();
                        ShowUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
                    else
                        __uiEditor.object.edit.name = __uiEditor.object.saved.name;
                        SetTextFieldValue(
                            GROUP_OBJECT_EDITOR_WIDGETS, 
                            TF_OBJECT_FILE_NAME, 
                            __uiEditor.object.edit.name);
                        ObjectEditor_UpdateEditDirty();
                    end
                end
                case ACT_SAVE_OBJECT:
                    ObjectEditor_SaveChanges();
                    ClearUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
                    ClearUIGroup(GROUP_OBJECT_EDITOR_WIDGETS);
                    ConfigureUI_ObjectEditorButtons();
                    ConfigureUI_ObjectEditorWidgets();
                    ShowUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
                    ShowUIGroup(GROUP_OBJECT_EDITOR_WIDGETS);
                end
                case ACT_DISCARD_OBJECT:
                    ObjectEditor_DiscardChanges();
                    ClearUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
                    ClearUIGroup(GROUP_OBJECT_EDITOR_WIDGETS);
                    ConfigureUI_ObjectEditorButtons();
                    ConfigureUI_ObjectEditorWidgets();
                    ShowUIGroup(GROUP_OBJECT_EDITOR_BUTTONS);
                    ShowUIGroup(GROUP_OBJECT_EDITOR_WIDGETS);
                end
                case ACT_SELECT_LEVEL..(ACT_SELECT_LEVEL + MAX_LEVEL_FILES - 1):
                    i = (__ui.action - ACT_SELECT_LEVEL);
                    LevelData_Load(__levelFileData[i].name);
                    EditorController();
                    PopulateEditorLevel();
                end
            end
            __ui.action = NULL;
        end
        frame;
    until (alive == false)
end



    // EDITOR SPECIFIC ---------------------------------------------------------
/* -----------------------------------------------------------------------------
 * Object Editor functionality
 * ---------------------------------------------------------------------------*/
function ObjectEditor_CopySavedFromEdit()
begin
    __uiEditor.object.saved.name       = __uiEditor.object.edit.name;
    __uiEditor.object.saved.angle      = __uiEditor.object.edit.angle;
    __uiEditor.object.saved.size       = __uiEditor.object.edit.size;
    __uiEditor.object.saved.z          = __uiEditor.object.edit.z;
    __uiEditor.object.saved.gfxIndex   = __uiEditor.object.edit.gfxIndex;
    __uiEditor.object.saved.material   = __uiEditor.object.edit.material;
    __uiEditor.object.saved.collidable = __uiEditor.object.edit.collidable;
end

function ObjectEditor_ResetEdit()
begin
    __uiEditor.object.edit.name       = "";
    __uiEditor.object.edit.angle      = 0;
    __uiEditor.object.edit.size       = 100;
    __uiEditor.object.edit.z          = 0;
    __uiEditor.object.edit.gfxIndex   = 1;
    __uiEditor.object.edit.material   = 0;
    __uiEditor.object.edit.collidable = true;
    ObjectEditor_CopySavedFromEdit();
end

function ObjectEditor_SetEditFromData(objectDataIndex)
begin
    __uiEditor.object.edit.name       = __objectData[objectDataIndex].name;
    __uiEditor.object.edit.angle      = __objectData[objectDataIndex].angle;
    __uiEditor.object.edit.size       = __objectData[objectDataIndex].size;
    __uiEditor.object.edit.z          = __objectData[objectDataIndex].z;
    __uiEditor.object.edit.gfxIndex   = __objectData[objectDataIndex].gfxIndex;
    __uiEditor.object.edit.material   = __objectData[objectDataIndex].material;
    __uiEditor.object.edit.collidable = __objectData[objectDataIndex].collidable;
    ObjectEditor_CopySavedFromEdit();
end

function ObjectEditor_IsEditDirty()
begin
    ObjectEditor_UpdateEditDirty();
    return (__uiEditor.object.dirty);
end

function ObjectEditor_UpdateEditDirty()
begin
    __uiEditor.object.dirty = 
        __uiEditor.object.saved.name          != __uiEditor.object.edit.name
        || __uiEditor.object.saved.angle      != __uiEditor.object.edit.angle
        || __uiEditor.object.saved.size       != __uiEditor.object.edit.size
        || __uiEditor.object.saved.z          != __uiEditor.object.edit.z
        || __uiEditor.object.saved.gfxIndex   != __uiEditor.object.edit.gfxIndex
        || __uiEditor.object.saved.material   != __uiEditor.object.edit.material
        || __uiEditor.object.saved.collidable != __uiEditor.object.edit.collidable;
end

function ObjectEditor_CanSaveEdit()
begin
    return (ObjectEditor_IsEditDirty() 
        && ObjectEditor_ValidateFileName(__uiEditor.object.edit.name));
end

function ObjectEditor_ValidateFileName(string name)
begin
    // TODO: Check whether a file already exists with the same file name.
    return (name != "");
end

function ObjectEditor_SaveChanges()
begin
    ObjectEditor_CopySavedFromEdit();
    SaveObject(
        __uiEditor.object.saved.name,
        __uiEditor.object.saved.angle,
        __uiEditor.object.saved.size,
        __uiEditor.object.saved.z,
        __uiEditor.object.saved.gfxIndex,
        __uiEditor.object.saved.material,
        __uiEditor.object.saved.collidable);
    ObjectEditor_UpdateEditDirty();
end

function ObjectEditor_DiscardChanges()
begin
    __uiEditor.object.edit.name       = __uiEditor.object.saved.name;
    __uiEditor.object.edit.angle      = __uiEditor.object.saved.angle;
    __uiEditor.object.edit.size       = __uiEditor.object.saved.size;
    __uiEditor.object.edit.z          = __uiEditor.object.saved.z;
    __uiEditor.object.edit.gfxIndex   = __uiEditor.object.saved.gfxIndex;
    __uiEditor.object.edit.material   = __uiEditor.object.saved.material;
    __uiEditor.object.edit.collidable = __uiEditor.object.saved.collidable;
    ObjectEditor_UpdateEditDirty();
end



    // EDITOR SPECIFIC ---------------------------------------------------------
/* -----------------------------------------------------------------------------
 * Level Editor UI Configuration
 * ---------------------------------------------------------------------------*/
function ConfigureUI()
begin
    // ui vars
    __uiEditor.palettePage = 0;
    __uiEditor.brush.dataIndex = NULL;

    // construct ui groups
    ConfigureUI_MainBg();
    ConfigureUI_MainMenu();
    ConfigureUI_StringPromptDialog();
    ConfigureUI_LoadLevelDialog();
    ConfigureUI_EditorBg();
    ConfigureUI_EditorPalette();
    ConfigureUI_EditorInfo();
    ConfigureUI_ObjectEditorBg();
    ConfigureUI_ObjectEditorButtons();
    ConfigureUI_ObjectEditorWidgets();

    __uiGroupsCount = 9;
end

function ConfigureUI_MainBg()
private
    ui = GROUP_MAIN_BG;
begin
    AddImageToUIGroup(ui,
        HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT, UI_Z_UNDER,
        GFX_MAIN, 2, 0, 100, FLAG_NORMAL);
end

function ConfigureUI_MainMenu()
private
    ui = GROUP_MAIN_MENU;
begin
    AddTextToUIGroup(ui,
        HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT - 20,
        FONT_MENU, FONT_ANCHOR_CENTERED, "LEVEL EDITOR", false);
    AddButtonToUIGroup(ui,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 20, 200, 40,
        COLOR_SCHEME_BLUE,
        FONT_MENU, ACT_GOTO_NEW_LEVEL, ENABLED);
    AddButtonToUIGroup(ui,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 70, 200, 40,
        COLOR_SCHEME_BLUE,
        FONT_MENU, ACT_GOTO_LOAD_LEVEL, ENABLED);
    AddButtonToUIGroup(ui,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 120, 200, 40,
        COLOR_SCHEME_BLUE,
        FONT_MENU, ACT_EXIT_APP, ENABLED);
end

function ConfigureUI_StringPromptDialog()
private
    ui = GROUP_STRING_PROMPT_DIALOG;
begin
    // BG & TITLE
    AddDrawingToUIGroup(ui,
        SCREEN_WIDTH / 6, 0, (SCREEN_WIDTH * 5) / 6, SCREEN_HEIGHT,
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 4, OPACITY_SOLID);
    AddTextToUIGroup(ui,
        HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT / 3,
        FONT_MENU, FONT_ANCHOR_CENTERED, "NEW LEVEL", false);

    // INPUT
    AddTextToUIGroup(ui,
        HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT - 50,
        FONT_MENU, FONT_ANCHOR_CENTERED, "Enter file name:", false);
    AddTextFieldToUIGroup(ui,
        HALF_SCREEN_WIDTH - 150, HALF_SCREEN_HEIGHT - 30, 300, 30,
        COLOR_SCHEME_BLACK, FONT_SYSTEM, FONT_ANCHOR_CENTERED, "", TF_LEVEL_FILE_NAME, ACTIVE, ENABLED);
    
    // BUTTONS
    AddButtonToUIGroup(ui,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 70, 200, 40,
        COLOR_SCHEME_BLUE,
        FONT_MENU, ACT_CREATE_NEW_LEVEL, ENABLED);
    AddButtonToUIGroup(ui,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 120, 200, 40,
        COLOR_SCHEME_BLUE,
        FONT_MENU, ACT_GOTO_MAIN_MENU, ENABLED);
end

function ConfigureUI_LoadLevelDialog()
private
    ui = GROUP_LOAD_LEVEL_DIALOG;
    struct lb
        count;
        rowCapacity;
        rowCount;
        cw;
        rh;
        columnCount;
        w, h;
        x, y;
        c, r;
    end
begin
    // BG & TITLE
    AddDrawingToUIGroup(ui,
        SCREEN_WIDTH / 6, 0, (SCREEN_WIDTH * 5) / 6, SCREEN_HEIGHT,
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 4, OPACITY_SOLID);
    AddTextToUIGroup(ui,
        HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT / 3,
        FONT_MENU, FONT_ANCHOR_CENTERED, "LOAD LEVEL", false);
    
    // LEVELS
    lb.count = __levelFileDataCount;
    lb.rowCapacity = 3;
    lb.columnCount = (lb.count / lb.rowCapacity);
    if (lb.count % lb.rowCapacity > 0)
        ++lb.columnCount;
    end
    lb.w = 120;
    lb.h = 30;
    lb.cw = lb.w + 5;
    lb.rh = lb.h + 5;
    if (lb.count >= lb.rowCapacity)
        lb.rowCount = lb.rowCapacity;
    else
        lb.rowCount = lb.count;
    end
    lb.x = HALF_SCREEN_WIDTH - ((lb.rowCount * lb.cw) / 2) + ((lb.cw - lb.w) / 2);
    lb.y = (SCREEN_HEIGHT * 8 / 16) - ((lb.columnCount * lb.rh) / 2) + ((lb.rh - lb.h) / 2) - 5;
    for (i = 0; i < lb.count; ++i)
        lb.c = i % lb.rowCapacity;
        lb.r = i / lb.rowCapacity;
        __uiButtons[ACT_SELECT_LEVEL + i].label = __levelFileData[i].name;
        AddButtonToUIGroup(ui,
            lb.x + (lb.c * lb.cw),
            lb.y + (lb.r * lb.rh),
            lb.w, lb.h,
            COLOR_SCHEME_BLUE,
            FONT_SYSTEM, ACT_SELECT_LEVEL + i, ENABLED);
    end

    // BUTTONS
    AddButtonToUIGroup(ui,
        HALF_SCREEN_WIDTH - 100, HALF_SCREEN_HEIGHT + 120, 200, 40,
        COLOR_SCHEME_BLUE,
        FONT_MENU, ACT_GOTO_MAIN_MENU, ENABLED);
end

function ConfigureUI_EditorBg()
private
    ui = GROUP_EDITOR_BG;
    bw;
    buttonOffset;
begin
    bw = (UI_UNIT * 16) + (UI_UNIT / 2);
    buttonOffset = bw + (UI_UNIT / 2);

    // SIDE PANEL BG
    AddDrawingToUIGroup(ui,
        SCREEN_WIDTH - UI_PW - 1, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 4, OPACITY_SOLID);

    // TOP BAR
    AddDrawingToUIGroup(ui,
        0, 0, SCREEN_WIDTH - UI_PW - 1, UI_UNIT * 5,
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 4, OPACITY_SOLID);
    AddButtonToUIGroup(ui,
        (buttonOffset * 0) + (UI_UNIT / 2), UI_UNIT / 2, bw, UI_UNIT * 4,
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_SAVE_LEVEL, ENABLED);
    AddButtonToUIGroup(ui,
        (buttonOffset * 1) + (UI_UNIT / 2), UI_UNIT / 2, bw, UI_UNIT * 4,
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_LOAD_LEVEL, ENABLED);
    AddButtonToUIGroup(ui,
        (buttonOffset * 2) + (UI_UNIT / 2), UI_UNIT / 2, bw, UI_UNIT * 4,
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_GOTO_VIEW_MODE, ENABLED);
    AddButtonToUIGroup(ui,
        (buttonOffset * 3) + (UI_UNIT / 2), UI_UNIT / 2, bw, UI_UNIT * 4,
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_GOTO_OBJECT_BRUSH_MODE, ENABLED);
    AddButtonToUIGroup(ui,
        (buttonOffset * 4) + (UI_UNIT / 2), UI_UNIT / 2, bw, UI_UNIT * 4,
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_GOTO_ENTITY_BRUSH_MODE, DISABLED);
    AddButtonToUIGroup(ui,
        (buttonOffset * 5) + (UI_UNIT / 2), UI_UNIT / 2, bw, UI_UNIT * 4,
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_GOTO_TERRAIN_BRUSH_MODE, DISABLED);
    AddButtonToUIGroup(ui,
        (buttonOffset * 6) + (UI_UNIT / 2), UI_UNIT / 2, bw, UI_UNIT * 4,
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_GOTO_OBJECT_EDITOR, ENABLED);
end

function ConfigureUI_EditorPalette()
private
    ui = GROUP_EDITOR_PALETTE;
    w, h;
    objectDataIndex;
    pbSize = 64;
    string pbText;
    pbFileIndex;
    pbGfxIndex;
begin
    // SEARCH BAR
    w = (UI_PW) - (UI_UNIT * 1) - (UI_UNIT / 2);
    h = (UI_UNIT * 4) + (UI_UNIT / 2);
    x = SCREEN_WIDTH - (UI_PW) + (UI_UNIT / 2);
    y = (UI_PAL_Y) - (h) + (UI_UNIT / 2);
    AddTextFieldToUIGroup(ui,
        x, y, w, h,
        COLOR_SCHEME_BLACK, FONT_SYSTEM, FONT_ANCHOR_CENTERED, "", TF_PALETTE_SEARCH, INACTIVE, ENABLED);

    // PALETTE BG
    AddDrawingToUIGroup(ui,
        SCREEN_WIDTH - (UI_PW) - 1 + (UI_UNIT / 2), UI_PAL_Y + (UI_UNIT) + (UI_UNIT / 2), SCREEN_WIDTH - (UI_UNIT / 2) - 1, SCREEN_HEIGHT - (UI_UNIT / 2) - 1,
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 5, OPACITY_SOLID);

    // PALETTE LINES
    AddDrawingToUIGroup(ui,
        SCREEN_WIDTH - (UI_PW) - 1 + (UI_UNIT * 2) + pbSize, UI_PAL_Y + (UI_UNIT) + (UI_UNIT / 2), 
        SCREEN_WIDTH - (UI_PW) - 1 + (UI_UNIT * 2) + pbSize, SCREEN_HEIGHT - (UI_UNIT / 2) - 1,
        DRAW_LINE, COLOR_BLUE - 6, OPACITY_SOLID);
    for (i = 1; i <= 3; ++i)
        AddDrawingToUIGroup(ui,
            SCREEN_WIDTH - (UI_PW) - 1 + (UI_UNIT / 2), UI_PAL_Y + (UI_UNIT) + (UI_UNIT / 2) + (pbSize * i), SCREEN_WIDTH - (UI_UNIT / 2) - 1, UI_PAL_Y + (UI_UNIT) + (UI_UNIT / 2) + (pbSize * i),
            DRAW_LINE, COLOR_BLUE - 6, OPACITY_SOLID);
    end

    // PALETTE BOXES
    for (i = 0; i < UI_EDITOR_PALETTE_SIZE; ++i)
        objectDataIndex = (__uiEditor.palettePage * UI_EDITOR_PALETTE_SIZE) + i;
        if (objectDataIndex > __objectDataCount)
            break;
        end
        if (objectDataIndex < __objectDataCount)
            pbText = __objectData[objectDataIndex].name;
            pbFileIndex = GFX_OBJECTS;
            pbGfxIndex = __objectData[objectDataIndex].gfxIndex;
        end
        // After all objects are displayed, display a 'new object' button.
        if (objectDataIndex == __objectDataCount)
            pbText = "NEW";
            pbFileIndex = GFX_UI;
            pbGfxIndex = 100;
        end
        x = (SCREEN_WIDTH - (UI_PW) - 1 + (UI_UNIT / 2)) + ((i % 2) * (pbSize + (UI_UNIT * 2)));
        y = (UI_PAL_Y + (UI_UNIT) + (UI_UNIT / 2)      ) + ((i / 2) * (pbSize));
        w = (pbSize) - (UI_UNIT * 3);
        h = (pbSize) - (UI_UNIT * 6);
        AddTextToUIGroup(ui,
            x + (pbSize / 2) + (UI_UNIT), y + (UI_UNIT * 2), 
            FONT_SYSTEM, FONT_ANCHOR_CENTERED, 
            pbText, false);
        AddButtonToUIGroup(ui,
            x + (UI_UNIT * 2), y + (UI_UNIT * 4), w, h,
            COLOR_SCHEME_BLUE,
            FONT_SYSTEM, ACT_SELECT_PALETTE + i, ENABLED);
            size = CalculateFittedSize(pbFileIndex, pbGfxIndex, w, h);
        AddImageToUIGroup(ui,
            x + (pbSize / 2) + (UI_UNIT / 2), y + (pbSize / 2) + (UI_UNIT), UI_Z_ABOVE,
            pbFileIndex, pbGfxIndex, __objectData[objectDataIndex].angle, size, FLAG_NORMAL);
    end

    // SCROLL BAR
    AddDrawingToUIGroup(ui,
        SCREEN_WIDTH - (UI_UNIT * 4) - (UI_UNIT / 2) - 1, UI_PAL_Y + (UI_UNIT) + (UI_UNIT / 2), SCREEN_WIDTH - (UI_UNIT / 2) - 1, SCREEN_HEIGHT - (UI_UNIT / 2) - 1,
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 6, OPACITY_SOLID);
    AddButtonToUIGroup(ui,
        SCREEN_WIDTH - (UI_UNIT * 4) - (UI_UNIT / 2) - 1, UI_PAL_Y + (UI_UNIT) + (UI_UNIT / 2), (UI_UNIT * 4), (UI_UNIT * 4),
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_SCROLL_PALETTE_UP, ENABLED);
    AddButtonToUIGroup(ui,
        SCREEN_WIDTH - (UI_UNIT * 4) - (UI_UNIT / 2) - 1, SCREEN_HEIGHT - (UI_UNIT * 4) - (UI_UNIT / 2) - 1, (UI_UNIT * 4), (UI_UNIT * 4),
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_SCROLL_PALETTE_DOWN, ENABLED);
end

function ConfigureUI_EditorInfo()
private
    ui = GROUP_EDITOR_INFO;
    w, h;
    bx, by; // box x, box y
    bw, bh; // box width, box height
    string objName;
    objAngle, objSize, objZ;
    objGfxIndex, objMaterial, objCollidable;
    buttonAction = NULL;
begin
    // one of these values cannot be NULL
    if (__uiEditor.brush.dataIndex == NULL
        && __uiEditor.object.selected.processId == NULL)
        return;
    end

    // VARS
    x = SCREEN_WIDTH - (UI_PW) - 1 + (UI_UNIT);
    y = (UI_UNIT);
    w = UI_PW - (UI_UNIT) - (UI_UNIT / 2);
    h = UI_PAL_Y - (UI_UNIT * 2);
    bw = (UI_UNIT * 22);
    bh = bw;
    bx = (x + w) - bw - (UI_UNIT / 2);
    by = y + (UI_UNIT * 5);

    // PREVIEW BG
    AddDrawingToUIGroup(ui,
        bx, by, bx + bw, by + bh,
        DRAW_RECTANGLE_FILL, COLOR_BLUE - 5, OPACITY_SOLID);
    
    // CONFIG BASED ON MODE
    if (__uiEditor.brush.dataIndex > NULL)
        buttonAction = ACT_EDIT_OBJECT;
        i = __uiEditor.brush.dataIndex;
        objName     = __objectData[i].name;
        objGfxIndex = __objectData[i].gfxIndex;
        objAngle    = &__uiEditor.brush.angleOffset;
        objSize     = &__uiEditor.brush.sizeOffset;
        objZ        = &__uiEditor.brush.zOffset;
    else
        buttonAction = ACT_DELETE_OBJECT;
        objName     = __uiEditor.object.selected.name;
        objAngle    = &__uiEditor.object.selected.processId.angle;
        objSize     = &__uiEditor.object.selected.processId.size;
        objZ        = &__uiEditor.object.selected.processId.z;
        objGfxIndex = __uiEditor.object.selected.processId.graph;
    end

    // BUTTON
    AddButtonToUIGroup(ui,
        x + w - (UI_UNIT * 16) - (UI_UNIT / 2), y, (UI_UNIT * 16), (UI_UNIT * 4),
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, buttonAction, ENABLED);

    // NAME
    AddTextToUIGroup(ui,
        x, y, 
        FONT_SYSTEM, FONT_ANCHOR_TOP_LEFT, 
        objName, false);

    // INFO
    AddTextToUIGroup(ui,
        x, y + (UI_UNIT * 5), 
        FONT_SYSTEM, FONT_ANCHOR_TOP_LEFT, 
        "A:", false);
    AddTextToUIGroup(ui,
        x + (UI_UNIT * 4), y + (UI_UNIT * 5), 
        FONT_SYSTEM, FONT_ANCHOR_TOP_LEFT, 
        objAngle, true);
    AddTextToUIGroup(ui,
        x, y + (UI_UNIT * 8), 
        FONT_SYSTEM, FONT_ANCHOR_TOP_LEFT, 
        "S:", false);
    AddTextToUIGroup(ui,
        x + (UI_UNIT * 4), y + (UI_UNIT * 8), 
        FONT_SYSTEM, FONT_ANCHOR_TOP_LEFT, 
        objSize, true);
    AddTextToUIGroup(ui,
        x, y + (UI_UNIT * 11), 
        FONT_SYSTEM, FONT_ANCHOR_TOP_LEFT, 
        "Z:", false);
    AddTextToUIGroup(ui,
        x + (UI_UNIT * 4), y + (UI_UNIT * 11), 
        FONT_SYSTEM, FONT_ANCHOR_TOP_LEFT, 
        objZ, true);

    // PREVIEW IMAGE
    size = CalculateFittedSize(GFX_OBJECTS, objGfxIndex, bw, bh);
    AddImageToUIGroup(ui,
        bx + (bw / 2), by + (bh / 2), UI_Z_ABOVE,
        GFX_OBJECTS, objGfxIndex, *objAngle, size, FLAG_NORMAL);
end

function ConfigureUI_ObjectEditorBg()
private
    ui = GROUP_OBJECT_EDITOR_BG;
begin
    // BG
    AddImageToUIGroup(ui,
        __regions[REGION_EDITOR_VIEWPORT].x + (__regions[REGION_EDITOR_VIEWPORT].width / 2), 
        __regions[REGION_EDITOR_VIEWPORT].y + (__regions[REGION_EDITOR_VIEWPORT].height / 2), 
        UI_Z_UNDER,
        GFX_UI, 1, 0, 100, FLAG_NORMAL);
end

function ConfigureUI_ObjectEditorButtons()
private
    ui = GROUP_OBJECT_EDITOR_BUTTONS;
    bw, bh, by;
    buttonOffsetY;
    canSave;
    canDiscard;
begin
    // SIDE PANEL BUTTONS
    canSave = ObjectEditor_CanSaveEdit();
    canDiscard = ObjectEditor_IsEditDirty();
    bw = (UI_PW) - (UI_UNIT * 1);
    bh = (UI_UNIT * 8);
    by = (UI_UNIT / 2);
    buttonOffsetY = bh + (UI_UNIT * 1);
    AddButtonToUIGroup(ui,
        UI_PX + (UI_UNIT / 2) - 1, by + (buttonOffsetY * 0), bw, bh,
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_SAVE_OBJECT, canSave);
    AddButtonToUIGroup(ui,
        UI_PX + (UI_UNIT / 2) - 1, by + (buttonOffsetY * 1), bw, bh,
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, ACT_DISCARD_OBJECT, canDiscard);
end

function ConfigureUI_ObjectEditorWidgets()
private
    ui = GROUP_OBJECT_EDITOR_WIDGETS;
    tx;
    w, h;
    textOffsetY;
begin
    // FILENAME
    w = (UI_PW) - (UI_UNIT * 1) - (UI_UNIT / 2);
    h = (UI_UNIT * 4) + (UI_UNIT / 2);
    x = SCREEN_WIDTH - (UI_PW) + (UI_UNIT / 2);
    y = (UI_PAL_Y) - (UI_UNIT * 9);
    textOffsetY = (UI_UNIT * 8);
    AddTextToUIGroup(ui,
        x + (UI_PW / 2), y - (textOffsetY / 2) + (UI_UNIT),
        FONT_SYSTEM, FONT_ANCHOR_TOP_CENTER, 
        "File Name:", false);
    AddTextFieldToUIGroup(ui,
        x, y, w, h,
        COLOR_SCHEME_BLACK, FONT_SYSTEM, FONT_ANCHOR_CENTERED, 
        __uiEditor.object.edit.name, TF_OBJECT_FILE_NAME, INACTIVE, ENABLED);

    // SIDE PANEL WIDGETS
    tx = (UI_PX) + (UI_UNIT * 16) + (UI_UNIT / 2);
    AddTextToUIGroup(ui,
        tx, (UI_PAL_Y) + (textOffsetY * 0),
        FONT_SYSTEM, FONT_ANCHOR_TOP_RIGHT, 
        "Graphic:", false);
    AddDialToUIGroup(ui,
        tx + (UI_UNIT * 4), (UI_PAL_Y) + (textOffsetY * 0) + (UI_UNIT * 1),
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, &__uiEditor.object.edit.gfxIndex, 1, 2, true,
        100, 25, 1, 1, ENABLED);
    AddTextToUIGroup(ui,
        tx, (UI_PAL_Y) + (textOffsetY * 1),
        FONT_SYSTEM, FONT_ANCHOR_TOP_RIGHT, 
        "Material:", false);
    AddDialToUIGroup(ui,
        tx + (UI_UNIT * 4), (UI_PAL_Y) + (textOffsetY * 1) + (UI_UNIT * 1),
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, &__uiEditor.object.edit.material, 0, MATERIAL_COUNT - 1, true,
        25, 5, 1, 10, ENABLED);
    AddTextToUIGroup(ui,
        tx, (UI_PAL_Y) + (textOffsetY * 2),
        FONT_SYSTEM, FONT_ANCHOR_TOP_RIGHT, 
        "Angle:", false);
    AddDialToUIGroup(ui,
        tx + (UI_UNIT * 4), (UI_PAL_Y) + (textOffsetY * 2) + (UI_UNIT * 1),
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, &__uiEditor.object.edit.angle, 0, 360000, true,
        2, 1, -1000, -5000, ENABLED);
    AddTextToUIGroup(ui,
        tx, (UI_PAL_Y) + (textOffsetY * 3),
        FONT_SYSTEM, FONT_ANCHOR_TOP_RIGHT, 
        "Size:", false);
    AddDialToUIGroup(ui,
        tx + (UI_UNIT * 4), (UI_PAL_Y) + (textOffsetY * 3) + (UI_UNIT * 1),
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, &__uiEditor.object.edit.size, 0, 1000, false,
        25, 5, 1, 10, ENABLED);
    AddTextToUIGroup(ui,
        tx, (UI_PAL_Y) + (textOffsetY * 4),
        FONT_SYSTEM, FONT_ANCHOR_TOP_RIGHT, 
        "Z Depth:", false);
    AddDialToUIGroup(ui,
        tx + (UI_UNIT * 4), (UI_PAL_Y) + (textOffsetY * 4) + (UI_UNIT * 1),
        COLOR_SCHEME_BLUE,
        FONT_SYSTEM, &__uiEditor.object.edit.z, -100, 100, false,
        25, 5, 1, 10, ENABLED);
    AddTextToUIGroup(ui,
        tx, (UI_PAL_Y) + (textOffsetY * 5),
        FONT_SYSTEM, FONT_ANCHOR_TOP_RIGHT, 
        "Collision:", false);
    AddCheckboxToUIGroup(ui, 
        tx + (UI_UNIT * 4), (UI_PAL_Y) + (textOffsetY * 5),
        COLOR_SCHEME_BLUE,
        &__uiEditor.object.edit.collidable, ENABLED);
end



/* -----------------------------------------------------------------------------
 * UI Input
 * ---------------------------------------------------------------------------*/
process UIController()
private
    j;
    lastDialTick;
    dialDelay;
    dialDelta;
begin
    alive = true;
    __ui.buttonClicked        = NULL;
    __ui.buttonHeldDown       = NULL;
    __ui.submittedTextFieldId = NULL;
    __ui.submittedText        = "";
    repeat
        if (__ui.submittedTextFieldId != NULL)
            DispatchAction(__uiTextFields[__ui.submittedTextFieldId].action, __ui.submittedText);
            __ui.submittedTextFieldId = NULL;
            __ui.submittedText = "";
        end
        if (__ui.buttonClicked != NULL)
            DispatchAction(__ui.buttonClicked, "");
            __ui.buttonClicked = NULL;
        end
        // TODO: Move this generic dial code somewhere else. Perhaps UIRenderer is appropriate?
        if (__ui.dial.active)
            if (__ui.dial.state != 0)
                switch (__ui.dial.state)
                    case -2:
                        dialDelay = __uiGroups[__ui.dial.uiGroupIndex].dials[__ui.dial.dialIndex].delayFast;
                        dialDelta = -__uiGroups[__ui.dial.uiGroupIndex].dials[__ui.dial.dialIndex].deltaFast;
                    end
                    case -1:
                        dialDelay = __uiGroups[__ui.dial.uiGroupIndex].dials[__ui.dial.dialIndex].delaySlow;
                        dialDelta = -__uiGroups[__ui.dial.uiGroupIndex].dials[__ui.dial.dialIndex].deltaSlow;
                    end
                    case 1:
                        dialDelay = __uiGroups[__ui.dial.uiGroupIndex].dials[__ui.dial.dialIndex].delaySlow;
                        dialDelta = __uiGroups[__ui.dial.uiGroupIndex].dials[__ui.dial.dialIndex].deltaSlow;
                    end
                    case 2:
                        dialDelay = __uiGroups[__ui.dial.uiGroupIndex].dials[__ui.dial.dialIndex].delayFast;
                        dialDelta = __uiGroups[__ui.dial.uiGroupIndex].dials[__ui.dial.dialIndex].deltaFast;
                    end
                end
                if (timer[0] > lastDialTick + dialDelay)
                    i = __ui.dial.uiGroupIndex;
                    j = __ui.dial.dialIndex;
                    *__uiGroups[i].dials[j].var += dialDelta;
                    if (*__uiGroups[i].dials[j].var < __uiGroups[i].dials[j].varMin)
                        if (__uiGroups[i].dials[j].varWrapValue)
                            *__uiGroups[i].dials[j].var = __uiGroups[i].dials[j].varMax;
                        else
                            *__uiGroups[i].dials[j].var = __uiGroups[i].dials[j].varMin;
                        end
                    end
                    if (*__uiGroups[i].dials[j].var > __uiGroups[i].dials[j].varMax)
                        if (__uiGroups[i].dials[j].varWrapValue)
                            *__uiGroups[i].dials[j].var = __uiGroups[i].dials[j].varMin;
                        else
                            *__uiGroups[i].dials[j].var = __uiGroups[i].dials[j].varMax;
                        end
                    end
                    lastDialTick = timer[0];
                end
            end
        else
            lastDialTick = 0;
        end
        frame;
    until (alive == false)
end

function DispatchAction(actionId, actionParam0)
begin
    // TODO: Consider using an action queue to avoid overwriting an action.
    __ui.action = actionId;
    __ui.actionParam0 = actionParam0;
end

process MouseCursor()
private
    previousMouseLeft;
    previousMouseRight;
begin
    // initialization
    resolution = GPR;
    SetGraphic(GFX_MAIN, 303);
    z = -1000;
    loop
        x = mouse.x * GPR;
        y = mouse.y * GPR;
        __mouse.leftHeldDown = mouse.left;
        __mouse.rightHeldDown = mouse.right;
        __mouse.leftClicked = previousMouseLeft && !mouse.left;
        __mouse.rightClicked = previousMouseRight && !mouse.right;
        previousMouseLeft = mouse.left;
        previousMouseRight = mouse.right;
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * UI Rendering
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
        RenderUIDials();
        RenderUICheckboxes();
        frame;
        DeleteAllUIDrawings();
        DeleteAllUITexts();
    until (alive == false)
end

function RenderUIButtons()
private
    j, k;
    w, h;
    c, o;
    hover = false;
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (j = 0; j < __uiGroups[i].buttonsCount; ++j)
            x = __uiGroups[i].buttons[j].x;
            y = __uiGroups[i].buttons[j].y;
            w = __uiGroups[i].buttons[j].width;
            h = __uiGroups[i].buttons[j].height;
            k = __uiGroups[i].buttons[j].colorScheme;
            c = __colorSchemes[k].color.normal;
            o = __colorSchemes[k].opacity.normal;

            if (__uiGroups[i].buttons[j].enabled)
                hover = RectangleContainsPoint(x, y, x + w, y + h, mouse.x, mouse.y);
                if (hover)
                    c = __colorSchemes[k].color.hover;
                    o = __colorSchemes[k].opacity.hover;
                else
                    c = __colorSchemes[k].color.normal;
                    o = __colorSchemes[k].opacity.normal;
                end

                if (hover)
                    if (__mouse.leftHeldDown)
                        c = __colorSchemes[k].color.pressed;
                        o = __colorSchemes[k].opacity.pressed;
                        __ui.buttonHeldDown = __uiGroups[i].buttons[j].action;
                    end
                    if (!__mouse.leftHeldDown 
                        && __ui.buttonHeldDown == __uiGroups[i].buttons[j].action)
                        c = __colorSchemes[k].color.hover;
                        o = __colorSchemes[k].opacity.hover;
                        __ui.buttonHeldDown = NULL;
                        __ui.buttonClicked = __uiGroups[i].buttons[j].action;
                    end
                end
            else
                c = __colorSchemes[k].color.disabled;
                o = __colorSchemes[k].opacity.disabled;
            end

            RenderUIDrawing(DRAW_RECTANGLE_FILL, c, o, REGION_FULL_SCREEN, x, y, x + w, y + h);

            if (__uiGroups[i].buttons[j].action == NULL)
                __uiGroups[i].buttons[j].text = "[NULL]";
            else
                __uiGroups[i].buttons[j].text = __uiButtons[__uiGroups[i].buttons[j].action].label;
            end

            RenderUIText(
                __uiGroups[i].buttons[j].fontIndex,
                x + (w / 2),
                y + (h / 2),
                FONT_ANCHOR_CENTERED,
                __uiGroups[i].buttons[j].text);
        end
    end
    if (!__mouse.leftHeldDown)
        __ui.buttonHeldDown = NULL;
    end
end

function RenderUICheckboxes()
private
    j, k;
    w, h;
    c, o;
    hover = false;
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (j = 0; j < __uiGroups[i].checkboxesCount; ++j)
            x = __uiGroups[i].checkboxes[j].x;
            y = __uiGroups[i].checkboxes[j].y;
            w = UI_UNIT * 5;
            h = UI_UNIT * 5;
            k = __uiGroups[i].checkboxes[j].colorScheme;
            c = __colorSchemes[k].color.normal;
            o = __colorSchemes[k].opacity.normal;

            if (__uiGroups[i].checkboxes[j].enabled)
                hover = RectangleContainsPoint(
                    x - (w / 2), y - (h / 2), x + (w / 2), y + (h / 2), mouse.x, mouse.y);
                if (hover)
                    c = __colorSchemes[k].color.hover;
                    o = __colorSchemes[k].opacity.hover;
                    if (__mouse.leftClicked)
                        if (*__uiGroups[i].checkboxes[j].var == true)
                            *__uiGroups[i].checkboxes[j].var = false;
                        else
                            *__uiGroups[i].checkboxes[j].var = true;
                        end
                    end
                else
                    c = __colorSchemes[k].color.normal;
                    o = __colorSchemes[k].opacity.normal;
                end

                if (hover)
                    if (__mouse.leftHeldDown)
                        c = __colorSchemes[k].color.pressed;
                        o = __colorSchemes[k].opacity.pressed;
                    end
                end
            else
                c = __colorSchemes[k].color.disabled;
                o = __colorSchemes[k].opacity.disabled;
            end

            RenderUIDrawing(DRAW_RECTANGLE_FILL, c, o, REGION_FULL_SCREEN,
                x - (w / 2), y - (h / 2), x + (w / 2), y + (h / 2));

            if (*__uiGroups[i].checkboxes[j].var == true)
                RenderUIDrawing(DRAW_ELLIPSE_FILL, COLOR_WHITE, OPACITY_SOLID, REGION_FULL_SCREEN,
                    x - (w / 3), y - (h / 3), x + (w / 3), y + (h / 3));
            end
        end
    end
end

function RenderUIDials()
private
    j, k;
    w, h;
    kx, ky, kw, kh;
    c, o;
    hover = false;
    dialDistance;
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (j = 0; j < __uiGroups[i].dialsCount; ++j)
            x = __uiGroups[i].dials[j].x;
            y = __uiGroups[i].dials[j].y;
            w = UI_UNIT * 5;
            h = UI_UNIT * 5;
            k = __uiGroups[i].dials[j].colorScheme;
            kw = UI_UNIT;
            kh = UI_UNIT;
            kx = x;
            ky = y - kh - 1;
            c = __colorSchemes[k].color.normal;
            o = __colorSchemes[k].opacity.normal;

            if (__uiGroups[i].dials[j].enabled)
                hover = CircleContainsPoint(x, y, w / 2, mouse.x, mouse.y);
                if (hover)
                    c = __colorSchemes[k].color.hover;
                    o = __colorSchemes[k].opacity.hover;
                else
                    c = __colorSchemes[k].color.normal;
                    o = __colorSchemes[k].opacity.normal;
                end

                if (hover)
                    if (__mouse.leftHeldDown)
                        c = __colorSchemes[k].color.pressed;
                        o = __colorSchemes[k].opacity.pressed;
                        __ui.dial.active       = true;
                        __ui.dial.state        = 0;
                        __ui.dial.uiGroupIndex = i;
                        __ui.dial.dialIndex    = j;
                        __ui.dial.clickX       = mouse.x;
                    end
                end
            else
                c = __colorSchemes[k].color.disabled;
                o = __colorSchemes[k].opacity.disabled;
            end

            if (__ui.dial.active 
                && __ui.dial.uiGroupIndex == i
                && __ui.dial.dialIndex == j)
                // set dial state
                dialDistance = mouse.x - __ui.dial.clickX;
                if (abs(dialDistance) > UI_DIAL_DEAD_ZONE_WIDTH)
                    __ui.dial.state = dialDistance / abs(dialDistance);
                    if (abs(dialDistance) > UI_DIAL_SLOW_ZONE_WIDTH)
                        __ui.dial.state *= 2;
                    end
                else
                    __ui.dial.state = 0;
                end
                // set dial knob offset based on state
                switch (__ui.dial.state)
                    case -2:
                        kx -= UI_UNIT;
                        ky += (UI_UNIT / 2) + 1;
                    end
                    case -1:
                        kx -= UI_UNIT / 2;
                        ky += 1;
                    end
                    case 1:
                        kx += UI_UNIT / 2;
                        ky += 1;
                    end
                    case 2:
                        kx += UI_UNIT;
                        ky += (UI_UNIT / 2) + 1;
                    end
                end
            end

            RenderUIDrawing(DRAW_ELLIPSE_FILL, c, o, REGION_FULL_SCREEN,
                x - (w / 2), y - (h / 2), x + (w / 2), y + (h / 2));
            RenderUIDrawing(DRAW_ELLIPSE_FILL, COLOR_WHITE, OPACITY_SOLID, REGION_FULL_SCREEN,
                kx - (kw / 2), ky - (kh / 2), kx + (kw / 2), ky + (kh / 2));
            RenderUITextInteger(
                __uiGroups[i].dials[j].fontIndex,
                __uiGroups[i].dials[j].x + w,
                __uiGroups[i].dials[j].y,
                FONT_ANCHOR_CENTER_LEFT,
                __uiGroups[i].dials[j].var);
        end
    end
    if (!__mouse.leftHeldDown)
        __ui.dial.active       = false;
        __ui.dial.state        = 0;
        __ui.dial.uiGroupIndex = NULL;
        __ui.dial.dialIndex    = NULL;
        __ui.dial.clickX       = NULL;
    end
end

function RenderUIDrawings()
private
    j;
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (j = 0; j < __uiGroups[i].drawingsCount; ++j)
            RenderUIDrawing(
                __uiGroups[i].drawings[j].drawType,
                __uiGroups[i].drawings[j].color,
                __uiGroups[i].drawings[j].opacity,
                REGION_FULL_SCREEN,
                __uiGroups[i].drawings[j].x0,
                __uiGroups[i].drawings[j].y0,
                __uiGroups[i].drawings[j].x1,
                __uiGroups[i].drawings[j].y1);
        end
    end
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
                __uiGroups[i].images[j].size,
                __uiGroups[i].images[j].flags);
        end
    end
end

function RenderUITexts()
private
    j;
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (j = 0; j < __uiGroups[i].textsCount; ++j)
            if (__uiGroups[i].texts[j].isInteger)
                RenderUITextInteger(
                    __uiGroups[i].texts[j].fontIndex,
                    __uiGroups[i].texts[j].x,
                    __uiGroups[i].texts[j].y,
                    __uiGroups[i].texts[j].anchor,
                    __uiGroups[i].texts[j].var);
            else
                RenderUIText(
                    __uiGroups[i].texts[j].fontIndex,
                    __uiGroups[i].texts[j].x,
                    __uiGroups[i].texts[j].y,
                    __uiGroups[i].texts[j].anchor,
                    __uiGroups[i].texts[j].text);
            end
        end
    end
end

function RenderUITextFields()
private
    j, k;
    w, h;
    c, o;
    hc, ho;
    hover = false;
begin
    __ui.activeTextFieldId = NULL;
    for (i = 0; i < __uiGroupsCount; ++i)
        if (!__uiGroups[i].visible)
            continue;
        end
        for (j = 0; j < __uiGroups[i].textFieldsCount; ++j)
            x = __uiGroups[i].textFields[j].x;
            y = __uiGroups[i].textFields[j].y;
            w = __uiGroups[i].textFields[j].width;
            h = __uiGroups[i].textFields[j].height;
            k = __uiGroups[i].textFields[j].colorScheme;
            c = __colorSchemes[k].color.normal;
            o = __colorSchemes[k].opacity.normal;
            hc = __colorSchemes[k].color.hover;
            ho = __colorSchemes[k].opacity.hover;

            if (__uiGroups[i].textFields[j].enabled)
                if (__uiGroups[i].textFields[j].active == ACTIVE)
                    hc = __colorSchemes[k].color.highlight;
                    ho = __colorSchemes[k].opacity.highlight;
                    __uiGroups[i].textFields[j].text = UpdateTextField(__uiGroups[i].textFields[j].text);
                    if (key(_esc) || __mouse.rightClicked)
                        __ui.submittedTextFieldId = __uiGroups[i].textFields[j].textFieldId;
                        __ui.submittedText = __uiGroups[i].textFields[j].text;
                        __uiGroups[i].textFields[j].active = INACTIVE;
                    end
                    if (key(_del))
                        __uiGroups[i].textFields[j].text = "";
                    end
                    if (key(_enter))
                        __ui.submittedTextFieldId = __uiGroups[i].textFields[j].textFieldId;
                        __ui.submittedText = __uiGroups[i].textFields[j].text;
                        __uiGroups[i].textFields[j].active = INACTIVE;
                    end
                else
                    hover = RectangleContainsPoint(x, y, x + w, y + h, mouse.x, mouse.y);
                    if (hover)
                        c = __colorSchemes[k].color.hover;
                        o = __colorSchemes[k].opacity.hover;
                        hc = __colorSchemes[k].color.highlight;
                        ho = __colorSchemes[k].opacity.highlight;
                        if (__mouse.leftHeldDown)
                            c = __colorSchemes[k].color.pressed;
                            o = __colorSchemes[k].opacity.pressed;
                            hc = __colorSchemes[k].color.normal;
                            ho = __colorSchemes[k].opacity.normal;
                        end
                        if (__mouse.leftClicked)
                            __uiGroups[i].textFields[j].active = ACTIVE;
                            c = __colorSchemes[k].color.normal;
                            o = __colorSchemes[k].opacity.normal;
                            hc = __colorSchemes[k].color.highlight;
                            ho = __colorSchemes[k].opacity.highlight;
                        end
                    else
                        c = __colorSchemes[k].color.normal;
                        o = __colorSchemes[k].opacity.normal;
                    end
                end
                if (__uiGroups[i].textFields[j].active == ACTIVE)
                    __ui.activeTextFieldId = __uiGroups[i].textFields[j].textFieldId;
                end
            else
                c = __colorSchemes[k].color.disabled;
                o = __colorSchemes[k].opacity.disabled;
                hc = __colorSchemes[k].color.disabled;
                ho = __colorSchemes[k].opacity.disabled;
            end

            RenderUIDrawing(DRAW_RECTANGLE_FILL, c, o, REGION_FULL_SCREEN, x, y, x + w, y + h);
            RenderUIDrawing(DRAW_RECTANGLE, hc, ho, REGION_FULL_SCREEN, x, y, x + w, y + h);

            if (__uiGroups[i].textFields[j].text == "")
                RenderUIText(
                    __uiGroups[i].textFields[j].fontIndex,
                    x + (w / 2), y + (h / 2),
                    __uiGroups[i].textFields[j].anchor,
                    "...");
            else
                RenderUIText(
                    __uiGroups[i].textFields[j].fontIndex,
                    x + (w / 2), y + (h / 2),
                    __uiGroups[i].textFields[j].anchor,
                    __uiGroups[i].textFields[j].text);
            end
        end
    end
end

function RenderUIDrawing(drawType, color, opacity, region, x0, y0, x1, y1)
begin
    if (__ui.drawingsCount == MAX_UI_DRAWINGS)
        return;
    end
    __ui.drawings[__ui.drawingsCount].handle = 
        draw(drawType, color, opacity, region, x0, y0, x1, y1);
    ++__ui.drawingsCount;
end

process RenderImageOneFrame(x, y, z, fileIndex, gfxIndex, angle, size, flags)
begin
    SetGraphic(fileIndex, gfxIndex);
    frame;
end

function RenderUIText(fontIndex, x, y, anchor, text)
begin
    if (__ui.textsCount == MAX_UI_TEXTS)
        return;
    end
    __ui.texts[__ui.textsCount].handle = 
        write(__fonts[fontIndex].handle, x, y, anchor, text);
    ++__ui.textsCount;
end

function RenderUITextInteger(fontIndex, x, y, anchor, var)
begin
    if (__ui.textsCount == MAX_UI_TEXTS)
        return;
    end
    __ui.texts[__ui.textsCount].handle = 
        write_int(__fonts[fontIndex].handle, x, y, anchor, var);
    ++__ui.textsCount;
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

function GetTextFieldValue(ui, textFieldId)
begin
    for (i = 0; i < __uiGroups[ui].textFieldsCount; ++i)
        if (__uiGroups[ui].textFields[i].textFieldId == textFieldId)
            return (__uiGroups[ui].textFields[i].text);
        end
    end
    return ("");
end

function SetTextFieldValue(ui, textFieldId, string text)
begin
    for (i = 0; i < __uiGroups[ui].textFieldsCount; ++i)
        if (__uiGroups[ui].textFields[i].textFieldId == textFieldId)
            __uiGroups[ui].textFields[i].text = text;
            return;
        end
    end
end

function IsTextFieldActive(ui, textFieldId)
begin
    for (i = 0; i < __uiGroups[ui].textFieldsCount; ++i)
        if (__uiGroups[ui].textFields[i].textFieldId == textFieldId)
            return (__uiGroups[ui].textFields[i].active);
        end
    end
    return (false);
end

function DeleteAllUIDrawings()
begin
    for (i = 0; i < __ui.drawingsCount; ++i)
        delete_draw(__ui.drawings[i].handle);
        __ui.drawings[i].handle = 0;
    end
    __ui.drawingsCount = 0;
end

function DeleteAllUITexts()
begin
    for (i = 0; i < __ui.textsCount; ++i)
        delete_text(__ui.texts[i].handle);
        __ui.texts[i].handle = 0;
    end
    __ui.textsCount = 0;
end

process RenderGfxPointsOneFrame(x, y, 
    fileIndex, gfxIndex, angle, size, resolution, 
    color, opacity, region, scrollSpace)
private
    pointsCount;
begin
    SetGraphic(fileIndex, gfxIndex);
    pointsCount = CountGfxPoints(fileIndex, gfxIndex);
    FindGfxPoints(id, pointsCount);
    graph = NULL;
    DrawGfxPointsOneFrame(pointsCount, color, opacity, region, scrollSpace);
    frame;
end



/* -----------------------------------------------------------------------------
 * UI Configuration
 * ---------------------------------------------------------------------------*/
function AddButtonToUIGroup(ui, x, y, width, height,
    colorScheme,
    fontIndex, action, enabled)
begin
    i = __uiGroups[ui].buttonsCount;
    __uiGroups[ui].buttons[i].x = x;
    __uiGroups[ui].buttons[i].y = y;
    __uiGroups[ui].buttons[i].width = width;
    __uiGroups[ui].buttons[i].height = height;
    __uiGroups[ui].buttons[i].colorScheme = colorScheme;
    __uiGroups[ui].buttons[i].fontIndex = fontIndex;
    __uiGroups[ui].buttons[i].action = action;
    __uiGroups[ui].buttons[i].enabled = enabled;
    __uiGroups[ui].buttonsCount++;
end

function AddCheckboxToUIGroup(ui, x, y, 
    colorScheme,
    var, enabled)
begin
    i = __uiGroups[ui].checkboxesCount;
    __uiGroups[ui].checkboxes[i].x = x;
    __uiGroups[ui].checkboxes[i].y = y;
    __uiGroups[ui].checkboxes[i].colorScheme = colorScheme;
    __uiGroups[ui].checkboxes[i].var = var;
    __uiGroups[ui].checkboxes[i].enabled = enabled;
    __uiGroups[ui].checkboxesCount++;
end

function AddDialToUIGroup(ui, x, y,
    colorScheme, fontIndex, 
    var, varMin, varMax, varWrapValue,
    delaySlow, delayFast, deltaSlow, deltaFast, enabled)
begin
    i = __uiGroups[ui].dialsCount;
    __uiGroups[ui].dials[i].x = x;
    __uiGroups[ui].dials[i].y = y;
    __uiGroups[ui].dials[i].colorScheme = colorScheme;
    __uiGroups[ui].dials[i].fontIndex = fontIndex;
    __uiGroups[ui].dials[i].var = var;
    __uiGroups[ui].dials[i].varMin = varMin;
    __uiGroups[ui].dials[i].varMax = varMax;
    __uiGroups[ui].dials[i].varWrapValue = varWrapValue;
    __uiGroups[ui].dials[i].delaySlow = delaySlow;
    __uiGroups[ui].dials[i].delayFast = delayFast;
    __uiGroups[ui].dials[i].deltaSlow = deltaSlow;
    __uiGroups[ui].dials[i].deltaFast = deltaFast;
    __uiGroups[ui].dials[i].enabled = enabled;
    __uiGroups[ui].dialsCount++;
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

function AddImageToUIGroup(ui, x, y, z, fileIndex, gfxIndex, angle, size, flags)
begin
    i = __uiGroups[ui].imagesCount;
    __uiGroups[ui].images[i].x = x;
    __uiGroups[ui].images[i].y = y;
    __uiGroups[ui].images[i].z = z;
    __uiGroups[ui].images[i].fileIndex = fileIndex;
    __uiGroups[ui].images[i].gfxIndex = gfxIndex;
    __uiGroups[ui].images[i].angle = angle;
    __uiGroups[ui].images[i].size = size;
    __uiGroups[ui].images[i].flags = flags;
    __uiGroups[ui].imagesCount++;
end

function AddTextToUIGroup(ui, x, y, fontIndex, anchor, text, isInteger)
begin
    i = __uiGroups[ui].textsCount;
    __uiGroups[ui].texts[i].x = x;
    __uiGroups[ui].texts[i].y = y;
    __uiGroups[ui].texts[i].fontIndex = fontIndex;
    __uiGroups[ui].texts[i].anchor = anchor;
    __uiGroups[ui].texts[i].isInteger = isInteger;
    if (isInteger)
        __uiGroups[ui].texts[i].var = text;
    else
        __uiGroups[ui].texts[i].text = text;
    end
    __uiGroups[ui].textsCount++;
end

function AddTextFieldToUIGroup(ui, x, y, width, height, 
    colorScheme, fontIndex, anchor, 
    text, textFieldId, active, enabled)
begin
    i = __uiGroups[ui].textFieldsCount;
    __uiGroups[ui].textFields[i].x = x;
    __uiGroups[ui].textFields[i].y = y;
    __uiGroups[ui].textFields[i].width = width;
    __uiGroups[ui].textFields[i].height = height;
    __uiGroups[ui].textFields[i].colorScheme = colorScheme;
    __uiGroups[ui].textFields[i].fontIndex = fontIndex;
    __uiGroups[ui].textFields[i].anchor = anchor;
    __uiGroups[ui].textFields[i].text = text;
    __uiGroups[ui].textFields[i].textFieldId = textFieldId;
    __uiGroups[ui].textFields[i].active = active;
    __uiGroups[ui].textFields[i].enabled = enabled;
    __uiGroups[ui].textFieldsCount++;
end

function ClearUIGroup(ui)
begin
    __uiGroups[ui].visible = false;
    __uiGroups[ui].buttonsCount = 0;
    for (i = 0; i < MAX_UI_GROUP_BUTTONS - 1; ++i)
        __uiGroups[ui].buttons[i].x               = 0;
        __uiGroups[ui].buttons[i].y               = 0;
        __uiGroups[ui].buttons[i].width           = 0;
        __uiGroups[ui].buttons[i].height          = 0;
        __uiGroups[ui].buttons[i].colorScheme     = 0;
        __uiGroups[ui].buttons[i].fontIndex       = 0;
        __uiGroups[ui].buttons[i].action          = 0;
        __uiGroups[ui].buttons[i].text            = "";
        __uiGroups[ui].buttons[i].enabled         = 0;
    end
    __uiGroups[ui].checkboxesCount = 0;
    for (i = 0; i < MAX_UI_GROUP_CHECKBOXES - 1; ++i)
        __uiGroups[ui].checkboxes[i].x               = 0;
        __uiGroups[ui].checkboxes[i].y               = 0;
        __uiGroups[ui].checkboxes[i].colorScheme     = 0;
        __uiGroups[ui].checkboxes[i].var             = NULL;
        __uiGroups[ui].checkboxes[i].enabled         = 0;
    end
    __uiGroups[ui].dialsCount = 0;
    for (i = 0; i < MAX_UI_GROUP_DIALS - 1; ++i)
        __uiGroups[ui].dials[i].x               = 0;
        __uiGroups[ui].dials[i].y               = 0;
        __uiGroups[ui].dials[i].colorScheme     = 0;
        __uiGroups[ui].dials[i].fontIndex       = 0;
        __uiGroups[ui].dials[i].var             = NULL;
        __uiGroups[ui].dials[i].varMin          = 0;
        __uiGroups[ui].dials[i].varMax          = 0;
        __uiGroups[ui].dials[i].varWrapValue    = 0;
        __uiGroups[ui].dials[i].delaySlow       = 0;
        __uiGroups[ui].dials[i].delayFast       = 0;
        __uiGroups[ui].dials[i].deltaSlow       = 0;
        __uiGroups[ui].dials[i].deltaFast       = 0;
        __uiGroups[ui].dials[i].enabled         = 0;
    end
    __uiGroups[ui].drawingsCount = 0;
    for (i = 0; i < MAX_UI_GROUP_BUTTONS - 1; ++i)
        __uiGroups[ui].drawings[i].x0       = 0;
        __uiGroups[ui].drawings[i].y0       = 0;
        __uiGroups[ui].drawings[i].x1       = 0;
        __uiGroups[ui].drawings[i].y1       = 0;
        __uiGroups[ui].drawings[i].drawType = 0;
        __uiGroups[ui].drawings[i].color    = 0;
        __uiGroups[ui].drawings[i].opacity  = 0;
    end
    __uiGroups[ui].imagesCount = 0;
    for (i = 0; i < MAX_UI_GROUP_IMAGES - 1; ++i)
        __uiGroups[ui].images[i].x         = 0;
        __uiGroups[ui].images[i].y         = 0;
        __uiGroups[ui].images[i].z         = 0;
        __uiGroups[ui].images[i].fileIndex = 0;
        __uiGroups[ui].images[i].gfxIndex  = 0;
        __uiGroups[ui].images[i].angle     = 0;
        __uiGroups[ui].images[i].size      = 0;
        __uiGroups[ui].images[i].flags     = 0;
    end
    __uiGroups[ui].textsCount = 0;
    for (i = 0; i < MAX_UI_GROUP_TEXTS - 1; ++i)
        __uiGroups[ui].texts[i].x         = 0;
        __uiGroups[ui].texts[i].y         = 0;
        __uiGroups[ui].texts[i].fontIndex = 0;
        __uiGroups[ui].texts[i].anchor    = 0;
        __uiGroups[ui].texts[i].text      = "";
        __uiGroups[ui].texts[i].var       = 0;
        __uiGroups[ui].texts[i].isInteger = false;
    end
    __uiGroups[ui].textFieldsCount = 0;
    for (i = 0; i < MAX_UI_GROUP_TEXTS - 1; ++i)
        __uiGroups[ui].textFields[i].textFieldId = NULL;
        __uiGroups[ui].textFields[i].x           = 0;
        __uiGroups[ui].textFields[i].y           = 0;
        __uiGroups[ui].textFields[i].width       = 0;
        __uiGroups[ui].textFields[i].height      = 0;
        __uiGroups[ui].textFields[i].colorScheme = 0;
        __uiGroups[ui].textFields[i].fontIndex   = 0;
        __uiGroups[ui].textFields[i].anchor      = 0;
        __uiGroups[ui].textFields[i].text        = "";
        __uiGroups[ui].textFields[i].active      = 0;
        __uiGroups[ui].textFields[i].enabled     = 0;
    end
end

function ClearAllUIGroups()
private
    ui;
begin
    for (ui = 0; ui < MAX_UI_GROUPS - 1; ++ui)
        ClearUIGroup(ui);
    end
    __uiGroupsCount = 0;
end

function ShowUIGroup(ui)
begin
    __uiGroups[ui].visible = true;
end

function HideUIGroup(ui)
begin
    // reset text fields
    for (i = 0; i < __uiGroups[ui].textFieldsCount; ++i)
        __uiGroups[ui].textFields[i].text = "";
    end
    __uiGroups[ui].visible = false;
end

function HideAllUIGroups()
begin
    for (i = 0; i < __uiGroupsCount; ++i)
        HideUIGroup(i);
    end
end



/* -----------------------------------------------------------------------------
 * Initialization & Resources
 * ---------------------------------------------------------------------------*/
function InitGraphics()
begin
    set_mode(SCREEN_MODE);
    set_fps(60, 1);

    DefineRegions();
end

function DefineRegions()
begin
    for (i = 1; i < REGION_COUNT; ++i)
        define_region(i, __regions[i].x, __regions[i].y, __regions[i].width, __regions[i].height);
    end
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

function LoadData()
begin
    LoadObjectData();
    LoadLevelFileData();
    LevelData_Clear();
end



// TODO: Refactor function names to use ObjectData_ prefix.
/* -----------------------------------------------------------------------------
 * Object Data
 * ---------------------------------------------------------------------------*/
function ClearObjectData()
begin
    for (i = 0; i < __objectDataCount; ++i)
        __objectData[i].name       = "";
        __objectData[i].angle      = 0;
        __objectData[i].size       = 100;
        __objectData[i].z          = 0;
        __objectData[i].gfxIndex   = 1;
        __objectData[i].material   = 0;
        __objectData[i].collidable = true;
    end
    __objectDataCount = 0;
end

function LoadObjectData()
begin
    ClearObjectData();

    // TODO: FIX THIS PATH HACK :( 
    // NOTE: DIV appears to have no way of retrieving the relative project path... see forum post:
    // http://div-arena.co.uk/forum2/viewthread.php?tid=288
    // NOTE: If this is still a problem at build/release time, use a table of hardcoded paths.
    chdir("C:\Projects\DIV\faust2\" + DATA_OBJECTS_PATH);

    // get list of object files in dirinfo struct
    get_dirinfo("*.*", _normal);

    __objectDataCount = dirinfo.files;

    for (i = 0; i < __objectDataCount; ++i)
        LoadObject(i, dirinfo.name[i]);
    end

    // make sure level objects are using the correct data indices of the freshly loaded object data
    LevelData_UpdateObjectsDataIndices();
end

function GetObjectDataIndexFromName(string name)
begin
    for (i = 0; i < __objectDataCount; ++i)
        if (__objectData[i].name == name)
            return (i);
        end
    end
    return (NULL);
end

function ObjectFileExists(string fileName)
begin
    fileName = fileName + ".obj";
    for (i = 0; i < dirinfo.files; ++i)
        if (dirinfo.name[i] == fileName)
            return (true);
        end
    end
    return (false);
end

function LoadObject(objectIndex, string fileName)
private
    fileHandle;
    obj_angle, obj_size, obj_z, obj_gfxIndex, obj_material, obj_collidable;
begin
    // open file handle
    fileHandle = fopen(DATA_OBJECTS_PATH + fileName, "r");

    // read object data
    fread(offset obj_angle,      sizeof(obj_angle),      fileHandle);
    fread(offset obj_size,       sizeof(obj_size),       fileHandle);
    fread(offset obj_z,          sizeof(obj_z),          fileHandle);
    fread(offset obj_gfxIndex,   sizeof(obj_gfxIndex),   fileHandle);
    fread(offset obj_material,   sizeof(obj_material),   fileHandle);
    fread(offset obj_collidable, sizeof(obj_collidable), fileHandle);

    // cut off file extension
    strdel(fileName, 0, 4);

    // pass data to global struct
    __objectData[objectIndex].name       = fileName;
    __objectData[objectIndex].angle      = obj_angle;
    __objectData[objectIndex].size       = obj_size;
    __objectData[objectIndex].z          = obj_z;
    __objectData[objectIndex].gfxIndex   = obj_gfxIndex;
    __objectData[objectIndex].material   = obj_material;
    __objectData[objectIndex].collidable = obj_collidable;

    // count points from object graphic
    __objectData[objectIndex].pointsCount = CountGfxPoints(GFX_OBJECTS, obj_gfxIndex);

    // close file handle
    fclose(fileHandle);
end

function SaveObject(string fileName, obj_angle, obj_size, obj_z, obj_gfxIndex, obj_material, obj_collidable)
private
    fileHandle;
begin
    // open file handle
    fileName = fileName + ".obj";
    fileHandle = fopen(DATA_OBJECTS_PATH + fileName, "w");

    // write object data
    fwrite(offset obj_angle,      sizeof(obj_angle),      fileHandle);
    fwrite(offset obj_size,       sizeof(obj_size),       fileHandle);
    fwrite(offset obj_z,          sizeof(obj_z),          fileHandle);
    fwrite(offset obj_gfxIndex,   sizeof(obj_gfxIndex),   fileHandle);
    fwrite(offset obj_material,   sizeof(obj_material),   fileHandle);
    fwrite(offset obj_collidable, sizeof(obj_collidable), fileHandle);

    // close file handle
    fclose(fileHandle);
end



/* -----------------------------------------------------------------------------
 * Level File Data
 * ---------------------------------------------------------------------------*/
function ClearLevelFileData()
begin
    for (i = 0; i < __levelFileDataCount; ++i)
        __levelFileData[i].name = "";
    end
    __levelFileDataCount = 0;
end

function LoadLevelFileData()
begin
    // clear out struct before writing to it
    ClearLevelFileData();

    // TODO: FIX THIS PATH HACK :( 
    // NOTE: DIV appears to have no way of retrieving the relative project path... see forum post:
    // http://div-arena.co.uk/forum2/viewthread.php?tid=288
    // NOTE: If this is still a problem at build/release time, use a table of hardcoded paths.
    chdir("C:\Projects\DIV\faust2\" + DATA_LEVELS_PATH);

    // get list of object files in dirinfo struct
    get_dirinfo("*.*", _normal);

    __levelFileDataCount = dirinfo.files;
    for (i = 0; i < __levelFileDataCount; ++i)
        __levelFileData[i].name = dirinfo.name[i];
    end
end



/* -----------------------------------------------------------------------------
 * Level Data
 * ---------------------------------------------------------------------------*/
function LevelData_Clear()
begin
    __levelData.name = "";
    for (i = 0; i < MAX_LEVEL_OBJECTS - 1; ++i)
        LevelData_ClearObjectIndex(i);
    end
    __levelData.objectCount = 0;
end

function LevelData_ClearObjectIndex(i)
begin
    __levelData.objects[i].x                  = 0;
    __levelData.objects[i].y                  = 0;
    __levelData.objects[i].angle              = 0;
    __levelData.objects[i].size               = 0;
    __levelData.objects[i].z                  = 0;
    __levelData.objects[i].objectDataFileName = "";
    __levelData.objects[i].objectDataIndex    = NULL;
    __levelData.objects[i].processId          = NULL;
end

function LevelData_Load(string fileName)
private
    fileHandle;
    string lvlName;
    lvlObjectCount;
    lvlObjX, lvlObjY, lvlObjAngle, lvlObjSize, lvlObjZ, lvlObjFileName, lvlObjIndex;
begin
    // clear out struct before writing to it
    LevelData_Clear();

    fileHandle = fopen(DATA_LEVELS_PATH + fileName, "r");

    // read level meta data
    fread(offset lvlName,        sizeof(lvlName),        fileHandle);
    fread(offset lvlObjectCount, sizeof(lvlObjectCount), fileHandle);
    __levelData.name        = lvlName;
    __levelData.objectCount = lvlObjectCount;

    // read level object data
    for (i = 0; i < __levelData.objectCount; ++i)
        fread(offset lvlObjX,        sizeof(lvlObjX),        fileHandle);
        fread(offset lvlObjY,        sizeof(lvlObjY),        fileHandle);
        fread(offset lvlObjAngle,    sizeof(lvlObjAngle),    fileHandle);
        fread(offset lvlObjSize,     sizeof(lvlObjSize),     fileHandle);
        fread(offset lvlObjZ,        sizeof(lvlObjZ),        fileHandle);
        fread(offset lvlObjFileName, sizeof(lvlObjFileName), fileHandle);
        __levelData.objects[i].x                   = lvlObjX;
        __levelData.objects[i].y                   = lvlObjY;
        __levelData.objects[i].angle               = lvlObjAngle;
        __levelData.objects[i].size                = lvlObjSize;
        __levelData.objects[i].z                   = lvlObjZ;
        __levelData.objects[i].objectDataFileName  = lvlObjFileName;
    end

    fclose(fileHandle);

    LevelData_UpdateObjectsDataIndices();
end

function LevelData_Save(string fileName)
private
    fileHandle;
    string lvlName;
    lvlObjectCount;
    lvlObjX, lvlObjY, lvlObjAngle, lvlObjSize, lvlObjZ, lvlObjFileName, lvlObjIndex;
begin
    fileName = fileName + ".lvl";
    fileHandle = fopen(DATA_LEVELS_PATH + fileName, "w");

    // write level meta data
    lvlName        = __levelData.name;
    lvlObjectCount = __levelData.objectCount;
    fwrite(offset lvlName,        sizeof(lvlName),        fileHandle);
    fwrite(offset lvlObjectCount, sizeof(lvlObjectCount), fileHandle);

    // write level object data
    for (i = 0; i < __levelData.objectCount; ++i)
        if (__levelData.objects[i].objectDataIndex == NULL)
            debug;
        end
        lvlObjX         = __levelData.objects[i].x;
        lvlObjY         = __levelData.objects[i].y;
        lvlObjAngle     = __levelData.objects[i].angle;
        lvlObjSize      = __levelData.objects[i].size;
        lvlObjZ         = __levelData.objects[i].z;
        lvlObjFileName  = __levelData.objects[i].objectDataFileName;
        fwrite(offset lvlObjX,        sizeof(lvlObjX),        fileHandle);
        fwrite(offset lvlObjY,        sizeof(lvlObjY),        fileHandle);
        fwrite(offset lvlObjAngle,    sizeof(lvlObjAngle),    fileHandle);
        fwrite(offset lvlObjSize,     sizeof(lvlObjSize),     fileHandle);
        fwrite(offset lvlObjZ,        sizeof(lvlObjZ),        fileHandle);
        fwrite(offset lvlObjFileName, sizeof(lvlObjFileName), fileHandle);
    end

    fclose(fileHandle);
end

function LevelData_AddObject(x, y, angle, size, z, objectDataIndex, processId)
begin
    for (i = 0; i < __levelData.objectCount + 1; ++i)
        if (__levelData.objects[i].objectDataIndex == NULL)
            break;
        end
    end
    __levelData.objects[i].x                  = x;
    __levelData.objects[i].y                  = y;
    __levelData.objects[i].angle              = angle;
    __levelData.objects[i].size               = size;
    __levelData.objects[i].z                  = z;
    __levelData.objects[i].objectDataFileName = __objectData[objectDataIndex].name;
    __levelData.objects[i].objectDataIndex    = objectDataIndex;
    __levelData.objects[i].processId          = processId;
    ++__levelData.objectCount;
    return (i);
end

function LevelData_RemoveObject(processId)
private
    levelDataObjectIndex;
begin
    levelDataObjectIndex = LevelData_GetObjectIndex(processId);
    if (levelDataObjectIndex == NULL)
        debug;
    end
    LevelData_ClearObjectIndex(levelDataObjectIndex);
    // compress objects struct by 1 place
    for (i = levelDataObjectIndex; i < __levelData.objectCount - 1; ++i)
        __levelData.objects[i].x                  = __levelData.objects[i + 1].x;
        __levelData.objects[i].y                  = __levelData.objects[i + 1].y;
        __levelData.objects[i].angle              = __levelData.objects[i + 1].angle;
        __levelData.objects[i].size               = __levelData.objects[i + 1].size;
        __levelData.objects[i].z                  = __levelData.objects[i + 1].z;
        __levelData.objects[i].objectDataFileName = __levelData.objects[i + 1].objectDataFileName;
        __levelData.objects[i].objectDataIndex    = __levelData.objects[i + 1].objectDataIndex;
        __levelData.objects[i].processId          = __levelData.objects[i + 1].processId;
    end
    // clear last index
    LevelData_ClearObjectIndex(__levelData.objectCount);
    --__levelData.objectCount;
end

function LevelData_UpdateObject(processId)
begin
    i = LevelData_GetObjectIndex(processId);
    if (i == NULL)
        debug;
    end
    __levelData.objects[i].x                  = processId.x;
    __levelData.objects[i].y                  = processId.y;
    __levelData.objects[i].angle              = processId.angle;
    __levelData.objects[i].size               = processId.size;
    __levelData.objects[i].z                  = processId.z;
    __levelData.objects[i].objectDataFileName = __objectData[processId.value].name;
    __levelData.objects[i].objectDataIndex    = GetObjectDataIndexFromName(__objectData[processId.value].name);
    __levelData.objects[i].processId          = processId;
end

function LevelData_GetObjectIndex(processId)
begin
    for (i = 0; i < __levelData.objectCount; ++i)
        if (__levelData.objects[i].processId == processId)
            return (i);
        end
    end
    return (NULL);
end

function LevelData_UpdateObjectsDataIndices()
begin
    for (i = 0; i < __levelData.objectCount; ++i)
        __levelData.objects[i].objectDataIndex = 
            GetObjectDataIndexFromName(__levelData.objects[i].objectDataFileName);
    end
end



    // EDITOR SPECIFIC ---------------------------------------------------------
/* -----------------------------------------------------------------------------
 * Level
 * ---------------------------------------------------------------------------*/
function PopulateEditorLevel()
private
    objectDataIndex;
begin
    for (i = 0; i < __levelData.objectCount; ++i)
        __levelData.objects[i].processId = EditorObject(
            __levelData.objects[i].x,
            __levelData.objects[i].y,
            __levelData.objects[i].angle,
            __levelData.objects[i].size,
            __levelData.objects[i].z,
            __levelData.objects[i].objectDataIndex);
    end
end



/* -----------------------------------------------------------------------------
 * Level
 * ---------------------------------------------------------------------------*/
function PopulateLevel()
begin
    // TODO: implement;
    debug;
end



/* -----------------------------------------------------------------------------
 * Camera & scrolling
 * ---------------------------------------------------------------------------*/
process CameraController(region)
begin
    // configuration
    input.move.granularity = 10;
    resolution = GPR;
    ctype = c_scroll;
    z = -1000;

    // initialization
    __camera.processId = id;
    alive = true;
    start_scroll(
        0,
        __graphics[GFX_MAIN].handle, 200, 0,
        region,
        SCROLL_FOREGROUND_HORIZONTAL + SCROLL_FOREGROUND_VERTICAL);

    // components & sub-processes
    components.physics = Physics(id);
    components.input = CameraInput(id);
    ScrollFollower(id, region);

    // NOTE: Set targetMoveSpeed after initializing Physics component.
    physics.targetMoveSpeed = CAMERA_FREE_LOOK_MAX_SPEED;
    repeat
        frame;
    until (alive == false)
end

process CameraInput(controllerId)
begin
    repeat
        switch (__camera.moveMode)
            case NULL:
                controllerId.input.move.x = 0;
                controllerId.input.move.y = 0;
            end
            case CAMERA_MOVE_FREE_LOOK:
                if (key(_a))
                    controllerId.input.move.x = -controllerId.input.move.granularity;
                else 
                    if (key(_d))
                        controllerId.input.move.x = +controllerId.input.move.granularity;
                    else
                        controllerId.input.move.x = 0;
                    end
                end
                if (key(_w))
                    controllerId.input.move.y = -controllerId.input.move.granularity;
                else
                    if (key(_s))
                        controllerId.input.move.y = +controllerId.input.move.granularity;
                    else
                        controllerId.input.move.y = 0;
                    end
                end
            end
            case CAMERA_MOVE_PLAYER_LOOK:
                // TODO: Apply movement to input.
                //if (__camera.targetId != NULL)
                //    aimAngle = fget_angle(
                //        HALF_SCREEN_WIDTH,
                //        HALF_SCREEN_HEIGHT,
                //        mouse.x,
                //        mouse.y);
                //    aimDistance = fget_dist(
                //        HALF_SCREEN_WIDTH,
                //        HALF_SCREEN_HEIGHT,
                //        mouse.x,
                //        mouse.y);
                //    aimPointX = __cameraTargetId.x + get_distx(aimAngle, Min(aimDistance, aimMaxDistance)) * GPR * aimBoost;
                //    aimPointY = __cameraTargetId.y + get_disty(aimAngle, Min(aimDistance, aimMaxDistance)) * GPR * aimBoost;
                //    x = (__camera.targetId.x + aimPointX) / 2;
                //    y = (__camera.targetId.y + aimPointY) / 2;
                //    scroll[0].x0 = (x / GPR) - HALF_SCREEN_WIDTH;
                //    scroll[0].y0 = (y / GPR) - HALF_SCREEN_HEIGHT;
                //    //DrawScrollSpaceLine1Frame(__camera.targetId.x, __camera.targetId.y, aimPointX, aimPointY, COLOR_WHITE, OPACITY_SOLID);
                //end
            end
        end
        frame;
    until (controllerId.alive == false)
end

process ScrollFollower(controllerId, region)
begin
    repeat
        // Set scroll position.
        scroll[0].x0 = (controllerId.x / GPR) - (__regions[region].width / 2);
        scroll[0].y0 = (controllerId.y / GPR) - (__regions[region].height / 2);
        frame;
    until (controllerId.alive == false)
end



/* -----------------------------------------------------------------------------
 * Actor components
 * ---------------------------------------------------------------------------*/
process Physics(controllerId)
begin
    controllerId.physics.targetMoveSpeed = PHYSICS_MAX_MOVE_SPEED;
    repeat
        ApplyInputToVelocity(controllerId);
        ApplyVelocity(controllerId);
        frame;
    until (controllerId.alive == false)
end



/* -----------------------------------------------------------------------------
 * Process utilities
 * ---------------------------------------------------------------------------*/
function SetGraphic(fileIndex, gfxIndex)
begin
    father.file = __graphics[fileIndex].handle;
    father.graph = gfxIndex;
end

function CalculateFittedSize(fileIndex, gfxIndex, maxWidth, maxHeight)
private
    w, h;
    wf, hf;
begin
    w = graphic_info(fileIndex, gfxIndex, g_wide);
    h = graphic_info(fileIndex, gfxIndex, g_height);
    if (w > maxWidth)
        wf = (w * GPR) / maxWidth;
    else
        wf = GPR;
    end
    if (h > maxHeight)
        hf = (h * GPR) / maxHeight;
    else
        hf = GPR;
    end
    if (wf >= hf)
        return ((100 * GPR) / wf);
    end
    return ((100 * GPR) / hf);
end

function IsInsideScrollWindow(processId, scrollIndex, region)
begin
    return (processId.x >= (scroll[scrollIndex].x0) * processId.resolution
        && processId.y >= (scroll[scrollIndex].y0) * processId.resolution
        && processId.x < (scroll[scrollIndex].x0 + __regions[region].width) * processId.resolution
        && processId.y < (scroll[scrollIndex].y0 + __regions[region].height) * processId.resolution);
end

function CountGfxPoints(fileIndex, gfxIndex)
private
    pointX, pointY;
begin
    repeat
        pointX = 0;
        pointY = 0;
        get_point(__graphics[fileIndex].handle, gfxIndex, i + 1, &pointX, &pointY);
        if (pointX != 0 || pointY != 0)
            ++i;
        else
            break;
        end
    until (i >= 1000)
    return (i);
end

function FindGfxPoints(processId, pointsCount)
begin
    file       = processId.file;
    graph      = processId.graph;
    x          = processId.x;
    y          = processId.y;
    angle      = processId.angle;
    size       = processId.size;
    resolution = processId.resolution;
    ctype      = processId.ctype;
    for (i = 0; i < pointsCount; ++i)
        get_real_point(i + 1, &__gfxPoints[i].x, &__gfxPoints[i].y);
    end
end



/* -----------------------------------------------------------------------------
 * Drawing and writing functions
 * ---------------------------------------------------------------------------*/
function Draw(drawType, x0, y0, x1, y1, color, opacity, region, scrollSpace)
private
    sx, sy;
begin
    if (scrollSpace)
        sx = -scroll[0].x0;
        sy = -scroll[0].y0;
    end
    x0 = (x0 / GPR) + sx + __regions[region].x;
    y0 = (y0 / GPR) + sy + __regions[region].y;
    x1 = (x1 / GPR) + sx + __regions[region].x;
    y1 = (y1 / GPR) + sy + __regions[region].y;
    return (draw(drawType, color, opacity, region, x0, y0, x1, y1));
end

process DrawOneFrame(drawType, x0, y0, x1, y1, color, opacity, region, scrollSpace)
begin
    value = Draw(drawType, x0, y0, x1, y1, color, opacity, region, scrollSpace);
    frame;
    delete_draw(value);
end

process DrawGfxPointsOneFrame(pointsCount, color, opacity, region, scrollSpace)
private
    drawings[MAX_GFX_POINTS - 1];
    x0, y0, x1, y1;
begin
    for (i = 0; i < pointsCount; ++i)
        x0 = __gfxPoints[i].x;
        y0 = __gfxPoints[i].y;
        x1 = __gfxPoints[(i + 1) % pointsCount].x;
        y1 = __gfxPoints[(i + 1) % pointsCount].y;
        drawings[i] = Draw(
            DRAW_LINE,
            __gfxPoints[i].x, 
            __gfxPoints[i].y, 
            __gfxPoints[(i + 1) % pointsCount].x, 
            __gfxPoints[(i + 1) % pointsCount].y,
            color, opacity, region, scrollSpace);
    end
    frame;
    for (i = 0; i < pointsCount; ++i)
        delete_draw(drawings[i]);
    end
end



/* -----------------------------------------------------------------------------
 * Physics & Input functions
 * ---------------------------------------------------------------------------*/
function ApplyInputToVelocity(processId)
begin
    x = processId.input.move.x * processId.input.move.granularity;
    y = processId.input.move.y * processId.input.move.granularity;
    VectorNormalize(&x, &y, GPR);

    // TODO: Don't hard set the velocity, instead implement acceleration.
    processId.physics.velocity.x = x * processId.physics.targetMoveSpeed / GPR;
    processId.physics.velocity.y = y * processId.physics.targetMoveSpeed / GPR;
end

function ApplyVelocity(processId)
begin
    processId.x += processId.physics.velocity.x;
    processId.y += processId.physics.velocity.y;
end

/*
function InputMoveTowards(processId, x, y, walk)
begin
    x = x - processId.x;
    y = y - processId.y;
    VectorNormalize(&x, &y, 10);
    processId.input.move.x = x;
    processId.input.move.y = y;
    processId.input.move.walk = walk;
end

function InputMoveNone(processId)
begin
    processId.input.move.x = 0;
    processId.input.move.y = 0;
    processId.input.move.walk = INPUT_RUN;
end

function InputLookAt(processId, x, y)
begin
    processId.input.lookAt.x = x;
    processId.input.lookAt.y = y;
end
*/



/* -----------------------------------------------------------------------------
 * Math functions
 * ---------------------------------------------------------------------------*/
function RectangleContainsPoint(x0, y0, x1, y1, pointX, pointY)
begin
    return (pointX >= x0 && pointX <= x1 && pointY >= y0 && pointY <= y1);
end

function RegionContainsPoint(regionIndex, pointX, pointY)
begin
    return (RectangleContainsPoint(
        __regions[regionIndex].x, 
        __regions[regionIndex].y,
        __regions[regionIndex].width,
        __regions[regionIndex].height,
        pointX, pointY));
end

function CircleContainsPoint(x, y, radius, pointX, pointY)
begin
    return (fget_dist(x, y, pointX, pointY) <= radius);
end

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
    i = --__logging.logCount;
    delete_text(__logging.logs[i].txtLabel);
    delete_text(__logging.logs[i].txtVal);
    signal(__logging.logs[i].logId, s_kill_tree);
    __logging.logs[i].logId = 0;
    __logging.logs[i].txtLabel = 0;
    __logging.logs[i].txtVal = 0;
end

function DeleteLocalLog(processId)
begin
    i = --processId.logging.logCount;
    delete_text(processId.logging.logs[i].txtLabel);
    delete_text(processId.logging.logs[i].txtVal);
    signal(processId.logging.logs[i].logId, s_kill_tree);
    processId.logging.logs[i].logId = 0;
    processId.logging.logs[i].txtLabel = 0;
    processId.logging.logs[i].txtVal = 0;
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




