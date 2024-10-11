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
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import funkin.data.song.SongData.SongMusicData;
import flixel.tweens.FlxEase;
import funkin.graphics.FunkinCamera;
import funkin.audio.FunkinSound;
import flixel.tweens.FlxTween;
import funkin.ui.MusicBeatState;
import flixel.util.FlxTimer;
import funkin.ui.AtlasMenuList;
import funkin.ui.freeplay.FreeplayState;
import funkin.ui.MenuList;
import funkin.ui.title.TitleState;
import funkin.ui.story.StoryMenuState;
import funkin.ui.Prompt;
import funkin.util.WindowUtil;
import funkin.mobile.util.TouchUtil;
#if FEATURE_DISCORD_RPC
import funkin.api.discord.DiscordClient;
#end
#if newgrounds
import funkin.ui.NgPrompt;
import io.newgrounds.NG;
#end

class MainMenuState extends MusicBeatState
{
  var menuItems:FlxTypedGroup<FlxSprite>;

  var magenta:FlxSprite;
  var camFollow:FlxObject;

  var overrideMusic:Bool = false;

  static var rememberedSelectedIndex:Int = 0;

  public function new(?_overrideMusic:Bool = false)
  {
    super();
    overrideMusic = _overrideMusic;
  }

  override function create():Void
  {
    #if FEATURE_DISCORD_RPC
    DiscordClient.instance.setPresence({state: "In the Menus", details: null});
    #end

    FlxG.cameras.reset(new FunkinCamera('mainMenu'));

    transIn = FlxTransitionableState.defaultTransIn;
    transOut = FlxTransitionableState.defaultTransOut;

    if (!overrideMusic) playMenuMusic();

    // We want the state to always be able to begin with being able to accept inputs and show the anims of the menu items.
    persistentUpdate = true;
    persistentDraw = true;

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

    // TODO: Why doesn't this line compile I'm going fucking feral

    if (Preferences.flashingLights) add(magenta);

    // Initialize menuItems
    menuItems = new FlxTypedGroup<FlxSprite>();
    add(menuItems);

    // Button creation logic
    var optionShit:Array<String> = ['storymode', 'freeplay', 'options', 'credits']; // Example, replace with actual options
    for (i in 0...optionShit.length) {
        var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
        var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
        menuItem.antialiasing = ClientPrefs.data.antialiasing;
        menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
        menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
        menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
        menuItem.animation.play('idle');
        menuItems.add(menuItem);
        var scr:Float = (optionShit.length - 4) * 0.135;
        if (optionShit.length < 6)
            scr = 0;
        menuItem.scrollFactor.set(0, scr);
        menuItem.updateHitbox();
        menuItem.screenCenter(X);
    }

    resetCamStuff();

    // Other existing code...
  }

  function playMenuMusic():Void
  {
    FunkinSound.playMusic('freakyMenu',
      {
        overrideExisting: true,
        restartTrack: false
      });
  }

  function resetCamStuff(?snap:Bool = true):Void
  {
    FlxG.camera.follow(camFollow, null, 0.06);

    if (snap) FlxG.camera.snapToTarget();
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    Conductor.instance.update();

    if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
    {
      FlxG.sound.music.volume += 0.5 * elapsed;
    }

    if (_exiting) menuItems.enabled = false;

    if (controls.BACK)
    {
      goBack();
    }
  }

  public function goBack():Void
  {
    if (menuItems.enabled && !menuItems.busy)
    {
      FlxG.switchState(() -> new TitleState());
      FunkinSound.playOnce(Paths.sound('cancelMenu'));
    }
  }
}
