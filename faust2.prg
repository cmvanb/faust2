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
    MAX_SOUNDS = 4;

    // file paths
    GFX_MAIN_PATH       = "assets/graphics/main.fpg";
    GFX_CHARACTERS_PATH = "assets/graphics/characters.fpg";
    FNT_MENU_PATH       = "assets/fonts/16x16-w-arcade.fnt";

    // graphics
    SCREEN_MODE        = m640x400;
    SCREEN_WIDTH       = 640;
    SCREEN_HEIGHT      = 400;
    HALF_SCREEN_WIDTH  = SCREEN_WIDTH / 2;
    HALF_SCREEN_HEIGHT = SCREEN_HEIGHT / 2;
    GAME_PROCESS_RESOLUTION = 10;

    // gameplay
    BULLET_PISTOL = 0;
    BULLET_RIFLE  = 1;
    CHAR_PLAYER    = 0;
    CHAR_GUARD_1   = 1;
    CHAR_GUARD_2   = 2;
    CHAR_GUARD_3   = 3;
    CHAR_OFFICER_1 = 4;
    CHAR_OFFICER_2 = 5;
    CHAR_OFFICER_3 = 6;
    FACTION_NEUTRAL = 0;
    FACTION_GOOD    = 1;
    FACTION_EVIL    = 2;

    // AI
    AI_STATE_NULL        = 0;
    AI_STATE_IDLE        = 1;
    AI_STATE_RESET       = 2;
    AI_STATE_PATROL      = 3;
    AI_STATE_GUARD       = 4;
    AI_STATE_INVESTIGATE = 5;
    AI_STATE_SHOOT       = 6;
    AI_STATE_CHASE       = 7;
    AI_STATE_HUNT        = 8;
    AI_STATE_RAISE_ALARM = 9;
    AI_STATE_FIND_COVER  = 10;
    AI_STATE_FLANK       = 11;
    AI_STATE_FLEE        = 12;
    AI_STATE_HIDE        = 13;
    AI_STATE_PEEK        = 14;
    MAX_CHARACTERS = 32;

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
    __gfxCharacters;
    __fntSystem;
    __fntMenu;
    __sounds[MAX_SOUNDS - 1];

    // gameplay
    struct __bulletData[1]
        damage;
        lifeDuration;
        speed;
        offsetForward;
        offsetLeft;
    end = 
        // pistol
        25, 40, 20 * GAME_PROCESS_RESOLUTION, 45 * GAME_PROCESS_RESOLUTION, 0 * GAME_PROCESS_RESOLUTION,
        // rifle
        65, 50, 30 * GAME_PROCESS_RESOLUTION, 45 * GAME_PROCESS_RESOLUTION, 0 * GAME_PROCESS_RESOLUTION;

    struct __characterData[6]
        maxMoveSpeed;
        maxTurnSpeed;
        gfxOffset;
        startingHealth;
        faction;
    end = 
        4 * GAME_PROCESS_RESOLUTION, 10000, 2, 200, FACTION_GOOD, // player
        3 * GAME_PROCESS_RESOLUTION, 10000, 1, 100, FACTION_EVIL, // guard level 1
        3 * GAME_PROCESS_RESOLUTION, 10000, 1, 150, FACTION_EVIL, // guard level 2
        3 * GAME_PROCESS_RESOLUTION, 10000, 1, 200, FACTION_EVIL, // guard level 3
        3 * GAME_PROCESS_RESOLUTION, 10000, 1, 100, FACTION_EVIL, // officer level 1
        3 * GAME_PROCESS_RESOLUTION, 10000, 1, 150, FACTION_EVIL, // officer level 2
        3 * GAME_PROCESS_RESOLUTION, 10000, 1, 200, FACTION_EVIL; // officer level 3

    // game processes
    __playerController;
    // TODO: Check if 2D arrays work in DIV, if yes turn this into one array of characters by faction.
    __neutralCharacters[MAX_CHARACTERS - 1];
    __goodCharacters[MAX_CHARACTERS - 1];
    __evilCharacters[MAX_CHARACTERS - 1];

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
    struct components
        animator;
        faction;
        health;
    end

    struct animation
        time; // 0-100
        string current;
    end

    struct input
        attackingPreviousFrame;
        attacking;
        struct move
            x;
            y;
        end
        struct lookAt
            x;
            y;
        end
    end

    struct physics
        maxMoveSpeed;
        struct velocity
            x;
            y;
        end
    end

    struct ai
        previousState;
        currentState;
        struct model
            knownOpponentCount;
            knownAllyCount;
            targetOpponentIndex;
            struct knownOpponents[MAX_CHARACTERS - 1]
                x;
                y;
                visible;
            end
            struct knownAllies[MAX_CHARACTERS - 1]
                x;
                y;
                visible;
            end
        end
    end

    // debugging
    value;
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
    __gfxCharacters = load_fpg(GFX_CHARACTERS_PATH);

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
    __playerController = PlayerController(40 * GAME_PROCESS_RESOLUTION, 40 * GAME_PROCESS_RESOLUTION);
    AIController(CHAR_GUARD_1, 320 * GAME_PROCESS_RESOLUTION, 200 * GAME_PROCESS_RESOLUTION);

    // game loop
    repeat
        // TODO: gameplay goes here
        frame;
    until (state == GAME_STATE_GAME_OVER)
end



/* -----------------------------------------------------------------------------
 * Player -> 320
 * ---------------------------------------------------------------------------*/
process PlayerController(x, y)
private
    mouseCursor;
begin
    // initialization
    resolution = GAME_PROCESS_RESOLUTION;
    components.health = HealthComponent(CHAR_PLAYER);
    components.animator = CharacterAnimator(CHAR_PLAYER);
    components.faction = CharacterFaction(CHAR_PLAYER);
    physics.maxMoveSpeed = __characterData[CHAR_PLAYER].maxMoveSpeed;
    mouseCursor = MouseCursor();

    // debugging
    LogValueFollow("health.value", &components.health.value);
    loop
        // capture input
        if (key(_a))
            input.move.x = -1;
        else
            if (key(_d))
                input.move.x = +1;
            else
                input.move.x = 0;
            end
        end
        if (key(_w))
            input.move.y = -1;
        else
            if (key(_s))
                input.move.y = +1;
            else
                input.move.y = 0;
            end
        end
        input.lookAt.x = mouseCursor.x;
        input.lookAt.y = mouseCursor.y;
        input.attackingPreviousFrame = input.attacking;
        input.attacking = mouse.left;

        // movement physics
        ApplyInputToVelocity(GAME_PROCESS_RESOLUTION);
        ApplyVelocity(id);

        // look at the mouse cursor
        TurnTowardsPosition(
            input.lookAt.x, 
            input.lookAt.y, 
            __characterData[CHAR_PLAYER].maxTurnSpeed);
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * AI Characters -> 380
 * ---------------------------------------------------------------------------*/
process AIController(charType, x, y)
private
    animator;
begin
    // initialization
    resolution = GAME_PROCESS_RESOLUTION;
    components.health = HealthComponent(charType);
    components.animator = CharacterAnimator(charType);
    components.faction = CharacterFaction(charType);
    ai.currentState = AI_STATE_NULL;
    physics.maxMoveSpeed = __characterData[charType].maxMoveSpeed;

    // debugging
    LogValueFollow("health.value", &components.health.value);
    LogValueFollow("ai.previousState", &ai.previousState);
    LogValueFollow("ai.currentState", &ai.currentState);
    LogValueFollow("ai.model.knownOpponentCount", &ai.model.knownOpponentCount);

    AIChangeState(id, AI_STATE_IDLE);
    loop
        AIHandleState(id);
        input.attackingPreviousFrame = input.attacking;
        if (key(_y))
            AIChangeState(id, AI_STATE_SHOOT);
        end
        if (key(_u))
            AIChangeState(id, AI_STATE_IDLE);
        end
        frame;
    end
end

function AIChangeState(controllerId, nextState)
begin
    controllerId.ai.previousState = controllerId.ai.currentState;
    switch (controllerId.ai.previousState)
        case AI_STATE_NULL:
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
        case AI_STATE_SHOOT:
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
        case AI_STATE_NULL:
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
        case AI_STATE_SHOOT:
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
begin
    switch (controllerId.ai.currentState)
        case AI_STATE_NULL:
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
        case AI_STATE_SHOOT:
            // TODO: Look at target.
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
 * AI management -> 530
 * ---------------------------------------------------------------------------*/
process AIVisionManager(faction)
private
    allOpponents[MAX_CHARACTERS - 1];
    aiCharacters[MAX_CHARACTERS - 1];
    knownOpponentIndex;
    knownOpponent;
    opponent;
    aiCharacter;
begin
    allOpponents = GetAllOpponents(faction);
    aiCharacters = GetFactionList(faction);
    loop
        // foreach AI
        for (x = 0; x < MAX_CHARACTERS; ++x)
            if (aiCharacters[x] <= 0)
                continue;
            end
            aiCharacter = aiCharacters[x];
            // foreach opponent
            for (y = 0; y < MAX_CHARACTERS; ++y)
                if (allOpponents[y] <= 0)
                    continue;
                end
                opponent = allOpponents[y];
                knownOpponentIndex = GetIndexOfValueInTable(
                    &aiCharacter.ai.model.knownOpponents,
                    MAX_CHARACTERS - 1,
                    opponent);
                // this AI character already knows this opponent, only update position
                if (knownOpponentIndex > -1)
                    //knownOpponent = aiCharacter.ai.model.knownOpponents[knownOpponentIndex];
                    knownOpponent = TableGetElement(
                        &aiCharacter.ai.model.knownOpponents,
                        knownOpponentIndex);
                else
                    // if AI can see opponent, update the AIs model
                    if (AILineOfSight(aiCharacter.x, aiCharacter.y, opponent.x, opponent.y))
                        knownOpponentIndex = FindFreeIndexInTable(
                            &aiCharacter.ai.model.knownOpponents,
                            MAX_CHARACTERS - 1);
                        //aiCharacter.ai.model.knownOpponents[knownOpponentIndex] = opponent;
                        TableSetElement(
                            &aiCharacter.ai.model.knownOpponents,
                            knownOpponentIndex,
                            opponent);
                        aiCharacter.ai.model.knownOpponentCount++;
                    end
                end
            end
        end
        frame;
    end
end

function AILineOfSight(x0, y0, x1, y2)
begin
    // TODO: Implement raycast. Consider using collision (hardness) map?
    return (true);
end

// TODO: move code to appropriate place
function TableGetElement(pointer table, index)
begin
    return (*table[index]);
end

function TableSetElement(pointer table, index, val)
begin
    *table[index] = val;
end

function FindFreeIndexInTable(pointer table, tableSize)
begin
    for (x = 0; x < tableSize; x++)
        if (*table[x] <= 0)
            return (x);
        end
    end
    return (-1);
end

function GetIndexOfValueInTable(pointer table, tableSize, val)
begin
    for (x = 0; x < tableSize; ++x)
        if (*table[x] == val)
            return (x);
        end
    end
    return (-1);
end



/* -----------------------------------------------------------------------------
 * Character components -> 560
 * ---------------------------------------------------------------------------*/
process CharacterFaction(charType)
private
    factionList[MAX_CHARACTERS - 1];
begin
    // initialization
    value = __characterData[charType].faction;
    factionList = GetFactionList(value);
    loop
        frame;
    end
end

process CharacterAnimator(charType)
private
    arms;
    base;
    head;
    weapon;
begin
    // initialization
    resolution = GAME_PROCESS_RESOLUTION;
    components.health = father.components.health;
    // sub-processes
    arms = CharacterArms(charType);
    base = CharacterBase(charType);
    head = CharacterHead(charType);
    weapon = CharacterWeapon(father);
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;
        frame;
    end
end

process CharacterArms(charType)
begin
    // initialization
    resolution = GAME_PROCESS_RESOLUTION;
    file = __gfxCharacters;
    graph = 200 + __characterData[charType].gfxOffset;
    z = -90;
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;
        frame;
    end
end

process CharacterBase(charType)
begin
    // initialization
    resolution = GAME_PROCESS_RESOLUTION;
    components.health = father.components.health;
    file = __gfxCharacters;
    graph = 100 + __characterData[charType].gfxOffset;
    z = -100;
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;
        frame;
    end
end

process CharacterHead(charType)
begin
    // initialization
    resolution = GAME_PROCESS_RESOLUTION;
    file = __gfxCharacters;
    graph = 401;
    z = -110;
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;
        frame;
    end
end

process CharacterWeapon(controllerId)
private
    lastShotTime = 0;
begin
    // initialization
    resolution = GAME_PROCESS_RESOLUTION;
    file = __gfxMain;
    graph = 800;
    z = -95;
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;

        if (controllerId.input.attacking && timer[0] > lastShotTime + 12)
            PlaySound(SOUND_MP40_SHOT, 128, 512);
            // NOTE: Disabled because DIV doesn't handle multiple sounds at the same time very well...
            //PlaySoundWithDelay(SOUND_SHELL_DROPPED_1 + rand(0, 2), 128, 256, 50);
            MuzzleFlash();
            Bullet(BULLET_PISTOL);
            lastShotTime = timer[0];
        end
        // Play a single 'shell drop' sound when stopped firing.
        if (controllerId.input.attacking == false && controllerId.input.attackingPreviousFrame == true)
            PlaySoundWithDelay(SOUND_SHELL_DROPPED_1 + rand(0, 2), 128, 256, 15);
        end
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * Components
 * ---------------------------------------------------------------------------*/
 process HealthComponent(charType)
 begin
    value = __characterData[charType].startingHealth;
    loop
        if (value <= 0)
            frame;
            break;
        end
        frame;
    end
    KillProcess(father);
 end

 function KillProcess(processId)
 begin
    y = processId.logCount;
    for (x = 0; x < y; ++x)
        DeleteLocalLog(processId);
    end
    signal(processId, s_kill_tree);
 end



/* -----------------------------------------------------------------------------
 * Projectiles
 * ---------------------------------------------------------------------------*/
process Bullet(bulletType)
private
    collisionId;
begin
    // initialization
    resolution = GAME_PROCESS_RESOLUTION;
    // graphics
    file = __gfxMain;
    graph = 600;
    z = -700;
    // positioning
    x = father.x;
    y = father.y;
    angle = father.angle;
    advance(__bulletData[bulletType].offsetForward); // TODO: implement offsetLeft
    // children
    LifeTimer(__bulletData[bulletType].lifeDuration);
    loop
        advance(__bulletData[bulletType].speed);
        collisionId = collision(type CharacterBase);
        if (collisionId != 0)
            collisionId.components.health.value -= __bulletData[bulletType].damage;
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
    resolution = GAME_PROCESS_RESOLUTION;
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
        x = father.x;
        y = father.y;
        advance(forwardOffset * GAME_PROCESS_RESOLUTION);
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * User interface
 * ---------------------------------------------------------------------------*/
process MouseCursor()
begin
    // initialization
    resolution = GAME_PROCESS_RESOLUTION;
    file = __gfxMain;
    graph = 300;
    z = -1000;
    loop
        x = mouse.x * GAME_PROCESS_RESOLUTION;
        y = mouse.y * GAME_PROCESS_RESOLUTION;
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * Factions
 * ---------------------------------------------------------------------------*/
function GetAllOpponents(faction)
begin
    // TODO: This code is fragile, improve it.
    switch (faction)
        case FACTION_GOOD:
            return (__evilCharacters);
        end
        case FACTION_EVIL:
            return (__goodCharacters);
        end
    end
end

function IsOpposingFaction(myFaction, otherFaction)
begin
    if (myFaction == FACTION_NEUTRAL || otherFaction == FACTION_NEUTRAL)
        return (false);
    end
    if (myFaction == otherFaction)
        return (false);
    end
    return (true);
end

function GetFactionList(faction)
begin
    switch (faction)
        case FACTION_NEUTRAL:
            return (__neutralCharacters);
        end
        case FACTION_GOOD:
            return (__goodCharacters);
        end
        case FACTION_EVIL:
            return (__evilCharacters);
        end
    end
end



/* -----------------------------------------------------------------------------
 * Utility functions
 * ---------------------------------------------------------------------------*/
function ApplyInputToVelocity(multiplier)
begin
    x = father.input.move.x * multiplier;
    y = father.input.move.y * multiplier;
    VectorNormalize(&x, &y, multiplier);
    // TODO: Don't hard set the velocity, instead add to it. Implement acceleration.
    father.physics.velocity.x = x * father.physics.maxMoveSpeed / multiplier;
    father.physics.velocity.y = y * father.physics.maxMoveSpeed / multiplier;
end

function ApplyVelocity(processId)
begin
    processId.x += processId.physics.velocity.x;
    processId.y += processId.physics.velocity.y;
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

function TurnTowards(target, turnSpeed)
begin
    father.angle = near_angle(father.angle, fget_angle(father.x, father.y, target.x, target.y), turnSpeed);
end

function TurnTowardsPosition(tX, tY, turnSpeed)
begin
    father.angle = near_angle(father.angle, fget_angle(father.x, father.y, tX, tY), turnSpeed);
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
        x = father.x / GAME_PROCESS_RESOLUTION;
        y = (father.y / GAME_PROCESS_RESOLUTION) + (index * __logsYOffset);
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
    return (-1);
end

function GetNextLocalLogIndex(processId)
begin
    for (x = 0; x < MAX_LOGS; x++)
        if (processId.logs[x].logId <= 0)
            return (x);
        end
    end
    return (-1);
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
    if (index == -1)
        index = GetNextFreeDelayIndex();
        __delays[index].processId = processId;
        __delays[index].startTime = timer[0];
        __delays[index].delayLength = delayLength;
        __delayCount++;
    end
    if (timer[0] > __delays[index].startTime + __delays[index].delayLength)
        __delayCount--;
        __delays[index].processId = -1;
        __delays[index].startTime = -1;
        __delays[index].delayLength = -1;
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
    return (-1);
end

function GetNextFreeDelayIndex()
begin
    for (x = 0; x < MAX_DELAYS; x++)
        if (__delays[x].processId <= 0)
            return (x);
        end
    end
    return (-1);
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






















