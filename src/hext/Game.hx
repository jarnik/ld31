package hext;

import hext.Game.Tile;
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
		_updateTimer = new Timer(500);
		_updateTimer.addEventListener(TimerEvent.TIMER, onUpdateTimer);
		_position = position;
		
		_online = true;
		_broken = false;
		
	    _masterSprite = new Sprite();
		_masterSprite.x = _position.col * Game._TILE_SIZE;
		_masterSprite.y = _position.row * Game._TILE_SIZE;
	    _bgLayer = new Sprite();
	    _fgLayer = new Sprite();
	    _popupLayer = new Sprite();
		_masterSprite.addChild(_bgLayer);
		_masterSprite.addChild(_fgLayer);
		_masterSprite.addChild(_popupLayer);
		
		loadBgSprite();
		setType(type);		
	}
	
	public function loadBgSprite()
	{
		if (_bgSprite == null)
		{
			_bgSprite = new AnimatedSprite("img/floor.png");
			//_bgSprite.scaleX = Game._TILE_SIZE / _bgSprite.width;
			//_bgSprite.scaleY = Game._TILE_SIZE / _bgSprite.height;
			//_bgSprite.x = _position.col * Game._TILE_SIZE;
			//_bgSprite.y = _position.row * Game._TILE_SIZE;
			_bgLayer.addChild(_bgSprite);
		}
	}
	
	public function loadFgSprite()
	{	
		if (_fgSprite != null)
		{
            _fgLayer.removeChildren();
			_fgSprite = null;
			// _bgSprite.removeChildren();
		}
		
		switch (_type)
		{
			case (TileType.Wall):
			{
				_updateTimer.stop();
				_fgSprite = new AnimatedSprite("img/wall.png");
			}
			case (TileType.Server):
			{
				_online = true;
				_corruption = 0;
				_fgSprite = new AnimatedSprite("img/server.png", { w: 16, h: 16 } );
				_fgSprite.setFrame(Math.floor((Math.random() * 10)) % 3);
				_fgSprite.start(500 + Math.random() * 1000);
				_updateTimer.start();
			}
			case (TileType.Workstation):
			{
				_broken = false;
				_corruption = 0;
				_fgSprite = new AnimatedSprite("img/workstation.png");
				_updateTimer.start();
			}
			case (TileType.User):
			{
				_anger = 0;
				if (Math.random() < 0.5)
				{
					_fgSprite = new AnimatedSprite("img/user_girl.png");
				}
				else
				{
					_fgSprite = new AnimatedSprite("img/user_boy.png");
				}
				_updateTimer.start();
			}
			default:
			{
				_updateTimer.stop();
				_fgSprite = null;
			}
		}
		if (_fgSprite != null)
		{
			_fgLayer.addChild(_fgSprite);
		}
	}

	private function loadPopupSprite()
	{	
		if (_popupLayer != null)
		{
            _popupLayer.removeChildren();
		}
		switch (_type)
		{			
			case TileType.User, TileType.Server, TileType.Workstation:
				_popupLayer = new Sprite();
				_popupLayer.addChild( _bar = new UserBar( 
					_type == TileType.Workstation ?
						 -4 : // above
						 17   // below
					 ) );
				_popupLayer.x = _masterSprite.x;
				_popupLayer.y = _masterSprite.y;
			default:
		}
	}
	
	public function setType(type: TileType)
	{
		_type = type;
		_passable = _type == TileType.Floor;
		loadFgSprite();
		loadPopupSprite();
	}
	
	public function getType() : TileType
	{
		return _type;
	}
	
	public function getMasterSprite() : Sprite
	{
		return _masterSprite;
	}
	public function getPopupLayer() : Sprite
	{
		return _popupLayer;
	}
	
	public function isPassable() : Bool
	{
		return _passable;
	}
	
	public function setGroup(group: Int)
	{
		_group = group;
	}
	
	public function getGroup() : Int
	{
		return _group;
	}
	
	public function setServer(server: Tile)
	{
		_server = server;
	}
	
	private function onUpdateTimer(event: TimerEvent)
	{
		switch (_type)
		{
			case TileType.Workstation: workstationUpdate();
			case TileType.Server: serverUpdate();
			case TileType.User: userUpdate();
			default: {};
		}
	}
	
	private function workstationUpdate()
	{
		maybeBreak();
	    if (_broken)
		{
			return;
		}
		if (_corruption == 0)
		{
			if (Math.random() < 0.03)
			{
				_corruption = 5;
			}
			return;
		}
		if (_corruption < 100)
		{
			_corruption += 5;
		    if (_corruption >= 100)
			{
				setInfected();
			}
		}
		if (_corruption >= 100 && _server._online)
		{
			if (_server._corruption == 0)
			{
				if (Math.random() < 0.1)
				{
					_server._corruption = 2;
				}
			}
			else if (_server._corruption < 100)
			{
				_server._corruption += 2;
				if (_server._corruption >= 100)
				{
					_server.setInfected();
				}
			}
		}
		_bar.setRatio( _corruption / 100 );
	}
	
	private function serverUpdate()
	{		
		if (!_online)
		{
			return;
		}
		if (_corruption > 0 && _corruption < 100)
		{
			_corruption += 2;
			if (_corruption >= 100)
			{
				setInfected();
			}
		}
		if (_corruption >= 100)
		{
			var workstations = Main.game.findWorkstations(_group);
			for (i in 0 ... workstations.length)
			{
				if (!workstations[i]._broken && workstations[i]._corruption < 100)
				{
					workstations[i]._corruption += 5;
				}
			}
		}
		_bar.setRatio( _corruption / 100 );
	}
	
	private function userUpdate()
	{
		var workstation = Main.game.getNearestWorkstation(_position);
		if (workstation == null)
		{
			return;
		}
		if (workstation._broken || workstation._corruption >= 100 || !workstation._server._online)
		{
			_anger += 10;
			SfxEngine.play("snd/npc_uses_pc_increasing_anger.mp3", false, 0.01);
			if (_anger > 100)
			{
				setType(TileType.Floor);
				SfxEngine.play("snd/npc_reached_anger_and_left.mp3", false, 0.01);
			}
		}
		else
		{
			if (_anger > 0)
			{
				_anger -= 10;
				SfxEngine.play("snd/npc_uses_pc_decreasing_anger.mp3", false, 0.01);
				if (_anger < 0)
				{
					_anger = 0;
				}
			}
		}
		_bar.setRatio( _anger / 100 );
	}
	
	private function maybeBreak()
	{
		if (_corruption < 100 && !_broken)
		{
			if (Math.random() < 0.01)
			{
				setBroken();
			}
		}
	}
	
	private function setBroken()
	{
		_broken = true;
		_fgLayer.removeChildren();
		_fgSprite = new AnimatedSprite("img/workstation_bsod.png");
		_fgLayer.addChild(_fgSprite);
	}
	
	private function setInfected()
	{
		if (_type == TileType.Workstation)
		{
			_fgLayer.removeChildren();
			_fgSprite = new AnimatedSprite("img/workstation_virus.png");
			_fgLayer.addChild(_fgSprite);
		}
		else if (_type == TileType.Server)
		{
			_fgLayer.removeChildren();
			_fgSprite = new AnimatedSprite("img/server_corrupted.png");
			_fgLayer.addChild(_fgSprite);
		}
	}
	
	private function refreshFgSprite()
	{
		// state: broken, normal (<100 corruption), infected (100 corruption)
		if (_type == TileType.Workstation)
		{
			
		}
		// state: offline, normal (<100 corruption), infected (100 corruption)
		else if (_type == TileType.Server)
		{
			
		}
	}
	
	private var _type: TileType;
	private var _passable: Bool;
	private var _position: Position;
	
	private var _online: Bool; // server
	private var _group: Int; // workstation/server
	private var _server: Tile; // workstation only
	private var _broken: Bool; // workstation only
	private var _corruption: Int; // workstation/server
	private var _anger: Int; // user only
    private var _updateTimer: Timer; // workstation/server/user update; 0.5s
	
	private var _masterSprite: Sprite; // for position
	private var _bgLayer: Sprite; // layer 0
	private var _fgLayer: Sprite; // layer 1
	private var _popupLayer: Sprite; // layer 2

	private var _bgSprite: AnimatedSprite;
	private var _fgSprite: AnimatedSprite;
	private var _bar: UserBar;
	
}

enum GameState
{
	STATE_TITLE;
	STATE_PLAY;
	STATE_GAME_OVER;
	STATE_WIN;
}

class Game
{
	
	public function new()
	{
		_scene = new SceneSprite( { w: _COLS * _TILE_SIZE, h: _ROWS * _TILE_SIZE } );
		_scene.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.addChild(_scene);
		_scene.addChild( _tileLayer = new Sprite() );		
		_scene.addChild( _popupLayer = new Sprite() );		
		
		// initialize
		_tiles = new Array<Array<Tile>>();
		for (r in 0 ... _ROWS) _tiles[r] = [];

		_avatar = new Avatar( { row: 0, col: 0 } );
		
		var initStr : String = new String("");
		initStr += "####################,";
		initStr += "#A      #  a  a  a #,";
		initStr += "#### ####  u  u  u #,";
		initStr += "# c  c  #          #,";
		initStr += "# u  u  #     ## ###,";
		initStr += "#         @   #   C#,";
		initStr += "# d  d  #     #   ##,";
		initStr += "# u  u  #     #   D#,";
		initStr += "#########     ## ###,";
		initStr += "#                  #,";
		initStr += "#    # b  b  b  b  #,";
		initStr += "#B   # u  u  u  u  #,";
		initStr += "####################";
		initFromString(initStr);
		
		_tileLayer.addChild(_avatar.getSprite());
		
		_movable = true;
		_movementTimer = new Timer(150);
		_movementTimer.addEventListener(TimerEvent.TIMER, onMovementTimer);
		
		_scene.addChild(_gui = new GameGUI());

		_scene.addChild(_commandLine = new CommandLine());
		_commandLine.setContent("START TYPING!!!");

		_scene.addChild(_helpLine = new CommandLine( false ));
		_helpLine.setVisible(true);
		_helpLine.setContent("HELP!!!");		
		
		switchState( STATE_PLAY );
		//switchState( STATE_TITLE );

		var generator:hext.ExpressionGenerator = new hext.ExpressionGenerator();
		// trace("action: "+generator.getAdminAction());
		// trace("scan: "+generator.getScan());

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
		var popup:Sprite;
		for (r in 0 ... rows.length)
		{
			for (c in 0 ... rows[r].length)
			{
				switch (rows[r].charAt(c))
				{
					case " ": _tiles[r][c] = new Tile(TileType.Floor, { row: r, col: c } );
					case "#": _tiles[r][c] = new Tile(TileType.Wall, { row: r, col: c } );
					case "A": _tiles[r][c] = new Tile(TileType.Server, { row: r, col: c } );
					          _tiles[r][c].setGroup(1);
					case "B": _tiles[r][c] = new Tile(TileType.Server, { row: r, col: c } );
					          _tiles[r][c].setGroup(2);
					case "C": _tiles[r][c] = new Tile(TileType.Server, { row: r, col: c } );
					          _tiles[r][c].setGroup(3);
					case "D": _tiles[r][c] = new Tile(TileType.Server, { row: r, col: c } );
					          _tiles[r][c].setGroup(4);
					case "a": _tiles[r][c] = new Tile(TileType.Workstation, { row: r, col: c } );
					          _tiles[r][c].setGroup(1);
					case "b": _tiles[r][c] = new Tile(TileType.Workstation, { row: r, col: c } );
					          _tiles[r][c].setGroup(2);
					case "c": _tiles[r][c] = new Tile(TileType.Workstation, { row: r, col: c } );
					          _tiles[r][c].setGroup(3);
					case "d": _tiles[r][c] = new Tile(TileType.Workstation, { row: r, col: c } );
					          _tiles[r][c].setGroup(4);
					case "u": _tiles[r][c] = new Tile(TileType.User, { row: r, col: c } );
				    case "@": _tiles[r][c] = new Tile(TileType.Floor, { row: r, col: c } );
					          _avatar.setPosition( { row: r, col: c } );
					default: _tiles[r][c] = null;
				}
				if (_tiles[r][c] != null)
				{
					_tileLayer.addChild(_tiles[r][c].getMasterSprite());
					popup = _tiles[r][c].getPopupLayer();
					if (popup != null)
					{
						_popupLayer.addChild( popup );
					}
				}
			}
		}
		
		for (i in 1 ... 5)
		{
			var server = findServer(i);
			var workstations = findWorkstations(i);
			for (j in 0 ... workstations.length)
			{
				workstations[j].setServer(server);
			}
		}
	}
	
	public function findServer(group: Int) : Tile
	{
		for (r in 0 ... _tiles.length)
		{
			for (c in 0 ... _tiles[r].length)
			{
				if (_tiles[r][c].getType() == TileType.Server && _tiles[r][c].getGroup() == group)
				{
					return _tiles[r][c];
				}
			}
		}
		return null;
	}
	
	public function findWorkstations(group: Int) : Array<Tile>
	{
		var workstations : Array<Tile> = [];
		for (r in 0 ... _tiles.length)
		{
			for (c in 0 ... _tiles[r].length)
			{
				if (_tiles[r][c].getType() == TileType.Workstation && _tiles[r][c].getGroup() == group)
				{
					workstations.push(_tiles[r][c]);
				}
			}
		}
		return workstations;
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

		// map
		_gui.setMapVisible( keysDown.exists(openfl.ui.Keyboard.CONTROL) && _state == STATE_PLAY );
				
		if (getTile(newPos) == null || !getTile(newPos).isPassable())
		{
			SfxEngine.play("snd/pc_bumping_into_wall.mp3", false, 0.01);
		}
		else if (_movable && (pos.col != newPos.col || pos.row != newPos.row))
		{
			_movable = false;
			_movementTimer.start();
			
			_avatar.setPosition(newPos);
			SfxEngine.play("snd/pc_movement.mp3", false, 0.01);
		}
	}
	
	public function getNearestWorkstation(position: Position) : Tile
	{
		var tile: Tile = null;
		var distance: Int = 1000;
		for (r in 0 ... _tiles.length)
		{
			for (c in 0 ... _tiles[r].length)
			{
				if (_tiles[r][c].getType() == TileType.Workstation)
				{
					var d = Math.floor(Math.abs(position.row - r) + Math.abs(position.col - c));
					if (d < distance)
					{
						tile = _tiles[r][c];
						distance = d;
					}
				}
			}
		}
		return tile;
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
	
	public function onKeyDown(charCode: Int)
	{
		if (_string == null)
		{
			_string = new String("_");
		}
		
		if (charCode == 0)
		{
			return;
		}
		// enter
		if (charCode == 13)
		{
			processInput( _string );
			return;
		}
		// backspace
		if (charCode == 8)
		{
			if (_string.length > 1)
			{
				_string = _string.substr(0, _string.length - 2) + "_";
				_commandLine.setContent(_string);
				SfxEngine.play("snd/pc_keypress.mp3", false, 0.01);
				
			}
			return;
		}
		
		_string = _string.substr(0, _string.length - 1);
		_string += String.fromCharCode(charCode) + "_";
		_commandLine.setContent(_string);
		SfxEngine.play("snd/pc_keypress.mp3", false, 0.01);
	}
	
	private function processInput(input:String):Void
	{
		if ( StringTools.endsWith(input,"_") )
		{
			input = input.substr(0,-1);
		}
	 	switch ( _state )
	    {
	    	case STATE_TITLE:
	    		if ( input == "start" )
	    		{
	    			switchState( STATE_PLAY );
	    		}
    		case STATE_PLAY:	    		
    			// TODO
	    	case STATE_GAME_OVER:
	    		if ( input == "continue" )
	    		{
	    			switchState( STATE_PLAY );
	    		}
	    	case STATE_WIN:
	    		if ( input == "i own3d" )
	    		{
	    			switchState( STATE_TITLE );
	    		}
	    	default:
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
	
	private function switchState(newState:GameState):Void
	{
		this._state = newState;
		this._gui.showState( this._state );
		this.clearCommandLine();
	    switch ( newState )
	    {
	    	case STATE_TITLE:
	    		playMusic("music/menu_1.mp3");
	    		setHelp("type \"start\"");
    		case STATE_PLAY:
	    		playMusic("music/music_1.mp3");
	    	case STATE_GAME_OVER:
	    		playMusic("music/game_over.mp3");
	    		setHelp("type \"i suck\" to try again");
	    	case STATE_WIN:
	    		playMusic("music/victory.mp3");
	    		setHelp("type \"i own3d\", oh mighty lord");
	    	default:
	    }
	}

	private function setHelp(help:String):Void
	{
	    this._helpLine.setContent( help );
	}

	private function clearCommandLine():Void
	{
		_string = "_";
	    this._commandLine.setContent(_string);
	}

	private function playMusic(asset:String):Void
	{
	    if ( this._music != null )
	    {
	    	this._music.channel.stop();
	    }

	    this._music = SfxEngine.play(asset, true, 0.02);
	}

	private static var _ROWS = 14;
	private static var _COLS = 20;
	
	public static var _TILE_SIZE = 16;
	
	private var _scene: SceneSprite;
	private var _tileLayer:Sprite;
	private var _popupLayer:Sprite;
	
	private var _tiles: Array<Array<Tile>>;
	
	private var _avatar: Avatar;
	private var _movable: Bool;
	private var _movementTimer: Timer;
	private var _string: String;
	private var _commandLine: CommandLine;
	private var _helpLine: CommandLine;
	private var _state: GameState;
	private var _gui: GameGUI;
	private var _music: SfxEngine.Sfx;

}
