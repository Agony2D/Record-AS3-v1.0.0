package org.as3wavsound {
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import org.as3wavsound.sazameki.core.AudioSamples;
	import org.as3wavsound.sazameki.core.AudioSetting;
	import org.as3wavsound.WavSoundChannel;
	
	internal class WavSoundPlayer {
		public static var MAX_BUFFERSIZE:Number = 8192;

		// the master samples buffer in which all seperate Wavsounds are mixed into, always stereo at 44100Hz and bitrate 16
		private const sampleBuffer:AudioSamples = new AudioSamples(new AudioSetting(), MAX_BUFFERSIZE);
		private const playingWavSounds:Vector.<WavSoundChannel> = new Vector.<WavSoundChannel>();
		private const player:Sound = configurePlayer();
		
		
		private function configurePlayer():Sound {
			var player:Sound = new Sound();
			player.addEventListener(SampleDataEvent.SAMPLE_DATA, onSamplesCallback);
			player.play();
			return player;
		}
		
		private function onSamplesCallback(event:SampleDataEvent):void {
			sampleBuffer.clearSamples();
			for each (var playingWavSound:WavSoundChannel in playingWavSounds) {
				playingWavSound.buffer(sampleBuffer);
			}
			
			var outputStream:ByteArray = event.data;
			var samplesLength:Number = sampleBuffer.length;
			var samplesLeft:Vector.<Number> = sampleBuffer.left;
			var samplesRight:Vector.<Number> = sampleBuffer.right;
			
			// write all mixed samples to the sound's outputstream
			for (var i:int = 0; i < samplesLength; i++) {
				outputStream.writeFloat(samplesLeft[i]);
				outputStream.writeFloat(samplesRight[i]);
			}
		}
		
		internal function play(sound:WavSound, startTime:Number, loops:int, sndTransform:SoundTransform):WavSoundChannel {
			var channel:WavSoundChannel = new WavSoundChannel(this, sound, startTime, loops, sndTransform);
			playingWavSounds.push(channel);
			return channel;
		}
		
		internal function stop(channel:WavSoundChannel):void {
			for each (var playingWavSound:WavSoundChannel in playingWavSounds) {
				if (playingWavSound == channel) {
					playingWavSounds.splice(playingWavSounds.lastIndexOf(playingWavSound), 1);
				}
			}
		}
		
		//private function onSamplesMirrorCallback(event:SampleDataEvent):void {
			//var outputStream:ByteArray = event.data;
			//for (var i:int = 0; i < 2048; i++) {
				//outputStream.writeFloat(0);
				//outputStream.writeFloat(0);
			//}
		//}
		
		public function getChannels():Vector.<WavSoundChannel>
		{
			return playingWavSounds;
		}
	}
}