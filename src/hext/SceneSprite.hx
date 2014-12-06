package hext;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

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
		onResize(null);
	}
	
	private function onResize(event)
	{
		scaleX = 2;
		scaleY = 2;
		
		/*
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
		*/
	}
	
	private var _size: Size;
	
}