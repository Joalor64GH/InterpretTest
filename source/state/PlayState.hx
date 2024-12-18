package state;

import flixel.text.FlxText;
import flixel.FlxState;
import script.HScript;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends FlxState {
	public var scripts:Array<HScript> = [];

	public static var instance:PlayState = null;

	override public function create() {
		super.create();

		instance = this;		

		var text = new FlxText(0, 0, 0, "Hello World", 64);
		text.screenCenter();
		add(text);

		var folders:Array<String> = [Paths.file('scripts/'), Paths.file('data/')];
		for (folder in folders) {
			if (FileSystem.exists(folder) && FileSystem.isDirectory(folder)) {
				for (file in FileSystem.readDirectory(folder)) {
					if (Paths.validScriptType(file)) {
						var script:HScript = new HScript(); 
						script.loadModule(folder + file);
						scripts.push(script);
					}
				}
			}
		}

		callFunction('create');
	}

	override public function update(elapsed:Float) {
		callFunction('update', [elapsed]);
		super.update(elapsed);
	}

	public function callFunction(name:String, ?args:Array<Dynamic>):Dynamic {
        for (i in scripts) {
            for (j in i.getPackageFile().dynamicClasses) {
                var clazz = j.createInstance();
                if (clazz.exists(name)) {
                    var callback = i.callf(clazz, name, args);
                    if (callback != null)
                        return callback;
                }
            }
        }
        return null;
    }
}