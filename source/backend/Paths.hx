package backend;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif neko
import neko.vm.Gc;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import haxe.io.Path;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;

import openfl.Assets;
import openfl.media.Sound;

using StringTools;
using haxe.io.Path;

enum SpriteSheetType {
	ASEPRITE;
	PACKER;
	SPARROW;
	TEXTURE_PATCHER_JSON;
	TEXTURE_PATCHER_XML;
}

@:access(openfl.display.BitmapData)
class Paths {
	public static var SOUND_EXT:Array<String> = ['.ogg', '.wav', '.mp3', '.flac'];
	public static var HSCRIPT_EXT:Array<String> = ['.hx', '.hxs', '.hxc', '.hscript'];

	inline public static final DEFAULT_FOLDER:String = 'assets';

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static var localTrackedAssets:Array<String> = [];

	@:noCompletion private inline static function _gc(major:Bool) {
		#if (cpp || neko)
		Gc.run(major);
		#elseif hl
		Gc.major();
		#end
	}

	@:noCompletion public inline static function compress() {
		#if cpp
		Gc.compact();
		#elseif hl
		Gc.major();
		#elseif neko
		Gc.run(true);
		#end
	}

	public inline static function gc(major:Bool = false, repeat:Int = 1) {
		while (repeat-- > 0)
			_gc(major);
	}

	public static function clearUnusedMemory() {
		for (key in currentTrackedAssets.keys()) {
			if (!localTrackedAssets.contains(key)) {
				destroyGraphic(currentTrackedAssets.get(key));
				currentTrackedAssets.remove(key);
			}
		}

		compress();
		gc(true);
	}

	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory() {
		for (key in FlxG.bitmap._cache.keys()) {
			if (!currentTrackedAssets.exists(key))
				destroyGraphic(FlxG.bitmap.get(key));
		}

		for (key => asset in currentTrackedSounds) {
			if (!localTrackedAssets.contains(key) && asset != null) {
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}

		localTrackedAssets = [];
		gc(true);
		compress();
	}

	inline static function destroyGraphic(graphic:FlxGraphic) {
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

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

	inline static public function script(key:String) {
		var extension = '.hxs';
		
		for (ext in HSCRIPT_EXT)
			extension = (exists(file(key + ext))) ? ext : extension;
		
		return file(key + extension);
	}

	static public function sound(key:String, ?cache:Bool = true):Sound
		return returnSound('sounds/$key', cache);

	inline static public function music(key:String, ?cache:Bool = true):Sound
		return returnSound('music/$key', cache);

	inline static public function font(key:String) {
		var path:String = file('fonts/$key');

		if (path.extension() == '') {
			if (exists(path.withExtension("ttf")))
				path = path.withExtension("ttf");
			else if (exists(path.withExtension("otf")))
				path = path.withExtension("otf");
		}

		return path;
	}

	inline static public function image(key:String, ?cache:Bool = true):FlxGraphic
		return returnGraphic('images/$key', cache);

	public static inline function spritesheet(key:String, ?cache:Bool = true, ?type:SpriteSheetType):FlxAtlasFrames {
		if (type == null)
			type = SPARROW;

		return switch (type) {
			case ASEPRITE:
				FlxAtlasFrames.fromAseprite(image(key, cache), json('images/$key'));
			case PACKER:
				FlxAtlasFrames.fromSpriteSheetPacker(image(key, cache), txt('images/$key'));
			case SPARROW:
				FlxAtlasFrames.fromSparrow(image(key, cache), xml('images/$key'));
			case TEXTURE_PATCHER_JSON:
				FlxAtlasFrames.fromTexturePackerJson(image(key, cache), json('images/$key'));
			case TEXTURE_PATCHER_XML:
				FlxAtlasFrames.fromTexturePackerXml(image(key, cache), xml('images/$key'));
			default:
				FlxAtlasFrames.fromSparrow(image('errorSparrow', cache), xml('images/errorSparrow'));
		}
	}

	public static function returnGraphic(key:String, ?cache:Bool = true):FlxGraphic {
		var path:String = file('$key.png');
		if (Assets.exists(path, IMAGE)) {
			if (!currentTrackedAssets.exists(path)) {
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(path), false, path, cache);
				graphic.persist = true;
				currentTrackedAssets.set(path, graphic);
			}

			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}

		trace('oops! graphic $key returned null');
		return null;
	}

	public static function returnSound(key:String, ?cache:Bool = true, ?beepOnNull:Bool = true):Sound {
		for (i in SOUND_EXT) {
			if (Assets.exists(file(key + i), SOUND)) {
				var path:String = file(key + i);
				if (!currentTrackedSounds.exists(path))
					currentTrackedSounds.set(path, Assets.getSound(path, cache));

				localTrackedAssets.push(path);
				return currentTrackedSounds.get(path);
			} else if (beepOnNull) {
				trace('oops! sound $key returned null');
				return FlxAssets.getSound('flixel/sounds/beep');
			}
		}

		trace('oops! sound $key returned null');
		return null;
	}

	static public function validScriptType(n:String):Bool {
		return n.endsWith('.hx') || n.endsWith('.hxs') || n.endsWith('.hxc') || n.endsWith('.hscript');
	}
}