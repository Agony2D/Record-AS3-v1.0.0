package supportClasses {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	
public class WavToMp3WorkerSWF extends Sprite {
	
	public function WavToMp3WorkerSWF() {
		m_worker           =  Worker.current;
		m_channelToMain    =  m_worker.getSharedProperty("channelToMain");
		m_channelToWorker  =  m_worker.getSharedProperty("channelToWorker");
		m_mp3Data          =  m_worker.getSharedProperty("mp3Data");
		m_channelToWorker.addEventListener(Event.CHANNEL_MESSAGE, ____onChannelToWorker);
	}
	
	
	private var m_worker:Worker;
	private var m_channelToMain:MessageChannel;
	private var m_channelToWorker:MessageChannel;
//	private var m_wavData:ByteArray;
	private var m_mp3Data:ByteArray;
	private var m_mp3Encoder:ShineMP3Encoder;
	
	
	private function ____onChannelToWorker( e:Event ) : void {
		var msg:*;
		var wavData:ByteArray;
		
		msg = m_channelToWorker.receive();
		if(msg == "encode") {
			wavData = m_channelToWorker.receive() as ByteArray;
			this.____doAutoEncodeToMp3(wavData);
		}
	}
	
	private function ____doAutoEncodeToMp3( wavData:ByteArray ) : void {
		m_mp3Data.length = 0;
		m_mp3Encoder = new ShineMP3Encoder(wavData, m_mp3Data);
		m_mp3Encoder.addEventListener(Event.COMPLETE,         ____onEncodeComplete);
		m_mp3Encoder.addEventListener(ProgressEvent.PROGRESS, ____onEncodeProgress);
		m_mp3Encoder.start();
	}
	
	private function ____onEncodeComplete( e:Event ) : void {
		m_mp3Encoder.removeEventListener(Event.COMPLETE, ____onEncodeComplete);
		m_mp3Encoder.removeEventListener(ProgressEvent.PROGRESS, ____onEncodeProgress);
		
		m_channelToMain.send("complete");
	}
	
	private function ____onEncodeProgress( e:ProgressEvent ) : void {
		m_channelToMain.send("progress");
		m_channelToMain.send(e.bytesLoaded / 100);
	}
}
}