package script;

import interpret.Env;
import interpret.DynamicModule;
import interpret.DynamicInstance;
import haxe.macro.Expr;
import openfl.Lib;

using StringTools;

#if lime
import lime.app.Application as LimeApplication;
import lime.ui.WindowAttributes;
#end

class HScript
{
	public var env:Env = new Env();
	public var packag3:String;

	public function new(?path:String)
	{
		env.addDefaultModules();
		env.addModule('StringTools', DynamicModule.fromStatic(StringTools));
		env.addModule('flixel.FlxCamera', DynamicModule.fromStatic(flixel.FlxCamera));
		env.addModule('flixel.FlxG', DynamicModule.fromStatic(flixel.FlxG));
		env.addModule('flixel.FlxBasic', DynamicModule.fromStatic(flixel.FlxBasic));
		env.addModule('flixel.FlxSprite', DynamicModule.fromStatic(flixel.FlxSprite));
		env.addModule('flixel.graphics.FlxGraphic', DynamicModule.fromStatic(flixel.graphics.FlxGraphic));
		env.addModule('flixel.graphics.tile.FlxGraphicsShader', DynamicModule.fromStatic(flixel.graphics.tile.FlxGraphicsShader));
		env.addModule('flixel.graphics.frames.FlxAtlasFrames', DynamicModule.fromStatic(flixel.graphics.frames.FlxAtlasFrames));
		env.addModule('flixel.group.FlxGroup', DynamicModule.fromStatic(flixel.group.FlxGroup));
		env.addModule('flixel.math.FlxMath', DynamicModule.fromStatic(flixel.math.FlxMath));
		env.addModule('flixel.math.FlxRect', DynamicModule.fromStatic(flixel.math.FlxRect));
		env.addModule('flixel.tweens.FlxEase', DynamicModule.fromStatic(flixel.tweens.FlxEase));
		env.addModule('flixel.tweens.FlxTween', DynamicModule.fromStatic(flixel.tweens.FlxTween));
		env.addModule('flixel.util.FlxColor', DynamicModule.fromStatic(flixel.util.RealColor));
		env.addModule('flixel.util.FlxTimer', DynamicModule.fromStatic(flixel.util.FlxTimer));
		env.addModule('haxe.Exception', DynamicModule.fromStatic(flixel.FlxCamera));
		env.addModule('haxe.Log', DynamicModule.fromStatic(haxe.Log));
		env.addModule('haxe.ds.StringMap', DynamicModule.fromStatic(haxe.ds.StringMap));
		env.addModule('lime.app.Application', DynamicModule.fromStatic(lime.app.Application));
		env.addModule('lime.graphics.Image', DynamicModule.fromStatic(lime.graphics.Image));
		env.addModule('lime.graphics.RenderContext', DynamicModule.fromStatic(lime.graphics.RenderContext));
		env.addModule('lime.ui.KeyCode', DynamicModule.fromStatic(lime.ui.KeyCode));
		env.addModule('lime.ui.MouseButton', DynamicModule.fromStatic(lime.ui.MouseButton));
		env.addModule('lime.ui.Window', DynamicModule.fromStatic(lime.ui.Window));
		env.addModule('openfl.display.Sprite', DynamicModule.fromStatic(openfl.display.Sprite));
		env.addModule('openfl.display.GraphicsShader', DynamicModule.fromStatic(openfl.display.GraphicsShader));
		env.addModule('openfl.display.Shader', DynamicModule.fromStatic(openfl.display.Shader));
		env.addModule('openfl.filters.ShaderFilter', DynamicModule.fromStatic(openfl.filters.ShaderFilter));
		env.addModule('openfl.geom.Matrix', DynamicModule.fromStatic(openfl.geom.Matrix));
		env.addModule('openfl.geom.Rectangle', DynamicModule.fromStatic(openfl.geom.Rectangle));
		env.addModule('openfl.utils.Assets', DynamicModule.fromStatic(openfl.utils.Assets));
		env.addModule('openfl.Lib', DynamicModule.fromStatic(openfl.Lib));
		env.addModule('sys.FileSystem', DynamicModule.fromStatic(sys.FileSystem));
		env.addModule('sys.io.File', DynamicModule.fromStatic(sys.io.File));
		env.addModule('Paths', DynamicModule.fromStatic(Paths));
		env.addModule('Main', DynamicModule.fromStatic(Main));
		env.addModule('state.PlayState', DynamicModule.fromStatic(state.PlayState));
		env.addModule('script.HScript', DynamicModule.fromStatic(script.HScript));

		if (path != null)
			loadModule(path);
	}

	public function loadModule(path:String)
	{
		var pArr = path.split('/'); /** WITHOUT POSTFIX IS IMPORTANT! **/
		var expr:DynamicModule = DynamicModule.fromString(env, pArr[pArr.length - 1], sys.io.File.getContent(Paths.script(path)));
		packag3 = expr.pack;
		env.addModule(packag3, expr);
		env.link();
	}

	public function getPackageFile()
		return env.modules.get(packag3);

	public function hasClass(name:String)
		return getPackageFile().dynamicClasses.exists(name);

	public function getClass(name:String)
	{
		if (hasClass(name))
		{
			return getPackageFile().dynamicClasses.get(name).createInstance();
		}
		else
		{
			Lib.application.window.alert("Module Name: " + name + " not exists.", "HScript Runtime Error");
		}
		return null;
	}

	/** Receive return val **/
	public function callf(classInstance:DynamicInstance, name:String, ?args:Array<Dynamic>)
	{
		try
		{
			return classInstance.call(name, args);
		}
		catch (e)
		{
			Lib.application.window.alert('An error occurred while trying to execute the method: \n' + e, "HScript Runtime Error");
		}
		return null;
	}

	/** Get a value, not callback **/
	public function get(classInstance:DynamicInstance, name:String, ?unwrap:Bool = true)
		return classInstance.get(name);

	/** Set a value **/
	public function set(classInstance:DynamicInstance, name:String, value:Dynamic, ?unwrap:Bool = true)
		return classInstance.set(name, value);

	/** Check methods or fields exists **/
	public function exists(classInstance:DynamicInstance, name:String)
		return classInstance.exists(name);

	/** Check if the field is a method **/
	public function isMethod(classInstance:DynamicInstance, name:String)
		return classInstance.isMethod(name);
}