/* =============================================================================
 * faust2.PRG by Casper
 * (c) 2017 altsrc
 * ========================================================================== */

COMPILER_OPTIONS _case_sensitive;

program Faust2;

/* -----------------------------------------------------------------------------
 * Constants
 * ---------------------------------------------------------------------------*/
const
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
    DRAW_LINE           = 1;
    DRAW_RECTANGLE      = 2;
    DRAW_RECTANGLE_FILL = 3;
    DRAW_ELLIPSE        = 4;
    DRAW_ELLIPSE_FILL   = 5;
    OPACITY_TRANSPARENT = 0;
    OPACITY_50_PERCENT  = 7;
    OPACITY_SOLID       = 15;

    // color enums
    COLOR_BLACK = 0;
    COLOR_WHITE = 15;
    COLOR_RED   = 22;
    COLOR_GREEN = 41;
    COLOR_BLUE  = 54;

    // null index value
    NULL = -1;

    // application state
    MENU_OPTION_NONE = 0;
    MENU_OPTION_PLAY = 1;
    GAME_STATE_NOT_STARTED  = 0;
    GAME_STATE_ACTIVE       = 1;
    GAME_STATE_PAUSED       = 2;
    GAME_STATE_GAME_OVER    = 3;
    GAME_STATE_LEVEL_EDITOR = 4;
    LEVEL_EDITOR_MODE_VIEW          = 0;
    LEVEL_EDITOR_MODE_EDIT_OBJECT   = 1;
    LEVEL_EDITOR_MODE_PAINT_OBJECTS = 2;

    // resources
    SOUND_MP40_SHOT       = 0;
    SOUND_SHELL_DROPPED_1 = 1;
    SOUND_SHELL_DROPPED_2 = 2;
    SOUND_SHELL_DROPPED_3 = 3;
    SOUND_KAR98K_SHOT     = 4;
    SOUNDS_COUNT = 5;
    FONT_SYSTEM = 0;
    FONT_MENU   = 1;

    // file paths
    GFX_MAIN_PATH     = "assets/graphics/main.fpg";
    GFX_ACTORS_PATH   = "assets/graphics/actors.fpg";
    GFX_ITEMS_PATH    = "assets/graphics/items.fpg";
    GFX_OBJECTS_PATH  = "assets/graphics/objects.fpg";
    FNT_MENU_PATH     = "assets/fonts/16x16-w-arcade.fnt";
    DATA_OBJECTS_PATH = "assets/data/objects/";

    // graphics
    SCREEN_MODE = m640x400;
    SCREEN_WIDTH       = 640;
    SCREEN_HEIGHT      = 400;
    HALF_SCREEN_WIDTH  = SCREEN_WIDTH / 2;
    HALF_SCREEN_HEIGHT = SCREEN_HEIGHT / 2;
    GPR = 10;
    GFX_OBJECTS_MAX = 2;

    // level editor
    OBJECT_EDIT_MODE_MAX = 2;

    // ui
    CURSOR_AIM_CIRCLE = 302;
    CURSOR_MENU       = 303;
    BUTTON_LEVEL_EDITOR_OBJECTS     = 0;
    BUTTON_LEVEL_EDITOR_ENTITIES    = 1;
    BUTTON_LEVEL_EDITOR_EDIT_OBJECT = 2;
    BUTTON_LEVEL_EDITOR_SAVE        = 3;
    BUTTON_LEVEL_EDITOR_LOAD        = 4;
    BUTTON_LEVEL_EDITOR_SEGMENTS    = 5;
    BUTTON_LEVEL_EDITOR_GRAPHIC     = 6;
    BUTTON_LEVEL_EDITOR_ASZ         = 7;
    BUTTON_LEVEL_EDITOR_MENU        = 8;
    UI_MAX_HANDLES = 32;

    // camera
    CAMERA_MOVE_FREE_LOOK   = 0;
    CAMERA_MOVE_PLAYER_LOOK = 1;
    CAMERA_FREE_LOOK_MAX_SPEED = 5 * GPR;

    // inventory & items
    INVENTORY_SLOTS = 5;
    ITEM_MP40       = 0;
    ITEM_KAR98K     = 1;
    ITEM_AMMO_9MM   = 2;
    ITEM_AMMO_RIFLE = 3;
    ITEM_TYPE_WEAPON     = 0;
    ITEM_TYPE_CONSUMABLE = 1;
    ITEM_TYPE_SPECIAL    = 2;
    ITEM_TYPE_AMMO       = 3;
    FIRING_MODE_SINGLE = 0;
    FIRING_MODE_AUTO   = 1;

    // physics
    PHYSICS_MAX_MOVE_SPEED = 10 * GPR;

    // projectiles
    BULLET_9MM   = 0;
    BULLET_RIFLE = 1;

    // actors
    ACTOR_PLAYER          = 0;
    ACTOR_GUARD_1         = 1;
    ACTOR_GUARD_2         = 2;
    ACTOR_GUARD_3         = 3;
    ACTOR_OFFICER_1       = 4;
    ACTOR_OFFICER_2       = 5;
    ACTOR_OFFICER_3       = 6;
    ACTOR_ALLIED_COMMANDO = 7;

    // factions
    FACTION_NEUTRAL = 0;
    FACTION_GOOD    = 1;
    FACTION_EVIL    = 2;

    // input
    INPUT_RUN  = 0;
    INPUT_WALK = 1;

    // AI
    AI_STATE_NONE        = 0;
    AI_STATE_IDLE        = 1;
    AI_STATE_RESET       = 2;
    AI_STATE_PATROL      = 3;
    AI_STATE_GUARD       = 4;
    AI_STATE_INVESTIGATE = 5;
    AI_STATE_ENGAGE      = 6;
    AI_STATE_CHASE       = 7;
    AI_STATE_HUNT        = 8;
    AI_STATE_RAISE_ALARM = 9;
    AI_STATE_FIND_COVER  = 10;
    AI_STATE_FLANK       = 11;
    AI_STATE_FLEE        = 12;
    AI_STATE_HIDE        = 13;
    AI_STATE_PEEK        = 14;
    AI_RESET_DISTANCE  = 30 * GPR;
    AI_ENGAGE_DISTANCE = 200 * GPR;
    MAX_ACTORS = 32;

    // level
    MAX_LEVEL_SEGMENTS = 1024;
    MAX_LEVEL_OBJECTS  = 1024;
    MATERIAL_CONCRETE = 0;
    MATERIAL_WOOD     = 1;
    MATERIAL_METAL    = 2;

    // objects
    MAX_OBJECT_TYPES = 16;
    MAX_OBJECT_SEGMENTS = 16;

    // timing
    MAX_DELAYS = 32;

    // debugging
    MAX_LOGS = 32;
    DEBUG_MODE = true;

/* -----------------------------------------------------------------------------
 * Global variables
 * ---------------------------------------------------------------------------*/
global
    // resources
    __gfxMain;
    __gfxActors;
    __gfxItems;
    __gfxObjects;
    __sounds[SOUNDS_COUNT - 1];

    // fonts
    struct __fonts[2]
        handle;
        path;
        avgCharWidth;
        lineHeight;
    end =
    //  handle  path           avgCharWidth  lineHeight
        NULL,   NULL,          7,            8,
        NULL,   FNT_MENU_PATH, 10,           16;

    // gameplay stats
    struct __itemStats[3]
        string name;
        itemType;
        gfxIndex;
        maxCarry;
        magazineSize;
        timeBetweenShots;
        timeToReload;
        firingMode;
        projectileType;
        ammoType;
        soundIndex;
        offsetForward;
        offsetLeft;
        offsetMuzzleForward;
    end =
    //  name          itemType          gfx  maxCarry magazineSize timeBetweenShots timeToReload firingMode          projectileType  ammoType,        soundIndex         offsetForward offsetLeft offsetMuzzleForward
        "MP40",       ITEM_TYPE_WEAPON, 101, 1,       30,          12,              300,         FIRING_MODE_AUTO,   BULLET_9MM,     ITEM_AMMO_9MM,   SOUND_MP40_SHOT,   45 * GPR,     0 * GPR,   44 * GPR,
        "Kar 98k",    ITEM_TYPE_WEAPON, 111, 1,       5,           100,             250,         FIRING_MODE_SINGLE, BULLET_RIFLE,   ITEM_AMMO_RIFLE, SOUND_KAR98K_SHOT, 45 * GPR,     0 * GPR,   51 * GPR,
        "9mm Ammo",   ITEM_TYPE_AMMO,   501, 150,     NULL,        NULL,            NULL,        NULL,               NULL,           NULL,            NULL,              NULL,         NULL,      NULL,
        "Rifle Ammo", ITEM_TYPE_AMMO,   511, 90,      NULL,        NULL,            NULL,        NULL,               NULL,           NULL,            NULL,              NULL,         NULL,      NULL;

    struct __projectileStats[1]
        damage;
        lifeDuration;
        speed;
        offsetForward;
        offsetLeft;
    end =
        25, 40, 20 * GPR, 45 * GPR, 0 * GPR, // pistol
        65, 50, 30 * GPR, 45 * GPR, 0 * GPR; // rifle

    struct __actorStats[7]
        walkSpeed;
        runSpeed;
        maxTurnSpeed;
        gfxOffset;
        startingHealth;
        faction;
    end =
        2 * GPR, 4 * GPR, 10000, 2, 2000, FACTION_GOOD, // player
        2 * GPR, 3 * GPR, 10000, 1, 100, FACTION_EVIL, // guard level 1
        2 * GPR, 3 * GPR, 10000, 1, 150, FACTION_EVIL, // guard level 2
        2 * GPR, 3 * GPR, 10000, 1, 200, FACTION_EVIL, // guard level 3
        2 * GPR, 3 * GPR, 10000, 1, 100, FACTION_EVIL, // officer level 1
        2 * GPR, 3 * GPR, 10000, 1, 150, FACTION_EVIL, // officer level 2
        2 * GPR, 3 * GPR, 10000, 1, 200, FACTION_EVIL, // officer level 3
        2 * GPR, 3 * GPR, 10000, 2, 200, FACTION_GOOD; // allied commando

    //(INVENTORY_SLOTS * 3) - 1
    // actor inventory contents
    __emptyInventory[] =
        NULL, NULL, NULL,
        NULL, NULL, NULL,
        NULL, NULL, NULL,
        NULL, NULL, NULL,
        NULL, NULL, NULL;
    __mp40Inventory[] =
        // statsIndex  count ammoLoaded
        ITEM_MP40,     1,    30,
        ITEM_AMMO_9MM, 60,   NULL,
        NULL,          NULL, NULL,
        NULL,          NULL, NULL,
        NULL,          NULL, NULL;
    __kar98kInventory[] =
        // statsIndex    count ammoLoaded
        ITEM_KAR98K,     1,    5,
        ITEM_AMMO_RIFLE, 60,   NULL,
        NULL,            NULL, NULL,
        NULL,            NULL, NULL,
        NULL,            NULL, NULL;

    // game management
    __gameManager;
    __previousGameState = NULL;
    __currentGameState = GAME_STATE_NOT_STARTED;

    // level editor
    __levelEditor;
    __previousLevelEditorMode = NULL;
    __currentLevelEditorMode = LEVEL_EDITOR_MODE_VIEW;
    __levelEditorModeString[] =
        "Menu Mode", "Edit Object", "Paint Objects";
    __objectEditMode = 0;
    __objectEditModeString[] = 
        "Angle", "Size", "Z Depth";

    // ui
    __mouseCursor;
    __buttonClicked = NULL;
    __buttonHeldDown = NULL;

    // camera
    __gameCamera;
    __cameraTargetId = NULL;
    __cameraMoveMode = CAMERA_MOVE_FREE_LOOK;

    // actors
    __playerController;
    // TODO: Check if 2D arrays work in DIV, if yes turn this into one array of actors by faction.
    __neutralActors[MAX_ACTORS - 1];
    __goodActors[MAX_ACTORS - 1];
    __evilActors[MAX_ACTORS - 1];

    // line intersection checks
    // TODO: Consider turning into table.
    struct __lineIntersectionData
        ix, iy;
    end

    // level
    __levelManager;
    struct __levelData
        actorSpawnCount;
        struct actorSpawns[MAX_ACTORS - 1]
            x, y;
            angle;
            actorIndex;
            // NOTE: We use a pointer to a table here because DIV doesn't properly support tables
            // inside structs.
            pointer actorInventoryContents;
        end
        objectCount;
        struct objects[MAX_LEVEL_OBJECTS - 1]
            string fileName;
            x, y;
            angle;
            size;
            z;
        end
        segmentCount;
        struct segments[MAX_LEVEL_SEGMENTS - 1]
            x0, y0;
            x1, y1;
            material;
        end
    end

    // object
    struct __objectData
        string fileName;
        angle;
        size;
        z;
        gfxIndex;
        struct segments[MAX_OBJECT_SEGMENTS - 1]
            x0, y0;
            x1, y1;
        end
    end

    // timing
    __deltaTime;
    __delayCount = 0;
    struct __delays[MAX_DELAYS - 1]
        processId;
        startTime;
        delayLength;
    end

    // debugging
    __logsX = 320;
    __logsY = 10;
    __logsYOffset = 15;
    __logCount;
    struct __logs[MAX_LOGS - 1]
        logId;
        txtLabel;
        txtVal;
    end

/* -----------------------------------------------------------------------------
 * Local variables (every process gets these)
 * ---------------------------------------------------------------------------*/
local
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

    // actor data
    alive;
    struct spawnPosition
        x, y;
    end

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

    // actor inventory component
    selectedItemIndex;
    // NOTE: Potential micro-optimization: use count var for weapons ammo loaded (this prevents holding multiple of same weapon, but that probably is undesirable anyway, but that probably is undesirable anyway).
    struct inventory[INVENTORY_SLOTS - 1]
        statsIndex;
        count;
        ammoLoaded;
    end

    // ai data
    struct ai
        // the state determines what the NPC is currently doing
        previousState;
        currentState;
        // the model determines what an NPC knows about it's environment
        struct model
            knownOpponentCount;
            targetOpponentIndex;
            struct knownOpponents[MAX_ACTORS - 1]
                processId;
                x, y;
                visible;
            end
        end
    end

    // ui
    struct ui
        color;
        needsUpdate;
    end

    // debugging
    logCount;
    struct logs[MAX_LOGS - 1]
        logId;
        txtLabel;
        txtVal;
    end

/* -----------------------------------------------------------------------------
 * Main program
 * ---------------------------------------------------------------------------*/
begin
    // initialization
    set_mode(SCREEN_MODE);
    set_fps(60, 1);

    // load graphics
    __gfxMain    = load_fpg(GFX_MAIN_PATH);
    __gfxActors  = load_fpg(GFX_ACTORS_PATH);
    __gfxItems   = load_fpg(GFX_ITEMS_PATH);
    __gfxObjects = load_fpg(GFX_OBJECTS_PATH);

    // load fonts
    __fonts[FONT_SYSTEM].handle = 0;
    __fonts[FONT_MENU].handle   = load_fnt(__fonts[FONT_MENU].path);

    // load sounds
    __sounds[SOUND_MP40_SHOT]       = load_sound("assets/audio/test-shot5.wav", 0);
    __sounds[SOUND_SHELL_DROPPED_1] = load_sound("assets/audio/shell-dropped1.wav", 0);
    __sounds[SOUND_SHELL_DROPPED_2] = load_sound("assets/audio/shell-dropped2.wav", 0);
    __sounds[SOUND_SHELL_DROPPED_3] = load_sound("assets/audio/shell-dropped3.wav", 0);
    __sounds[SOUND_KAR98K_SHOT]     = load_sound("assets/audio/test-shot7.wav", 0);

    // timing
    LogValue("FPS", &fps);
    DeltaTimer();

    // show title screen
    TitleScreen();
end



/* -----------------------------------------------------------------------------
 * Menu screens
 * ---------------------------------------------------------------------------*/
process TitleScreen()
private
    selected = MENU_OPTION_NONE;
    txtTitle;
begin
    // initialization
    clear_screen();
    put_screen(__gfxMain, 1);
    // TODO: Use WriteText functions.
    txtTitle = write(
        __fonts[FONT_MENU].handle,
        HALF_SCREEN_WIDTH,
        HALF_SCREEN_HEIGHT,
        FONT_ANCHOR_CENTERED,
        "PRESS ANY KEY TO PLAY");

    // wait for input
    repeat
        if (scan_code != 0)
            selected = MENU_OPTION_PLAY;
        end
        frame;
    until (selected != MENU_OPTION_NONE)

    // clean up
    delete_text(txtTitle);

    // handle selection
    if (selected == MENU_OPTION_PLAY)
        __gameManager = GameManager();
    end
end



/* -----------------------------------------------------------------------------
 * Game state management
 * ---------------------------------------------------------------------------*/
process GameManager()
begin
    // initialization
    clear_screen();

    // ui
    __mouseCursor = MouseCursor();

    // level
    __levelManager = LevelManager();

    // gameplay
    GameChangeState(GAME_STATE_ACTIVE);

    // game loop
    repeat
        GameHandleState(__currentGameState);
        frame;
    until (__currentGameState == GAME_STATE_GAME_OVER)
    // NOTE: GameHandleState() should catch any game over related events, but this is another
    // place you can run end of game logic.
end

function GameChangeState(nextState)
begin
    __previousGameState = __currentGameState;
    switch (__previousGameState)
        case GAME_STATE_NOT_STARTED:
        end
        case GAME_STATE_ACTIVE:
        end
        case GAME_STATE_PAUSED:
            GameResume();
        end
        case GAME_STATE_GAME_OVER:
        end
        case GAME_STATE_LEVEL_EDITOR:
        end
    end
    __currentGameState = nextState;
    switch (__currentGameState)
        case GAME_STATE_NOT_STARTED:
        end
        case GAME_STATE_ACTIVE:
            __mouseCursor.graph = CURSOR_AIM_CIRCLE;
            // If the game just started, reset the level.
            if (__previousGameState == GAME_STATE_NOT_STARTED)
                StartLevel();
            end
        end
        case GAME_STATE_PAUSED:
            GamePause();
        end
        case GAME_STATE_GAME_OVER:
            CleanUpLevel();
        end
        case GAME_STATE_LEVEL_EDITOR:
            __mouseCursor.graph = CURSOR_MENU;
            CleanUpLevel();
            __levelEditor = LevelEditor();
        end
    end
end

function GameHandleState(currentState)
begin
    switch (currentState)
        case GAME_STATE_NOT_STARTED:
        end
        case GAME_STATE_ACTIVE:
            if (DEBUG_MODE)
                if (key(_alt) && key(_l))
                    GameChangeState(GAME_STATE_LEVEL_EDITOR);
                    return;
                end
            end
        end
        case GAME_STATE_PAUSED:
        end
        case GAME_STATE_GAME_OVER:
        end
        case GAME_STATE_LEVEL_EDITOR:
            if (DEBUG_MODE)
                if (key(_alt) && key(_k))
                    GameChangeState(GAME_STATE_ACTIVE);
                    return;
                end
            end
        end
    end
end

function GamePause()
begin
    // TODO: freeze all game processes
end

function GameResume()
begin
    // TODO: unfreeze all game processes
end



/* -----------------------------------------------------------------------------
 * Camera & scrolling
 * ---------------------------------------------------------------------------*/
process CameraController()
private
    scrollBackground = 0;
    aimAngle;
    aimDistance;
    aimPointX;
    aimPointY;
    aimMaxDistance = 180;
    aimBoost = 2;
begin
    // configuration
    input.move.granularity = 10;
    resolution = GPR;
    ctype = c_scroll;
    graph = 301;
    z = -1000;

    // initialization
    alive = true;
    start_scroll(
        scrollBackground,
        __gfxMain, 200, 0,
        REGION_FULL_SCREEN,
        SCROLL_FOREGROUND_HORIZONTAL + SCROLL_FOREGROUND_VERTICAL);

    // components & sub-processes
    components.physics = Physics(id);
    components.input = CameraInput(id);
    ScrollFollower(id);

    // NOTE: Set targetMoveSpeed after initializing Physics component.
    physics.targetMoveSpeed = CAMERA_FREE_LOOK_MAX_SPEED;

    //LogValue("aimAngle", &aimAngle);
    //LogValue("aimDistance", &aimDistance);
    //LogValue("aimPointX", &aimPointX);
    //LogValue("aimPointY", &aimPointY);
    //LogValue("gameCamera.x", &x);
    //LogValue("gameCamera.y", &y);
    //LogValue("gameCamera.physics.velocity.x", &physics.velocity.x);
    //LogValue("gameCamera.physics.velocity.y", &physics.velocity.y);
    repeat
        frame;
    until (alive == false)
end

process CameraInput(controllerId)
begin
    repeat
        switch (__cameraMoveMode)
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
                //if (__cameraTargetId != NULL)
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
                //    x = (__cameraTargetId.x + aimPointX) / 2;
                //    y = (__cameraTargetId.y + aimPointY) / 2;
                //    scroll[0].x0 = (x / GPR) - HALF_SCREEN_WIDTH;
                //    scroll[0].y0 = (y / GPR) - HALF_SCREEN_HEIGHT;
                //    //DrawScrollSpaceLine1Frame(__cameraTargetId.x, __cameraTargetId.y, aimPointX, aimPointY, COLOR_WHITE, OPACITY_SOLID);
                //end
            end
        end
        frame;
    until (controllerId.alive == false)
end

process ScrollFollower(controllerId)
begin
    repeat
        // Set scroll position.
        scroll[0].x0 = (controllerId.x / GPR) - HALF_SCREEN_WIDTH;
        scroll[0].y0 = (controllerId.y / GPR) - HALF_SCREEN_HEIGHT;
        frame;
    until (controllerId.alive == false)
end



/* -----------------------------------------------------------------------------
 * Level management
 * ---------------------------------------------------------------------------*/
process LevelManager()
begin
    LevelData_Initialize();
    loop
        frame;
    end
end

// TODO: finish implementing
function StartLevel()
private
    i;
begin
    //LevelData_AddActorSpawn(0 * GPR, 0 * GPR, 0, ACTOR_PLAYER, &__mp40Inventory);
    //LevelData_AddActorSpawn(200 * GPR, 0 * GPR, 0, ACTOR_GUARD_1, &__mp40Inventory);

    // Read spawn points from level data and spawn correct actors.
    if (__levelData.actorSpawnCount > 0)
        for (i = 0; i < __levelData.actorSpawnCount; ++i)
            if (__levelData.actorSpawns[i].actorIndex != NULL)
                switch (__levelData.actorSpawns[i].actorIndex)
                    case ACTOR_PLAYER:
                        __playerController = PlayerController(
                            __levelData.actorSpawns[i].x,
                            __levelData.actorSpawns[i].y,
                            __levelData.actorSpawns[i].actorInventoryContents);
                    end
                    case ACTOR_GUARD_1,
                         ACTOR_GUARD_2,
                         ACTOR_GUARD_3,
                         ACTOR_OFFICER_1,
                         ACTOR_OFFICER_2,
                         ACTOR_OFFICER_3,
                         ACTOR_ALLIED_COMMANDO:
                        AIController(
                            __levelData.actorSpawns[i].actorIndex,
                            __levelData.actorSpawns[i].x,
                            __levelData.actorSpawns[i].y,
                            __levelData.actorSpawns[i].actorInventoryContents);
                    end
                end
            end
        end
    end

    // TODO: Read item points from level data and spawn correct items.
    // items
    //Item(200 * GPR, 200 * GPR, 0, ITEM_AMMO_9MM, 150, NULL);

    // AI managers
    AIModelManager(FACTION_EVIL);
    AIModelManager(FACTION_GOOD);

    // camera
    __gameCamera = CameraController();
end

// TODO: implement
function CleanUpLevel()
begin
end

// TODO: implement
function LoadLevel(fileName)
begin
    // open file handle
    // read line
    // parse line
    // assign levelData
    // close file handle
end

function SaveLevel(fileName)
begin
    // open file handle
    // parse levelData
    // write line
    // close file handle
end

function LevelData_Initialize()
private
    i;
begin
    __levelData.actorSpawnCount = 0;
    for (i = 0; i < MAX_ACTORS; ++i)
        __levelData.actorSpawns[i].x = 0;
        __levelData.actorSpawns[i].y = 0;
        __levelData.actorSpawns[i].angle = 0;
        __levelData.actorSpawns[i].actorIndex = NULL;
        __levelData.actorSpawns[i].actorInventoryContents = &__emptyInventory;
    end

    __levelData.objectCount = 0;
    for (i = 0; i < MAX_LEVEL_OBJECTS; ++i)
        __levelData.objects[i].x = 0;
        __levelData.objects[i].y = 0;
        __levelData.objects[i].angle = 0;
        __levelData.objects[i].size = 0;
        __levelData.objects[i].z = 0;
    end

    __levelData.segmentCount = 0;
    for (i = 0; i < MAX_LEVEL_SEGMENTS; ++i)
        __levelData.segments[i].x0 = 0;
        __levelData.segments[i].y0 = 0;
        __levelData.segments[i].x1 = 0;
        __levelData.segments[i].y1 = 0;
        __levelData.segments[i].material = NULL;
    end
end

function LevelData_AddLevelSegment(x0, y0, x1, y1, material)
private
    i;
begin
    // TODO: Replace (and test) with: FindFreeTableIndex(&__levelData.segments, __levelData.segmentCount + 1)
    i = LevelData_FindFreeLevelSegmentIndex();
    if (i > NULL)
        __levelData.segments[i].x0 = x0;
        __levelData.segments[i].y0 = y0;
        __levelData.segments[i].x1 = x1;
        __levelData.segments[i].y1 = y1;
        __levelData.segments[i].material = material;
        __levelData.segmentCount++;
    end
end

function LevelData_RemoveLevelSegment(i)
begin
    if (__levelData.segments[i].material > NULL)
        __levelData.segments[i].x0 = 0;
        __levelData.segments[i].y0 = 0;
        __levelData.segments[i].x1 = 0;
        __levelData.segments[i].y1 = 0;
        __levelData.segments[i].material = NULL;
        __levelData.segmentCount--;
    end
end

function LevelData_FindFreeLevelSegmentIndex()
private
    i;
begin
    for (i = 0; i < __levelData.segmentCount + 1; ++i)
        if (__levelData.segments[i].material == NULL)
            return (i);
        end
    end
    return (NULL);
end

function LevelData_AddActorSpawn(x, y, angle, actorIndex, pointer inventoryContents)
begin
    // TODO: Replace (and test) with: FindFreeTableIndex(&__levelData.actorSpawns, __levelData.actorSpawnCount + 1)
    value = LevelData_FindFreeActorSpawnIndex();
    if (value != NULL)
        ++__levelData.actorSpawnCount;
        LevelData_SetActorSpawn(value, x, y, angle, actorIndex, inventoryContents);
    end
end

function LevelData_SetActorSpawn(actorSpawnIndex, x, y, angle, actorIndex, pointer inventoryContents)
begin
    __levelData.actorSpawns[actorSpawnIndex].x = x;
    __levelData.actorSpawns[actorSpawnIndex].y = y;
    __levelData.actorSpawns[actorSpawnIndex].angle = angle;
    __levelData.actorSpawns[actorSpawnIndex].actorIndex = actorIndex;
    __levelData.actorSpawns[actorSpawnIndex].actorInventoryContents = inventoryContents;
end

function LevelData_FindFreeActorSpawnIndex()
private
    i;
begin
    for (i = 0; i < __levelData.actorSpawnCount + 1; ++i)
        if (__levelData.actorSpawns[i].actorIndex == NULL)
            return (i);
        end
    end
    return (NULL);
end



/* -----------------------------------------------------------------------------
 * Object management
 * ---------------------------------------------------------------------------*/
// TODO: implement
function LoadObject(string fileName)
private
    fileHandle;
    o_a, o_s, o_z, o_g;
begin
    // open file handle
    fileName = DATA_OBJECTS_PATH + fileName;
    fileHandle = fopen(fileName, "r");

    // read object data
    fread(offset o_a, sizeof(o_a), fileHandle);
    fread(offset o_s, sizeof(o_s), fileHandle);
    fread(offset o_z, sizeof(o_z), fileHandle);
    fread(offset o_g, sizeof(o_g), fileHandle);
    // TODO: read segments data

    // assign object data to global struct
    __objectData.angle    = o_a;
    __objectData.size     = o_s;
    __objectData.z        = o_z;
    __objectData.gfxIndex = o_g;
    // TODO: assign segments data

    // close file handle
    fclose(fileHandle);
end

function SaveObject(string fileName, o_a, o_s, o_z, o_g)
private
    fileHandle;
begin
    // open file handle
    fileName = DATA_OBJECTS_PATH + fileName;
    fileHandle = fopen(fileName, "w");

    // write object data
    fwrite(offset o_a, sizeof(o_a), fileHandle);
    fwrite(offset o_s, sizeof(o_s), fileHandle);
    fwrite(offset o_z, sizeof(o_z), fileHandle);
    fwrite(offset o_g, sizeof(o_g), fileHandle);
    // TODO: write segments data

    // close file handle
    fclose(fileHandle);
end



/* -----------------------------------------------------------------------------
 * Level editor
 * ---------------------------------------------------------------------------*/
process LevelEditor()
private
    uiRenderer;
begin
    __levelEditor = id;
    LevelEditorChangeMode(LEVEL_EDITOR_MODE_VIEW);

    uiRenderer = LevelEditorUIRenderer();

    // level editor loop
    repeat
        LevelEditorHandleMode(__currentLevelEditorMode);
        if (ui.needsUpdate == true)
            uiRenderer.ui.needsUpdate = true;
            ui.needsUpdate = false;
        end
        frame;
    until (__currentGameState != GAME_STATE_LEVEL_EDITOR)
    uiRenderer.alive = false;
end

function LevelEditorChangeMode(nextMode)
begin
    __previousLevelEditorMode = __currentLevelEditorMode;
    switch (__previousLevelEditorMode)
        case LEVEL_EDITOR_MODE_VIEW:
        end
        case LEVEL_EDITOR_MODE_EDIT_OBJECT:
        end
        case LEVEL_EDITOR_MODE_PAINT_OBJECTS:
        end
    end
    __currentLevelEditorMode = nextMode;
    switch (__currentLevelEditorMode)
        case LEVEL_EDITOR_MODE_VIEW:
            __cameraMoveMode = CAMERA_MOVE_FREE_LOOK;
        end
        case LEVEL_EDITOR_MODE_EDIT_OBJECT:
            __cameraMoveMode = NULL;
            __objectData.fileName = "default.dat";
            __objectData.angle    = 0;
            __objectData.size     = 100;
            __objectData.z        = 0;
            __objectData.gfxIndex = 1;
        end
        case LEVEL_EDITOR_MODE_PAINT_OBJECTS:
            __cameraMoveMode = CAMERA_MOVE_FREE_LOOK;
        end
    end
    __levelEditor.ui.needsUpdate = true;
end

function LevelEditorHandleMode(currentMode)
begin
    switch (currentMode)
        case LEVEL_EDITOR_MODE_VIEW:
            if (__buttonClicked != NULL)
                switch (__buttonClicked)
                    case BUTTON_LEVEL_EDITOR_SAVE:
                        // TODO: Save level.
                    end
                    case BUTTON_LEVEL_EDITOR_LOAD:
                        // TODO: Load level.
                    end
                    case BUTTON_LEVEL_EDITOR_EDIT_OBJECT:
                        LevelEditorChangeMode(LEVEL_EDITOR_MODE_EDIT_OBJECT);
                    end
                end
                __buttonClicked = NULL;
            end
        end
        case LEVEL_EDITOR_MODE_EDIT_OBJECT:
            if (__buttonClicked != NULL)
                switch (__buttonClicked)
                    case BUTTON_LEVEL_EDITOR_SAVE:
                        SaveObject(
                            __objectData.fileName, 
                            __objectData.angle,
                            __objectData.size,
                            __objectData.z,
                            __objectData.gfxIndex);
                    end
                    case BUTTON_LEVEL_EDITOR_LOAD:
                        LoadObject(__objectData.fileName);
                        __levelEditor.ui.needsUpdate = true;
                    end
                    case BUTTON_LEVEL_EDITOR_MENU:
                        LevelEditorChangeMode(LEVEL_EDITOR_MODE_VIEW);
                    end
                    case BUTTON_LEVEL_EDITOR_GRAPHIC:
                        __objectData.gfxIndex = CycleValue(__objectData.gfxIndex, 1, GFX_OBJECTS_MAX);
                        __levelEditor.ui.needsUpdate = true;
                    end
                    case BUTTON_LEVEL_EDITOR_ASZ:
                        __objectEditMode = CycleValue(__objectEditMode, 0, OBJECT_EDIT_MODE_MAX);
                        __levelEditor.ui.needsUpdate = true;
                    end
                end
                __buttonClicked = NULL;
            end
        end
        case LEVEL_EDITOR_MODE_PAINT_OBJECTS:
        end
    end
end

process LevelEditorUIRenderer()
private
    x0, y0, x1, y1;
    margin;
    fntHeight;
    ySplit0, ySplit1;
    panelColor, sectionColor;
    buttonWidth, buttonHeight;
    buttonColor0, buttonColor1;

    uiCounter;
    uiHandles[UI_MAX_HANDLES];
    uiModeTextIndex;
    uiObjectEditModeTextIndex;
    uiObjectImageIndex;
begin
    // initialization
    alive = true;
    InitializeTable(&uiHandles, UI_MAX_HANDLES, NULL);

    // ui calculations
    x0 = (SCREEN_WIDTH / 4) * 3;
    y0 = 0;
    x1 = SCREEN_WIDTH;
    y1 = SCREEN_HEIGHT;
    margin = (x1 - x0) / 40;
    fntHeight = 10;
    ySplit0 = ((x1 - x0) / 4) * 3;
    ySplit1 = ySplit0 + (SCREEN_WIDTH / 16);
    panelColor = 81;
    sectionColor = 82;
    buttonWidth = 68;
    buttonHeight = 40;
    buttonColor0 = 54;
    buttonColor1 = 56;

    repeat
        if (ui.needsUpdate == true)
            // Clean up.
            for (value = 0; value < UI_MAX_HANDLES - 1; ++value)
                if (uiHandles[value] != NULL)
                    uiHandles[value].alive = false;
                    uiHandles[value] = NULL;
                end
            end
            // TODO: This frame call is causing flickering. Without it however there are some Z depth
            // rendering bugs. One possible solution would be total refactor of UI rendering to a
            // more generalized system.
            frame;

            // Draw side panel & sections.
            uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = DrawRenderer(
                DRAW_RECTANGLE_FILL, 
                x0, y0, x1, y1, 
                panelColor, OPACITY_SOLID);
            uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = DrawRenderer(
                DRAW_RECTANGLE_FILL, 
                x0 + margin, 
                y0 + margin, 
                x1 - margin, 
                ySplit0 - margin - 1, 
                sectionColor, OPACITY_SOLID);
            uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = DrawRenderer(
                DRAW_RECTANGLE_FILL, 
                x0 + margin, 
                ySplit0, 
                x1 - margin, 
                ySplit1 - margin - 1, 
                sectionColor, OPACITY_SOLID);
            uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = DrawRenderer(
                DRAW_RECTANGLE_FILL, 
                x0 + margin, 
                ySplit1, 
                x1 - margin, 
                y1 - margin - 1, 
                sectionColor, OPACITY_SOLID);

            // Draw level editor mode text.
            uiModeTextIndex = FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES);
            uiHandles[uiModeTextIndex] = TextRenderer(
                FONT_SYSTEM,
                x0 + (margin * 2),
                ySplit0 + margin,
                FONT_ANCHOR_TOP_LEFT,
                __levelEditorModeString[__currentLevelEditorMode]);
            uiHandles[uiModeTextIndex].ui.needsUpdate = true;

            switch (__currentLevelEditorMode)
                case LEVEL_EDITOR_MODE_VIEW:
                    // Draw buttons.
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2),
                        ySplit1 + margin,
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "OBJECTS", BUTTON_LEVEL_EDITOR_OBJECTS);
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2) + (buttonWidth + margin + 2),
                        ySplit1 + margin,
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "ENTITIES", BUTTON_LEVEL_EDITOR_ENTITIES);
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2),
                        ySplit1 + margin + (buttonHeight + margin + 2),
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "EDIT OBJ", BUTTON_LEVEL_EDITOR_EDIT_OBJECT);
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2),
                        ySplit1 + margin + ((buttonHeight + margin + 2) * 2),
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "SAVE", BUTTON_LEVEL_EDITOR_SAVE);
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2) + (buttonWidth + margin + 2),
                        ySplit1 + margin + ((buttonHeight + margin + 2) * 2),
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "LOAD", BUTTON_LEVEL_EDITOR_LOAD);
                end
                case LEVEL_EDITOR_MODE_EDIT_OBJECT:
                    // Draw object edit mode text.
                    uiObjectEditModeTextIndex = FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES);
                    uiHandles[uiObjectEditModeTextIndex] = TextRenderer(
                        FONT_SYSTEM,
                        x0 + (margin * 2),
                        ySplit0 + (margin * 2) + fntHeight,
                        FONT_ANCHOR_TOP_LEFT,
                        "A/S/Z Mode: " + __objectEditModeString[__objectEditMode]);
                    uiHandles[uiObjectEditModeTextIndex].ui.needsUpdate = true;

                    // Draw info.
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = TextRenderer(
                        FONT_SYSTEM,
                        x0 + (margin * 2),
                        y0 + (margin * 2),
                        FONT_ANCHOR_TOP_LEFT,
                        __objectData.fileName);
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = TextRenderer(
                        FONT_SYSTEM,
                        x0 + (margin * 18),
                        y0 + (margin * 3) + fntHeight,
                        FONT_ANCHOR_TOP_RIGHT,
                        "Angle:");
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = TextRenderer(
                        FONT_SYSTEM,
                        x0 + (margin * 20),
                        y0 + (margin * 3) + fntHeight,
                        FONT_ANCHOR_TOP_LEFT,
                        itoa(__objectData.angle));
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = TextRenderer(
                        FONT_SYSTEM,
                        x0 + (margin * 18),
                        y0 + (margin * 4) + (fntHeight * 2),
                        FONT_ANCHOR_TOP_RIGHT,
                        "Size:");
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = TextRenderer(
                        FONT_SYSTEM,
                        x0 + (margin * 20),
                        y0 + (margin * 4) + (fntHeight * 2),
                        FONT_ANCHOR_TOP_LEFT,
                        itoa(__objectData.size));
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = TextRenderer(
                        FONT_SYSTEM,
                        x0 + (margin * 18),
                        y0 + (margin * 5) + (fntHeight * 3),
                        FONT_ANCHOR_TOP_RIGHT,
                        "Z Depth:");
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = TextRenderer(
                        FONT_SYSTEM,
                        x0 + (margin * 20),
                        y0 + (margin * 5) + (fntHeight * 3),
                        FONT_ANCHOR_TOP_LEFT,
                        itoa(__objectData.z));
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = TextRenderer(
                        FONT_SYSTEM,
                        x0 + (margin * 2),
                        y0 + (margin * (3 + __objectEditMode)) + (fntHeight * (__objectEditMode + 1)),
                        FONT_ANCHOR_TOP_LEFT,
                        "=>");

                    // Draw panel.
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = DrawRenderer(
                        DRAW_RECTANGLE_FILL, 
                        0,
                        0,
                        x0, 
                        y1, 
                        COLOR_BLACK, OPACITY_SOLID);

                    // Draw object being edited.
                    uiObjectImageIndex = FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES);
                    uiHandles[uiObjectImageIndex] = ImageRenderer(
                        __gfxObjects, 
                        __objectData.gfxIndex,
                        x0 / 2,
                        HALF_SCREEN_HEIGHT,
                        0,
                        100);
                    uiHandles[uiObjectImageIndex].angle = __objectData.angle;
                    uiHandles[uiObjectImageIndex].graph = __objectData.gfxIndex;

                    // Draw object segments.
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = SegmentRenderer(
                        (x0 / 2) - 50,
                        HALF_SCREEN_HEIGHT - 50,
                        (x0 / 2) + 50,
                        HALF_SCREEN_HEIGHT + 50,
                        COLOR_WHITE, OPACITY_SOLID,
                        COLOR_WHITE, OPACITY_SOLID, 5);

                    // Draw buttons.
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2),
                        ySplit1 + margin,
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "A/S/Z", BUTTON_LEVEL_EDITOR_ASZ);
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2) + (buttonWidth + margin + 2),
                        ySplit1 + margin,
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "GRAPHIC", BUTTON_LEVEL_EDITOR_GRAPHIC);
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2),
                        ySplit1 + margin + (buttonHeight + margin + 2),
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "SEGMENTS", BUTTON_LEVEL_EDITOR_SEGMENTS);
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2) + (buttonWidth + margin + 2),
                        ySplit1 + margin + (buttonHeight + margin + 2),
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "MENU", BUTTON_LEVEL_EDITOR_MENU);
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2),
                        ySplit1 + margin + ((buttonHeight + margin + 2) * 2),
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "SAVE OBJ", BUTTON_LEVEL_EDITOR_SAVE);
                    uiHandles[FindFreeTableIndex(&uiHandles, UI_MAX_HANDLES)] = ButtonRenderer(
                        x0 + (margin * 2) + (buttonWidth + margin + 2),
                        ySplit1 + margin + ((buttonHeight + margin + 2) * 2),
                        buttonWidth, buttonHeight,
                        buttonColor0, OPACITY_SOLID,
                        buttonColor1, OPACITY_SOLID,
                        FONT_SYSTEM, "LOAD OBJ", BUTTON_LEVEL_EDITOR_LOAD);
                end
                case LEVEL_EDITOR_MODE_PAINT_OBJECTS:
                end
            end
            ui.needsUpdate = false;
        end

        frame;
    until (alive == false)

    for (value = 0; value < UI_MAX_HANDLES; ++value)
        if (uiHandles[value] != NULL)
            uiHandles[value].alive = false;
            uiHandles[value] = NULL;
        end
    end
end



/* -----------------------------------------------------------------------------
 * User interface
 * ---------------------------------------------------------------------------*/
process ButtonRenderer(x, y, width, height, color0, opacity0, color1, opacity1, fontIndex, text, buttonIndex)
private
    drawBackground;
    textButton;
    hover = false;
begin
    // initialization
    alive = true;

    // ui
    drawBackground = DrawRenderer(
        DRAW_RECTANGLE_FILL, x, y, x + width, y + height, color0, opacity0);
    textButton = TextRenderer(
        fontIndex, x + (width / 2), y + (height / 2), FONT_ANCHOR_CENTERED, text);

    // TODO: Use opacity values, not just color values.
    repeat
        // TODO: if (ui.active == true)
        if (RectangleContainsPoint(x, y, x + width, y + height, mouse.x, mouse.y))
            if (hover == false)
                drawBackground.ui.color = color1;
                drawBackground.ui.needsUpdate = true;
                hover = true;
            end
        else
            if (hover == true)
                drawBackground.ui.color = color0;
                drawBackground.ui.needsUpdate = true;
                hover = false;
            end
        end
        if (hover)
            if (mouse.left)
                // TODO: Pass in color2 and use that here for the pressed state.
                drawBackground.ui.color = color0;
                drawBackground.ui.needsUpdate = true;
                __buttonHeldDown = buttonIndex;
            end
            if (!mouse.left && __buttonHeldDown == buttonIndex)
                drawBackground.ui.color = color1;
                drawBackground.ui.needsUpdate = true;
                __buttonHeldDown = NULL;
                __buttonClicked = buttonIndex;
            end
        else
            if (__buttonHeldDown == buttonIndex)
                __buttonHeldDown = NULL;
            end
        end
        frame;
    until (alive == false)

    drawBackground.alive = false;
    textButton.alive = false;
end

process DrawRenderer(drawType, x0, y0, x1, y1, color, opacity)
private
    drawHandle = NULL;
begin
    // initialization
    alive = true;
    ui.color = color;
    drawHandle = draw(drawType, ui.color, opacity, REGION_FULL_SCREEN, x0, y0, x1, y1);

    repeat
        if (ui.needsUpdate == true)
            move_draw(drawHandle, ui.color, opacity, x0, y0, x1, y1);
            ui.needsUpdate = false;
        end
        frame;
    until (alive == false)

    if (drawHandle > 0)
        delete_draw(drawHandle);
    end
end

process TextRenderer(fontIndex, x, y, anchor, string text)
private
    textHandle;
begin
    // initialization
    alive = true;
    ui.needsUpdate = true;

    repeat
        if (ui.needsUpdate == true)
            if (textHandle != 0)
                delete_text(textHandle);
            end
            textHandle = write(__fonts[fontIndex].handle, x, y, anchor, text);
            ui.needsUpdate = false;
        end
        frame;
    until (alive == false)

    if (textHandle > 0)
        delete_text(textHandle);
    end
end

process ImageRenderer(file, graph, x, y, angle, size)
begin
    // initialization
    alive = true;
    z = draw_z - 1;

    repeat
        if (ui.needsUpdate == true)
            ui.needsUpdate = false;
        end
        frame;
    until (alive == false)
end

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
        DRAW_LINE, x0, y0, x1, y1, lineColor, lineOpacity);
    drawPoint0 = DrawRenderer(
        DRAW_ELLIPSE, x0 - pointRadius, y0 - pointRadius, x0 + pointRadius, y0 + pointRadius, pointColor, pointOpacity);
    drawPoint1 = DrawRenderer(
        DRAW_ELLIPSE, x1 - pointRadius, y1 - pointRadius, x1 + pointRadius, y1 + pointRadius, pointColor, pointOpacity);

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

process MouseCursor()
begin
    // initialization
    resolution = GPR;
    file = __gfxMain;
    graph = 303;
    z = -1000;
    loop
        x = mouse.x * GPR;
        y = mouse.y * GPR;
        frame;
    end
end

// TODO: Restore this functionality.
/*
process DrawDebugAimLine()
private
    color;
    x0, y0;
    x1, y1;
begin
    LogValue("x0", &x0);
    LogValue("y0", &y0);
    LogValue("x1", &x1);
    LogValue("y1", &y1);

    LogValue("ix", &__lineIntersectionData.ix);
    LogValue("iy", &__lineIntersectionData.iy);
    loop
        //DrawScrollSpaceLine1Frame(-100 * GPR, -100 * GPR, 100 * GPR, -100 * GPR, COLOR_RED, OPACITY_SOLID);
        DrawScrollSpaceLine1Frame(100 * GPR, -100 * GPR, 100 * GPR, 100 * GPR, COLOR_RED, OPACITY_SOLID);
        //DrawScrollSpaceLine1Frame(100 * GPR, 100 * GPR, -100 * GPR, 100 * GPR, COLOR_RED, OPACITY_SOLID);
        //DrawScrollSpaceLine1Frame(-100 * GPR, 100 * GPR, -100 * GPR, -100 * GPR, COLOR_RED, OPACITY_SOLID);

        // draw aim line, blue = no hit, green = hit
        color = COLOR_BLUE;
        x0 = __playerController.x / GPR;
        y0 = __playerController.y / GPR;
        x1 = (mouse.x + scroll[0].x0);
        y1 = (mouse.y + scroll[0].y0);
        if (LineIntersection(
            x0, 
            y0, 
            x1, 
            y1, 
            100,
            -100,
            100,
            100))
            color = COLOR_GREEN;
        end
        DrawScrollSpaceLine1Frame(
            __playerController.x, 
            __playerController.y, 
            (mouse.x + scroll[0].x0) * GPR, 
            (mouse.y + scroll[0].y0) * GPR, 
            color, OPACITY_SOLID);

        // draw intersection point
        value = 5;
        DrawScrollSpaceLine1Frame(
            (__lineIntersectionData.ix - value) * GPR, 
            (__lineIntersectionData.iy - value) * GPR, 
            (__lineIntersectionData.ix + value) * GPR, 
            (__lineIntersectionData.iy + value) * GPR, COLOR_WHITE, OPACITY_SOLID);
        DrawScrollSpaceLine1Frame(
            (__lineIntersectionData.ix + value) * GPR, 
            (__lineIntersectionData.iy - value) * GPR, 
            (__lineIntersectionData.ix - value) * GPR, 
            (__lineIntersectionData.iy + value) * GPR, COLOR_WHITE, OPACITY_SOLID);

        frame;
    end
end
*/



/* -----------------------------------------------------------------------------
 * Actor Controllers
 * ---------------------------------------------------------------------------*/
process PlayerController(x, y, inventoryContents)
begin
    // configuration
    input.move.granularity = 1;
    resolution = GPR;
    ctype = c_scroll;

    // initialization
    alive = true;
    RecordSpawnPosition(id);

    // components & sub-processes
    components.physics = HumanPhysics(id, __actorStats[ACTOR_PLAYER].walkSpeed, __actorStats[ACTOR_PLAYER].runSpeed);
    components.animator = HumanAnimator(id, ACTOR_PLAYER);
    components.faction = ActorFaction(id, ACTOR_PLAYER);
    components.health = Health(id, __actorStats[ACTOR_PLAYER].startingHealth);
    components.inventory = Inventory(id, inventoryContents);
    
    repeat
        // capture input
        if (key(_a))
            input.move.x = -input.move.granularity;
        else
            if (key(_d))
                input.move.x = +input.move.granularity;
            else
                input.move.x = 0;
            end
        end
        if (key(_w))
            input.move.y = -input.move.granularity;
        else
            if (key(_s))
                input.move.y = +input.move.granularity;
            else
                input.move.y = 0;
            end
        end
        InputLookAt(id,
            __mouseCursor.x + scroll[0].x0 * GPR, 
            __mouseCursor.y + scroll[0].y0 * GPR);
        input.attackingPreviousFrame = input.attacking;
        input.attacking = mouse.left;
        input.reloading = key(_r);
        // TODO: implement player walk controls
        input.move.walk = false;

        // apply input
        TurnTowardsPosition(
            id,
            input.lookAt.x, 
            input.lookAt.y, 
            __actorStats[ACTOR_PLAYER].maxTurnSpeed);
        frame;
    until (alive == false)
end

process AIController(actorType, x, y, inventoryContents)
private
    animator;
begin
    // configuration
    input.move.granularity = 10;
    resolution = GPR;
    ctype = c_scroll;

    // initialization
    alive = true;
    RecordSpawnPosition(id);
    ai.previousState = AI_STATE_NONE;
    ai.currentState = AI_STATE_NONE;
    ai.model.targetOpponentIndex = NULL;

    // components & sub-processes
    components.physics = HumanPhysics(id, __actorStats[actorType].walkSpeed, __actorStats[actorType].runSpeed);
    components.animator = HumanAnimator(id, actorType);
    components.faction = ActorFaction(id, actorType);
    components.health = Health(id, __actorStats[actorType].startingHealth);
    components.inventory = Inventory(id, inventoryContents);

    AIChangeState(id, AI_STATE_IDLE);
    repeat
        AIHandleState(id);
        /*
        if (key(_y))
            AIChangeState(id, AI_STATE_ENGAGE);
        end
        if (key(_u))
            AIChangeState(id, AI_STATE_IDLE);
        end
        */
        // turn towards the look input
        TurnTowardsPosition(
            id,
            input.lookAt.x, 
            input.lookAt.y, 
            __actorStats[actorType].maxTurnSpeed);
        frame;
    until (alive == false)
end



/* -----------------------------------------------------------------------------
 * AI state management
 * ---------------------------------------------------------------------------*/
function AIHandleState(controllerId)
private
    nextState = NULL;
    targetOpponentIndex;
    targetOpponentX;
    targetOpponentY;
    targetOpponentDistance = max_int;
    distance = max_int;
begin
    // reset move input
    InputMoveNone(controllerId);

    // select target opponent
    targetOpponentIndex = controllerId.ai.model.targetOpponentIndex;
    if (targetOpponentIndex == NULL)
        targetOpponentIndex = AIGetNearestVisibleKnownOpponentIndex(controllerId);
    end
    if (targetOpponentIndex > NULL)
        z = targetOpponentIndex;
        targetOpponentX = controllerId.ai.model.knownOpponents[z].x;
        targetOpponentY = controllerId.ai.model.knownOpponents[z].y;
        targetOpponentDistance = fget_dist(
            controllerId.x, 
            controllerId.y, 
            targetOpponentX, 
            targetOpponentY);
    end

    // Only reload if the selected weapon is empty and can be reloaded.
    controllerId.input.reloading = 
        IsSelectedWeaponEmpty(controllerId) 
        && CanReloadSelectedWeapon(controllerId);

    switch (controllerId.ai.currentState)
        case AI_STATE_NONE:
        end
        case AI_STATE_IDLE:
            if (targetOpponentIndex > NULL)
                nextState = AI_STATE_INVESTIGATE;
            end
        end
        case AI_STATE_RESET:
            // TODO: return to spawn position OR last position ordered by higher ranking AI
            if (targetOpponentIndex > NULL)
                nextState = AI_STATE_INVESTIGATE;
            else
                distance = fget_dist(
                    controllerId.x, 
                    controllerId.y, 
                    controllerId.spawnPosition.x, 
                    controllerId.spawnPosition.y);
                if (distance > AI_RESET_DISTANCE)
                    InputMoveTowards(controllerId, controllerId.spawnPosition.x, controllerId.spawnPosition.y, INPUT_RUN);
                    InputLookAt(controllerId, controllerId.spawnPosition.x, controllerId.spawnPosition.y);
                else
                    nextState = AI_STATE_IDLE;
                end
            end
        end
        case AI_STATE_PATROL:
        end
        case AI_STATE_GUARD:
        end
        case AI_STATE_INVESTIGATE:
            if (targetOpponentIndex > NULL)
                if (targetOpponentDistance > AI_ENGAGE_DISTANCE)
                    InputLookAt(controllerId, targetOpponentX, targetOpponentY);
                    InputMoveTowards(controllerId, targetOpponentX, targetOpponentY, INPUT_WALK);
                else
                    nextState = AI_STATE_ENGAGE;
                end
            else
                nextState = AI_STATE_RESET;
            end
        end
        case AI_STATE_ENGAGE:
            if (targetOpponentIndex > NULL)
                InputLookAt(controllerId, targetOpponentX, targetOpponentY);
                if (targetOpponentDistance > AI_ENGAGE_DISTANCE)
                    nextState = AI_STATE_CHASE;
                end
            else
                nextState = AI_STATE_RESET;
            end
        end
        case AI_STATE_CHASE:
            if (targetOpponentIndex > NULL)
                if (targetOpponentDistance > AI_ENGAGE_DISTANCE)
                    InputLookAt(controllerId, targetOpponentX, targetOpponentY);
                    InputMoveTowards(controllerId, targetOpponentX, targetOpponentY, INPUT_RUN);
                else
                    nextState = AI_STATE_ENGAGE;
                end
            else
                nextState = AI_STATE_RESET;
            end
        end
        case AI_STATE_HUNT:
        end
        case AI_STATE_RAISE_ALARM:
        end
        case AI_STATE_FIND_COVER:
        end
        case AI_STATE_FLANK:
        end
        case AI_STATE_FLEE:
        end
        case AI_STATE_HIDE:
        end
        case AI_STATE_PEEK:
        end
    end

    controllerId.ai.model.targetOpponentIndex = targetOpponentIndex;
    controllerId.input.attackingPreviousFrame = input.attacking;

    if (nextState > NULL)
        AIChangeState(controllerId, nextState);
    end
end

function AIChangeState(controllerId, nextState)
begin
    controllerId.ai.previousState = controllerId.ai.currentState;
    switch (controllerId.ai.previousState)
        case AI_STATE_NONE:
        end
        case AI_STATE_IDLE:
        end
        case AI_STATE_RESET:
        end
        case AI_STATE_PATROL:
        end
        case AI_STATE_GUARD:
        end
        case AI_STATE_INVESTIGATE:
        end
        case AI_STATE_ENGAGE:
            controllerId.input.attacking = false;
        end
        case AI_STATE_CHASE:
        end
        case AI_STATE_HUNT:
        end
        case AI_STATE_RAISE_ALARM:
        end
        case AI_STATE_FIND_COVER:
        end
        case AI_STATE_FLANK:
        end
        case AI_STATE_FLEE:
        end
        case AI_STATE_HIDE:
        end
        case AI_STATE_PEEK:
        end
    end
    controllerId.ai.currentState = nextState;
    switch (controllerId.ai.currentState)
        case AI_STATE_NONE:
        end
        case AI_STATE_IDLE:
        end
        case AI_STATE_RESET:
        end
        case AI_STATE_PATROL:
        end
        case AI_STATE_GUARD:
        end
        case AI_STATE_INVESTIGATE:
        end
        case AI_STATE_ENGAGE:
            controllerId.input.attacking = true;
        end
        case AI_STATE_CHASE:
        end
        case AI_STATE_HUNT:
        end
        case AI_STATE_RAISE_ALARM:
        end
        case AI_STATE_FIND_COVER:
        end
        case AI_STATE_FLANK:
        end
        case AI_STATE_FLEE:
        end
        case AI_STATE_HIDE:
        end
        case AI_STATE_PEEK:
        end
    end
end



/* -----------------------------------------------------------------------------
 * AI model management
 * ---------------------------------------------------------------------------*/
process AIModelManager(faction)
private
    pointer opponents;
    pointer actors;
    knownOpponentIndex = NULL;
    opponent;
    actor;
    isVisible = false;
begin
    opponents = GetFactionOpponents(faction);
    actors = GetFactionActors(faction);
    loop
        // foreach AI
        for (x = 0; x < MAX_ACTORS; ++x)
            if (actors[x] <= 0)
                continue;
            end
            actor = actors[x];
            // prune dead opponents
            for (y = 0; y < MAX_ACTORS - 1; ++y)
                if (actor.ai.model.knownOpponents[y].processId <= 0)
                    continue;
                end
                if (actor.ai.model.knownOpponents[y].processId.alive == false)
                    actor.ai.model.knownOpponents[y].processId = NULL;
                    actor.ai.model.knownOpponentCount--;
                    if (actor.ai.model.targetOpponentIndex == y)
                        actor.ai.model.targetOpponentIndex = NULL;
                    end
                end
            end
            // find new opponents and update known ones
            for (y = 0; y < MAX_ACTORS; ++y)
                if (opponents[y] <= 0)
                    continue;
                end
                opponent = opponents[y];
                if (opponent.alive == false)
                    continue;
                end
                // can AI see opponent?
                isVisible = AILineOfSight(actor.x, actor.y, opponent.x, opponent.y);
                knownOpponentIndex = NULL;
                // TODO: Clean this up into a function.
                // find index of element where processId == opponent
                for (z = 0; z < MAX_ACTORS - 1; ++z)
                    if (actor.ai.model.knownOpponents[z].processId == opponent)
                        knownOpponentIndex = z;
                        break;
                    end
                end
                if (knownOpponentIndex < 0 && isVisible)
                    // TODO: Clean this up into a function.
                    // find next free index
                    for (z = 0; z < MAX_ACTORS - 1; ++z)
                        if (actor.ai.model.knownOpponents[z].processId <= 0)
                            knownOpponentIndex = z;
                            break;
                        end
                    end
                    // visible but previously unknown opponents are added to AI's model
                    actor.ai.model.knownOpponents[z].processId = opponent;
                    actor.ai.model.knownOpponentCount++;
                end
                // if knownOpponentIndex is valid (>= 0), then update x, y and visible properties of AI's model
                if (knownOpponentIndex >= 0)
                    z = knownOpponentIndex;
                    actor.ai.model.knownOpponents[z].visible = isVisible;
                    if (isVisible)
                        actor.ai.model.knownOpponents[z].x = opponent.x;
                        actor.ai.model.knownOpponents[z].y = opponent.y;
                    end
                end
            end
        end
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * AI utilities
 * ---------------------------------------------------------------------------*/
function AILineOfSight(x0, y0, x1, y2)
begin
    // TODO: Implement raycast. Consider using collision (hardness) map?
    return (true);
end

function AIGetNearestVisibleKnownOpponentIndex(controllerId)
private
    closestOpponentIndex = NULL;
    shortestDistance = max_int;
    distance;
    pointer opponent;
begin
    if (controllerId.ai.model.knownOpponentCount > 0)
        for (z = 0; z < MAX_ACTORS - 1; ++z)
            if (controllerId.ai.model.knownOpponents[z].processId > NULL 
                && controllerId.ai.model.knownOpponents[z].visible)
                distance = fget_dist(
                    controllerId.x, 
                    controllerId.y, 
                    controllerId.ai.model.knownOpponents[z].x, 
                    controllerId.ai.model.knownOpponents[z].y);
                if (distance < shortestDistance)
                    shortestDistance = distance;
                    closestOpponentIndex = z;
                end
            end
        end
    end
    return (closestOpponentIndex);
end



/* -----------------------------------------------------------------------------
 * Actor components
 * ---------------------------------------------------------------------------*/
process ActorFaction(controllerId, actorType)
private
    pointer factionActors;
begin
    // initialization
    value = __actorStats[actorType].faction;
    factionActors = GetFactionActors(value);
    // find next free index
    for (x = 0; x < MAX_ACTORS - 1; ++x)
        if (factionActors[x] <= 0)
            factionActors[x] = father;
            break;
        end
    end
    repeat
        frame;
    until (controllerId.alive == false)
    // clear table entry
    factionActors[x] = NULL;
end

process HumanAnimator(controllerId, actorType)
private
    arms;
    base;
    head;
    weapon;
begin
    // initialization
    resolution = GPR;
    ctype = c_scroll;

    // sub-processes
    arms = HumanArms(controllerId, actorType);
    base = HumanBase(controllerId, actorType);
    head = HumanHead(controllerId, actorType);
    weapon = Weapon(controllerId);
    repeat
        CopyXYAngle(controllerId);
        frame;
    until (controllerId.alive == false)
end

process HumanArms(controllerId, actorType)
begin
    // initialization
    resolution = GPR;
    ctype = c_scroll;
    file = __gfxActors;
    graph = 200 + __actorStats[actorType].gfxOffset;
    z = -90;
    repeat
        CopyXYAngle(controllerId);
        frame;
    until (controllerId.alive == false)
end

process HumanBase(controllerId, actorType)
begin
    // initialization
    resolution = GPR;
    ctype = c_scroll;
    file = __gfxActors;
    graph = 100 + __actorStats[actorType].gfxOffset;
    z = -100;
    value = controllerId;
    repeat
        CopyXYAngle(controllerId);
        frame;
    until (controllerId.alive == false)
end

process HumanHead(controllerId, actorType)
begin
    // initialization
    resolution = GPR;
    ctype = c_scroll;
    file = __gfxActors;
    graph = 401;
    z = -110;
    repeat
        CopyXYAngle(controllerId);
        frame;
    until (controllerId.alive == false)
end

process Health(controllerId, startingHealth)
begin
    value = startingHealth;
    //LogValueFollow(controllerId, "health.value", &value);
    repeat
        frame;
    until (value <= 0)
    CleanUpLocalLogs(controllerId);
    controllerId.alive = false;
end

process HumanPhysics(controllerId, walkSpeed, runSpeed)
begin
    controllerId.physics.walkSpeed = walkSpeed;
    controllerId.physics.runSpeed = runSpeed;
    components.physics = Physics(controllerId);
    repeat
        if (controllerId.input.move.walk == INPUT_WALK)
            controllerId.physics.targetMoveSpeed = controllerId.physics.walkSpeed;
        else
            controllerId.physics.targetMoveSpeed = controllerId.physics.runSpeed;
        end
        frame;
    until (controllerId.alive == false)
end

process Physics(controllerId)
begin
    // NOTE: This seems wrong. Target move speed should be determined by the controller, not by the 
    // physics component, even at initilization time.
    controllerId.physics.targetMoveSpeed = PHYSICS_MAX_MOVE_SPEED;
    repeat
        ApplyInputToVelocity(controllerId);
        ApplyVelocity(controllerId);
        frame;
    until (controllerId.alive == false)
end

process Inventory(controllerId, pointer inventoryContents)
private
    i;
    statsIndex;
    count;
    ammoLoaded;
begin
    for (i = 0; i < INVENTORY_SLOTS; ++i)
        controllerId.inventory[i].statsIndex = NULL;
        controllerId.inventory[i].count = NULL;
        controllerId.inventory[i].ammoLoaded = NULL;
    end
    for (i = 0; i < INVENTORY_SLOTS; ++i)
        statsIndex = i * 3;
        count = statsIndex + 1;
        ammoLoaded = statsIndex + 2;
        if (inventoryContents[statsIndex] > NULL)
            GiveItem(
                controllerId, 
                inventoryContents[statsIndex], 
                inventoryContents[count],
                inventoryContents[ammoLoaded]);
        end
    end
    //LogValueFollow(controllerId, "inventory[0].statsIndex", &controllerId.inventory[0].statsIndex);
    //LogValueFollow(controllerId, "inventory[0].count", &controllerId.inventory[0].count);
    //LogValueFollow(controllerId, "inventory[0].ammoLoaded", &controllerId.inventory[0].ammoLoaded);
    //LogValueFollow(controllerId, "inventory[1].statsIndex", &controllerId.inventory[1].statsIndex);
    //LogValueFollow(controllerId, "inventory[1].count", &controllerId.inventory[1].count);
    //LogValueFollow(controllerId, "inventory[1].ammoLoaded", &controllerId.inventory[1].ammoLoaded);
    repeat
        frame;
    until (controllerId.alive == false)
    // TODO: drop all items when dead
end



/* -----------------------------------------------------------------------------
 * Weapons
 * ---------------------------------------------------------------------------*/
process Weapon(controllerId)
private
    lastShotTime = 0;
    inventoryIndex;
    statsIndex;
    reloadInProgress = false;
begin
    // initialization
    resolution = GPR;
    ctype = c_scroll;
    file = __gfxItems;
    z = -95;
    //LogValueFollow(controllerId, "reloadInProgress", &reloadInProgress);
    repeat
        CopyXYAngle(controllerId);
        inventoryIndex = controllerId.selectedItemIndex;
        statsIndex = controllerId.inventory[inventoryIndex].statsIndex;

        // If actor isn't holding a weapon, do nothing and make this invisible.
        if (statsIndex == NULL)
            graph = 0;
            continue;
        else
            graph = __itemStats[statsIndex].gfxIndex;
        end

        // Firing logic.
        if (controllerId.input.attacking)             
            if ((__itemStats[statsIndex].firingMode == FIRING_MODE_SINGLE 
                && controllerId.input.attackingPreviousFrame == false)
                || (__itemStats[statsIndex].firingMode == FIRING_MODE_AUTO))
                if (controllerId.inventory[inventoryIndex].ammoLoaded > 0)
                    if (timer[0] > lastShotTime + __itemStats[statsIndex].timeBetweenShots)
                        // NOTE: Disabled because DIV doesn't handle multiple sounds at the same time very well...
                        //PlaySoundWithDelay(SOUND_SHELL_DROPPED_1 + rand(0, 2), 128, 256, 50);
                        PlaySound(__itemStats[statsIndex].soundIndex, 128, 512);
                        MuzzleFlash(__itemStats[statsIndex].offsetMuzzleForward);
                        Projectile(__itemStats[statsIndex].projectileType);
                        lastShotTime = timer[0];
                        controllerId.inventory[inventoryIndex].ammoLoaded--;
                    end
                end
            end
        end

        // Reloading logic.
        // TODO: Consider how to cancel reloads due to weapon switching or other overriding input.
        if (!reloadInProgress)
            if (controllerId.input.reloading)
                if (CanReloadSelectedWeapon(controllerId))
                    reloadInProgress = true;
                end
            end
        else
            while (Delay(id, __itemStats[statsIndex].timeToReload) 
                && controllerId.alive == true)
                CopyXYAngle(controllerId);
                // TODO: Reload animations.
                frame;
            end
            reloadInProgress = false;
            ReloadWeapon(controllerId);
        end

        frame;
    until (controllerId.alive == false)
    CleanUpLocalLogs(id);
end

function CanReloadSelectedWeapon(actorId)
private
    statsIndex;
    ammoIndex;
begin
    statsIndex = actorId.inventory[actorId.selectedItemIndex].statsIndex;

    // Must have selected an item.
    if (statsIndex == NULL)
        return (false);
    end

    // Selected item must be a weapon.
    if (__itemStats[statsIndex].itemType != ITEM_TYPE_WEAPON)
        return (false);
    end

    // Must be holding some appropriate ammo.
    ammoIndex = GetItemInventoryIndex(actorId, __itemStats[statsIndex].ammoType);
    if (ammoIndex == NULL || actorId.inventory[ammoIndex].count <= 0)
        return (false);
    end

    // Must have less than full magazine loaded.
    if (actorId.inventory[actorId.selectedItemIndex].ammoLoaded >= __itemStats[statsIndex].magazineSize)
        return (false);
    end
    return (true);
end

function ReloadWeapon(actorId)
private
    statsIndex;
    ammoIndex;
    count;
begin
    if (!actorId.alive)
        return;
    end

    statsIndex = actorId.inventory[actorId.selectedItemIndex].statsIndex;
    ammoIndex = GetItemInventoryIndex(actorId, __itemStats[statsIndex].ammoType);

    // Return loaded ammo from weapon to inventory.
    actorId.inventory[ammoIndex].count += actorId.inventory[actorId.selectedItemIndex].ammoLoaded; 

    // Determine new magazine count.
    count = Min(actorId.inventory[ammoIndex].count, __itemStats[statsIndex].magazineSize);

    // Remove ammo from inventory and add it to weapon.
    actorId.inventory[ammoIndex].count -= count;
    actorId.inventory[actorId.selectedItemIndex].ammoLoaded = count;
end

function IsSelectedWeaponEmpty(actorId)
begin
    return (actorId.inventory[actorId.selectedItemIndex].ammoLoaded == 0);
end



/* -----------------------------------------------------------------------------
 * Inventory & items
 * ---------------------------------------------------------------------------*/
function GiveItem(actorId, statsIndex, count, ammoLoaded)
private
    i;
begin
    // Can't give 0 or negative items.
    if (count <= 0)
        return (false);
    end

    // If the actor already has this item...
    i = GetItemInventoryIndex(actorId, statsIndex);
    if (i != NULL)
        // ...and maxCarry is not yet exceeded...
        if (actorId.inventory[i].count < __itemStats[statsIndex].maxCarry)
            // ...and the combined count still doesn't exceed maxCarry...
            if (actorId.inventory[i].count + count <= __itemStats[statsIndex].maxCarry)
                // ...then increase the existing item's count.
                actorId.inventory[i].count += count;
                return (true);
            else
                // ...but it is splittable, then split it.
                if (__itemStats[statsIndex].itemType == ITEM_TYPE_AMMO)
                    SplitItem(actorId, i, statsIndex, count, ammoLoaded);
                    return (true);
                end
            end
        end
    // If actor hasn't got this item already, find a free index.
    else
        // TODO: Replace (and test) with: FindFreeTableIndex(&actorId.inventory, INVENTORY_SLOTS - 1)
        i = GetNextFreeInventoryIndex(actorId);
        // If there is space, add item to actor's inventory.
        if (i != NULL)
            actorId.inventory[i].statsIndex = statsIndex;
            actorId.inventory[i].count = count;
            actorId.inventory[i].ammoLoaded = ammoLoaded;
            return (true);
        end
    end

    // Actor unable to hold this item.
    return (false);
end

function SplitItem(actorId, inventoryIndex, statsIndex, count, ammoLoaded)
private
    combinedCount;
    splitCount;
begin
    combinedCount = actorId.inventory[inventoryIndex].count + count;

    // Give actor amount up to maxCarry.
    actorId.inventory[inventoryIndex].count = Min(combinedCount, __itemStats[statsIndex].maxCarry);
    actorId.inventory[inventoryIndex].ammoLoaded = ammoLoaded;

    // Drop the rest.
    splitCount = combinedCount - __itemStats[statsIndex].maxCarry;
    if (splitCount > 0)
        Item(actorId.x, actorId.y, actorId.angle, statsIndex, splitCount, NULL);
    end
end

function GetItemInventoryIndex(actorId, statsIndex)
private
    i;
begin
    while (i < INVENTORY_SLOTS)
        if (actorId.inventory[i].statsIndex == statsIndex)
            return (i);
        end
        ++i;
    end
    return (NULL);
end

function GetNextFreeInventoryIndex(actorId)
private
    i;
begin
    while (i < INVENTORY_SLOTS)
        if (actorId.inventory[i].statsIndex == NULL)
            return (i);
        end
        ++i;
    end
    return (NULL);
end

process Item(x, y, angle, statsIndex, count, ammoLoaded) 
private
    collisionId;
begin
    resolution = GPR;
    ctype = c_scroll;
    file = __gfxItems;
    graph = __itemStats[statsIndex].gfxIndex;
    LogValueFollow(id, "count", &count);
    value = false;
    loop
        collisionId = collision(type HumanBase);
        if (collisionId != 0)
            value = GiveItem(collisionId.value, statsIndex, count, ammoLoaded);
            if (value)
                break;
            end
        end
        frame;
    end
    CleanUpLocalLogs(id);
end



/* -----------------------------------------------------------------------------
 * Projectiles
 * ---------------------------------------------------------------------------*/
process Projectile(projectileType)
private
    collisionId;
begin
    resolution = GPR;
    ctype = c_scroll;
    file = __gfxMain;
    graph = 601;
    z = -700;
    CopyXYAngle(father);
    advance(__projectileStats[projectileType].offsetForward); 
    // TODO: implement offsetLeft
    LifeTimer(__projectileStats[projectileType].lifeDuration);
    loop
        advance(__projectileStats[projectileType].speed);
        collisionId = collision(type HumanBase);
        if (collisionId != 0)
            collisionId.value.components.health.value -= __projectileStats[projectileType].damage;
            break;
        end
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * Special FX
 * ---------------------------------------------------------------------------*/
process MuzzleFlash(forwardOffset)
private
    lifeDuration = 5;
    animationTime = 0;
begin
    // initialization
    resolution = GPR;
    ctype = c_scroll;
    file = __gfxMain;
    graph = 700;
    z = -710;
    angle = father.angle;
    // children
    LifeTimer(lifeDuration);
    loop
        // animation
        animationTime += 1000 / (lifeDuration / __deltaTime);
        size = (sin(animationTime * 180) + 1000) / 40;

        // positioning
        CopyXY(father);
        advance(forwardOffset);
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * Faction utilities
 * ---------------------------------------------------------------------------*/
function GetFactionOpponents(faction)
begin
    // TODO: This code is fragile, improve it.
    switch (faction)
        case FACTION_GOOD:
            return (&__evilActors);
        end
        case FACTION_EVIL:
            return (&__goodActors);
        end
    end
end

function GetFactionActors(faction)
begin
    // TODO: This code is fragile, improve it.
    switch (faction)
        case FACTION_NEUTRAL:
            return (&__neutralActors);
        end
        case FACTION_GOOD:
            return (&__goodActors);
        end
        case FACTION_EVIL:
            return (&__evilActors);
        end
    end
end

function IsOpposingFaction(myFaction, otherFaction)
begin
    // TODO: This code is fragile, improve it.
    if (myFaction == FACTION_NEUTRAL || otherFaction == FACTION_NEUTRAL)
        return (false);
    end
    if (myFaction == otherFaction)
        return (false);
    end
    return (true);
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



/* -----------------------------------------------------------------------------
 * Process utilities
 * ---------------------------------------------------------------------------*/
function KillProcess(processId)
begin
    CleanUpLocalLogs(processId);
    signal(processId, s_kill_tree);
end

function RecordSpawnPosition(processId)
begin
    processId.spawnPosition.x = processId.x;
    processId.spawnPosition.y = processId.y;
end

function CopyXY(processId)
begin
    father.x = processId.x;
    father.y = processId.y;
end

function CopyXYAngle(processId)
begin
    father.x = processId.x;
    father.y = processId.y;
    father.angle = processId.angle;
end

function TurnTowards(processId, targetProcessId, turnSpeed)
begin
    TurnTowardsPosition(processId, targetProcessId.x, targetProcessId.y, turnSpeed);
end

function TurnTowardsPosition(processId, tX, tY, turnSpeed)
begin
    processId.angle = near_angle(
        processId.angle, 
        fget_angle(processId.x, processId.y, tX, tY), 
        turnSpeed);
end



/* -----------------------------------------------------------------------------
 * Drawing and writing functions
 * ---------------------------------------------------------------------------*/
function DrawScrollSpaceLine(x0, y0, x1, y1, color, opacity)
begin
    x0 = (x0 / GPR) - scroll[0].x0;
    y0 = (y0 / GPR) - scroll[0].y0;
    x1 = (x1 / GPR) - scroll[0].x0;
    y1 = (y1 / GPR) - scroll[0].y0;
    return (draw(DRAW_LINE, color, opacity, REGION_FULL_SCREEN, x0, y0, x1, y1));
end

process DrawScrollSpaceLine1Frame(x0, y0, x1, y1, color, opacity)
begin
    value = DrawScrollSpaceLine(x0, y0, x1, y1, color, opacity);
    frame;
    delete_draw(value);
end

function DrawScreenSpaceRectangle(x0, y0, x1, y1, color, opacity)
begin
    return (draw(DRAW_RECTANGLE_FILL, color, opacity, REGION_FULL_SCREEN, x0, y0, x1, y1));
end

process DrawScreenSpaceRectangle1Frame(x0, y0, x1, y1, color, opacity)
begin
    value = DrawScreenSpaceRectangle(x0, y0, x1, y1, color, opacity);
    frame;
    delete_draw(value);
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
        __lineIntersectionData.ix = x0 + ((t * rx) / precision);
        __lineIntersectionData.iy = y0 + ((t * ry) / precision);
        return (true);
    end

    // Non-intersecting.
    __lineIntersectionData.ix = 0;
    __lineIntersectionData.iy = 0;
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



/* -----------------------------------------------------------------------------
 * Debugging
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
private
    index;
begin
    index = GetNextLocalLogIndex(processId);
    LogValueBase(processId, label, val, true);
    loop
        x = (processId.x / GPR) + xOffset;
        y = (processId.y / GPR) + (index * __logsYOffset) + yOffset;
        if (processId.ctype == c_scroll)
            x -= scroll[0].x0;
            y -= scroll[0].y0;
        end
        move_text(processId.logs[index].txtLabel, x, y);
        move_text(processId.logs[index].txtVal, x, y);
        frame;
    end
end

process LogValueBase(processId, string label, val, follow)
private
    index;
    txtLabel;
    txtVal;
begin
    if (follow)
        index = GetNextLocalLogIndex(processId);
        processId.logs[index].logId = father;
        processId.logCount++;
    else
        x = __logsX;
        y = __logsY + (__logCount * __logsYOffset);
        index = GetNextGlobalLogIndex();
        __logs[index].logId = id;
        __logCount++;
    end

    label = label + ": ";
    // TODO: Use WriteText functions.
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
        processId.logs[index].txtLabel = txtLabel;
        processId.logs[index].txtVal = txtVal;
    else
        __logs[index].txtLabel = txtLabel;
        __logs[index].txtVal = txtVal;
    end
    loop
        frame;
    end
end

function DeleteGlobalLog()
begin
    __logCount--;
    delete_text(__logs[__logCount].txtLabel);
    delete_text(__logs[__logCount].txtVal);
    signal(__logs[__logCount].logId, s_kill_tree);
end

function DeleteLocalLog(processId)
begin
    processId.logCount--;
    delete_text(processId.logs[processId.logCount].txtLabel);
    delete_text(processId.logs[processId.logCount].txtVal);
    signal(processId.logs[processId.logCount].logId, s_kill_tree);
end

function GetNextGlobalLogIndex()
begin
    for (x = 0; x < MAX_LOGS; x++)
        if (__logs[x].logId <= 0)
            return (x);
        end
    end
    return (NULL);
end

function GetNextLocalLogIndex(processId)
begin
    for (x = 0; x < MAX_LOGS; x++)
        if (processId.logs[x].logId <= 0)
            return (x);
        end
    end
    return (NULL);
end

function CleanUpLocalLogs(processId)
begin
    y = processId.logCount;
    for (x = 0; x < y; ++x)
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
    LogValue("__deltaTime", &__deltaTime);
    loop
        t0 = timer[0];
        frame;
        t1 = timer[0];
        __deltaTime = Max(t1 - t0, 1); // deltaTime can never be 0
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
private
    index;
begin
    index = GetDelayIndex(processId);
    if (index == NULL)
        // TODO: Replace (and test) with: FindFreeTableIndex(&__delays, MAX_DELAYS - 1)
        index = GetNextFreeDelayIndex();
        __delays[index].processId = processId;
        __delays[index].startTime = timer[0];
        __delays[index].delayLength = delayLength;
        __delayCount++;
    end
    if (timer[0] > __delays[index].startTime + __delays[index].delayLength)
        __delayCount--;
        __delays[index].processId = NULL;
        __delays[index].startTime = NULL;
        __delays[index].delayLength = NULL;
        return (false);
    end
    return (true);
end

function GetDelayIndex(processId)
begin
    // TODO: This might be a performance problem... need a hash map.
    for (x = 0; x < MAX_DELAYS; x++)
        if (__delays[x].processId == processId)
            return (x);
        end
    end
    return (NULL);
end

function GetNextFreeDelayIndex()
begin
    for (x = 0; x < MAX_DELAYS; x++)
        if (__delays[x].processId <= 0)
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
private
    i;
begin
    for (i = 0; i < tableSize; ++i)
        tablePtr[i] = initialValue;
    end
end

function FindFreeTableIndex(pointer tablePtr, tableSize)
private
    i;
begin
    for (i = 0; i < tableSize; ++i)
        if (tablePtr[i] == NULL)
            return (i);
        end
    end
    return (NULL);
end




















