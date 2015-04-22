**Getting ready to use Pyro in various contexts.**

You can use Pyro in a few different contexts lets examine which ones and how to set up Pyro so that you dont get errors popping everywhere.


It doesnt matter if your using FlexBuilder, Eclipse, the Flash IDE itself, Flash Develop or TextMate, or a combination of the Flash IDE and external files, Pyro works the same.<br><br>

First, start by either checking out the SVN version, or by downloading the package, that sure will help a lot ;).<br>

Now, set up your classpath references so that you can import our ca.turbulent.media package easily.<br>
<br>
Also, I'd like to mention that <b>you absolutely need to know how to code Actionscript, and AS3 more specifically</b>. If you dont know how to program AS3 and don't have a clue of what I'm talking about in the following explanations, use another flash video player such as JW player. I'm not here to show anyone how to code or setup AS projects. Not that I'm elitist in anyways, I just didn't build Pyro in the purpose of showing how actionscript works.<br>
<br>
<br><br>
<b>1) Flash IDE - actionscript AS3 projects</b><br>
This covers the vast majority of Pyro usage. Its the most sought after use for a class like this one.<br>
<br>
First, I'll demonstrate how to use a Pyro.as class instance inside your classes. (Later down the road, how to extend the Pyro class will be tackled).<br>
<br>
We will be building a small class named PyroExemple (as a flash.display.Sprite extension) just as a theoric exemple.<br>
<br>
So without further adue, here it goes:<br>
<br>
<pre><code>package<br>
{<br>
   import ca.turbulent.media.Pyro;<br>
   import flash.display.Sprite;<br>
<br>
   public class PyroExemple extends Sprite<br>
   {<br>
      public var pyroInstance:Pyro;<br>
<br>
      public function PyroExemple()<br>
      {<br>
         pyroInstance = new Pyro(640, 480);<br>
         addChild(pyroInstance);<br>
      }<br>
<br>
      public function playVideoURL(url:String):void<br>
      {<br>
         pyroInstance.play(url);<br>
      }<br>
<br>
   }<br>
}<br>
</code></pre>

That's pretty much it for starters... Now that was easy wasn't it ? :)<br>
<br>
In the above PyroExemple class, we first instanciate pyroInstance with a width of 640 and a height of 480. Those set the dimensions of the canvas the video is boxed-in.<br>
In order to load and play a new video file, one would call the playVideoURL method with the targetted url as param. All that function does is call Pyro's omnipotent play method with the url. If the specified file exists and is a playable video format for flash, your video should be playing.<br>
<br><sub>Yes this method is totally superfluous, you could just call Pyro's play method directly. Its an exemple, just so you start.</sub>

Now there is a lot more to Pyro, but this just the getting started section, and we've done just that.<br>
<br>
If all you are doing is pure actionscript/flash projects without doing any Flex, nor will you be using 3D frameworks (or other weird tentacular frameworks), you might want to skip whats coming and carry on to other topics.<br>
<br>
<br><br><br>

<b>2) Using Pyro in flex</b><br>
Now for Flex, there is quite a few ways you can embed Pyro, however, I recommend wrapping a component around your Pyro instance. Here is how I would code such a thing, lets call it our PyroML.mxml component:<br>
<br>
<pre><code>&lt;?xml version="1.0" encoding="utf-8"?&gt;<br>
&lt;mx:UIComponent xmlns:mx="http://www.adobe.com/2006/mxml" creationComplete="insertPyroInstance()"&gt;<br>
	<br>
	&lt;mx:Script&gt;<br>
		&lt;![CDATA[<br>
		<br>
			import ca.turbulent.media.Pyro;<br>
			import ca.turbulent.media.events.PyroEvent;<br>
			<br>
			public var pyro	:Pyro;<br>
			<br>
			public function insertPyroInstance(e:*=null):void<br>
			{<br>
				pyro = new Pyro(width, height);<br>
				pyro.killOnRemoval = false;<br>
				this.addChild(pyro);<br>
			}	<br>
			<br>
		]]&gt;<br>
	&lt;/mx:Script&gt;<br>
	<br>
&lt;/mx:UIComponent&gt;<br>
</code></pre>

Notice the usage of pyro property <b>killOnRemoval</b>. This is usefulll if you use states mechanics. If left to its default true value, you will end up killing your pyro instance everytime you leave a state that contains a PyroML in its hierarchy.<br>
I strongly recommend setting <b>pyroInstance.killOnRemoval=false</b> whenever your dealing with Flex integration.<br>
<br>
<br><br><br>

<b>3) Using a pyro instance as material in 3D frameworks such as Away3D or Papervision</b><br>
I'm not going to show you how to build video materials for 3d frameworks, that has been covered plenty of times on many sites. Knowing Pyro is a flash.display.Sprite extension should be enough for anyone with proper knowledge of how materials work to know what to do here.<br>
<br>
What you need to know about is the stageEventMechanics property. Pyro has stage listeners set up here and there, and if left in action, will cause a crash at runtime or at compile time. Luckily, this is easy to circumvent.<br>
<br>
Pyro's constructor holds a 3rd parameter that toggles stage listeners on and off, so on instanciation do the following to prevent stage Events activity inside Pyro:<br>
<br>
<pre><code>pyroInstance = new Pyro(640, 480, Pyro.STAGE_EVENTS_MECHANICS_ALL_OFF);<br>
</code></pre>

Voilà, you should have a Pyro instance ready to be set as a material. Rendering should work a-ok.<br>
<br><br><br>
<b>Documentation</b><br>
The online, not finished but pretty complete, docs is live on my personal site located at:<br>
<a href='http://gronour.com/pyro/doc/html/index.html'>http://gronour.com/pyro/doc/html/index.html</a>
<br>You will also find this documentation in the downloadable zip package and under version control.<br>
<br><br>


