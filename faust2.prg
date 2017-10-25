/* =============================================================================
 * faust2.PRG by Casper
 * (c) 2017 altsrc
 * ========================================================================== */

COMPILER_OPTIONS _case_sensitive;

program Faust2;
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

    // enums
    MENU_OPTION_NONE = 0;
    MENU_OPTION_PLAY = 1;
    GAME_STATE_NOT_STARTED = 0;
    GAME_STATE_ACTIVE      = 1;
    GAME_STATE_GAME_OVER   = 2;

    // resources
    SOUND_MP40_SHOT = 0;
    SOUND_SHELL_DROPPED_1 = 1;
    SOUND_SHELL_DROPPED_2 = 2;
    SOUND_SHELL_DROPPED_3 = 3;

    // gameplay
    BULLET_PISTOL = 0;
    BULLET_RIFLE = 1;

    // settings
    SCREEN_MODE = m640x400;
    SCREEN_WIDTH = 640;
    SCREEN_HEIGHT = 400;
    HALF_SCREEN_WIDTH = SCREEN_WIDTH / 2;
    HALF_SCREEN_HEIGHT = SCREEN_HEIGHT / 2;

    // file paths
    GFX_MAIN_PATH = "main.fpg";
    FNT_MENU_PATH = "16x16-w-arcade.fnt";
    FNT_GAME_PATH = "game.fnt";
global
    // resources
    __gfxMain;
    __fntSystem;
    __fntMenu;
    __fntGame;
    __sounds[31];

    // gameplay
    struct bulletData[1]
        damage;
        speed;
        lifeDuration;
        offsetForward;
        offsetLeft;
    end = 
        // pistol
        25, 20, 40, 45, 0,
        // rifle
        65, 30, 50, 50, 0;

    // timing
    __deltaTime;

    // game processes
    __playerController;

    // debug vars
    __logs[31];
    __logCount;
    __logsX = 320;
    __logsY = 10;
    __logsYOffset = 15;
begin
    // initialization
    set_mode(SCREEN_MODE);
    set_fps(60, 1);

    // load graphics
    __gfxMain = load_fpg(GFX_MAIN_PATH);

    // load fonts
    __fntSystem = 0;
    __fntMenu = load_fnt(FNT_MENU_PATH);
    //__fntGame = load_fnt(FNT_GAME_PATH); // TODO: find font

    // load sounds
    __sounds[SOUND_MP40_SHOT] = load_sound("assets/audio/test-shot5.wav", 0);
    __sounds[SOUND_SHELL_DROPPED_1] = load_sound("assets/audio/shell-dropped1.wav", 0);
    __sounds[SOUND_SHELL_DROPPED_2] = load_sound("assets/audio/shell-dropped2.wav", 0);
    __sounds[SOUND_SHELL_DROPPED_3] = load_sound("assets/audio/shell-dropped3.wav", 0);

    // timing
    LogValue("FPS", offset fps);
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
    put_screen(__gfxMain, __gfxMain + 1);
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
        __gfxMain, __gfxMain + 200, 0, 
        REGION_FULL_SCREEN, 
        SCROLL_FOREGROUND_HORIZONTAL + SCROLL_FOREGROUND_VERTICAL);

    // gameplay
    state = GAME_STATE_ACTIVE;
    __playerController = PlayerController(40, 40);

    // game loop
    repeat
        // TODO: gameplay goes here

        frame;
    until (state == GAME_STATE_GAME_OVER)
end



/* -----------------------------------------------------------------------------
 * Player
 * ---------------------------------------------------------------------------*/

process PlayerController(x, y)
private
    walkSpeed = 3;
    turnSpeed = 10000;

    velocityX;
    velocityY;

    mouseCursor;
    animator;
begin
    // initialization
    mouseCursor = MouseCursor();
    animator = CharacterAnimator();

    // debugging
    LogValue("player x", offset x);
    LogValue("player y", offset y);
    LogValue("player angle", offset angle);
    loop
        // movement input
        if (key(_a))
            velocityX = -walkSpeed;
        else
            if (key(_d))
                velocityX = +walkSpeed;
            else
                velocityX = 0;
            end
        end

        if (key(_w))
            velocityY = -walkSpeed;
        else
            if (key(_s))
                velocityY = +walkSpeed;
            else
                velocityY = 0;
            end
        end

        if (mouse.left && timer[0] > 12)
            PlaySound(SOUND_MP40_SHOT, 128, 512);
            // NOTE: Disabled because DIV doesn't handle multiple sounds at the same time very well...
            //PlaySoundWithDelay(SOUND_SHELL_DROPPED_1 + rand(0, 2), 128, 256, 25);

            MuzzleFlash();
            Bullet(BULLET_PISTOL);
            timer[0] = 0;
        end

        // TODO: Refactor velocity out into separate process.
        // TODO: Normalize velocity vector.

        // apply velocity
        x += velocityX;
        y += velocityY;

        // look at the mouse cursor
        TurnTowards(mouseCursor, turnSpeed);
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * Character Animations
 * ---------------------------------------------------------------------------*/

process CharacterAnimator()
private
    arms;
    base;
    head;
    weapon;
begin
    // initialization
    arms = CharacterArms();
    base = CharacterBase();
    head = CharacterHead();
    weapon = CharacterWeapon();
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;
        frame;
    end
end

process CharacterArms()
begin
    // initialization
    graph = __gfxMain + 902;
    z = -90;
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;
        frame;
    end
end

process CharacterBase()
begin
    // initialization
    graph = __gfxMain + 900;
    z = -100;
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;
        frame;
    end
end

process CharacterHead()
begin
    // initialization
    graph = __gfxMain + 901;
    z = -110;
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;
        frame;
    end
end

process CharacterWeapon()
begin
    // initialization
    graph = __gfxMain + 800;
    z = -95;
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * Entities
 * ---------------------------------------------------------------------------*/

process Bullet(bulletType)
begin
    x = father.x;
    y = father.y;
    angle = father.angle;
    graph = __gfxMain + 600;
    advance(bulletData[bulletType].offsetForward);
    // TODO: implement offsetLeft
    LifeTimer(bulletData[bulletType].lifeDuration);
    loop
        advance(bulletData[bulletType].speed);
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * User interface
 * ---------------------------------------------------------------------------*/

process MouseCursor()
begin
    // initialization
    graph = __gfxMain + 300;
    z = -1000;
    loop
        x = mouse.x;
        y = mouse.y;
        frame;
    end
end



/* -----------------------------------------------------------------------------
 * Utility functions
 * ---------------------------------------------------------------------------*/

function TurnTowards(target, turnSpeed)
private
    currentAngle;
    targetAngle;
    angleDifference;
    angleChange;
begin
    currentAngle = WrapAngle180(father.angle);
    targetAngle = WrapAngle180(fget_angle(father.x, father.y, target.x, target.y));
    father.angle = near_angle(currentAngle, targetAngle, turnSpeed);
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

process LogValue(string label, val)
private
    txtLogLabel;
    txtLogValue;
    logIndex;
begin
    logIndex = __logCount;
    __logs[__logCount] = id;
    __logCount++;

    x = __logsX;
    y = __logsY + (logIndex * __logsYOffset);

    label = label + ": ";

    txtLogLabel = write(
        __fntSystem,
        x,
        y,
        FONT_ANCHOR_TOP_RIGHT,
        label);

    txtLogValue = write_int(
        __fntSystem,
        x,
        y,
        FONT_ANCHOR_TOP_LEFT,
        val);
    loop
        frame;
    end
end

process DeleteLastLog()
begin
    signal(__logs[__logCount - 1], s_kill);
    __logCount--;
end



/* -----------------------------------------------------------------------------
 * Timing
 * ---------------------------------------------------------------------------*/

process DeltaTimer()
private
    t0;
    t1;
begin
    LogValue("__deltaTime", offset __deltaTime);
    loop
        t0 = timer[9];
        frame;
        t1 = timer[9];
        __deltaTime = Max(t1 - t0, 1); // deltaTime can never be 0
    end
end

process LifeTimer(lifeDuration)
private
    lifeStartTime;
begin
    lifeStartTime = timer[9];
    repeat
        frame;
    until (timer[9] > lifeStartTime + lifeDuration)
    signal(father, s_kill);
end



/* -----------------------------------------------------------------------------
 * Audio
 * ---------------------------------------------------------------------------*/

process PlaySound(soundIndex, volume, frequency)
begin
    sound(__sounds[soundIndex], volume, frequency);
end

process PlaySoundWithDelay(soundIndex, volume, frequency, delay)
private
    lifeStartTime;
begin
    lifeStartTime = timer[9];
    repeat
        frame;
    until (timer[9] > lifeStartTime + delay)

    /*
    Delay(id, delay);
    while (IsDelayed(id))
        frame
    end
    */

    PlaySound(soundIndex, volume, frequency);
end


/*
__delayCount = 0;
struct __delays[31]
    processId;
end

process Delay(id, delay)
private
    lifeStartTime;
begin
    lifeStartTime = timer[9];
    __delays[__delayCount].processId = id;
    __delayCount++;
    repeat
        frame;
    until (timer[9] > lifeStartTime + delay)
    __delayCount--;
end

function IsDelayed(id)
begin
    for (x = 0; x < __delayCount; x++)
        if (__delays[x].processId == id)
            return (true);
        end
    end
    return (false);
end
*/



/* -----------------------------------------------------------------------------
 * Special FX
 * ---------------------------------------------------------------------------*/

process MuzzleFlash()
private
    lifeDuration = 5;
    animationTime = 0;
begin
    // initialization
    graph = __gfxMain + 700;
    z = -700;
    angle = father.angle;

    // behaviors
    LifeTimer(lifeDuration);
    loop
        // animation
        animationTime += 1000 / (lifeDuration / __deltaTime);
        size = (sin(animationTime * 180) + 1000) / 40;

        // positioning
        x = father.x;
        y = father.y;
        advance(44);
        frame;
    end
end






















