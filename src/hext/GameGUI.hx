
package hext;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import hext.Game;

class GameGUI extends Sprite
{

	private var _screenTitle:Bitmap;
	private var _screenWin:Bitmap;
	private var _screenFail:Bitmap;
	private var _map:Bitmap;

	private var screens:Array<Bitmap>;

	public function new():Void
	{
	    super();
	    addChild( this._screenTitle = new Bitmap( Assets.getBitmapData("img/screen_title.png") ) );
	    addChild( this._screenWin = new Bitmap( Assets.getBitmapData("img/screen_win.png") ) );
	    addChild( this._screenFail = new Bitmap( Assets.getBitmapData("img/screen_fail.png") ) );	    	
	    addChild( this._map = new Bitmap( Assets.getBitmapData("img/map.png") ) );
    	screens = [
    		this._screenTitle,
    		this._screenWin,
    		this._screenFail,
    		this._map
    	];
	}

	public function showState(state:GameState):Void
	{
	    for (screen in screens)
	    {
	    	screen.visible = false;
	    }
	    switch ( state ) {
	    	case STATE_TITLE:
	    		this._screenTitle.visible = true;
	    	case STATE_GAME_OVER:
	    		this._screenFail.visible = true;
	    	case STATE_WIN:
	    		this._screenWin.visible = true;
	    	default:
	    }
	}

	public function setMapVisible(visible:Bool):Void
	{
	    this._map.visible = visible;
	}

}