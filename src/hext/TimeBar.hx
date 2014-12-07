package hext;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.DisplayObject;
import openfl.display.Bitmap;
import openfl.geom.ColorTransform;

class TimeBar extends Sprite
{

	private var _text:String;
	private var _border:Bitmap;
	private var _background:Bitmap;
	private var _bar:Bitmap;
	private var _barWidth:Float;
	private var _ratio:Float;

	public function new():Void
	{
	    super();

	    this.y = 208;
	    this.x = 256;

	    addChild( this._border = new Bitmap( Assets.getBitmapData("img/bar.png") ) );
	    setColorTint( this._border, 0x000000 );
	    this._border.width = 64;
	    this._border.height = 16;
	    this._border.alpha = 0.1;

	    addChild( this._background = new Bitmap( Assets.getBitmapData("img/bar.png") ) );
		setColorTint( this._background, 0x505050 );
		_background.x = 1;
		_background.y = 1;
		this._background.width = 62;
		this._background.height = 14;

	    addChild( this._bar = new Bitmap( Assets.getBitmapData("img/bar.png") ) );
		setColorTint( this._bar, 0x50b050 );
		this._bar.x = 1;
		this._bar.y = 1;
		_barWidth = 62;
		this._bar.width = _barWidth;
		this._bar.height = 14;

		addChild( new Bitmap( Assets.getBitmapData("img/timebar_label.png") ) );

		setRatio(0);
	}	

	// ratio = <0;1>
	public function setRatio(ratio:Float):Void
	{
		ratio = Math.max( 0, Math.min ( 1, ratio ) );

	    this._ratio = ratio;
	    this._bar.width = ratio * this._barWidth;
	    var color:Int = 0;
	    if ( ratio <= 0.2 )
	    {
	    	color = 0xffffff; // white
	    } else if ( ratio <= 0.4 )
	    {
	    	color = 0xee89f4; // pink
	    } else if ( ratio <= 0.6 )
	    {
	    	color = 0xff2bad; // purple
	    } else if ( ratio <= 0.8 )
	    {
	    	color = 0xff7800; // orange
	    } else
	    {
	    	color = 0xff0000; // red
	    }
		setColorTint( this._bar, color );

		this.visible = ( ratio > 0 );
	}

	private function setColorTint(displayObject:DisplayObject, color:Int):Void
	{
		var r:Int = (color & 0xff0000) >> 16;
	    var g:Int = (color & 0x00ff00) >> 8;
		var b:Int = (color & 0x0000ff);
		displayObject.transform.colorTransform = new ColorTransform( r / 255, g / 255, b / 255 );
	}

}