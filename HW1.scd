/*
TODO:
- Jingle window
- Fix the pattern
- Put the values in the knobs
*/
s.waitForBoot({

/*Setup of  variables */
var mainWindow, additiveWindow, phone, phoneScreen, phoneKeyboard,phoneControl, buttonArray, playButton, jingleButton;
var funPrintText, funPrintKnobText;
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

SynthDef(\addsynth, {
			arg freq = 440, amp = 0.1, att = 0.01, dec = 0.3, rel = 1;
			var snd, env, gate = 1,sus = 0.5;
			env = EnvGen.ar(Env.adsr(att, dec, sus, rel), gate, doneAction: 2);
			snd = SinOsc.ar(freq, 0, amp) * env;
			Out.ar(0, snd!2);
		}).add;

/*Setup of Functions*/

//Funzione che stampa il numero di telefono nello schermo
funPrintText = {
		arg numberToPrint,viewPrint;
		TextView(viewPrint,Rect(0,viewPrint.bounds.top/2 +25,viewPrint.bounds.width, viewPrint.bounds.height))
		.string_(numberToPrint.asString)
		.editable_(false)
		.font_(Font("Artifakt Element Light",34))
		.background_(Color.cyan)
		.front;
	};
//Funzione che stampa staticamente il nome delle variabili delle sinusoidi
funPrintKnobText = {
		arg viewPrint;
		TextView(viewPrint,Rect(0,0,400,30))
		.string_("Value1      Value2       Value3       Value4      Value5")
		.editable_(false)
		.font_(Font("Artifakt Element Light",15))
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
		"Bye Bye!".postln
};
CmdPeriod.doOnce({mainWindow.close});

//Phone//
phone = CompositeView.new(mainWindow,Rect(10,10,mainWindow.bounds.width - 20,mainWindow.bounds.height - 20))
	.background_(Color.grey);
StaticText.new(phone,Rect(phone.bounds.width/4,0,300,100)).string_("NOCHIA 2022").font_(Font("Artifakt Element Light",40));

//Phone screen//
phoneScreen = CompositeView.new(phone,Rect(40,80,400,200)).background_(Color.cyan);

//INITIALIZATION OF THE PHONE NUMBER LINE//
funPrintText.value(number,phoneScreen);


//Setup of the view of the phone//
phoneControl = CompositeView.new(phone,Rect(40,300,400,70)).background_(Color.new255(50,50,50));
phoneKeyboard = CompositeView.new(phone,Rect(40,370,400,250)).background_(Color.black);
phoneKeyboard.decorator = FlowLayout(phoneKeyboard.bounds, margin: 40@20, gap: 5@5 );

//Setup of the buttons of the phone//
playButton = Button(phoneControl, Rect(40,10,100,50)).font_(Font("Artifakt Element Light",10))
	.states_([
		["", Color.black],
		["", Color.black]
	]);

jingleButton = Button(phoneControl, Rect(250,10,100,50))
	.font_(Font("Artifakt Element Light",10))
	.states_([
		["", Color.black],
		["",Color.black]
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
});//End of buttonarray.do

buttonArray.do({
		arg me, count;
		me.mouseDownAction_({
			if( ((count != 9) && (count != 11)),{a = Synth(\ring, [\freq,70+(50*me.string.asInteger)])})
		})
		.action_({
			arg me;
			playButton.value_(0);
			if( (counterNumbers < 10) && (me.string != "*") && (me.string != "#") ,
				{
				number.add(me.string.asInteger);
				funPrintText.value(number,phoneScreen);
				counterNumbers = counterNumbers+1;
				}
			);
			if( (me.string == "#")&&(counterNumbers>0),
				{
					counterNumbers = counterNumbers-1;
					number.removeAt(counterNumbers);
					funPrintText.value(number,phoneScreen);

				}
			);
			if( (number.size>0),
				{
					playButton.states_([["PLAY", Color.black,Color.green],["PLAY", Color.black,Color.red]]);
					jingleButton.states_([["PLAY JINGLE", Color.black],["STOP JINGLE",Color.white, Color.red]]);
				},
				{
					playButton.states_([["", Color.black],["", Color.black]]);
					jingleButton.states_([["", Color.black],["",Color.white]]);
				}
			);
		});
});//End of buttonArray.do.action

playButton.action_({
		arg me;
		//Setup of variables //
		var displayKnobs, displayButtons, knobMatrix, buttonsWave, numKnob = 1;
		var notesArray = Array.newClear(number.size);

		//Setup of the plots//
		s.freqscope;
		s.scope;

		if((me.value == 1) && (number.size > 0),
			{
				//Make the phone invisible//
				mainWindow.visible_(false);

				//Setup of the number of knobs (they depend by the size of the phone number)//
				numKnob = number.size;

				//Setup of the additive Window //
				additiveWindow = Window.new("Additive Synthesis",Rect(1000,200,500,60*numKnob + 50))
				.alwaysOnTop_(true)
				.background_(Color.new255(50,50,50))
				.front;

				//Setup of the display that contains the knobs //
				displayKnobs = CompositeView.new(additiveWindow,Rect(0,0,350,60*numKnob + 50)).background_(Color.black);
				funPrintKnobText.value(displayKnobs);
				displayKnobs.decorator = FlowLayout(displayKnobs.bounds, margin:10@40,gap: 20@10);
				knobMatrix = Array.fill2D(numKnob,5, {Knob(displayKnobs, 50@50)});

				//Setup of the display that contains the buttons for start and stop sound//
				displayButtons = CompositeView.new(additiveWindow,
					Rect(displayKnobs.bounds.width,0,120,60*numKnob + 50)).background_(Color.black);
				displayButtons.decorator = FlowLayout(displayButtons.bounds, margin:10@40,gap: 20@10);
				buttonsWave = Array.fill(numKnob,{Button(displayButtons, 100@50)});

				//Definition of the states of the start and stop buttons
				buttonsWave.do({
					arg me, index;
					me.states = [
						[number[index].asString, Color.black],
						[number[index].asString, Color.black, Color.green]
					]
				});

				//Definition of the action of the start and stop buttons
				buttonsWave.do({
					arg me, index;
					me.action = {
						arg state;
						case
						{state.value == 1}
						//Start the sound
						{
							notesArray[index] = Synth(\addsynth, [
								\freq,  440 * (index+1),
								//\amp, 1/number.size,
								\amp, 1/10,
								\att,  0.1,
								\dec,  0.2,
								\rel,  0.6])}
						{state.value == 0}
						//Stop the sound
						{notesArray[index].free; /*Maybe not the best way, but it works*/}
					}
				});

				/*Back to the phone*/
				additiveWindow.onClose = {
				s.freeAll;//Stop the sound
				mainWindow.visible_(true);
				playButton.value_(0);
				"Goodbye!!".postln
				};

			},{/*else*/}
		);

});//End of playButton.action

"Additive Synthesis Demo Starts".postln;

});//End of the code

