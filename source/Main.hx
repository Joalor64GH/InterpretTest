package;

class Main extends openfl.display.Sprite {
	public final config:Dynamic = {
		gameDimensions: [1280, 720], // Width + Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		framerate: 60, // How many frames per second the game should run at.
		initialState: state.PlayState, // is the state in which the game will start.
		skipSplash: false, // Whether to skip the flixel splash screen that appears in release mode.
		startFullscreen: false // Whether to start the game in fullscreen on desktop targets'
	};

	public function new() {
		super();

		addChild(new flixel.FlxGame(config.gameDimensions[0], config.gameDimensions[1], config.initialState, config.framerate, config.framerate,
			config.skipSplash, config.startFullscreen));
	}
}