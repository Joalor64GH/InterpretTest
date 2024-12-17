package state;

import flixel.text.FlxText;
import flixel.FlxState;

import script.HScript;
import script.ScriptHandler;

class PlayState extends FlxState {
	public var scriptHandler:ScriptHandler;

	public static var instance:PlayState = null;

	override public function create() {
		super.create();

		instance = this;		

		var text = new FlxText(0, 0, 0, "Hello World", 64);
		text.screenCenter();
		add(text);

		scriptHandler = new ScriptHandler(['scripts/', 'data/']);
		scriptHandler.callFunction('create');
	}

	override public function update(elapsed:Float) {
		scriptHandler.callFunction('update', [elapsed]);
		super.update(elapsed);
	}
}