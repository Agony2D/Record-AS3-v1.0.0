package org.as3wavsound {
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	
	import org.as3wavsound.sazameki.core.AudioSamples;
	import org.as3wavsound.sazameki.core.AudioSetting;
	import org.as3wavsound.sazameki.format.wav.Wav;
	
	public class WavSound {
		
		private static const player:WavSoundPlayer = new WavSoundPlayer();
		
		private var _bytesTotal:Number;
		private var _samples:AudioSamples;
		private var _playbackSettings:AudioSetting;
		private var _length:Number;
		
		public function WavSound(wavData:ByteArray, audioSettings:AudioSetting = null) {
			load(wavData, audioSettings);
		}
		
		internal function load(wavData:ByteArray, audioSettings:AudioSetting = null): void {
			this._bytesTotal = wavData.length;
			this._samples = new Wav().decode(wavData);
			this._playbackSettings = (audioSettings != null) ? audioSettings : new AudioSetting();
			this._length = samples.length / samples.setting.sampleRate * 1000;
		}
		
		public function play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null): WavSoundChannel {
			return player.play(this, startTime, loops, sndTransform);
		}
		
		public function stop():void
		{
			//player.stop(player.playingWavSounds);
			for each (var channel:* in player.getChannels())
			{
				player.stop(channel);
			}
		}
		
		/**
		 * No idea if this works. Alpha state. Read up on Sound.extract():
		 * http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/media/Sound.html#extract()
		 */
		public function extract(target:ByteArray, length:Number, startPosition:Number = -1): Number {
			var start:Number = Math.max(startPosition, 0);
			var end:Number = Math.min(length, samples.length);
			
			for (var i:Number = start; i < end; i++) {
				target.writeFloat(samples.left[i]);
				if (samples.setting.channels == 2) {
					target.writeFloat(samples.right[i]);
				} else {
					target.writeFloat(samples.left[i]);
				}
			}
			
			return samples.length;
		}
		
		public function get bytesLoaded () : uint {return _bytesTotal;}
		public function get bytesTotal () : int {return _bytesTotal;}
		
		public function get length() : Number {return _length;}
		internal function get samples():AudioSamples {return _samples;}
		internal function get playbackSettings():AudioSetting {return _playbackSettings;}
	}
}