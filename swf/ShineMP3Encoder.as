package supportClasses {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import cmodule.shine.CLibInit;
	
public class ShineMP3Encoder extends EventDispatcher {
	
	public function ShineMP3Encoder(wavData:ByteArray, mp3Data:ByteArray) {
		this.wavData = wavData;
		this.mp3Data = mp3Data;
	}

	public function start() : void {
		initTime = getTimer();
		
		timer = new Timer(1000/30);
		timer.addEventListener(TimerEvent.TIMER, update);
		
		cshine = (new cmodule.shine.CLibInit).init();
		cshine.init(this, wavData, mp3Data);
		
		if(timer) {
			timer.start();
		}
	}
	
	
	public var wavData:ByteArray;
	public var mp3Data:ByteArray;
	
	private var cshine:Object;
	private var timer:Timer;
	private var initTime:uint;
	
	
	private function update(event : TimerEvent) : void {
		
		var percent:int = cshine.update();
		dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, percent, 100));
		
		trace("encoding mp3...", percent+"%");
		
		if(percent>=100) {
			
			trace("Done in", (getTimer()-initTime) * 0.001 + "s");
			
			timer.removeEventListener(TimerEvent.TIMER, update);
			timer.stop();
			timer = null;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
}