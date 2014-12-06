package hext;

import openfl.Lib;
import openfl.Assets;

import openfl.utils.Timer;
import openfl.events.TimerEvent;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

import openfl.geom.Point;
import openfl.geom.Rectangle;

import hext.Size;

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
