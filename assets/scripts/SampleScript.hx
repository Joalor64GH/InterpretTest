package runtime.scripts;

import flixel.FlxSprite;
import flixel.util.RealColor;
import state.PlayState;
import haxe.Log;

class SampleScript {
    public function create() {
        var sprite:FlxSprite = new FlxSprite(0, 0);
        sprite.makeGraphic(50, 50, RealColor.fromRGB(255, 255, 255));
        PlayState.instance.add(sprite);
    }

    public function update(elapsed:Float) {
        Log.trace('hi');
    }
}