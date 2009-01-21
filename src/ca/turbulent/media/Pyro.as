/*
Disclaimer for Eric Poirier's ca.turbulent.media.Pyro's license:

TERMS OF USE - PYRO

Open source under the BSD License.

Copyright © 2007-2009 Eric Poirier [Nibman] and Turbulent Media inc. 
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package ca.turbulent.media
{
	import ca.turbulent.media.events.*;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.*;
	
	/**
	* Pyro
	* Version 1.0.0
	*
	*  @author Eric Poirier 2008-2009, epoirier@turbulent.ca || nibman@gmail.com
	* 	  
	*  	@description 
	* 	ABOUT PYRO
	*  	Encapsulates methods for handling and displaying video files in a swf based environment.
	* 	Standardizes progressive http, proxied http and rtmp streams handling by using a common, simple and direct AS3 API.
	* 	Works and tested for flashPlayer 9,1,1,5 up to 10,0,12,36 . Should logically work for all flashPlayer 10 versions too. 
	*         
	* 	Not a complete media player, Pyro bundles all core functionalities of standard flash video players and leaves out defined design aspects
	*	Like most other available 'players' Pyro extends the flash.display.Sprite class.    
	*  
	* 	Events dispatched are for the most part proprietary. Pyro events are located in the ca.turbulent.media.events package.  
	*	
	*	Pyro's constants naming scheme uses a prefix terminology for tighter code completion in your AS editor of choice.
	*   
	*	@usage
	*	Using Pyro is easy and quick. 
	*	1. Create a Pyro instance, insert width then height as arguments and add your pyro instance to the child list, as follows:   
	* 	<code>
	*	var pyroInstance:Pyro = new Pyro(320, 240);
	* 	addChild(pyroInstance);
	* 	</code>
	*	
	*   2.Once your Pyro instance is created, understanding how the play method behaves is crucial. 
	* 	<code>pyroInstance.play("http://epoirier.developers.turbulent.ca/pyro/sharedmedias/videos/gratton.flv"); // Connects to a file and starts streaming it as a regular progressive download.
	*	pyroInstance.play("http://epoirier.developers.turbulent.ca/pyro/sharedmedias/videos/gratton.flv?start=34.454"); // Connects to a file thru a middleware script and starts streaming.         	    
	*	pyroInstance.play("rtmp://epoirier.developers.turbulent.ca/pyro/sharedmedias/gratton.mp4"); // Connects to an rtmp server and starts streaming. 
	*	pyroInstance.play(); // resumes from a paused status</code>	
	* 	You can call up a new stream at anytime.
	* 	Pyro takes care of resetting, closing and clearing all required necessary variables, parameters and assets. 
	* 	As shown above, calling the play method without arguments acts as the usual play method and resumes the stream if it has been paused or stopped.      
	*  	
	* 	3.Creating visual states and stream progress related visuals is easy. 
	*   I've put together a few exemples that will get anyone with minimal actionscript 3 knowledge started quickly.
	* 
	* @tiptext	Pyro
	* 	@playerversion Flash 9.1.1.5	  
	* 
	* */
	
	public class Pyro extends Sprite
	{
		/**
		* Used as hAlignMode property value. -->> pyroInstance.hAlignMode = Pyro.ALIGN_HORIZONTAL_CENTER ['center']) 
		* Forces the Video class instance to align horizontally to the center of pyro's physical canvas if it is somehow smaller than the specified width. 
		* @see #ALIGN_HORIZONTAL_LEFT
		* @see #ALIGN_HORIZONTAL_RIGHT 
		* @see #hAlignMode 
		**/ 	
		public static const ALIGN_HORIZONTAL_CENTER				:String				= "center";
		
		/**
		* Used as hAlignMode property value. -->> pyroInstance.hAlignMode = Pyro.ALIGN_HORIZONTAL_LEFT ['left']) 
		* Forces the Video class instance to align horizontally to the left of pyro's physical canvas if it is somehow smaller than the specified width. 
		* @see #ALIGN_HORIZONTAL_CENTER
		* @see #ALIGN_HORIZONTAL_RIGHT 
		* @see #hAlignMode 
		**/	
		public static const ALIGN_HORIZONTAL_LEFT				:String				= "left";
		
		/**
		* Used as hAlignMode property value. -->> pyroInstance.hAlignMode = Pyro.ALIGN_HORIZONTAL_RIGHT ['right']) 
		* Forces the Video class instance to align horizontally to the right of pyro's physical canvas if it is somehow smaller than the specified width. 
		* @see #ALIGN_HORIZONTAL_LEFT
		* @see #ALIGN_HORIZONTAL_CENTER 
		* @see #hAlignMode 
		**/
		public static const ALIGN_HORIZONTAL_RIGHT				:String				= "right";
		
		/**
		* Used as vAlignMode property value. -->> pyroInstance.vAlignMode = Pyro.ALIGN_VERTICAL_BOTTOM ['bottom']) 
		* Forces the Video class instance to align vertically to the right of pyro's physical canvas if it is somehow smaller than the specified height. 
		* @see #ALIGN_VERTICAL_TOP
		* @see #ALIGN_VERTICAL_CENTER 
		* @see #vAlignMode 
		**/
		public static const ALIGN_VERTICAL_BOTTOM				:String				= "bottom";
		
		/**
		* Used as vAlignMode property value. -->> pyroInstance.vAlignMode = Pyro.ALIGN_VERTICAL_TOP ['top']) 
		* Forces the Video class instance to align vertically to the center of pyro's physical canvas if it is somehow smaller than the specified height. 
		* @see #ALIGN_VERTICAL_CENTER
		* @see #ALIGN_VERTICAL_BOTTOM 
		* @see #vAlignMode 
		**/
		public static const ALIGN_VERTICAL_TOP					:String 			= "top";
		
		/**
		* Used as vAlignMode property value. -->> pyroInstance.vAlignMode = Pyro.ALIGN_VERTICAL_CENTER ['center']) 
		* Forces the Video class instance to align vertically to the center of pyro's physical canvas if it is somehow smaller than the specified height. 
		* @see #ALIGN_VERTICAL_TOP
		* @see #ALIGN_VERTICAL_BOTTOM 
		* @see #vAlignMode 
		**/
		public static const ALIGN_VERTICAL_CENTER				:String 			= "center";
		
		/**
		* Used as connectionSpeed read-only property value.
		* Will return if checkBandwidth is true and bandwidthCheckDone is true. connectionSpeed == Pyro.CONNECTION_SPEED_LOW when client is on lowBandwidth connection approximately 56 k connections and lower.
		* @see #CONNECTION_SPEED_MEDIUM
		* @see #CONNECTION_SPEED_HIGH 
		* @see #connectionSpeed 
		**/
		public static const CONNECTION_SPEED_LOW				:String				= "low";
		
		/**
		* Used as connectionSpeed read-only property value.
		* Will return if checkBandwidth is true and bandwidthCheckDone is true. connectionSpeed == Pyro.CONNECTION_SPEED_MEDIUM when client is on regular DSL and limited cable connections.
		* @see #CONNECTION_SPEED_LOW
		* @see #CONNECTION_SPEED_HIGH 
		* @see #connectionSpeed 
		**/
		public static const CONNECTION_SPEED_MEDIUM				:String				= "medium";
		
		/**
		* Used as connectionSpeed read-only property value.
		* Will return if checkBandwidth is true and bandwidthCheckDone is true. connectionSpeed == Pyro.CONNECTION_SPEED_HIGH is on residential high-speed connections and higher.
		* @see #CONNECTION_SPEED_LOW
		* @see #CONNECTION_SPEED_MEDIUM 
		* @see #connectionSpeed 
		**/
		public static const CONNECTION_SPEED_HIGH				:String				= "high";
		
		/**
		* Pyro's status gets set to STATUS_CLOSED ['statusClosed'] when the close method is called and the active netStream is closed.
		* Be extra careful when listening for the STATUS_CLOSED since it gets called everytime a new stream is queried thru the play method.    
	 	* @see #StatusUpdateEvent.STATUS_UPDATE
		**/
		public static const STATUS_CLOSED						:String 			= "statusClosed";
		
		/**
		* Pyro's status gets set to STATUS_COMPLETED ['statusCompleted'] when the stream reaches its end to prevent hazardous double dispatching of the PyroEvent.COMPLETE Event.
		* Using the PyroEvent.COMPLETE Event is considered best practice for monitoring stream completion. 
	 	* @see #PyroEvent.COMPLETE
	 	* @see #StatusUpdateEvent.STATUS_UPDATE
		**/
		public static const STATUS_COMPLETED					:String				= "statusCompleted";
		
		/**
		* Pyro's status gets set to STATUS_CONNECTING ['statusConnecting'] when the play method is called with a new url, and remains like so until the stream starts playing or an error is dispatched.  
	 	* @see #StatusUpdateEvent.STATUS_UPDATE
		**/
		public static const STATUS_CONNECTING					:String 			= "statusConnecting";
		
		/**
		* Pyro's status gets set to STATUS_INITIALIZING ['statusInitializing'] when your Pyro instance is instanciated, and remains like so until the player is ready to receive connections (STATUS_READY)  
	 	* @see #STATUS_READY
	 	* @see #StatusUpdateEvent.STATUS_UPDATE
		**/
		public static const STATUS_INITIALIZING					:String 			= "statusInitializing"
		
		/**
		* Pyro's status gets set to STATUS_PENDING ['statusPending'] is used as the buffering, idle and obviously as the pending status.
		* @see #STATUS_PLAYING
		* @see #STATUS_PAUSED
		* @see #STATUS_STOPPED    
	 	* @see #StatusUpdateEvent.STATUS_UPDATE
		**/
		public static const STATUS_PENDING						:String				= "statusPending";
		
		/**
		* Pyro's status gets set to STATUS_PLAYING ['statusPlaying'] when the stream starts playing.
		* 
		* @see #STATUS_PAUSED
		* @see #STATUS_PENDING
		* @see #STATUS_STOPPED    
	 	* @see #StatusUpdateEvent.STATUS_UPDATE
		**/
		public static const STATUS_PLAYING						:String				= "statusPlaying";
		
		/**
		* Pyro's status gets set to STATUS_PAUSED ['statusPaused'] when the stream gets paused.
		* 
		* @see #STATUS_PLAYING
		* @see #STATUS_PENDING
		* @see #STATUS_STOPPED    
	 	* @see #StatusUpdateEvent.STATUS_UPDATE
		**/
		public static const STATUS_PAUSED						:String				= "statusPaused";
		
		/**
		* Pyro's status gets set to STATUS_READY ['statusReady'] when your Pyro instance has successfully been initialized. 
		* @see #STATUS_INITIALIZING
	 	* @see #StatusUpdateEvent.STATUS_UPDATE
		**/
		public static const STATUS_READY						:String 			= "statusReady";
		
		/**
		* Pyro's status gets set to STATUS_STOPPED ['statusStopped'] when Pyro's stop method is called. 
		* 		
		* @see #STATUS_PLAYING
		* @see #STATUS_PAUSED
		* @see #STATUS_PENDING    
	 	* @see #StatusUpdateEvent.STATUS_UPDATE
		**/
		public static const STATUS_STOPPED						:String				= "statusStopped";
		
		/**
		* Used as fullscreenMode property value. -->> pyroInstance.fullscreenMode = Pyro.FS_MODE_HARDWARE ['hardwareMode'] 
		* Forces pyro to use hardware acceleration when fullscreen mode is toggled-in.
		* If system has no video encoding possibilities, fullscreenMode is resetted to default FS_MODE_SOFTWARE.		
		* @see #FS_MODE_SOFTWARE
		* @see #toggleFullScreen
		* @see #fullscreenRectangle 
		**/
		public static const FS_MODE_HARDWARE					:String				= "hardwareMode";
		
		/**
		* Used as fullscreenMode property value. -->> pyroInstance.fullscreenMode = Pyro.FS_MODE_SOFTWARE ['softwareMode'] 
		* Forces pyro to use software rendering when fullscreen mode is toggled-in.
		* @see #FS_MODE_HARDWARE
		* @see #toggleFullScreen
		* @see #fullscreenRectangle 
		**/
		public static const FS_MODE_SOFTWARE					:String				= "softwareMode";
		
		/**
		* Used as scaleMode property value. -->> pyroInstance.scaleMode = Pyro.SCALE_MODE_HEIGHT_BASED ['heightBasedScale']) 
		* Sets the videoHeight as base factor for resizing while maintainAspectRatio is set to true.
		* Usually proper to 4:3 ratios. 
		* @see #SCALE_MODE_WIDTH_BASED
		* @see #maintainAspectRatio 
		* @see #forceResize
		* @see #scaleMode 
		**/
		public static const SCALE_MODE_HEIGHT_BASED				:String				= "heightBasedScale";
		
		/**
		* Used as scaleMode property value. -->> pyroInstance.scaleMode = Pyro.SCALE_MODE_WIDTH_BASED ['widthBasedScale']) 
		* Sets the videoWidth as base factor for resizing while maintainAspectRatio is set to true.
		* Usually proper to 16:9 ratios. 
		* @see #SCALE_MODE_HEIGHT_BASED
		* @see #maintainAspectRatio 
	 	* @see #forceResize
		* @see #scaleMode 
		**/	
		public static const SCALE_MODE_WIDTH_BASED				:String				= "widthBasedScale";
		
		/**
		* Used as scaleMode property value. -->> pyroInstance.scaleMode = Pyro.SCALE_MODE_NO_SCALE ['noScale']) 
		* Ignores canvas rescaling and ratios once metadata sizes are received.
		* @see #SCALE_MODE_HEIGHT_BASED
		* @see #SCALE_MODE_WIDTH_BASED
		* @see #maintainAspectRatio 
	 	* @see #forceResize
		* @see #scaleMode 
		**/	
		public static const SCALE_MODE_NO_SCALE					:String				= "noScale";	
		
		/**
		* Used as streamType read-only property value. -->> if (pyroInstance.streamType == Pyro.STREAM_TYPE_PROGRESSIVE ['progressive']) 
		* Indicates the current playing stream is beeing read as regular progressive http (https) download. 
		* @see #STREAM_TYPE_TRUE_STREAM
		* @see #STREAM_TYPE_PROXIED_PROGRESSIVE
		* @see #streamType 
		**/			
		public static const STREAM_TYPE_PROGRESSIVE				:String				= "progressive";
		
		/**
		* Used as streamType read-only property value. -->> if (pyroInstance.streamType == Pyro.STREAM_TYPE_PROXIED_PROGRESSIVE ['proxiedProgressive']) 
		* Indicates the current playing stream is beeing read as a simulated stream (proxied or handled by a middleware script such as python, php, etc...), usually delivered thru http or https. 
		* @see #STREAM_TYPE_TRUE_STREAM
		* @see #STREAM_TYPE_PROGRESSIVE
		* @see #streamType 
		* @see #timeOffset
		**/
		public static const STREAM_TYPE_PROXIED_PROGRESSIVE		:String				= "proxiedProgressive";
		
		/**
		* Used as streamType read-only property value. -->> if (pyroInstance.streamType == Pyro.STREAM_TYPE_TRUE_STREAM ['streamed']) 
		* Indicates the current playing stream is beeing read as a true stream (either rtmp, rtmps, etc...) delivered by a streaming server. 
		* @see #STREAM_TYPE_PROGRESSIVE
		* @see #STREAM_TYPE_PROXIED_PROGRESSIVE
		* @see #streamType 
		**/
		public static const STREAM_TYPE_TRUE_STREAM				:String				= "streamed";
		
		/**
		*	Indicates main pyro version beeing used. 
		*/		
		public static const VERSION								:String 			= "1.0.0";
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 ------------------------------------------------------------------------------------------------ >>
		*/
		
		/**
		* Toggles automatic video alignment when resizing occurs. Defaults to true.
		* @see #vAlignMode
		* @see #hAlignMode 
	 	* @see #forceResize 
		**/	
		public var autoAlign									:Boolean			= true;
		
		/**
		* Toggles video automatic start when a new stream is called. If set to true, video will start playing when buffer is sufficient.  Defaults to true.
		* @see #play
		* @see #onStreamStatus 
		**/
		public var autoPlay										:Boolean			= true;
		
		/**
		* Toggles automatic bufferTime readjustement if the video is playing over a slow connection. Defaults to true.
		* @see #checkBandwidth
		* @see #onStreamStatus 
		* @see #bufferTime 
		**/
		public var autoAdjustBufferTime							:Boolean			= true;
		
		/**
		* Toggles automatic resizing to actual video width and height when sufficient data gets in thru metadata. If width and height are not encoded in the metadata, video is kept at specified size. Defaults to false.  
		* @see #metadata
		* @see #onStreamStatus 
		**/
		public var autoSize										:Boolean			= false;
		
		/**
		* Stores if bandwitdth check was executed. Bandwidth check is executed only if checkBandwidth is set to true. Defaults to false.    
		* @see #checkBandwidth
		* @see #onStreamStatus 
		**/
		public var bandwidthCheckDone							:Boolean			= false;
		
		/**
		* Toggles if Pyro events bubble. Defaults to false.
		**/
		public var bubbleEvents									:Boolean 			= false;
		
		/**
		* Toggles if Pyro events are cancelable. Defaults to false. 
		**/
		public var cancelableEvents								:Boolean			= false;
		
		/**
		* Toggles if pyro's built-in checkBandwidth occurs.  
		* Stores its result in connectionSpeed property.  
		* Will also adjust bufferTime if autoAdjustBuferTime is set to true.
		* @see #connectionSpeed 
		* @see #bandwidthCheckDone
		* @see #autoAdjustBuferTime
		* @see #buffertTime  
		* @see #PyroEvent.BANDWIDTH_CHECKED 
		**/
		public var checkBandwidth								:Boolean			= true;	
		
		/**
		* Toggles mp4 encoded files to be called with the streamName formatted as -->> mp4:['file'] when streaming thru RTMP. Defaults to true. 
		* Leave out to true for yor pyro instance to take any possible format.  
		* Possible mp4 encoded formats are: '.mp4', ".mov", ".aac", ".3gp" and ".m4a".      
		*/
		public var forceMP4Extension							:Boolean 			= true;
		
		/**
		 * Sets the horizontal alignment mode. Possible values are:
		 * ALIGN_HORIZONTAL_LEFT -->> Aligns video (snapes to) to the left. 
		 * ALIGN_HORIZONTAL_CENTER -->> Aligns video to the center with equal gaps on both sides.
		 * ALIGN_HORIZONTAL_RIGHT -->> Aligns video (snaps to) to the right.
		 * 
		 * Horizontal alignments occurs only if video object is displayed at a smaller size than the specified (requiredWidth) width defined on instanciation. Defaults to to ALIGN_HORIZONTAL_CENTER.   
		 * @see #ALIGN_HORIZONTAL_LEFT
		 * @see #ALIGN_HORIZONTAL_CENTER
		 * @see #ALIGN_HORIZONTAL_RIGHT
		 * @see align
		*/		
		public var hAlignMode									:String				= Pyro.ALIGN_HORIZONTAL_CENTER;
		
		/**
		* Toggles if video keeps proportions on each resize. Ratio is based on original sizes if encoded in video's metadata. If not, ratio is based on specified size (requiredWidth, requiredHeight) defined on instanciation. Defaults to true
		*  
		* @see #adjustSize 
		* @see #checkForSize
		* @see #forceResize 
		* @see #scaleMode 
		* @see #PyroEvent.SIZE_UPDATE
		*/
		public var maintainAspectRatio							:Boolean			= true;
		
		/**
		 * Sets Pyro's main scaling parameter. The scale mode is usefull if videos are either to be shown to fill horizontal(16:9) or vertical(4:3) space. 
		 * Recalculated on each resize.
		 * Only taken in consideration if maintainAspectRatio is set to true. 
		 * @usage For exemple, if your video space is meant to always fill as  much horizontal space as possible, the SCALE_MODE_WIDTH_BASED needs to be used. 
		 * The contrary is true with SCALE_MODE_HEIGHT_BASED.
		 * Possible values are Pyro.SCALE_MODE_WIDTH_BASED, Pyro.SCALE_MODE_HEIGHT_BASED and Pyro.NO_SCALE
		 * @see #maintainAspectRatio
		 * @see #adjustSize
		 * @see #checkForSize
		 * @see #forceResize 
		 * @see #PyroEvent.SIZE_UPDATE
		*/		
		public var scaleMode									:String				= Pyro.SCALE_MODE_WIDTH_BASED;	
		
		/**
		 * Toggles if RTMP streams are called with dot [.] and extension name ['flv', 'mp4' etc..] inside the url.
		 * Defaults to true.
		*/		
		public var streamNameHasExtension						:Boolean			= true;		
		
		/**
		 * Toggles if application name prepends the fileName when streaming thru RTMP. Defaults to true, and usually should never be changed.
		*/	
		public var useDirectFilePath							:Boolean			= true;	
			
		// public var useVolumeCookie								:Boolean			= true;		
		
		/**
		 * Sets the vertical alignment mode. Possible values are:
		 * ALIGN_VERTICAL_TOP -->> Aligns video (snaps to) to the top. 
		 * ALIGN_VERTICAL_CENTER -->> Aligns video to the center with equal gaps on top and bottom.
		 * ALIGN_VERTICAL_BOTTOM -->> Aligns video (snaps to) to the bottom.
		 * 
		 * Vertical alignments occurs only if video object is displayed at a smaller size than the specified (requiredHeight) height defined on instanciation. Defaults to ALIGN_VERTICAL_CENTER.   
		 * @see #ALIGN_VERTICAL_TOP
		 * @see #ALIGN_VERTICAL_CENTER
		 * @see #ALIGN_VERTICAL_BOTTOM
		 * @see align
		*/	
		public var vAlignMode									:String				= Pyro.ALIGN_VERTICAL_CENTER;
		 	
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 ------------------------------------------------------------------------------------------------ >>
		*/
		
		protected var _backgroundColor							:Number 			= 0x000000;
		protected var _backgroundOpacity						:Number				= 1;
		protected var _bufferTime								:Number 			= 2;
		protected var _connectionSpeed							:String;
		protected var _cookie									:SharedObject;
		protected var _cuePoints								:Array				= new Array();
		protected var _duration									:Number				= 0;
		protected var _fullscreenRectangle						:Rectangle;
		protected var _fullscreenMode							:String				= Pyro.FS_MODE_SOFTWARE;
		protected var _hasCloseCaptions							:Boolean			= false;
		protected var _metadata									:Object				= new Object();
		protected var _metadataCheckOver						:Boolean			= false;
		protected var _metadataReceived							:Boolean			= false;
		protected var _muted									:Boolean			= false;
		protected var _nConnection								:NetConnection;
		protected var _nStream									:NetStream;
		protected var _requestedWidth							:Number				= 0;
		protected var _requestedHeight							:Number				= 0;
		protected var _ready									:Boolean 			= false;
		protected var _src										:String				= "";
		protected var _status									:String				= Pyro.STATUS_INITIALIZING;
		protected var _streamType								:String				= Pyro.STREAM_TYPE_PROGRESSIVE;
		protected var _timeOffset								:Number				= 0;
		protected var _urlDetails								:URLDetails;
		protected var _video									:Video;
		protected var _volume									:Number				= 1;
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 ------------------------------------------------------------------------------------------------ >>
		*/
		
		protected var checkSizeTimer							:Timer;
		protected var checkSizeFrequency						:Number 			= 50;
		protected var connectionReady							:Boolean			= false;
		protected var defaultVideoWidth							:Number				= 340;
		protected var defaultVideoHeight						:Number				= 280;
		protected var delayedPlayTimer							:Timer				= new Timer(100, 0);
		protected var dying										:Boolean			= false;
		protected var flushed									:Boolean			= false;
		protected var fullscreenMemoryObject					:Object				= new Object();
		protected var initTimer									:Timer				= new Timer(10, 1);
		protected var metadataCheckTimer						:Timer;	
		protected var metadataCheckFrequency					:Number				= 12000;
		protected var delayedPlay								:Boolean			= false;						
		protected var hasCompleted								:Boolean			= false;
		protected var isPaused									:Boolean			= false; 
		protected var playerRectangle							:Rectangle;
		protected var startTime									:Number;
		protected var stopped									:Boolean			= false;
		protected var temporarySizesOn							:Boolean			= false;
		protected var videoPropsValid							:Boolean			= false;
		protected var videoRectangle							:Rectangle;
		protected var volumeCache								:Number 			= 1;
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 ---------------------------CONSTRUCT------------------------------------------------------------ >>
		*/
		
		/**
		 * 
		 * @param _width -->> Pyro instance canvas width.
		 * @param _height -->> Pyro instance canvas height. 
		 * 
		 * Calling a new Pyro Instance only requires _width and _height as arguments if your video is meant to be boxed-in a restrained canvas. 
		 * Leaving _width parameter empty or null automatically sets autoSize to true.    
		 * Leaving _width and/or _height parameter(s) empty or null automatically sets _requested sizes to defaults sizes (_defVideoWidth, _defVideoHeight). 
		 * */					
		public function Pyro(_width:Number=undefined, _height:Number=undefined)
		{
			super();
			setStatus(Pyro.STATUS_INITIALIZING);
			if (isNaN(_width)) autoSize = true;
			_requestedWidth = !isNaN(_width) && _width > 0 ? _width : defaultVideoWidth;
			_requestedHeight = !isNaN(_height) && _height > 0 ? _height : defaultVideoHeight;
			
			playerRectangle = new Rectangle(0, 0, _requestedWidth, _requestedHeight);
			
			checkSizeTimer = new Timer(checkSizeFrequency, 0);
			metadataCheckTimer = new Timer(metadataCheckFrequency, 1);
			
			checkSizeTimer.addEventListener(TimerEvent.TIMER, checkForSize, false, 0, true);
			delayedPlayTimer.addEventListener(TimerEvent.TIMER, checkReadiness, false, 0, true);
			metadataCheckTimer.addEventListener(TimerEvent.TIMER_COMPLETE, metadataCheckDone, false, 0, true);
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
		}
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 									INITIALIZATION	
		 ------------------------------------------------------------------------------------------------ >>
		*/
		
		
		protected function addedToStage(evt:Event):void
		{
			if (this.hasEventListener(Event.ADDED_TO_STAGE)) removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			startInitTimer();
		}
		
		protected function startInitTimer():void
		{
			if (initTimer.hasEventListener(TimerEvent.TIMER_COMPLETE))
				initTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, initTimerDone);
				
			initTimer.addEventListener(TimerEvent.TIMER_COMPLETE, initTimerDone, false, 0, true);
			initTimer.start();
		}
		
		protected function initTimerDone(evt:TimerEvent):void
		{
			if (stage.stageWidth > 0 && stage.stageHeight > 0)
				initialize();
			else
				startInitTimer();
		}
		
		protected function initialize()
		{
			if (initTimer.running) initTimer.stop();
			if (initTimer.hasEventListener(TimerEvent.TIMER_COMPLETE)) initTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, initTimerDone);
			registerStageHandlers();
			
			if (_video && contains(_video)) removeChild(_video);
			_video = new Video(_requestedWidth, _requestedHeight);	
			addChild(_video);
			
			if (autoSize) _video.visible = false;
			_ready = true;
			setStatus(Pyro.STATUS_READY);
		}
		
		protected function registerStageHandlers():void
		{
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullscreenHandler, false, 0, true);
		}
		
		protected function checkReadiness(evt:TimerEvent):void
		{
			if (_ready)
			{
				if (delayedPlayTimer.running)
					delayedPlayTimer.stop();
					
				if (delayedPlayTimer.hasEventListener(TimerEvent.TIMER_COMPLETE)) delayedPlayTimer.removeEventListener(TimerEvent.TIMER, checkReadiness);
				play(_src);
			}	
				
		}
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 									DEATH and KILLING PROCESSES	
		 ------------------------------------------------------------------------------------------------ >>
		*/
		
		protected function removedFromStage(evt:Event):void
		{
			if (!dying)
				kill();
		}
		
		protected function kill():void
		{
			if (dying)
				return;
			
			dying = true;
			close();
			if (_video && contains(_video)) removeChild(_video);
			if (checkSizeTimer.running) checkSizeTimer.stop();
			if (metadataCheckTimer.running) metadataCheckTimer.stop();	
			if (delayedPlayTimer.running) delayedPlayTimer.stop();
			removeEventListeners();
			dying = false;
		}
		
		protected function removeEventListeners():void
		{
			if (stage.hasEventListener(FullScreenEvent.FULL_SCREEN)) stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullscreenHandler); 
  			if (hasEventListener(PyroEvent.SIZE_UPDATE)) removeEventListener(PyroEvent.SIZE_UPDATE, sizeChanged);
  			
			clearPipelineListeners(_nConnection);
			clearPipelineListeners(_nStream);
			
			if (hasEventListener(Event.ADDED_TO_STAGE)) removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			if (hasEventListener(Event.REMOVED_FROM_STAGE)) removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			if (delayedPlayTimer.hasEventListener(TimerEvent.TIMER_COMPLETE)) delayedPlayTimer.removeEventListener(TimerEvent.TIMER, checkReadiness);
			if (initTimer.hasEventListener(TimerEvent.TIMER_COMPLETE)) initTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, initTimerDone);
			if (metadataCheckTimer.hasEventListener(TimerEvent.TIMER_COMPLETE)) metadataCheckTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, metadataCheckDone);
		}
		
		protected function clearPipelineListeners(pipeline:*):void
		{
			if (pipeline is NetConnection)
			{
				try
				{
					if (_nConnection.hasEventListener(NetStatusEvent.NET_STATUS)) _nConnection.removeEventListener(NetStatusEvent.NET_STATUS, onConnStatus);
					if (_nConnection.hasEventListener(SecurityErrorEvent.SECURITY_ERROR)) _nConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
					if (_nConnection.hasEventListener(IOErrorEvent.IO_ERROR)) _nConnection.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	  				if (_nConnection.hasEventListener(AsyncErrorEvent.ASYNC_ERROR)) _nConnection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
				}
				catch(err:Error)
				{
					;
				}
			}	
			else if (pipeline is NetStream)
			{
				try
				{
					if (_nStream.hasEventListener(NetStatusEvent.NET_STATUS)) _nStream.removeEventListener(NetStatusEvent.NET_STATUS, onStreamStatus);
					if (_nStream.hasEventListener(IOErrorEvent.IO_ERROR)) _nStream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	  				if (_nStream.hasEventListener(AsyncErrorEvent.ASYNC_ERROR)) _nStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);	
				}
				catch(err:Error)
				{
					;
				}
			}	
		}
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 									  WORKFLOW	
		 ------------------------------------------------------------------------------------------------ >>
		*/
		
		/**  
		 * @param fileURL
		 * The play(url:String=null). Use the play() method to either connect to new streams by giving a URL(string) as argument, or to resume a paused stream by leaving out any arguments.
		*/		
		public function play(fileURL:String=null):void
		{
			if (!ready)
			{
				_src = fileURL;
				delayedPlayTimer.start();
				return;
			}
			
			resetInternalState();
			if (fileURL == null || fileURL == "")
			{
				if (connectionReady)
				{
					if (status == Pyro.STATUS_PAUSED)
					{
						setStatus(Pyro.STATUS_PLAYING);
						_nStream.togglePause();	
						dispatchEvent(new PyroEvent(PyroEvent.UNPAUSED, bubbleEvents, cancelableEvents));			
					}
				}
			}	
			else
			{	
				var localDetails:URLDetails = new URLDetails(fileURL);
					
				if (connectionReady)
				{
					if(urlDetails != null && localDetails.protocol != null)
					{
						if ((localDetails.streamName != urlDetails.streamName)) // || (localDetails.nConnURL=="") || (localDetails.nConnURL=="http:///"))
						{	
							setStatus(Pyro.STATUS_CONNECTING);
							_timeOffset = 0;
							connectionReady = false;
							reset(); 
							_src = fileURL;
							delayedPlay = true;
							this.initConnection(_src);
							return;
						}
					}
					
					_timeOffset = localDetails.startTime;
					
					reset();
					_nStream.play(fileURL);
					
					if (!autoPlay && this.timeOffset == 0) 
					{
						seek(0);
						pause(); 
					}
				}	
				else
				{
					reset();
					setStatus(Pyro.STATUS_CONNECTING);
					_timeOffset = localDetails.startTime;
					_src = fileURL;
					delayedPlay = true;
					this.initConnection(_src);
				}
			}			
		}
		
		protected function initConnection(urlString:String):void
		{
			this.setStatus(Pyro.STATUS_PENDING);
			
			close();
			_urlDetails = new URLDetails(urlString, useDirectFilePath, forceMP4Extension);
			
			if (_nConnection)
			{
				_nConnection.close();
				_nConnection = null;
				clearPipelineListeners(_nConnection);
			}	
			
			_nConnection = new NetConnection();
			_nConnection.addEventListener(NetStatusEvent.NET_STATUS, onConnStatus, false, 0, true);
        	_nConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
        	_nConnection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
        	_nConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler, false, 0, true);
        		
			switch (urlDetails.protocol)
			{
				case "http:/":
				case "https:/":
				case "httpd:/":
				case undefined:
				default:
				
				if (urlDetails.streamName.indexOf("?start=") > 0)
					_streamType = Pyro.STREAM_TYPE_PROXIED_PROGRESSIVE; 
				else
					_streamType = Pyro.STREAM_TYPE_PROGRESSIVE;
				
				
				break;
				
				case "rtmp:/":
				case "rtmps:/":
				_streamType = Pyro.STREAM_TYPE_TRUE_STREAM;
				
				break;		
			}
			
			setupConnection();
			dispatchEvent(new PyroEvent(PyroEvent.NEW_STREAM_INIT, bubbleEvents, cancelableEvents));
		}
		 
		protected function setupConnection():void
		{
			switch(streamType)
			{
				case Pyro.STREAM_TYPE_PROGRESSIVE:
				_timeOffset = 0;
				_nConnection.connect(null); 
				break;
				
				case Pyro.STREAM_TYPE_PROXIED_PROGRESSIVE:
				_timeOffset = urlDetails.startTime;
				_nConnection.connect(null); 
				break;
				
				case Pyro.STREAM_TYPE_TRUE_STREAM:
				_timeOffset = 0;
				_nConnection.connect(urlDetails.nConnURL); 
				break;
				
			}
		}
		
		protected function onConnStatus(evt:NetStatusEvent):void
		{
			switch (evt.info.code) 
            {
            	case "NetConnection.Call.Prohibited":
            	case "NetConnection.Call.BadVersion":
            	case "NetConnection.Call.Failed":
            	case "NetConnection.Connect.AppShutdown":
            	case "NetConnection.Connect.Closed":
            	case "NetConnection.Connect.Failed":
            	case "NetConnection.Connect.Rejected":
            	case "NetConnection.Connect.InvalidApp":
            	dispatchEvent(new ErrorEvent(ErrorEvent.CONNECTION_ERROR, evt.info.code, bubbleEvents, cancelableEvents));
            	break;
            	
                case "NetConnection.Connect.Success":
                setupStream();
                break;
            }
		}
		
		protected function setupStream():void
		{

			clearNetStream();
				
			_nStream = new NetStream(_nConnection);
			_nStream.client = this;
			_nStream.bufferTime = _bufferTime;
			_video.attachNetStream(_nStream);
			_nStream.soundTransform	= new SoundTransform(_volume, 0);
        	_nStream.addEventListener(NetStatusEvent.NET_STATUS, onStreamStatus, false, 0, true);
        	_nStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
       	 	_nStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler, false, 0, true);
       	 	connectionReady = true;
       	 	
       	 	if (delayedPlay) 
       	 	{
       	 		reset();
       	 		
       	 		switch (streamType)
       	 		{
       	 			case Pyro.STREAM_TYPE_PROGRESSIVE:
       	 			default:
       	 			play(urlDetails.rawURL);
       	 			adjustSize();
       	 			break;
       	 			
       	 			case Pyro.STREAM_TYPE_TRUE_STREAM:
       	 			play(urlDetails.streamName);
       	 			adjustSize(); 
       	 			break;
       	 		}
       	 		
       	 	}
       	 	
       	 	if (this.hasEventListener(PyroEvent.SIZE_UPDATE))
       	 		this.removeEventListener(PyroEvent.SIZE_UPDATE, sizeChanged);
       	 			
       	 	this.addEventListener(PyroEvent.SIZE_UPDATE, sizeChanged, false, 0, true);
		}
		
		protected function onStreamStatus(evt:NetStatusEvent):void
		{
			switch (evt.info.code) 
            {
	        	case "NetStream.Pause.Notify":
	        	if (_status != Pyro.STATUS_PAUSED) 
	        	{ 
	        		dispatchEvent(new PyroEvent(PyroEvent.PAUSED, bubbleEvents, cancelableEvents));
	        		setStatus(Pyro.STATUS_PAUSED);	
		       	}
            	break;
            	
                case "NetStream.Buffer.Empty":
				dispatchEvent(new PyroEvent(PyroEvent.BUFFER_EMPTY, bubbleEvents, cancelableEvents));
               	break;
                
                case "NetStream.Buffer.Full":
               	dispatchEvent(new PyroEvent(PyroEvent.BUFFER_FULL, bubbleEvents, cancelableEvents));
               
               	if (checkBandwidth && !bandwidthCheckDone) 
               	{
               		var connTime:Number = getTimer() - startTime;
               		var userBandwidth:Number = (1000 * _nStream.bytesLoaded / connTime) / 1024;
               		var buffer:Number = getBandwidth(_duration, 300, userBandwidth);
               		
               		if (buffer >= 20)
					{
						_connectionSpeed = Pyro.CONNECTION_SPEED_LOW;
						if (autoAdjustBufferTime) { _nStream.bufferTime = buffer; }	
					} 
					else
					{
						if (buffer >= 10)
						{
							_connectionSpeed = Pyro.CONNECTION_SPEED_MEDIUM;	
						}
						else
						{
							_connectionSpeed = Pyro.CONNECTION_SPEED_HIGH;
						}
						
					}
					
               		dispatchEvent(new PyroEvent(PyroEvent.BANDWIDTH_CHECKED, bubbleEvents, cancelableEvents));
               		bandwidthCheckDone = true;
               	}
               	break;
                
                case "NetStream.Buffer.Flush":
                flushed = true;
				dispatchEvent(new PyroEvent(PyroEvent.BUFFER_FLUSH, bubbleEvents, cancelableEvents));
				break;
				
                case "NetStream.Play.Complete":
                
                if (status != Pyro.STATUS_COMPLETED)
                {
	                dispatchEvent(new PyroEvent(PyroEvent.COMPLETED, bubbleEvents, cancelableEvents));
	                _status = Pyro.STATUS_COMPLETED;
                }
               	break;
                
                case "NetStream.Play.Reset":
                break;
                
                case "NetStream.Play.Start":
               	if(autoPlay) { setStatus(Pyro.STATUS_PLAYING); }
                startTime = getTimer();
                adjustSize();
                
                dispatchEvent(new PyroEvent(PyroEvent.STARTED, bubbleEvents, cancelableEvents));
                break;
                
                case "NetStream.Play.Stop":
                stopped = true;
                adjustSize();
                dispatchEvent(new PyroEvent(PyroEvent.STOPPED, bubbleEvents, cancelableEvents));
                break;
                              
                case "NetStream.Seek.Notify":
                if (status != Pyro.STATUS_STOPPED) { dispatchEvent(new PyroEvent(PyroEvent.SEEKED, bubbleEvents, cancelableEvents)); }
                break;

               	case "NetStream.Play.StreamNotFound":
               	setStatus(Pyro.STATUS_STOPPED);
               	dispatchEvent(new ErrorEvent(ErrorEvent.FILE_NOT_FOUND_ERROR, evt.info.code, bubbleEvents, cancelableEvents));
               	break;
               	
               	case "NetStream.Unpause.Notify":
                dispatchEvent(new PyroEvent(PyroEvent.UNPAUSED, bubbleEvents, cancelableEvents));
                break;
               	
               	case "NetStream.Play.NoSupportedTrackFound":
               	case "NetStream.Seek.Failed":
               	case "NetStream.Failed":
               	case "NetStream.Play.Failed":
               	case "NetStream.Play.FileStructureInvalid":
				case "NetStream.Play.InsufficientBW":
               	case "NetStream.Publish.BadName":
               	case "NetStream.Record.Failed":
               	dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, evt.info.code, bubbleEvents, cancelableEvents));
				break;	
					
				case "NetStream.Play.Switch":
               	break;
                	
               	case "NetStream.Publish.Idle":
                case "NetStream.Publish.Start":
                case "NetStream.Unpublish.Success":
                case "NetStream.Play.UnpublishNotify":
                case "NetStream.Play.UnpublishNotify":
               	case "NetStream.Record.Start":
               	case "NetStream.Record.NoAccess":
                case "NetStream.Record.Stop":
				break;
            }
            
            if(flushed && stopped)
            {
        		resetInternalState();
        		dispatchEvent(new PyroEvent(PyroEvent.COMPLETED, bubbleEvents, cancelableEvents));
            }
		}
		
		/*
		 * 	NetStream, NetConnection, connection and NetStream.client related methods.  
		*/
		
		protected function asyncErrorHandler(evt:AsyncErrorEvent):void 
		{
			reset(); 
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, "ASYNC_ERROR", bubbleEvents, cancelableEvents)); 
		}
		
		protected function ioErrorHandler(evt:IOErrorEvent):void 
		{ 
			reset();
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, "IO_ERROR", bubbleEvents, cancelableEvents)); 
		}
		
		protected function onCuePoint(infoObject:Object):void
		{
			dispatchEvent(new CuePointEvent(CuePointEvent.CUE_POINT_RECEIVED, infoObject, bubbleEvents, cancelableEvents));
		}
		
		public function onMetaData(info:Object, ...rest):void
		{
			_metadataReceived = true;
			_metadata = info;	
			if (rest) { _metadata['rest'] = rest; }
			if (info['duration']) { _duration = Number(info['duration']); }
			if (info['cuePoints']) { _cuePoints = info['cuePoints']; } 
			dispatchEvent(new PyroEvent(PyroEvent.METADATA_RECEIVED, bubbleEvents, cancelableEvents));
		}
		
		public function onTextData(textData:Object):void 
		{
			dispatchEvent(new TextDataEvent(TextDataEvent.TEXT_DATA_RECEIVED, textData, bubbleEvents, cancelableEvents));
		}
		
		public function onTransition(args:*, ...rest):void { }
		
		protected function securityErrorHandler(evt:SecurityErrorEvent):void { dispatchEvent(new ErrorEvent(ErrorEvent.SECURITY_ERROR, "SECURITY_ERROR", bubbleEvents, cancelableEvents)); }
		
		protected function clearNetStream():void
		{
			if (_nStream)
			{
				_nStream.soundTransform	= null;
				clearPipelineListeners(_nStream);
				_nStream.close();
				_nStream = null;
			}
		}
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 									metadata CHECK	
		 ------------------------------------------------------------------------------------------------ >>
		*/
		
		protected function metadataCheckDone(evt:TimerEvent):void { _metadataCheckOver = true; }
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 									SIZE HANDLING	
		 ------------------------------------------------------------------------------------------------ >>
		*/
		
		protected function adjustSize():void
		{	
			if (autoSize || (!autoSize && maintainAspectRatio))
			{
				if (!metadataReceived)
       	 		{
       	 			_video.visible = false;
       	 			if (!checkSizeTimer.running) 
       	 			{
       	 				if (this._src != null && this._src != "")
       	 				{
       	 					checkSizeTimer.start();
       	 					metadataCheckTimer.start();
       	 				}
       	 			}
       	 		}	
       	 		else
				{
					videoPropsValid = true;
					forceResize(metadata['width'], metadata['height'], maintainAspectRatio, scaleMode);		
				}
			}
			else
			{
				forceResize(_requestedWidth, _requestedHeight, maintainAspectRatio, scaleMode);
			}
		}
		
		public function align(e:*=null):void
		{
			if (videoWidth <= _requestedWidth)
			{
				switch (hAlignMode)
				{
					case Pyro.ALIGN_HORIZONTAL_CENTER:
					default:
					_video.x = ((_requestedWidth/2) - (video.width/2));
					break;
					
					case Pyro.ALIGN_HORIZONTAL_RIGHT:
					_video.x = (_requestedWidth - video.width);
					break;
					
					case Pyro.ALIGN_HORIZONTAL_RIGHT:
					_video.x = 0;
					break;	
				}
			}
			
			if (videoHeight <= _requestedHeight)
			{
				switch (vAlignMode)
				{
					case Pyro.ALIGN_VERTICAL_CENTER:
					default:
					_video.y = ((_requestedHeight/2)-(video.height/2));
					break;
					
					case Pyro.ALIGN_VERTICAL_BOTTOM:
					_video.y = (_requestedHeight - video.height);
					break;
					
					case Pyro.ALIGN_VERTICAL_TOP:
					_video.y = 0;
					break;
					
				}
			}
		}
	
		protected function checkForSize(evt:TimerEvent):void
		{
			if (metadataReceived)
			{
				if (metadata['width'] && metadata['height'])
				{
					forceResize(Number(metadata['width']), Number(metadata['height']), maintainAspectRatio, scaleMode);
					checkSizeTimer.stop();
					metadataCheckTimer.stop();
					_metadataCheckOver = false;
				}
				else
				{		
					temporarySizesOn = true;
					forceResize(_requestedWidth, _requestedHeight, maintainAspectRatio, scaleMode);
					metadataCheckTimer.stop();
					_metadataCheckOver = false;
				}					 
			}
			else
			{
				if (metadataCheckOver)
				{
					forceResize(_requestedWidth, _requestedHeight, maintainAspectRatio, scaleMode);
					checkSizeTimer.stop();
					metadataCheckTimer.stop();
					_metadataCheckOver = false;
					play();
				}
			}	
		} 
		
		public function forceResize(w:Number, h:Number, aspectRatio:Boolean, sMode:String):void
		{
			var localWidth:Number = w;
			var localHeight:Number = h;
			var scaleFactor:Number;
			
			var tWidth:Number;
			var tHeight:Number;
			
			if (checkSizeTimer.running) 
				checkSizeTimer.stop();
		
			if (metadataCheckOver)
			{
				if(metadataCheckTimer.running)
					metadataCheckTimer.stop();
			}
				
		
			if (autoSize && !temporarySizesOn || (!autoSize && aspectRatio) || (!autoSize && sMode==Pyro.SCALE_MODE_NO_SCALE))
			{
				if (_metadata['width'])   
				{	
					localWidth = Number(_metadata['width']);
					localHeight = Number(_metadata['height']);
				}
			}				
			
			if (autoSize || sMode == Pyro.SCALE_MODE_NO_SCALE)
			{
				if (metadataReceived)
				{
					_video.width = localWidth;
					_video.height = localHeight;
					dispatchEvent(new PyroEvent(PyroEvent.SIZE_UPDATE, this.bubbleEvents, this.cancelableEvents));
					if (autoAlign) { align(); }
					_video.visible = true;
					// return;
				}
			}	
				
			switch (sMode)
			{
				case Pyro.SCALE_MODE_WIDTH_BASED:
				default:
				if (aspectRatio)
				{
					if (metadataReceived)
					{	
						tWidth = _requestedWidth;
						tHeight = (localHeight * tWidth / localWidth);
						
						if (tHeight > _requestedHeight)
						{
							tHeight = _requestedHeight;
							tWidth = (localWidth * tHeight / localHeight);
						}
						_video.width = tWidth;
						_video.height = tHeight;
					}		
				}
				else
				{
					_video.width = _requestedWidth;
					_video.height = _requestedHeight;
				}
				break;
				
				
						
				case Pyro.SCALE_MODE_HEIGHT_BASED:
				if (aspectRatio)
				{
					if (metadataReceived)
					{	
						tHeight = _requestedHeight;
						tWidth = (localWidth * tHeight / localHeight);
						
						if (tWidth > _requestedWidth)
						{
							tWidth = _requestedWidth;
							tHeight = (localHeight * tWidth / localWidth);
						}
						_video.width = tWidth;
						_video.height = tHeight;
					}
				}	
				else
				{
					_video.width = _requestedWidth;
					_video.height = _requestedHeight;
				}		
				break;
				
				case Pyro.SCALE_MODE_NO_SCALE:
				break;
			}
			
			dispatchEvent(new PyroEvent(PyroEvent.SIZE_UPDATE, bubbleEvents, cancelableEvents));
			if (autoAlign) { align(); }
			_video.visible = true;
		}
		
		/**
		 * Resizes pyro instance properly. It is considered best practice to optimize resizing execution. Use desired width and height as arguments.
		 * Width and height properties are still available. Calling them simply repoints to the resize method. 
		 * Using the resize method ensures the video gets resized and realigned properly, depending on sizing and alignments settings used.       
		 * @param w 
		 * @param h
		 * 
		 */		
		public function resize(w:Number=undefined, h:Number=undefined):void 
		{
			if (!ready)
			{
				this._requestedWidth = w;
				this._requestedHeight = h;	
				return;
			}
			
			if ( (w == _video.width && h == _video.height)) 
			{
				return;
			}
			else
			{
				var dWidth:Number = _requestedWidth ? _requestedWidth : defaultVideoWidth;  
				_requestedWidth = !isNaN(w) && w > 0 ? w : dWidth;
				
				var forcedHeight:Number;
				
				if (isNaN(h))
				{
					if (Number(_metadata['width']))
					{ 
						_requestedHeight = Number(_metadata['height']);
					}
					else
					{
						var dHeight:Number = _requestedHeight ? _requestedHeight : defaultVideoHeight;
						_requestedHeight = dHeight;
					}	
				}
				else
				{
					_requestedHeight = h;
				}	
				
				adjustSize();	
			} 
		}
		
		public function fullscreenHandler(evt:*=null):void
		{
			if (stage.displayState != StageDisplayState.FULL_SCREEN)
			{
				if (fullscreenMode == Pyro.FS_MODE_HARDWARE)
				{
					_video.smoothing = fullscreenMemoryObject.smoothing;
					_video.deblocking = fullscreenMemoryObject.deblocking;
					_video.width = fullscreenMemoryObject.width;
					_video.height = fullscreenMemoryObject.height;
				}
			}
		}
		
		public function sizeChanged(evt:PyroEvent):void
		{
			videoRectangle = new Rectangle(this.x+this._video.x, this.y+this._video.y, this._video.width, this._video.height);
			playerRectangle = new Rectangle(this.x, this.y, this.width, this.height);
		}
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 									  PUBLIC CONTROLS
		 ------------------------------------------------------------------------------------------------ >>
		*/
		/**
		 * Kills the connection and clears all listebners. 
		*/	
		public function close():void
		{
			try
			{
				_nStream.pause();
				_nStream.seek(0);	
				_video.clear();
				_nStream.close();
				setStatus(Pyro.STATUS_CLOSED);
				this.clearPipelineListeners(_nConnection);
				this.clearPipelineListeners(_nStream);
				this.removeChild(_video)
				clearNetStream();
				this.addChild(_video);
			} 
			catch(e:Error) 
			{
				;
			}
		}
		
		/**
		 * Mutes volume. 
		 * @see volume
		*/		
		public function mute():void 
		{ 
			_muted = true;
			volumeCache = volume;
			volume = 0; 
			this.dispatchEvent(new PyroEvent(PyroEvent.MUTED, bubbleEvents, cancelableEvents));
		}
		
		/**
		 * Unmutes volume. 
		 * @see volume
		*/	
		public function unmute():void
		{
			if (_muted)
			{
				_muted = false;
				volume = volumeCache;
				this.dispatchEvent(new PyroEvent(PyroEvent.UNMUTED, bubbleEvents, cancelableEvents));
			}	
			
		}
		
		/**
		 * Pauses the stream, sets the status to PAUSED_STATUS and dispatches a PyroEvent.PAUSED event.
		 * @see PyroEvent.PAUSED
		 */	
		public function pause():void 
		{ 
			setStatus(Pyro.STATUS_PAUSED);
			_nStream.pause(); 
			dispatchEvent(new PyroEvent(PyroEvent.PAUSED, bubbleEvents, cancelableEvents));
		}
		
		/**
		 * Sets the playhead to desired time if possible. Be aware that files served as regular progressive downloads can not be seeked beyond their buffered zone. 
		 * @param offset
		 * 
		 */		
		public function seek(offset:Number):void 
		{ 
			_nStream.seek(offset); 
		}
		
		/**
		 * Pauses the stream and brings the playhead to 00:00:00.   
		 * 
		*/	
		public function stop():void 
		{
			setStatus(Pyro.STATUS_STOPPED);
			_nStream.pause();
			_nStream.seek(0);
		}
		
		/**
		 * Toggles volume muting.   
		 * 
		*/
		public function toggleMute():void
		{
			_muted ? unmute() : mute();
		}
		
		/**
		 * Toggles stream pausing and resuming.   
		 * 
		*/
		public function togglePause():void 
		{ 
			switch (_status)
			{
				case Pyro.STATUS_PAUSED:
				setStatus(Pyro.STATUS_PLAYING);
				dispatchEvent(new PyroEvent(PyroEvent.UNPAUSED, bubbleEvents, cancelableEvents));
				_nStream.togglePause();	
				break;
				
				case Pyro.STATUS_PLAYING:
				setStatus(Pyro.STATUS_PAUSED);
				dispatchEvent(new PyroEvent(PyroEvent.PAUSED, bubbleEvents, cancelableEvents));
				_nStream.togglePause();	
				break;		
			}
		}
		
		/**
		 * Toggles flash player state in between fullscreen and normal size. 
		 * Be aware that toggleFullScreen does not resize the video nor any ui asset dynamically. 
		 * 
		*/
		public function toggleFullScreen(e:*=null):void
		{
			if (stage.displayState == StageDisplayState.NORMAL)
			{
				if (fullscreenMode == Pyro.FS_MODE_HARDWARE)
				{
					fullscreenMemoryObject = {smoothing:_video.smoothing, deblocking:_video.deblocking, height:_video.height, width:_video.width};
					_video.smoothing = false;
					_video.deblocking = 0;
					// stage.fullScreenSourceRect = fullscreenRectangle;		
				}		
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
			}	
		}
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 									  PUBLIC ACCESSORS
		 ------------------------------------------------------------------------------------------------ >>
		*/
		
		public function get bufferLength():Number { return _nStream.bufferLength; }
		
		public function set bufferTime(bt:Number):void 
		{ 
			_bufferTime = bt;
			if (_nStream != null)
				_nStream.bufferTime = bt; 
		}
		public function get bufferTime():Number { return _bufferTime; }
		public function get bytesLoaded():Number 
		{ 
			if (_nStream != null)
			{
				if (_nStream.bytesLoaded)
					return _nStream.bytesLoaded;
				else
					return 0;
			}
			else
			{
				return 0;
			}
		}
		
		public function get connectionSpeed():String { return _connectionSpeed; }
		public function get cuePoints():Array { return _cuePoints; }
		
		public function get currentStageRect():Rectangle { return new Rectangle(this.x, this.y, this.height, this.width); }
		
		public function set deblocking(deb:int):void 
		{ 
			_video.deblocking = deb;
		}
		public function get deblocking():int { return _video.deblocking; }
		
		public function get duration():Number { return _duration; }
		
		public function get formattedDuration():String { return formatTime(_duration); }
		public function get formattedTimeRemaining():String { return formatTime(timeRemaining); }
		public function get formattedTime():String 
		{
			if (_nStream != null)
			{
				if (_nStream.time)
					return formatTime(_nStream.time+this.timeOffset);
				else
					return formatTime(0);
			}
			else
			{
				return formatTime(0);
			}	 
		}
		
		public function set fullscreenMode(fsMode:String):void
		{
			switch (fsMode)
			{
				case Pyro.FS_MODE_SOFTWARE:
				default:
				_fullscreenMode = Pyro.FS_MODE_SOFTWARE;
				break;
				
				case Pyro.FS_MODE_HARDWARE:
				_fullscreenMode = Pyro.FS_MODE_HARDWARE; 
				if (Capabilities.hasVideoEncoder)
				{
					_fullscreenMode = Pyro.FS_MODE_HARDWARE; 
				}		
				else
				{
					_fullscreenMode = Pyro.FS_MODE_SOFTWARE;
				}
			}
		}
		
		public function get fullscreenMode():String { return _fullscreenMode; }
		
		public function get fullscreenRectangle():Rectangle 
		{ 
			if (_fullscreenRectangle)
			{
				return _fullscreenRectangle;
			}
			else
			{
				return this.videoRectangle;
			}
		}
		
		public function set fullscreenRectangle(rect:Rectangle):void { _fullscreenRectangle = rect; }
		
		public function get loadRatio():Number 
		{
			if (_nStream != null)
			{
				if (_nStream.bytesLoaded && _nStream.bytesTotal)
					return _nStream.bytesLoaded / _nStream.bytesTotal; 
				else
					return 0;
			}
			else
			{
				return 0;
			}	 
		}
		
		
		public function get metadata():Object { return _metadata; }
		public function get metadataReceived():Boolean { return _metadataReceived; }
		public function get metadataCheckOver():Boolean { return _metadataCheckOver; }
		
		public function get muted():Boolean { return _muted; }

		public function get netConnection():NetConnection  { return _nConnection; }
		public function get netStream():NetStream { return _nStream; }
		
		public function get progressRatio():Number 
		{ 
			if (_nStream != null)
			{
				if (_nStream.time && _duration)
					return ((_nStream.time+_timeOffset) / _duration); 
				else
					return 0;
			}
			else
			{
				return 0;
			}
		} 
		
		public function get ready():Boolean { return _ready; }
		
		public function set smoothing(sm:Boolean):void { _video.smoothing = sm; }
		public function get smoothing():Boolean { return _video.smoothing; }
		
		public function get source():String { return _src; }
		public function get streamType():String { return _streamType; }
		
		public function get status():String { return _status; }
		
		public function get time():Number 
		{ 
			if (_nStream != null)
			{
				if (_nStream.time)
					return (Number(_nStream.time)+Number(this.timeOffset)); 
				else
					return 0;
			}
			else
			{
				return 0;
			}
		}
		
		public function get timeOffset():Number { return _timeOffset; }
		
		public function get timeRemaining():Number 
		{ 
			if (_nStream != null)
			{
				if (_nStream.time && _duration)
					return (_duration - ( Number(_nStream.time)+Number(_timeOffset)) );
				else
					return 0;
			}
			else
			{
				return 0;
			}  
		}
		
		public function get urlDetails():URLDetails { return _urlDetails; }
		
		public function get video():Video { return _video; }			
		public function get videoHeight():Number { return _video.height; }
		public function set videoHeight(h:Number):void 
		{ 
			if (h>0 && !checkSizeTimer.running) 
			{
				video.height = h;
				dispatchEvent(new PyroEvent(PyroEvent.SIZE_UPDATE, bubbleEvents, cancelableEvents));	
				if (autoAlign) { align(); }
			} 
		}
		
		public function get videoWidth():Number { return _video.width; }			
		public function set videoWidth(w:Number):void
		{
			if (w>0 && !checkSizeTimer.running)
			{
				video.width = w;	
				dispatchEvent(new PyroEvent(PyroEvent.SIZE_UPDATE, bubbleEvents, cancelableEvents));	
				if (autoAlign) { align(); }
			}
		}
		
		public function set volume(vol:Number):void 
		{ 
			_volume = vol;
			if (connectionReady) { _nStream.soundTransform = new SoundTransform(vol, 0); }
			this.dispatchEvent(new PyroEvent(PyroEvent.VOLUME_UPDATE, bubbleEvents, cancelableEvents));
		}
		
		public function get volume():Number { return _volume; }
		
		override public function get width():Number { return _requestedWidth; }
		override public function set width(w:Number):void { resize(w, _requestedHeight); }
		override public function get height():Number { return _requestedHeight; }
		override public function set height(h:Number):void { resize(_requestedWidth, h); }
		
		/*
		 ------------------------------------------------------------------------------------------------ >>
		 									  INTERNAL STUFF	
		 ------------------------------------------------------------------------------------------------ >>
		*/
		
		public function formatTime(timeCue:Number):String
		{
			var minutes:String = String(Math.floor(timeCue / 60)).length > 1 ? String(Math.floor(timeCue / 60)) : "0"+String(Math.floor(timeCue / 60));
			var seconds:String = String(Math.floor(timeCue%60)).length > 1 ? String(Math.floor(timeCue%60)) : "0"+String(Math.floor(timeCue%60));
			return minutes + ":"+ seconds;
		}
		
		protected function getBandwidth(flvLength:Number, flvBitrate:Number, bandwidth:Number):Number
		{	
			var bt		:Number;
			var padding	:Number = 6;
			
			flvBitrate > bandwidth ? bt = Math.ceil(flvLength - flvLength/(flvBitrate/bandwidth)) : bt = 0;	
			bt += padding;
			if(bt > 30) bt = 20;
			
			return bt;
		}
		
		
		protected function reset():void
		{
			resetInternalState();
			
			hasCompleted		= false;
			_duration			= 0;
			_metadata			= new Object();
			_metadataReceived	= false;
		}
		
		protected function resetInternalState():void
		{
			flushed = stopped = false;
		}
		
		protected function setStatus(st:String):void
		{
			_status = st;
			dispatchEvent(new StatusUpdateEvent(StatusUpdateEvent.STATUS_UPDATE, _status, bubbleEvents, cancelableEvents));
		}
		
		
	}
}

import ca.turbulent.media.Pyro;

internal class URLDetails
{
	
	public var info					:Object = new Object();
	public var isRelative			:Boolean = false;
	public var isRTMP				:Boolean = false;
	public var appName				:String = "";
	public var rawURL				:String = "";
	public var startTime			:Number = 0;
	public var protocol				:String = "";
	public var nConnURL				:String = "";
	public var serverName			:String = "";
	public var streamName			:String = "";
	public var portNumber			:String = ""; 
	public var wrappedURL			:String = "";
	
	public function URLDetails(url:String, useDirectFilePath:Boolean=false, forceMP4Extension:Boolean=true, hasExtension:Boolean=true):void
	{
        rawURL 				= url;												
        info 				= URLDetails.parseURL(url, useDirectFilePath, forceMP4Extension, hasExtension);
        appName 			= info.appName;
        protocol 			= info.protocol;			
        serverName 			= info.serverName; 
        isRelative			= info.isRelative;
        isRTMP				= info.isRTMP; 
        portNumber			= info.portNumber;
        wrappedURL			= info.wrappedURL;
        streamName			= info.streamName;
        startTime			= info.startTime;
        nConnURL			= info.nConnURL;
        
        if (!portNumber && portNumber != "")
        	nConnURL			= protocol+"/"+serverName+"/"+appName;
        else
        	nConnURL			= protocol+"/"+serverName+":"+portNumber+"/"+appName+"/";
	}
	
	public static function parseURL(url:String, useDirectFilePath:Boolean=false, forceMP4Extension:Boolean=true, hasExtension:Boolean = true):Object 
	{
		var parseResults:Object = new Object();
			
		// get protocol
		var startIndex:Number = 0;
		var endIndex:Number = url.indexOf(":/", startIndex);
		
		if (endIndex >= 0) 
		{
			endIndex += 2;
			parseResults.protocol = url.slice(startIndex, endIndex);
			parseResults.isRelative = false;
		}
		else 
		{
			parseResults.isRelative = true;
		}
		
		if (parseResults.protocol != undefined &&
		     ( parseResults.protocol == "rtmp:/" ||
		       parseResults.protocol == "rtmpt:/" ||
		       parseResults.protocol == "rtmps:/") )
		{
			parseResults.isRTMP = true;
			startIndex = endIndex;

			if (url.charAt(startIndex) == '/') 
			{
				startIndex++;
				// get server (and maybe port)
				var colonIndex:Number = url.indexOf(":", startIndex);
				var slashIndex:Number = url.indexOf("/", startIndex);
				
				if (slashIndex < 0) 
				{
					if (colonIndex < 0) 
					{
						parseResults.serverName = url.slice(startIndex);
					} 
					else 
					{
						endIndex = colonIndex;
						parseResults.portNumber = url.slice(startIndex, endIndex);
						startIndex = endIndex + 1;
						parseResults.serverName = url.slice(startIndex);
					}
					return parseResults;
				}
				
				if (colonIndex >= 0 && colonIndex < slashIndex) 
				{
					endIndex = colonIndex;
					parseResults.serverName = url.slice(startIndex, endIndex);
					startIndex = endIndex + 1;
					endIndex = slashIndex;
					parseResults.portNumber = url.slice(startIndex, endIndex);
				} 
				else 
				{
					endIndex = slashIndex;
					parseResults.serverName = url.slice(startIndex, endIndex);
				}
				startIndex = endIndex + 1;
			}

			// handle wrapped RTMP servers bit recursively, if it is there
			if (url.charAt(startIndex) == '?') 
			{
				var subURL:String = url.slice(startIndex + 1);
				var subParseResults:Object = parseURL(subURL);
				if (subParseResults.protocol == undefined || !subParseResults.isRTMP) 
				{
					// throw new VideoError(VideoError.INVALID_CONTENT_PATH, url);
				}
				parseResults.wrappedURL = "?";
				parseResults.wrappedURL += subParseResults.protocol;
				
				if (subParseResults.serverName != undefined) 
				{
					parseResults.wrappedURL += "/";
					parseResults.wrappedURL +=  subParseResults.serverName;
				}
				
				if (subParseResults.wrappedURL != undefined) 
				{
					parseResults.wrappedURL += "/?";
					parseResults.wrappedURL +=  subParseResults.wrappedURL;
				}
				
				parseResults.appName = subParseResults.appName;
				parseResults.streamName = subParseResults.streamName;
				return parseResults;
			}
			
			// get application name
			endIndex = url.indexOf("/", startIndex);
			if (endIndex < 0) 
			{
				parseResults.appName = url.slice(startIndex);
				return parseResults;
			}
			
			parseResults.appName = url.slice(startIndex, endIndex);
			startIndex = endIndex + 1;

			// check for instance name to be added to application name
			endIndex = url.indexOf("/", startIndex);
			if (endIndex < 0) 
			{
				parseResults.streamName = url.slice(startIndex);
				// strip off .flv if included
				if (!hasExtension && ((parseResults.streamName.slice(-4).toLowerCase() == ".flv") || (parseResults.streamName.slice(-4).toLowerCase() == ".mp4"))) 
				{
					parseResults.streamName = parseResults.streamName.slice(0, -4);
				}
				return parseResults;
			}
			parseResults.appName += "/";
			parseResults.appName += url.slice(startIndex, endIndex);
			startIndex = endIndex + 1;
				
			// get flv name
			parseResults.streamName = url.slice(startIndex);
			// strip off .flv if included
			
			if (useDirectFilePath)
			{
				var sNameArray:Array = String(parseResults.streamName).split("/");
				if (sNameArray.length > 1)
				{
					for (var i:Number=0; i<sNameArray.length-1; ++i)
					{
						parseResults.appName = parseResults.appName + "/" + sNameArray[i];
					}
					parseResults.streamName = sNameArray[sNameArray.length-1];
				}
			}
			
			
			if (forceMP4Extension)
			{
				var sName:String = parseResults.streamName;
				var ext:String = sName.substr(-4).toLowerCase();
				if(ext == '.mp4' || ext == ".mov" || ext == ".aac" || ext == ".m4a" || ext == ".3gp")
				{
					parseResults.streamName = 'mp4:'+sName.substr(0, sName.length-4);
				}
			}

			
			if (!hasExtension && ((parseResults.streamName.slice(-4).toLowerCase() == ".flv") || (parseResults.streamName.slice(-4).toLowerCase() == ".mp4"))) 
			{
				parseResults.streamName = parseResults.streamName.slice(0, -4);
			}
	
		} 
		else 
		{
			// HTTP PROTOCOL
			parseResults.isRTMP = false;
			parseResults.streamName = url;
			parseResults.appName = "";
			parseResults.serverName = ""; 
        	parseResults.isRTMP	= false; 
        	parseResults.wrappedURL	= "";
        	parseResults.startTime = 0;			
			parseResults.nConnURL = "";
			startIndex = url.indexOf("start=");			
			
			if (startIndex > 0)
			{
				startIndex += 6;
				parseResults.startTime = Number(url.substring(startIndex));
			}
			else
			{
				parseResults.startTime = 0;	
			}
		}	
		return parseResults;
	}
}