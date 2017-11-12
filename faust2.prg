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
    // general
    NULL = -1;

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

    // application
    MENU_OPTION_NONE = 0;
    MENU_OPTION_PLAY = 1;
    GAME_STATE_NOT_STARTED = 0;
    GAME_STATE_ACTIVE      = 1;
    GAME_STATE_GAME_OVER   = 2;

    // resources
    SOUND_MP40_SHOT       = 0;
    SOUND_SHELL_DROPPED_1 = 1;
    SOUND_SHELL_DROPPED_2 = 2;
    SOUND_SHELL_DROPPED_3 = 3;
    SOUNDS_COUNT = 4;

    // file paths
    GFX_MAIN_PATH   = "assets/graphics/main.fpg";
    GFX_ACTORS_PATH = "assets/graphics/actors.fpg";
    FNT_MENU_PATH   = "assets/fonts/16x16-w-arcade.fnt";

    // graphics
    SCREEN_MODE        = m640x400;
    SCREEN_WIDTH       = 640;
    SCREEN_HEIGHT      = 400;
    HALF_SCREEN_WIDTH  = SCREEN_WIDTH / 2;
    HALF_SCREEN_HEIGHT = SCREEN_HEIGHT / 2;
    GPR = 10;

    // inventory & items
    INVENTORY_SLOTS = 5;
    ITEM_TYPE_WEAPON     = 0;
    ITEM_TYPE_CONSUMABLE = 1;
    ITEM_TYPE_SPECIAL    = 2;
    ITEM_TYPE_AMMO       = 3;
    ITEMS_COUNT = 4;
    ITEM_MP40       = 0;
    ITEM_KAR98K     = 1;
    ITEM_AMMO_9MM   = 1;
    ITEM_AMMO_RIFLE = 2;

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

    // timing
    MAX_DELAYS = 32;

    // debugging
    MAX_LOGS = 32;

/* -----------------------------------------------------------------------------
 * Global variables
 * ---------------------------------------------------------------------------*/
global
    // resources
    __gfxMain;
    __gfxActors;
    __fntSystem;
    __fntMenu;
    __sounds[SOUNDS_COUNT - 1];

    // gameplay stats
    struct __itemStats[ITEMS_COUNT - 1]
        string name;
        itemType;
        slotsNeeded; // TODO: consider just adding check for ITEM_TYPE_AMMO where relevant
        maxCarry;
        magazineSize;
        soundIndex;
        offsetForward;
        offsetLeft;
    end =
        "MP40",       ITEM_TYPE_WEAPON, 1, 1,   30,   SOUND_MP40_SHOT, 45 * GPR, 0 * GPR,
        "Kar 98k",    ITEM_TYPE_WEAPON, 1, 1,   5,    SOUND_MP40_SHOT, 45 * GPR, 0 * GPR,
        "9mm Ammo",   ITEM_TYPE_AMMO,   0, 150, NULL, NULL,            NULL,     NULL,
        "Rifle Ammo", ITEM_TYPE_AMMO,   0, 90,  NULL, NULL,            NULL,     NULL;

    struct __bulletStats[1]
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
        2 * GPR, 4 * GPR, 10000, 2, 200, FACTION_GOOD, // player
        2 * GPR, 3 * GPR, 10000, 1, 100, FACTION_EVIL, // guard level 1
        2 * GPR, 3 * GPR, 10000, 1, 150, FACTION_EVIL, // guard level 2
        2 * GPR, 3 * GPR, 10000, 1, 200, FACTION_EVIL, // guard level 3
        2 * GPR, 3 * GPR, 10000, 1, 100, FACTION_EVIL, // officer level 1
        2 * GPR, 3 * GPR, 10000, 1, 150, FACTION_EVIL, // officer level 2
        2 * GPR, 3 * GPR, 10000, 1, 200, FACTION_EVIL, // officer level 3
        2 * GPR, 3 * GPR, 10000, 2, 200, FACTION_GOOD; // allied commando

    // starting inventories
    struct guardInventory[INVENTORY_SLOTS - 1]
        statsIndex;
        count;
    end =
        ITEM_MP40, 1,
        ITEM_AMMO_9MM, 90,
        NULL, NULL,
        NULL, NULL,
        NULL, NULL;

    // game processes
    __playerController;
    // TODO: Check if 2D arrays work in DIV, if yes turn this into one array of actors by faction.
    __neutralActors[MAX_ACTORS - 1];
    __goodActors[MAX_ACTORS - 1];
    __evilActors[MAX_ACTORS - 1];

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
        inventory;
        physics;
    end
    value; // A value held by a component. What this holds is determined by the individual component.

    // actor data
    alive;
    struct spawnPosition
        x;
        y;
    end

    // actor input data
    struct input
        attackingPreviousFrame;
        attacking;
        struct move
            x;
            y;
            granularity;
            walk;
        end
        struct lookAt
            x;
            y;
        end
    end

    // actor physics
    struct physics
        walkSpeed;
        runSpeed;
        targetMoveSpeed;
        struct velocity
            x;
            y;
        end
    end

    // actor inventory
    struct inventory[INVENTORY_SLOTS - 1]
        statsIndex;
        count;
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
                x;
                y;
                visible;
            end
        end
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
    __gfxMain       = load_fpg(GFX_MAIN_PATH);
    __gfxActors = load_fpg(GFX_ACTORS_PATH);

    // load fonts
    __fntSystem = 0;
    __fntMenu   = load_fnt(FNT_MENU_PATH);

    // load sounds
    __sounds[SOUND_MP40_SHOT]       = load_sound("assets/audio/test-shot5.wav", 0);
    __sounds[SOUND_SHELL_DROPPED_1] = load_sound("assets/audio/shell-dropped1.wav", 0);
    __sounds[SOUND_SHELL_DROPPED_2] = load_sound("assets/audio/shell-dropped2.wav", 0);
    __sounds[SOUND_SHELL_DROPPED_3] = load_sound("assets/audio/shell-dropped3.wav", 0);

    // timing
    LogValue("FPS", &fps);
    LogValue("__goodActors[0]", &__goodActors[0]);
    LogValue("__evilActors[0]", &__evilActors[0]);
    DeltaTimer();

    // show title screen
    TitleScreen();
end



/* -----------------------------------------------------------------------------
 * Menu screens
 * ---------------------------------------------------------------------------*/
function TitleScreen()
private
    selected = MENU_OPTION_NONE;
    txtTitle;
begin
    // initialization
    clear_screen();
    put_screen(__gfxMain, 1);
    txtTitle = write(
        __fntMenu, 
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
        GameManager();
    end
end



/* -----------------------------------------------------------------------------
 * Gameplay
 * ---------------------------------------------------------------------------*/
function GameManager()
private
    state = GAME_STATE_NOT_STARTED;
    scrollBackground = 0;
begin
    // initialization
    clear_screen();

    // graphics
    start_scroll(
        scrollBackground, 
        __gfxMain, 200, 0, 
        REGION_FULL_SCREEN, 
        SCROLL_FOREGROUND_HORIZONTAL + SCROLL_FOREGROUND_VERTICAL);

    // gameplay
    state = GAME_STATE_ACTIVE;

    // actors
    __playerController = PlayerController(40 * GPR, 40 * GPR, &guardInventory);
    //GiveItem(__playerController, CreateItem(ITEM_MP40, 1));
    //GiveItem(__playerController, CreateItem(ITEM_AMMO_9MM, 90));

    AIController(ACTOR_GUARD_1, 320 * GPR, 200 * GPR, &guardInventory);
    //AIController(ACTOR_GUARD_1, 350 * GPR, 240 * GPR, &aiStartingItems);
    //AIController(ACTOR_ALLIED_COMMANDO, 560 * GPR, 100 * GPR, &aiStartingItems);

    // managers
    AIModelManager(FACTION_EVIL);
    AIModelManager(FACTION_GOOD);

    // game loop
    repeat
        // TODO: gameplay goes here
        frame;
    until (state == GAME_STATE_GAME_OVER)
end



/* -----------------------------------------------------------------------------
 * Actor Controllers
 * ---------------------------------------------------------------------------*/
process PlayerController(x, y, startingItems)
private
    mouseCursor;
begin
    // configuration
    input.move.granularity = 1;
    resolution = GPR;

    // initialization
    alive = true;
    RecordSpawnPosition(id);

    // components & sub-processes
    components.health = HealthComponent(id, __actorStats[ACTOR_PLAYER].startingHealth);
    components.animator = ActorAnimator(id, ACTOR_PLAYER);
    components.faction = ActorFaction(id, ACTOR_PLAYER);
    components.inventory = InventoryComponent(id, startingItems);
    components.physics = PhysicsComponent(id, __actorStats[ACTOR_PLAYER].walkSpeed, __actorStats[ACTOR_PLAYER].runSpeed);
    mouseCursor = MouseCursor();

    // debugging
    LogValueFollow("health.value", &components.health.value);
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
        InputLookAt(id, mouseCursor.x, mouseCursor.y);
        input.attackingPreviousFrame = input.attacking;
        input.attacking = mouse.left;
        // TODO: implement player walk controls
        input.move.walk = false;

        // turn towards the look input
        TurnTowardsPosition(
            id,
            input.lookAt.x, 
            input.lookAt.y, 
            __actorStats[ACTOR_PLAYER].maxTurnSpeed);
        frame;
    until (alive == false)
end

process AIController(actorType, x, y, startingItems)
private
    animator;
begin
    // configuration
    input.move.granularity = 10;
    resolution = GPR;

    // initialization
    alive = true;
    RecordSpawnPosition(id);
    ai.previousState = AI_STATE_NONE;
    ai.currentState = AI_STATE_NONE;
    ai.model.targetOpponentIndex = NULL;

    // components & sub-processes
    components.health = HealthComponent(id, __actorStats[actorType].startingHealth);
    components.animator = ActorAnimator(id, actorType);
    components.faction = ActorFaction(id, actorType);
    components.inventory = InventoryComponent(id, startingItems);
    components.physics = PhysicsComponent(id, __actorStats[actorType].walkSpeed, __actorStats[actorType].runSpeed);

    // debugging
    LogValueFollow("health.value", &components.health.value);
    LogValueFollow("input.move.walk", &input.move.walk);
    LogValueFollow("ai.previousState", &ai.previousState);
    LogValueFollow("ai.currentState", &ai.currentState);
    LogValueFollow("ai.model.knownOpponentCount", &ai.model.knownOpponentCount);
    LogValueFollow("ai.model.targetOpponentIndex", &ai.model.targetOpponentIndex);
    LogValueFollow("spawnPosition.x", &spawnPosition.x);
    LogValueFollow("spawnPosition.y", &spawnPosition.y);

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



// TODO: Clean up with CicTec's improvements on DIV-arena.
/* -----------------------------------------------------------------------------
 * AI model management
 * ---------------------------------------------------------------------------*/
process AIModelManager(faction)
private
    pointer opponents;
    pointer actors;
    knownOpponentIndex = NULL;
    // TODO: Remove this pointer, might be unnecessary.
    pointer opponent;
    pointer actor;
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
                // TODO: Test cleaning up * syntax, might be unnecessary.
                isVisible = AILineOfSight(actor.x, actor.y, (*opponent).x, (*opponent).y);
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

process ActorAnimator(controllerId, actorType)
private
    arms;
    base;
    head;
    weapon;
begin
    // initialization
    resolution = GPR;
    // sub-processes
    arms = ActorArms(controllerId, actorType);
    base = ActorBase(controllerId, actorType);
    head = ActorHead(controllerId, actorType);
    weapon = ActorWeapon(controllerId);
    repeat
        CopyXYAngle(controllerId);
        frame;
    until (controllerId.alive == false)
end

process ActorArms(controllerId, actorType)
begin
    // initialization
    resolution = GPR;
    file = __gfxActors;
    graph = 200 + __actorStats[actorType].gfxOffset;
    z = -90;
    repeat
        CopyXYAngle(controllerId);
        frame;
    until (controllerId.alive == false)
end

process ActorBase(controllerId, actorType)
begin
    // initialization
    resolution = GPR;
    components.health = controllerId.components.health;
    file = __gfxActors;
    graph = 100 + __actorStats[actorType].gfxOffset;
    z = -100;
    repeat
        CopyXYAngle(controllerId);
        frame;
    until (controllerId.alive == false)
end

process ActorHead(controllerId, actorType)
begin
    // initialization
    resolution = GPR;
    file = __gfxActors;
    graph = 401;
    z = -110;
    repeat
        CopyXYAngle(controllerId);
        frame;
    until (controllerId.alive == false)
end

process ActorWeapon(controllerId)
private
    lastShotTime = 0;
begin
    // initialization
    resolution = GPR;
    file = __gfxMain;
    graph = 800;
    z = -95;
    repeat
        CopyXYAngle(controllerId);
        if (controllerId.input.attacking && timer[0] > lastShotTime + 12)
            // NOTE: Disabled because DIV doesn't handle multiple sounds at the same time very well...
            //PlaySoundWithDelay(SOUND_SHELL_DROPPED_1 + rand(0, 2), 128, 256, 50);
            PlaySound(SOUND_MP40_SHOT, 128, 512);
            MuzzleFlash();
            Bullet(BULLET_9MM);
            lastShotTime = timer[0];
        end
        // Play a single 'shell drop' sound when stopped firing.
        if (controllerId.input.attacking == false && controllerId.input.attackingPreviousFrame == true)
            PlaySoundWithDelay(SOUND_SHELL_DROPPED_1 + rand(0, 2), 128, 256, 15);
        end
        frame;
    until (controllerId.alive == false)
end



/* -----------------------------------------------------------------------------
 * Components
 * ---------------------------------------------------------------------------*/
process HealthComponent(controllerId, startingHealth)
begin
    value = startingHealth;
    repeat
        frame;
    until (value <= 0)
    CleanUpLocalLogs(controllerId);
    controllerId.alive = false;
end

process PhysicsComponent(controllerId, walkSpeed, runSpeed)
begin
    controllerId.physics.walkSpeed = walkSpeed;
    controllerId.physics.runSpeed = runSpeed;
    repeat
        ApplyInputToVelocity(controllerId);
        ApplyVelocity(controllerId);
        frame;
    until (controllerId.alive == false)
end

process InventoryComponent(controllerId, pointer startingItems)
private
    i;
begin
    for (i = 0; i < INVENTORY_SLOTS; ++i)
        if (startingItems[i] > NULL)
            GiveItem(
                controllerId, 
                startingItems[i].statsIndex, 
                startingItems[i].count);
        end
    end
    repeat
        frame;
    until (controllerId.alive == false)
    // TODO: drop all items when dead
end



/* -----------------------------------------------------------------------------
 * Inventory & items
 * ---------------------------------------------------------------------------*/
function GiveItem(actorId, statsIndex, count)
private
    freeIndex = NULL;
begin
    // Can't give 0 or negative items.
    if (count <= 0)
        return;
    end

    // TODO: Check if count against maxCarry.

    // TODO: implement
    for (freeIndex = 0; freeIndex < INVENTORY_SLOTS; ++freeIndex)
        if (actorId.inventory[freeIndex].itemId == NULL)
            break;
        end
    end
    // Handle no free index.
    if (freeIndex == NULL)
        // TODO: drop item
        return;
    end
    // Add item to actor's inventory table.
    actorId.inventory[freeIndex].statsIndex = statsIndex;
    actorId.inventory[freeIndex].count = count;
end

function PickUpItem(actorId, itemId, statsIndex, count)
begin
end

process Item(statsIndex, count)
begin
    // TODO: implement
    loop
        // TODO: detect collision with actor and attempt pick up
        //PickUpItem(actorId, id, statsIndex, count);
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * Projectiles
 * ---------------------------------------------------------------------------*/
// TODO: Refactor to generic projectile.
process Bullet(bulletType)
private
    collisionId;
begin
    // initialization
    resolution = GPR;
    // graphics
    file = __gfxMain;
    graph = 601;
    z = -700;
    // positioning
    CopyXYAngle(father);
    advance(__bulletStats[bulletType].offsetForward); // TODO: implement offsetLeft
    // children
    LifeTimer(__bulletStats[bulletType].lifeDuration);
    loop
        advance(__bulletStats[bulletType].speed);
        collisionId = collision(type ActorBase);
        if (collisionId != 0)
            collisionId.components.health.value -= __bulletStats[bulletType].damage;
            break;
        end
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * Special FX
 * ---------------------------------------------------------------------------*/
process MuzzleFlash()
private
    lifeDuration = 5;
    animationTime = 0;
    forwardOffset = 44;
begin
    // initialization
    resolution = GPR;
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
        advance(forwardOffset * GPR);
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * User interface
 * ---------------------------------------------------------------------------*/
process MouseCursor()
begin
    // initialization
    resolution = GPR;
    file = __gfxMain;
    graph = 300;
    z = -1000;
    loop
        x = mouse.x * GPR;
        y = mouse.y * GPR;
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
    if (processId.input.move.walk == INPUT_WALK)
        processId.physics.targetMoveSpeed = processId.physics.walkSpeed;
    else
        processId.physics.targetMoveSpeed = processId.physics.runSpeed;
    end
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
 * Math functions
 * ---------------------------------------------------------------------------*/
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



/* -----------------------------------------------------------------------------
 * Debugging
 * ---------------------------------------------------------------------------*/
function LogValue(string label, val)
begin
    LogValueBase(father, label, val, false);
end

process LogValueFollow(string label, val)
private
    index;
begin
    index = GetNextLocalLogIndex(father);
    LogValueBase(father, label, val, true);
    loop
        x = father.x / GPR;
        y = (father.y / GPR) + (index * __logsYOffset);
        move_text(father.logs[index].txtLabel, x, y);
        move_text(father.logs[index].txtVal, x, y);
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
    txtLabel = write(
        __fntSystem,
        x,
        y,
        FONT_ANCHOR_TOP_RIGHT,
        label);
    txtVal = write_int(
        __fntSystem,
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






















