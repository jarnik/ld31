package hext;

import openfl.Lib;
import openfl.Assets;

import openfl.utils.Timer;
import openfl.events.TimerEvent;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;

import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

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
		
		if (!Assets.exists(pathName, AssetType.SOUND))
		{
			return;
		}
		
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
