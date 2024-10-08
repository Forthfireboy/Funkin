package funkin.ui.mainmenu;

import funkin.graphics.FunkinSprite;
import flixel.addons.transition.FlxTransitionableState;
import funkin.ui.debug.DebugMenuSubState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.typeLimit.NextState;
import flixel.util.FlxColor;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import funkin.data.song.SongData.SongMusicData;
import flixel.tweens.FlxEase;
import funkin.graphics.FunkinCamera;
import funkin.audio.FunkinSound;
import flixel.tweens.FlxTween;
import funkin.ui.MusicBeatState;
import flixel.util.FlxTimer;
import funkin.ui.freeplay.FreeplayState;
import funkin.ui.MenuList;
import funkin.ui.title.TitleState;
import funkin.ui.story.StoryMenuState;
import funkin.ui.Prompt;
import funkin.util.WindowUtil;
#if FEATURE_DISCORD_RPC
import funkin.api.discord.DiscordClient;
#end
#if newgrounds
import funkin.ui.NgPrompt;
import io.newgrounds.NG;
#end

class MainMenuState extends MusicBeatState {
    public static var curSelected:Int = 0;

    var menuItems:FlxTypedGroup<FlxSprite>;
    var magenta:FlxSprite;
    var camFollow:FlxObject;

    var optionShit:Array<String> = [
        'storymode',
        'freeplay',
        'options',
        'credits'
    ];

    public function new(?_overrideMusic:Bool = false) {
        super();
    }

    override function create():Void {
        #if FEATURE_DISCORD_RPC
        DiscordClient.instance.setPresence({state: "In the Menus", details: null});
        #end

        FlxG.cameras.reset(new FunkinCamera('mainMenu'));

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        playMenuMusic();

        var bg:FlxSprite = new FlxSprite(Paths.image('menuBG'));
        bg.scrollFactor.x = 0;
        bg.scrollFactor.y = 0.17;
        bg.setGraphicSize(Std.int(bg.width * 1.2));
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);

        camFollow = new FlxObject(0, 0, 1, 1);
        add(camFollow);

        magenta = new FlxSprite(Paths.image('menuBGMagenta'));
        magenta.scrollFactor.x = bg.scrollFactor.x;
        magenta.scrollFactor.y = bg.scrollFactor.y;
        magenta.setGraphicSize(Std.int(bg.width));
        magenta.updateHitbox();
        magenta.x = bg.x;
        magenta.y = bg.y;
        magenta.visible = false;

        if (Preferences.flashingLights) add(magenta);

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        // Create menu items
        for (i in 0...optionShit.length) {
            var offset:Float = 160 - (Math.max(optionShit.length, 4) - 4) * 80;
            var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
            menuItem.frames = Paths.getSparrowAtlas('mainmenu/' + optionShit[i]);
            menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
            menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
            menuItem.animation.play('idle');
            menuItems.add(menuItem);
            menuItem.scrollFactor.set(0, 0.4);
            menuItem.updateHitbox();
            menuItem.screenCenter(X);
        }

        var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Your Game Version", 12);
        psychVer.scrollFactor.set();
        psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(psychVer);

        changeItem(); // Set initial selected item

        super.create();
    }

    override function update(elapsed:Float):Void {
        if (FlxG.sound.music.volume < 0.8) {
            FlxG.sound.music.volume += 0.5 * elapsed;
        }

        if (controls.UI_UP_P) changeItem(-1);
        if (controls.UI_DOWN_P) changeItem(1);
        if (controls.ACCEPT_P) selectItem();

        super.update(elapsed);
    }

    function playMenuMusic():Void {
        FunkinSound.playMusic('freakyMenu', {
            overrideExisting: true,
            restartTrack: false
        });
    }

    function changeItem(dir:Int = 0):Void {
        menuItems.members[curSelected].animation.play('idle');
        curSelected += dir;

        if (curSelected < 0) curSelected = menuItems.length - 1;
        if (curSelected >= menuItems.length) curSelected = 0;

        menuItems.members[curSelected].animation.play('selected');
        camFollow.setPosition(menuItems.members[curSelected].x, menuItems.members[curSelected].y);
    }

    function selectItem():Void {
        switch (curSelected) {
            case 0:
                FlxG.switchState(() -> new StoryMenuState());
            case 1:
                openSubState(new FreeplayState());
            case 2:
                FlxG.switchState(() -> new funkin.ui.options.OptionsState());
            case 3:
                FlxG.switchState(() -> new funkin.ui.credits.CreditsState());
        }
    }

    public function goBack():Void {
        FlxG.switchState(() -> new TitleState());
    }
}
