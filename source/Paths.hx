package;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;
import openfl.utils.AssetType;

using StringTools;

class Paths {
	inline public static final SOUND_EXT = #if !html5 "ogg" #else "mp3" #end;
	inline public static final DEFAULT_FOLDER:String = 'assets';

	static public function getPath(folder:Null<String>, file:String) {
		if (folder == null)
			folder = DEFAULT_FOLDER;
		return folder + '/' + file;
	}

	static public function file(file:String, folder:String = DEFAULT_FOLDER) {
		if (#if sys FileSystem.exists(folder) && #end (folder != null && folder != DEFAULT_FOLDER))
			return getPath(folder, file);
		return getPath(null, file);
	}

	inline static public function txt(key:String)
		return file('$key.txt');

	inline static public function xml(key:String)
		return file('$key.xml');

	inline static public function json(key:String)
		return file('$key.json');

	inline static public function script(key:String)
		return file('$key.hx');

	inline static public function sound(key:String)
		return file('sounds/$key.$SOUND_EXT');

	inline static public function soundRandom(key:String, min:Int, max:Int)
		return file('sounds/$key${FlxG.random.int(min, max)}.$SOUND_EXT');

	inline static public function music(key:String)
		return file('music/$key.$SOUND_EXT');

	inline static public function image(key:String)
		return file('images/$key.png');

	inline static public function font(key:String)
		return file('fonts/$key');

	inline static public function getSparrowAtlas(key:String)
		return FlxAtlasFrames.fromSparrow(image(key), file('images/$key.xml'));

	inline static public function getPackerAtlas(key:String)
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), file('images/$key.txt'));

	static var externalAssetsTemp:Array<String> = [];
	static public function getExternalAssets(type:AssetType = FILE):Array<String>
	{
		var mainDirectory:String = '.';
		forEachDirectory(mainDirectory, type);
	    var assetPaths = externalAssetsTemp;
		externalAssetsTemp = [];
		return assetPaths;
	}
	
	static public function forEachDirectory(key:String = '', type:AssetType) {
		#if sys
		if (FileSystem.exists(key)) {
			for (file in FileSystem.readDirectory(key))
			{
				if (type == FILE) {
					if (!file.contains('.')) {
						file = pathFormat(key, file);
						forEachDirectory(file, type);
					}
					file = pathFormat(key, file);
					externalAssetsTemp.push(file);
				} else if (!file.contains('.') && type == FOLDER) {
     	   			file = pathFormat(key, file);
					forEachDirectory(file, type);
     	  	 		externalAssetsTemp.push(file);
				}
			}
		}
		#end
	}

	static public function pathFormat(path:String, key:String = '')
	{
		var cut:String = '';
    	if (!path.endsWith('/') && !key.startsWith('/'))
     		cut = '/';
     	return path + cut + key;
	}

	static public function findScripts():Array<String>
	{
		var containScripts:Array<String> = [];
		for (i in getExternalAssets(FILE))
		{
			var flag0:Bool = validScriptType(i);
			if ((i.contains('assets/') && validScriptType(i)) || flag0) {
				var scriptFrom:String = 'assets/';
				var finalP:String = finalP.replace('./', '');
				finalP = finalP.split('.')[0];
				containScripts.push(finalP);
			}
		}
		return containScripts;
	}

	static public function validScriptType(n:String):Bool {
		return n.endsWith('.hx') || n.endsWith('.hxs') || n.endsWith('.hxc') || n.endsWith('.hscript');
	}
}