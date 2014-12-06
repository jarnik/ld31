package hext;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.display.Bitmap;

class CommandLine extends Sprite
{

	private var _text:String;
	private var _input:TextField;

	public function new():Void
	{
	    super();

	    this.x = 0;
	    this.y = 224;

	    addChild( new Bitmap( Assets.getBitmapData("img/command_line.png") ) );

        var format:TextFormat = new TextFormat (Assets.getFont ("assets/fonts/nokiafc22.ttf").fontName, 8, 0x669f34);
		addChild( _input = new TextField() );
		_input.width = 250;
		_input.y = 1;
		_input.x = 10;
		_input.height = 16;
		_input.wordWrap = false;
		_input.multiline = false;
		_input.defaultTextFormat = format;
		_input.embedFonts = true;

		setContent("");
	}	

	public function setContent(text:String):Void
	{
	    this._text = text;
	    this._input.text = text;
	}

	public function getContent():String
	{
	    return this._text;
	}

}