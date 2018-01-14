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
    MAX_LOGS = 32;

    // debug mode
    DEBUG_MODE = true;

// **** UNIQUE ****
    // ui
    MAX_MENU_OPTIONS = 5;
    
    // menu indices
    MENU_MAIN = 0;


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
    //  handle  path                      count
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
    //  handle  path                              avgCharWidth  lineHeight
        NULL,   NULL,                             7,            8,
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
    // TODO: Consider turning into table.
    struct __physics
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
        struct logs[MAX_LOGS - 1]
            logId;
            txtLabel;
            txtVal;
        end
    end

// **** UNIQUE ****
    // ui
    struct __menus[0]
        struct options[MAX_MENU_OPTIONS - 1]
            string label;
            index;
        end
    end =
    //  MENU_MAIN
    "NEW LEVEL",  0,
    "LOAD LEVEL", 1;

/* -----------------------------------------------------------------------------
 * Local variables (every process gets these)
 * ---------------------------------------------------------------------------*/
local
// **** COMMON ****
    // general purpose
    alive;
    i;
    
    struct logging
        logCount;
        struct logs[MAX_LOGS - 1]
            logId;
            txtLabel;
            txtVal;
        end
    end

// **** UNIQUE ****
    // ui
    struct ui
        active;
    end

/* -----------------------------------------------------------------------------
 * Main program
 * ---------------------------------------------------------------------------*/
begin
    // set graphics mode
    InitGraphics();
   
    // load resources
    LoadResources();

    // show menu
    ShowMenu(MENU_MAIN);
end



/* -----------------------------------------------------------------------------
 * UI
 * ---------------------------------------------------------------------------*/
function ShowMenu(menuIndex)
begin
    repeat
        frame;
    until (scan_code != 0)
end



                              /***************\
                              |* COMMON CODE *|
                              \***************/

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
        __sounds[i].handle = load_sound(__sounds[i].path, SOUND_PLAYBACK_ONCE);
    end
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

function CycleValue(currentValue, minValue, maxValue)
begin
    currentValue++;
    if (currentValue > maxValue)
        return (minValue);
    end
    return (currentValue);
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
        //i = GetNextGlobalLogIndex();
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
    for (i = 0; i < MAX_LOGS; i++)
        if (__logging.logs[i].logId <= 0)
            return (i);
        end
    end
    return (NULL);
end

function GetNextLocalLogIndex(processId)
begin
    for (i = 0; i < MAX_LOGS; i++)
        if (processId.logging.logs[i].logId <= 0)
            return (i);
        end
    end
    return (NULL);
end

function CleanUpLocalLogs(processId)
begin
    //y = processId.logging.logCount;
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
    for (x = 0; x < MAX_DELAYS; x++)
        if (__timing.delays[x].processId == processId)
            return (x);
        end
    end
    return (NULL);
end

function GetNextFreeDelayIndex()
begin
    for (x = 0; x < MAX_DELAYS; x++)
        if (__timing.delays[x].processId <= 0)
            return (x);
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



