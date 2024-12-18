package script;

import flixel.text.FlxText;
import flixel.FlxState;
import script.HScript;
import flixel.FlxG;

// untested
class ScriptState extends FlxState {
	public var script:HScript = null;
	public static var instance:ScriptState = null;

    public function new(path:String, ?args:Array<Dynamic>) {
        instance = this;

        try {
            script = new HScript();
            script.loadModule(Paths.script('states/$path'));
        } catch(e:Dynamic) {
            script = null;
            trace(e);
        }

        callFunction('new', args);

        super();
    }

	override public function create() {
        callFunction('create');
		super.create();
	}

	override public function update(elapsed:Float) {
		callFunction('update', [elapsed]);
		super.update(elapsed);
	}

	public function callFunction(name:String, ?args:Array<Dynamic>):Dynamic {
        for (j in script.getPackageFile().dynamicClasses) {
            var clazz = j.createInstance();
            if (clazz.exists(name)) {
                var callback = script.callf(clazz, name, args);
                if (callback != null)
                    return callback;
            }
        }
        return null;
    }
}