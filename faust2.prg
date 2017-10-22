/*
 * faust2.PRG by Casper
 * (c) 2017 altsrc
 */

COMPILER_OPTIONS _case_sensitive;

program Faust2;
const
    // DIV command helpers
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

    // settings
    SCREEN_WIDTH = 640;
    SCREEN_HEIGHT = 400;
    HALF_SCREEN_WIDTH = SCREEN_WIDTH / 2;
    HALF_SCREEN_HEIGHT = SCREEN_HEIGHT / 2;

    // file paths
    GFX_MAIN_PATH = "main.fpg";
    FNT_MENU_PATH = "16x16-w-arcade.fnt";
    FNT_GAME_PATH = "game.fnt";

    // enums
    MENU_OPTION_NONE = 0;
    MENU_OPTION_PLAY = 1;
    GAME_STATE_NOT_STARTED = 0;
    GAME_STATE_ACTIVE      = 1;
    GAME_STATE_GAME_OVER   = 2;

global
    // resources
    gfxMain;
    fntSystem;
    fntMenu;
    fntGame;

    // game processes
    playerController;

    // debug vars
    __logCount;
    __logsX = 100;
    __logsY = 10;
    __logsYOffset = 15;

begin
    // initialization
    set_mode(m640x400);
    set_fps(60, 4);

    // load resources
    gfxMain = load_fpg(GFX_MAIN_PATH);
    fntSystem = 0;
    fntMenu = load_fnt(FNT_MENU_PATH);
    //fntGame = load_fnt(FNT_GAME_PATH); // TODO: find font

    // debugging
    ValueLogger("FPS", offset fps);

    // show title screen
    TitleScreen();
end



/*
 * Menu screens
 */

function TitleScreen()
private
    selected = MENU_OPTION_NONE;
    txtTitle;

begin
    // initialization
    clear_screen();
    put_screen(gfxMain, gfxMain + 1);
    txtTitle = write(
        fntMenu, 
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



/*
 * Gameplay
 */

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
        gfxMain, gfxMain + 200, 0, 
        REGION_FULL_SCREEN, 
        SCROLL_FOREGROUND_HORIZONTAL + SCROLL_FOREGROUND_VERTICAL);

    // gameplay
    state = GAME_STATE_ACTIVE;
    playerController = PlayerController(40, 40);

    // game loop
    repeat
        // TODO: gameplay goes here

        frame;
    until (state == GAME_STATE_GAME_OVER)
end



/*
 * Player
 */

process PlayerController(x, y)
private
    walkSpeed = 4;
    turnSpeed = 10000;

    velocityX;
    velocityY;

    mouseCursor;
    animator;

    targetAngle;
    angleDifference;

begin
    // initialization
    mouseCursor = MouseCursor();
    animator = CharacterAnimator();

    // debugging
    ValueLogger("angle", offset angle);
    ValueLogger("targetAngle", offset targetAngle);
    ValueLogger("angleDifference", offset angleDifference);

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

        // TODO: Refactor velocity out into separate process.
        // TODO: Normalize velocity vector.

        // apply velocity
        x += velocityX;
        y += velocityY;

        // look at the mouse cursor
        targetAngle = get_angle(mouseCursor);
        angleDifference = angle - targetAngle;

        if (angleDifference < 0)
            if (abs(angleDifference) > turnSpeed)
                angle += turnSpeed;
            else
                angle = targetAngle;
            end
        end

        if (angleDifference > 0)
            if (angleDifference > turnSpeed)
                angle -= turnSpeed;
            else
                angle = targetAngle;
            end
        end
        frame;
    end
end



/*
 * Character Animations
 */

process CharacterAnimator()
private
    arms;
    base;
    head;

begin
    // initialization
    arms = CharacterArms();
    base = CharacterBase();
    head = CharacterHead();

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
    graph = gfxMain + 902;
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
    graph = gfxMain + 900;
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
    graph = gfxMain + 901;
    z = -110;
    loop
        x = father.x;
        y = father.y;
        angle = father.angle;
        frame;
    end
end



/*
 * User interface
 */

process MouseCursor()
begin
    // initialization
    graph = gfxMain + 300;
    z = -1000;
    loop
        x = mouse.x;
        y = mouse.y;
        frame;
    end
end



/*
 * Math
 */

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


/*
 * Debugging
 */

process ValueLogger(string label, val)
private
    txtLogLabel;
    txtLogValue;
    logIndex;

begin
    logIndex = __logCount;
    __logCount++;

    x = __logsX;
    y = __logsY + (logIndex * __logsYOffset);

    label = label + ": ";

    txtLogLabel = write(
        fntSystem,
        x,
        y,
        FONT_ANCHOR_TOP_RIGHT,
        label);

    txtLogValue = write_int(
        fntSystem,
        x,
        y,
        FONT_ANCHOR_TOP_LEFT,
        val);

    loop
        frame;
    end
end



