package hext;

import openfl.Lib;
import openfl.Assets;

import openfl.utils.Timer;
import openfl.events.TimerEvent;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;

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