package hext;

import hext.Main.Size;
import openfl._v2.system.PixelFormat;
import openfl.Lib;
import openfl.Assets;

import openfl.utils.Timer;
import openfl.events.TimerEvent;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;

import openfl.geom.Point;
import openfl.geom.Rectangle;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

import motion.Actuate;
import motion.easing.Quad;
import motion.easing.Linear;

/**
 * ...
 * @author MaKu
 */

// rendering text boxes, gui, clipping rendering to parent (aka moving with camera)

class Game
{
	
	public function new()
	{
		_scene = new SceneSprite( { w: 1024, h: 768 } );
		_scene.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.addChild(_scene);
		
		SfxEngine.play("snd/applause.wav", true);
		
		var sprite = new AnimatedSprite("img/xowl.jpg", { w: 25, h: 25 } );
		sprite.scaleX = sprite.scaleY = 5;
		sprite.start(100);
		sprite.x = 10;
		sprite.y = 10;
		// sprite.rotation = 33;
		
		sprite.addEventListener(MouseEvent.CLICK, onClick);
		_scene.addChild(sprite);
		
		/*
		_scene._callback = function()
		{
			Lib.current.removeChildren();
			Lib.current.addChild(_scene);
			Lib.current.addChild(_scene._clipRect[0]);
			Lib.current.addChild(_scene._clipRect[1]);
		}
		*/
		
		/*
		Actuate.update(ovce, 2.0, [ 0 ], [ 10 ]).ease(Linear.easeNone) .onComplete(
				function() { Actuate.update(ovce, 2.0, [ 10 ], [ 0 ]).ease(Linear.easeNone); }
			);
		
		Actuate.tween(sprite, 10.0, { x: 500 } ).repeat().reflect().ease(Quad.easeInOut);
		*/
		
		/*
		var tf: TextField = new TextField();
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.setTextFormat(new TextFormat("Arial"));
		// tf.lin
		tf.wordWrap = true;
		tf.x = 0;
		tf.y = 0;
		tf.text = "Nazdar Lamo Lolafaefeolol lamfaeif aef oaeijf aoief aoief aeoif eaoifj aeoijf eoia jf!";
		
		_scene.addChild(tf);
		*/
	}
	
	public function ovce(o: Int)
	{
		trace(o);
	}
	
	public function run(delta: Float, keysDown: Map<Int, Bool>)
	{
		
	}
	
	public function onMouseMove(event: MouseEvent)
	{
		
		// trace(event.localX);
	}
	
	private function onClick(event: MouseEvent)
	{
		
		SfxEngine.stop();
		// trace("sprite clicked");
	}
	
	private var _scene: SceneSprite;
	private var _gui: Sprite; // unaffected by camera
	private var _world: Sprite;
	private var _camera: Point;
	private var _offscreen: Bitmap;
	
	private var _music: Sfx;
	
}

typedef Size =
{
	w : Int,
	h : Int
}

class SceneSprite extends Sprite
{
	
	public function new(size: Size)
	{
		super();
		_size = size;
		addChild(new Bitmap(new BitmapData(_size.w, _size.h)));
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	public function size() : Size
	{
		return _size;
	}
	
	private function onAddedToStage(event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		stage.addEventListener(Event.RESIZE, onResize);
	}
	
	private function onResize(event)
	{
		var sceneRatio = _size.w / _size.h;
		var stageRatio = stage.stageWidth / stage.stageHeight;
		
		if (stageRatio > sceneRatio)
		{
			scaleX = scaleY = stage.stageHeight / _size.h;
			x = (stage.stageWidth - width) / 2;
			y = 0;
		}
		else
		{
			scaleX = scaleY = stage.stageWidth / _size.w;
			y = (stage.stageHeight - height) / 2;
			x = 0;
		}
		
		/*
		if (x != 0)
		{			
			_clipRect = [];
			_clipRect[0] = new Bitmap(new BitmapData(Math.round((stage.stageWidth - width) / 2), stage.stageHeight, false, 0xFFFF));		
			_clipRect[1] = new Bitmap(new BitmapData(Math.round((stage.stageWidth - width) / 2), stage.stageHeight, false, 0xFF00));
			_clipRect[1].x = width + x - 10;
		}
		else
		{	
			_clipRect = [];
			_clipRect[0] = new Bitmap(new BitmapData(stage.stageWidth, Math.round((stage.stageHeight - height) / 2), false, 0xFF0000));
			_clipRect[1] = new Bitmap(new BitmapData(stage.stageWidth, Math.round((stage.stageHeight - height) / 2), false, 0xFFFF00));
			_clipRect[1].y = height + y - 1;
		}
		
		_callback();
		*/
	}
	
	private var _size: Size;
	
	/*
	public var _callback: Void -> Void;
	public var _clipRect: Array<Bitmap>;
	*/
}

class AnimatedSprite extends Sprite
{
	
	public function new(pathName: String, ?frameSize: Size)
	{
		super();
		
		_bitmaps = [];
		
		var bitmapData = Assets.getBitmapData(pathName);
		
		if (frameSize == null)
		{
			_frameSize = { w: bitmapData.width, h: bitmapData.height };
			_bitmaps[0] = new Bitmap(bitmapData);
			_rows = _cols = 1;
		}
		else
		{
			_frameSize = frameSize;
			_cols = Math.floor(bitmapData.width / _frameSize.w);
			_rows = Math.floor(bitmapData.height / _frameSize.h);
			
			for (j in 0 ... _rows)
			{
				for (i in 0 ... _cols)
				{
					var frameBitmapData = new BitmapData(_frameSize.w, _frameSize.h);
					frameBitmapData.copyPixels(bitmapData,
						new Rectangle(i * _frameSize.w, j * _frameSize.h, _frameSize.w, _frameSize.h), new Point(0, 0));
					var frameBitmap = new Bitmap(frameBitmapData);
					_bitmaps[j * _rows + i] = frameBitmap;
				}
			}
		}
		
		setFrame(0);
	}
	
	public function frames() : Int
	{
		return _cols * _rows;
	}
	
	public function frame() : Int
	{
		return _index;
	}
	
	public function setFrame(index: Int)
	{
		_index = index;
		removeChildren();
		addChild(_bitmaps[_index]);
	}
	
	public function advanceFrame()
	{
		if (++_index == frames())
		{
			_index = 0;
		}
		setFrame(_index);
	}
	
	public function start(step: Float)
	{
		if (_timer == null)
		{
			_timer = new Timer(step);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		if (_timer.running)
		{
			_timer.stop();
		}
		
		_timer.delay = step;
		_timer.start();
	}
	
	public function stop()
	{
		if (_timer != null && _timer.running)
		{
			_timer.stop();
		}
	}
	
	public function isRunning() : Bool
	{
		return _timer != null && _timer.running;
	}
	
	private function onTimer(event: TimerEvent)
	{
		advanceFrame();
	}
	
	private var _index: Int;
	private var _bitmaps: Array<Bitmap>; 
	private var _frameSize: Size;
	private var _rows: Int;
	private var _cols: Int;
	private var _timer: Timer;
	
}

class Sfx
{
	
	public function new(channel: SoundChannel, volume: Float, panning: Float)
	{
		this.channel = channel;
		this.volume = volume;
		this.panning = panning;
	}
	
	public var channel: SoundChannel;
	public var panning: Float;
	public var volume: Float;
	
}

class SfxEngine
{
	
	public static function master() : Float
	{
		return _master;
	}
	
	public static function setMaster(master: Float)
	{
		_master = Math.max(0.0, Math.min(1.0, master));
		
		for (i in _sfxs)
		{
			i.channel.soundTransform = new SoundTransform(_master * i.volume, i.panning);
		}
	}
	
	public static function play(pathName: String, loop: Bool = false, volume: Float = 1.0, panning: Float = 0.0)
	{
		volume = Math.max(0.0, Math.min(1.0, volume));
		panning = Math.max(-1.0, Math.min(1.0, panning));
		
		var channel = Assets.getSound(pathName).play(0, loop ? 1000 : 0, new SoundTransform(_master * volume, panning));
		channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		
		var sfx = new Sfx(channel, volume, panning);
		_sfxs.add(sfx);
	}
	
	public static function stop()
	{
		for (i in _sfxs)
		{
			i.channel.stop();
		}
		_sfxs.clear();
	}
	
	private static function onSoundComplete(event : Event)
	{
		var channel = event.target;
		
		for (i in _sfxs)
		{
			if (i.channel == channel)
			{	
				_sfxs.remove(i);
				return;
			}
		}
	}
	
	private static var _sfxs: List<Sfx> = new List<Sfx>();
	private static var _master: Float = 1.0;
	
}

class Core
{
	
	public function new()
	{
		_keysDown = new Map<Int, Bool>();
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		_timer = new Timer(33);
		_timer.addEventListener(TimerEvent.TIMER, onTimer);
		_timer.start();
	}
	
	private function run(delta: Float)
	{
		Main.game.run(delta, _keysDown);
	}
	
	private function onTimer(event: TimerEvent)
	{
		var stamp = haxe.Timer.stamp();
		
		if (Math.isNaN(_stamp))
		{
			_stamp = stamp;
			return;
		}
		
		var delta = stamp - _stamp;
		_stamp = stamp;
		run(delta);
	}
	
	private function onKeyUp(event: KeyboardEvent)
	{
		_keysDown.remove(event.keyCode);
	}
	
	private function onKeyDown(event: KeyboardEvent)
	{
		_keysDown[event.keyCode] = true;
	}
	
	private var _stamp: Float;
	private var _delta: Float;
	private var _timer: Timer;
	
	private var _keysDown: Map<Int, Bool>;
	
}

class Main
{
	
	public static function main() 
	{
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		core = new Core();
		game = new Game();
	}
	
	public static var core: Core;
	public static var game: Game;
	
}
