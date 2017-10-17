/*
 * faust2.PRG by Casper
 * (c) 2017 altsrc
 */

COMPILER_OPTIONS _case_sensitive;

program Faust2;
const
    // settings
    screenWidth = 640;
    screenHeight = 400;
    halfScreenWidth = screenWidth / 2;
    halfScreenHeight = screenHeight / 2;

    // file paths
    gfxMainPath = "main.fpg";
    fntMenuPath = "16x16-w-arcade.fnt";
    fntGamePath = "game.fnt";

    // enums
    menuOption_NONE = 0;
    menuOption_PLAY = 1;
    gameState_NOT_STARTED = 0;
    gameState_ACTIVE      = 1;
    gameState_GAME_OVER   = 2;

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
    gfxMain = load_fpg(gfxMainPath);
    fntMenu = load_fnt(fntMenuPath);
    //fntGame = load_fnt(fntGamePath); // TODO: find font

    // show title screen
    TitleScreen();
end



function TitleScreen()
private
    selected = menuOption_NONE;
    txtTitle;

begin
    // initialization
    clear_screen();

    // background
    put_screen(gfxMain, 1);

    // instructions
    txtTitle = write(fntMenu, halfScreenWidth, halfScreenHeight, 4, "PRESS ANY KEY TO PLAY");

    // wait for input
    repeat
        if (scan_code != 0)
            selected = menuOption_PLAY;
        end

        frame;
    until (selected != menuOption_NONE)

    // clean up
    delete_text(txtTitle);

    // handle selection
    if (selected == menuOption_PLAY)
        GameManager();
    end
end



function GameManager()
private
    state = gameState_NOT_STARTED;

begin
    // initialization
    clear_screen();

    // graphics
    put_screen(gfxMain, 2);

    // gameplay
    state = gameState_ACTIVE;
    playerCharacter = PlayerCharacter(40, 40);

    repeat
        // TODO: gameplay goes here

        frame;
    until (state == gameState_GAME_OVER)
end



process PlayerCharacter(x, y)
begin
    // initialization
    graph = gfxMain + 3;
    loop
        frame;
    end
end
