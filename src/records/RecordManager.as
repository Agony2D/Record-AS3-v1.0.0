package records {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.media.Microphone;
	import flash.system.MessageChannel;
	import flash.system.Security;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	
	import org.as3wavsound.WavSound;
	import org.as3wavsound.sazameki.core.AudioSetting;
	import org.bytearray.micrecorder.MicRecorder;
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import org.bytearray.micrecorder.events.RecordingEvent;
	
	[Event(name = "complete",  type = "flash.events.Event")] 
	
	[Event(name = "progress",  type = "flash.events.ProgressEvent")] 
	
	[Event(name = "recording", type = "org.bytearray.micrecorder.events.RecordingEvent")] 
	
public class RecordManager extends EventDispatcher {
	
	public function RecordManager() {
		m_microphone = Microphone.getMicrophone();
		m_microphone.setSilenceLevel(0);
		m_microphone.gain = 100;
		m_microphone.setLoopBack(false);
		m_microphone.setUseEchoSuppression(true);
		Security.showSettings("2");
		m_mp3Data = new ByteArray;
		m_mp3Data.shareable = true;
		
		
	}
	
	/**
	 * Singleton.
	 */
	public static function getInstance() : RecordManager {
		return g_instance ||= new RecordManager;
	}
	
	/** 輸出的mp3數據. */
	public function get mp3Data() : ByteArray {
		return m_mp3Data;
	}
	
	/** 是否為可使用狀態. */
	public function get enabled() : Boolean {
		return m_enabled;
	}
	
	public function set enabled( b:Boolean ) : void {
		if (m_enabled != b) {
			m_enabled = b;
			if (b) {
				m_worker           =  WorkerDomain.current.createWorker((new WavToMp3WorkerSWF) as ByteArray);
				m_channelToMain    =  m_worker.createMessageChannel(Worker.current);
				m_channelToWorker  =  Worker.current.createMessageChannel(m_worker);
				m_worker.setSharedProperty("channelToMain",   m_channelToMain);
				m_worker.setSharedProperty("channelToWorker", m_channelToWorker);
				m_worker.setSharedProperty("mp3Data",         m_mp3Data);
				m_worker.start();
				m_channelToMain.addEventListener(Event.CHANNEL_MESSAGE, ____onChannelToMain);
			}
			else {
				m_channelToMain.removeEventListener(Event.CHANNEL_MESSAGE, ____onChannelToMain);
				m_worker.terminate();
				m_worker = null;
				m_channelToMain = m_channelToWorker = null;
				m_mp3Data.length = 0;
			}
		}
	}
	
	/**
	 * 錄音開始.
	 */
	public function start() : void {
		m_isRecording = true;
		if(m_micRecorder){
			this.____doClearRecord();
		}
		this.micRecorder.record();
	}
	
	/**
	 * 錄音結束.
	 */
	public function finish() : void {
		if(m_micRecorder){
			m_micRecorder.stop();
		}
	}
	
	/**
	 * 播放.
	 */
	public function play() : void {
		if(m_isRecording){
			trace("錄音期間不可播放 !!");
			return;
		}
		if(m_wavSound){
			m_wavSound.play();
		}
		else{
			m_channelToMain.send("No play record !!")
		}
	}
	
	/**
	 * 停止.
	 */
	public function stop() : void{
		if(m_wavSound){
			m_wavSound.stop();
		}
		else{
			m_channelToMain.send("No stop record !!")
		}
	}
	
	
	
	private static var g_instance:RecordManager;
	
	[Embed(source = "WavToMp3WorkerSWF.swf", mimeType="application/octet-stream")]
	private const WavToMp3WorkerSWF:Class;
	
	private const MIN_LENGTH:int = 1000;
	
	private var m_worker:Worker;
	private var m_channelToMain:MessageChannel;
	private var m_channelToWorker:MessageChannel;
	private var m_microphone:Microphone;
	private var m_enabled:Boolean;
	private var m_mp3Data:ByteArray;
	private var m_micRecorder:MicRecorder;
	private var m_wavSound:WavSound;
	private var m_isRecording:Boolean;
	private var m_wavEncoder:WaveEncoder;
	
	
	private function get micRecorder() : MicRecorder {
		if(!m_micRecorder){
			if(!m_wavEncoder){
				m_wavEncoder = new WaveEncoder;
			}
			m_micRecorder = new MicRecorder(m_wavEncoder);
			m_micRecorder.addEventListener(RecordingEvent.RECORDING, ____onRecording);
			m_micRecorder.addEventListener(Event.COMPLETE,           ____onRecordComplete);
		}
		return m_micRecorder;
	}
	
	private function ____doClearRecord() : void {
		m_micRecorder.removeEventListener(RecordingEvent.RECORDING, ____onRecording);
		m_micRecorder.removeEventListener(Event.COMPLETE,           ____onRecordComplete);
		m_micRecorder = null;
	}
	
	private function ____onRecordComplete(e:Event):void {
		m_isRecording = false;
		m_wavSound = new WavSound(m_micRecorder.output, new AudioSetting);
		if (m_wavSound.length > MIN_LENGTH) {
			m_channelToWorker.send("encode");
			m_micRecorder.output.shareable = true;
			m_channelToWorker.send(m_micRecorder.output);
			trace("開始轉換mp3...")
		}
		else{
			this.____doClearRecord();
			m_wavSound = null;
		}
	}
	
	private function ____onChannelToMain( e:Event ) : void {
		var msg:*;
		var value:Number;
		
		msg = m_channelToMain.receive();
//		trace("[Loop]:" + msg);
		if (msg == "progress") {
			value = m_channelToMain.receive();
//			trace("[mp3 ratio]: " + value);
			this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, value, 1));
		}
		else if(msg == "complete") {
//			trace("[mp3 complete]");
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
	}
	
	private function ____onRecording(e:RecordingEvent):void {
		this.dispatchEvent(new RecordingEvent(RecordingEvent.RECORDING, e.time))
	}
}
}