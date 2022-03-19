s.waitForBoot({

/*Setup of  variables */
var mainWindow, additiveWindow, phone, phoneScreen, phoneKeyboard,phoneControl, buttonArray, playButton, jingleButton;
var funPrintText;
var space = 0, counterNumbers = 0;
var number = Array.new(10);

Window.closeAll;
GUI.current;

/*Setup of SyntDef*/
SynthDef(\ring, {
	arg freq = 44, amp = 0.1;
	var env, snd;
	snd = EnvGen.kr(Env.new([1,0.7,0.8,0],[0.1,0.1,0.2,0.1]), doneAction: 2) * LFPulse.ar(freq,0,mul:0.3);
	Out.ar(0, snd*0.5);
	Out.ar(1, snd*0.5);
	}
).add;

/*Setup of Functions*/
funPrintText = {
		arg numberToPrint,viewPrint;
		TextView(viewPrint,Rect(0,viewPrint.bounds.top/2 +25,viewPrint.bounds.width, viewPrint.bounds.height,))
		.string_(numberToPrint.asString)
		.editable_(false)
		.font_(Font("Artifakt Element Light",30))
		.background_(Color.cyan)
		.front;
	};

/*Setup of Routine*/

/*Initialization of window components*/

//Main Window//
mainWindow = Window.new("Fourier's phone - Additive Synthesis",Rect(Window.screenBounds.width/2 - 750,Window.screenBounds.height/2 -300,500,700))
	.alwaysOnTop_(true)
	.background_(Color.black)
	.front;

/*CLOSE ALL AND STOP ALL*/
mainWindow.onClose = {
		Server.freeAll;
		additiveWindow.close;
		"Bye Bye!".postln
};
CmdPeriod.doOnce({mainWindow.close});

//Phone//
phone = CompositeView.new(mainWindow,Rect(10,10,mainWindow.bounds.width - 20,mainWindow.bounds.height - 20))
	.background_(Color.grey);
StaticText.new(phone,Rect(phone.bounds.width/4,0,300,100)).string_("NOCHIA 2022").font_(Font("Artifakt Element Light",40));

//Phone screen //
phoneScreen = CompositeView.new(phone,Rect(40,80,400,200)).background_(Color.cyan);

/*-----------------------------------------------------------------------------------*/
/* INITIALIZATION OF THE PHONE NUMBER LINE
TextView(phoneScreen,Rect(0,phoneScreen.bounds.top/2 +25,phoneScreen.bounds.width, phoneScreen.bounds.height,))
	.string_(number.asString)
	.editable_(false)
	.font_(Font("Artifakt Element Light",30))
	.background_(Color.cyan)
	.front;
	*/
	funPrintText.value(number,phoneScreen);
/*-----------------------------------------------------------------------------------*/

//Setup of the viewa of the phone//
phoneControl = CompositeView.new(phone,Rect(40,300,400,70)).background_(Color.new255(50,50,50));
phoneKeyboard = CompositeView.new(phone,Rect(40,370,400,250)).background_(Color.black);
phoneKeyboard.decorator = FlowLayout(phoneKeyboard.bounds, margin: 40@20, gap: 5@5 );

//Setup of the buttons of the phone//
playButton = Button(phoneControl, Rect(40,10,100,50)).font_(Font("Artifakt Element Light",10))
	.states_([
		["PLAY", Color.black,Color.green],
		["STOP",Color.black, Color.red]
	]);

jingleButton = Button(phoneControl, Rect(250,10,100,50))
	.font_(Font("Artifakt Element Light",10))
	.states_([
		["PLAY JINGLE", Color.black],
		["STOP JINGLE",Color.black, Color.cyan]
	]);

buttonArray = Array.fill(12, {Button(phoneKeyboard, 100@50)});

/* Setup Actions of Buttons */

buttonArray.do({
		arg me, count;
		me.states = [
			[(count+1).asString, Color.black],
			[(count+1).asString, Color.black]
		];
		if(count == 9, {me.states_([["*"]])});
		if(count == 10, {me.states = [["0"]]});
		if(count == 11, {me.states = [["#"]]});
		me.font_(Font("Artifakt Element Light",20));
});

buttonArray.do({
		arg me, count;
		me.mouseDownAction_({
			if( ((count != 9) && (count != 11)),{a = Synth(\ring, [\freq,70+(50*me.string.asInteger)])})
		})
		.action_({ arg me;
			playButton.value_(0);
			if( (counterNumbers < 10) && (me.string != "*") && (me.string != "#") ,
				{
				number.add(me.string.asInteger);
				funPrintText.value(number,phoneScreen);
				counterNumbers = counterNumbers+1;

			});
			if( (me.string == "#")&&(counterNumbers>0),{
				counterNumbers = counterNumbers-1;
				number.removeAt(counterNumbers);
				funPrintText.value(number,phoneScreen);
			});

		});

	});

playButton.action_({
		arg me;
		if((me.value == 1) && (number.size > 0),
			{
				mainWindow.visible_(false);
				additiveWindow = Window.new("Additive Synthesis",Rect(Window.screenBounds.width/3 + 10,mainWindow.bounds.top + 30,900,700))
				.alwaysOnTop_(true)
				.background_(Color.yellow)
				.front;
			},{if((me.value == 0) && (number.size > 0), {additiveWindow.close;})}
		);

	});

"Additive Synthesis Demo Starts".postln;

});


