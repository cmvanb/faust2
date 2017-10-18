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
    FONT_ALIGNMENT_CENTERED = 4;

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
    fntMenu;
    fntGame;

    // game processes
    playerCharacter;

begin
    // initialization
    set_mode(m640x400);
    set_fps(60, 4);

    // load resources
    gfxMain = load_fpg(GFX_MAIN_PATH);
    fntMenu = load_fnt(FNT_MENU_PATH);
    //fntGame = load_fnt(FNT_GAME_PATH); // TODO: find font

    // show title screen
    TitleScreen();
end



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
        FONT_ALIGNMENT_CENTERED, 
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
    playerCharacter = PlayerCharacter(40, 40);

    repeat
        // TODO: gameplay goes here

        frame;
    until (state == GAME_STATE_GAME_OVER)
end



process PlayerCharacter(x, y)
private
    walkSpeed = 4;
    velocityX;
    velocityY;
    mouseCursor;

begin
    // initialization
    graph = gfxMain + 100;
    mouseCursor = MouseCursor();

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

        // TODO: Normalize velocity vector.

        // apply velocity
        x += velocityX;
        y += velocityY;

        // look at the mouse cursor
        angle = get_angle(mouseCursor);
        frame;
    end
end



process MouseCursor()
begin
    // initialization
    graph = gfxMain + 300;
    loop
        x = mouse.x;
        y = mouse.y;
        frame;
    end
end
