
package hext;

class ExpressionGenerator 
{

	private var _actions:Array<String>;
	private var _switches:Array<String>;
	private var _signs:Array<String>;

	public function new():Void
	{
	    this._actions = parseArray( ",", ADMIN_ACTIONS );
	    this._switches = parseArray( " ", SWITCHES );
	    this._signs = parseArray( " ", SIGNS );
	}

	public function getAdminAction():String
	{
	    return getRandomItem(this._actions);
	}

	public function getScan():String
	{
	    return "scan expression will be here";
	}

	private function getRandomItem(array:Array<String>):String
	{
	    return array[ Math.floor( Math.random() * array.length ) ];
	}

	private function parseArray(delimiter:String, input:String):Array<String>
	{
		var items:Array<String> = input.split(delimiter);
		var itemsTrimmed:Array<String> = [];
		for ( i in items )
		{
			itemsTrimmed.push( StringTools.trim( i ) );
		}
	    return itemsTrimmed;
	}

	private static var ADMIN_ACTIONS:String = "facepalm, clean mouse, slap user, 
	connect mouse, connect keyboard, turn on, turn off, restart, turn on monitor, 
	maniacal laughter, watch porn, turn back, reinstall win, reboot, pray, 
	eat harmburger, drink coke, tweet, google, take selfie, take footie, 
	feet on table, sleep";

	private static var SWITCHES:String = "a b c d e f g h i j k l m n o p q r s t u v w x y z";	

	private static var SIGNS:String = "; | > < &";	

}