package hext;

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

class Avatar
{
	
	public function new(position: Position)
	{
		if (Math.random() < 0.5)
		{
			_sprite = new AnimatedSprite("img/player_girl.png");
		}
		else
		{
			_sprite = new AnimatedSprite("img/player_boy.png");
		}
		_sprite.scaleX = Game._TILE_SIZE / _sprite.width;
		_sprite.scaleY = Game._TILE_SIZE / _sprite.height;
		setPosition(position);
	}
	
	public function setPosition(position: Position)
	{
		_position = position;
		_sprite.x = _position.col * Game._TILE_SIZE;
		_sprite.y = _position.row * Game._TILE_SIZE;
	}
	
	public function getPosition() : Position
	{
		return _position;
	}
	
	public function getSprite() : AnimatedSprite
	{
		return _sprite;
	}
	
	private var _position: Position;
	private var _sprite : AnimatedSprite;
	
}

enum TileType
{
	Floor;
	Wall;
	Server;
	Workstation;
	User;
}

typedef Position =
{
	row: Int,
	col: Int
}

class Tile
{
	public function new(type: TileType, position: Position)
	{
		_position = position;
		setType(type);
	}
	
	public function loadBgSprite()
	{
		if (_bgSprite == null)
		{
			_bgSprite = new AnimatedSprite("img/floor.png");
			_bgSprite.scaleX = Game._TILE_SIZE / _bgSprite.width;
			_bgSprite.scaleY = Game._TILE_SIZE / _bgSprite.height;
			_bgSprite.x = _position.col * Game._TILE_SIZE;
			_bgSprite.y = _position.row * Game._TILE_SIZE;
		}
	}
	
	public function loadFgSprite()
	{
		if (_fgSprite != null)
		{
			_bgSprite.removeChildren();
		}
		
		switch (_type)
		{
			case (TileType.Wall):
			{
				_fgSprite = new AnimatedSprite("img/wall.png");
			}
			case (TileType.Server):
			{
				_fgSprite = new AnimatedSprite("img/server.png", { w: 16, h: 16 } );
				_fgSprite.start(1000);
			}
			case (TileType.Workstation):
			{
				_fgSprite = new AnimatedSprite("img/workstation.png");
			}
			case (TileType.User):
			{
				if (Math.random() < 0.5)
				{
					_fgSprite = new AnimatedSprite("img/user_girl.png");
				}
				else
				{
					_fgSprite = new AnimatedSprite("img/user_boy.png");
				}
			}
			default:
			{
				_fgSprite = null;
			}
		}
		
		if (_fgSprite != null)
		{
			_bgSprite.addChild(_fgSprite);
		}
	}
	
	public function setType(type: TileType)
	{
		_type = type;
		_passable = _type == TileType.Floor;
		loadBgSprite();
		loadFgSprite();
	}
	
	public function getBgSprite() : AnimatedSprite
	{
		return _bgSprite;
	}
	
	public function getFgSprite() : AnimatedSprite
	{
		return _fgSprite;
	}
	
	public function isPassable() : Bool
	{
		return _passable;
	}
	
	private var _type: TileType;
	private var _passable: Bool;
	private var _position: Position;
	
	private var _bgSprite: AnimatedSprite;
	private var _fgSprite: AnimatedSprite;
	
}

class Game
{
	
	public function new()
	{
		_scene = new SceneSprite( { w: _ROWS * _TILE_SIZE, h: _COLS * _TILE_SIZE } );
		_scene.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.addChild(_scene);
		
		// initialize
		_tiles = new Array<Array<Tile>>();
		for (r in 0 ... _ROWS) _tiles[r] = [];

		_avatar = new Avatar( { row: 0, col: 0 } );
		
		var initStr : String = new String("");
		initStr += "################,";
		initStr += "#A   # a  a  a #,";
		initStr += "#    # u  u  u #,";
		initStr += "#              #,";
		initStr += "######    @    #,";
		initStr += "#              #,";
		initStr += "#              #,";
		initStr += "#              #,";
		initStr += "#              #,";
		initStr += "#              #,";
		initStr += "#              #,";
		initStr += "######         #,";
		initStr += "#              #,";
		initStr += "#    # b  b  b #,";
		initStr += "#B   # u  u  u #,";
		initStr += "################";
		initFromString(initStr);
		
		_scene.addChild(_avatar.getSprite());
		
		_movable = true;
		_movementTimer = new Timer(150);
		_movementTimer.addEventListener(TimerEvent.TIMER, onMovementTimer);
		
		/*
		SfxEngine.play("snd/applause.wav", true);
		
		var sprite = new AnimatedSprite("img/xowl.jpg", { w: _TILE_SIZE, h: 25 } );
		sprite.scaleX = sprite.scaleY = 5;
		sprite.start(100);
		sprite.x = 10;
		sprite.y = 10;
		// sprite.rotation = 33;
		
		sprite.addEventListener(MouseEvent.CLICK, onClick);
		_scene.addChild(sprite);
		*/
	}
	
	public function initFromString(string: String)
	{
		var rows : Array<String> = string.split(",");
		for (r in 0 ... rows.length)
		{
			for (c in 0 ... rows[r].length)
			{
				switch (rows[r].charAt(c))
				{
					case " ": _tiles[r][c] = new Tile(TileType.Floor, { row: r, col: c } );
					case "#": _tiles[r][c] = new Tile(TileType.Wall, { row: r, col: c } );
					case "A": _tiles[r][c] = new Tile(TileType.Server, { row: r, col: c } );
					case "B": _tiles[r][c] = new Tile(TileType.Server, { row: r, col: c } );
					case "C": _tiles[r][c] = new Tile(TileType.Server, { row: r, col: c } );
					case "D": _tiles[r][c] = new Tile(TileType.Server, { row: r, col: c } );
					case "a": _tiles[r][c] = new Tile(TileType.Workstation, { row: r, col: c } );
					case "b": _tiles[r][c] = new Tile(TileType.Workstation, { row: r, col: c } );
					case "c": _tiles[r][c] = new Tile(TileType.Workstation, { row: r, col: c } );
					case "d": _tiles[r][c] = new Tile(TileType.Workstation, { row: r, col: c } );
					case "u": _tiles[r][c] = new Tile(TileType.User, { row: r, col: c } );
				    case "@": _tiles[r][c] = new Tile(TileType.Floor, { row: r, col: c } );
					          _avatar.setPosition( { row: r, col: c } );
					default: _tiles[r][c] = null;
				}
				if (_tiles[r][c] != null)
				{
					_scene.addChild(_tiles[r][c].getBgSprite());
				}
			}
		}
	}

	public function run(delta: Float, keysDown: Map<Int, Bool>)
	{
		if (_avatar == null)
		{
			return;
		}
		var pos = _avatar.getPosition();
		var newPos = { row: pos.row, col: pos.col };
		
		// left
		if (keysDown.exists(37))
		{
			newPos.col = newPos.col - 1;
		}
		// right
		if (keysDown.exists(39)) 
		{
			newPos.col = newPos.col + 1;
		}
		// up
		if (keysDown.exists(38))
		{
			newPos.row = newPos.row - 1; 
		}
		// down
		if (keysDown.exists(40))
		{
			newPos.row = newPos.row + 1;
		}
		
		if (getTile(newPos) == null || !getTile(newPos).isPassable())
		{
			SfxEngine.play("snd/bump.wav");
		}
		else if (_movable && (pos.col != newPos.col || pos.row != newPos.row))
		{
			_movable = false;
			_movementTimer.start();
			
			_avatar.setPosition(newPos);
			SfxEngine.play("snd/move.wav");
		}
	}
	
	public function getTile(position: Position) : Tile
	{
		if (position.row < 0 || position.row >= Game._ROWS
		    || position.col < 0 || position.col >= Game._COLS)
		{
			return null;
		}
		else
		{
			return _tiles[position.row][position.col];
		}
	}
	
	public function onMovementTimer(event: TimerEvent)
	{
		_movementTimer.stop();
		_movable = true;
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
	
	private static var _ROWS = 16;
	private static var _COLS = 16;
	
	public static var _TILE_SIZE = 20;
	
	private var _scene: SceneSprite;
	
	private var _tiles: Array<Array<Tile>>;
	
	private var _avatar: Avatar;
	private var _movable: Bool;
	private var _movementTimer: Timer;
	
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
