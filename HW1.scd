/*
*************************************************************************************************************************************
--Company: Politecnico di Milano
--Course name: Computer Music - Languages and Systems
--Module name: Homework 1
--Assignement: #1
--Project name: Fourier's phone: Additive Synthesis Demo (GUI)
--Group ID: 6
--Group nickname: GELVS
--Engineers:
            Perego Gabriele
            Roncuzzi Enrico
            Di lLerico Letizia
            Negroni Viola
            Del Moro Samuele
--Description:
If Fourier had lived in the 90s, how would he have reacted to a cell phone full of ringtones ?
In this assignement we created a demo prototype of additive synthesis in the form of a mobile phone able to generate
a series of up to 7 harmonic components that can be modulated and modified in real time.
The pattern used to create the components of the additive synthesis is the following:
The "telephone number" entered corresponds to an array in which: the i-th position corresponds to the i-th note of the C major scale
and the entered value corresponds to the number of semitones to add to the corresponding note.
Examples:
[0,0,0,0,0] = C-D-E-F-G
[0,1,2,3] = C-D#-E##-F### = C-D#-F#-G#
In the phase in which the signals are generated, it is possible to start them individually, or simultaneously,
and modularly: frequency, amplitude, cutoff, ampHz and jingle time.

*************************************************************************************************************************************
*/
s.waitForBoot({

/*Setup of  variables */
var mainWindow, additiveWindow, phone, phoneScreen, phoneKeyboard,phoneControl, buttonArray, playButton, signalButton;
var funPrintText, funPrintKnobText, funNote;
var space = 0, counterNumbers = 0, wave=0;
var number = Array.new(10);

Window.closeAll;
GUI.current;

/*Setup of SyntDef*/
SynthDef(\ring, {
	arg freq = 440, amp = 0.1;
	var env, snd;
	snd = EnvGen.kr(Env.new([1,0.7,0.8,0],[0.1,0.1,0.2,0.1]), doneAction: 2) * LFPulse.ar(freq,0,mul:0.3);
	Out.ar(0, snd*0.5);
	Out.ar(1, snd*0.5);
	}
).add;

SynthDef.new(\addSin, {
		arg ampHz=10, fund=440, maxPartial=4, width=5, totalAmp=0.5,vel = 1, fc = 20000, rq = 0.25;
		var amp, sig,freq, sen;
		amp = SinOsc.kr(ampHz,0,0.12) * totalAmp;
		freq = LFNoise0.kr(vel).exprange(fund, fund * maxPartial).round(fund);
		sig = SinOsc.ar(freq, width, amp);
		sig = RLPF.ar(sig, fc, rq);
		Out.ar(0, sig);
		Out.ar(1, sig);
	}).add;

SynthDef.new(\addSaw, {
		arg ampHz=10, fund=440, maxPartial=4, width=5, totalAmp=0.5,vel = 1, fc = 20000, rq = 0.25;
		var amp, sig,freq, sen;
		amp = SinOsc.kr(ampHz,0,0.12) * totalAmp;
		freq = LFNoise0.kr(vel).exprange(fund, fund * maxPartial).round(fund);
		sig = LFSaw.ar(freq, width, amp);
		sig = RLPF.ar(sig, fc, rq);
		Out.ar(0, sig);
		Out.ar(1, sig);
	}).add;

SynthDef.new(\addTri, {
		arg ampHz=10, fund=440, maxPartial=4, width=5, totalAmp=0.5,vel = 1, fc = 20000, rq = 0.25;
		var amp, sig,freq, sen;
		amp = SinOsc.kr(ampHz,0,0.12) * totalAmp;
		freq = LFNoise0.kr(vel).exprange(fund, fund * maxPartial).round(fund);
	    sig = LFTri.ar(freq,width,amp);
		sig = RLPF.ar(sig, fc, rq);
		Out.ar(0, sig);
		Out.ar(1, sig);
	}).add;

/*Setup of Functions*/
f = {
		arg index, number;
		o = case
				{index==0}{2*130.8*pow(2,number/12)}//Do3
				{index==1}{2*146.8*pow(2,number/12)}//Re3
				{index==2}{2*164.8*pow(2,number/12)}//Mi3
				{index==3}{2*174.6*pow(2,number/12)}//Fa3
				{index==4}{2*196*pow(2,number/12)}//Sol3
				{index==5}{2*220*pow(2,number/12)}//La3
				{index==6}{2*246.9*pow(2,number/12)}//Si3
};


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
		.string_("Freq            Amp        Cutoff      AmpHz       Jingle")
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
		["", Color.black,Color.new255(100,100,100)]])
	.font_(Font("Artifakt Element Light",15));

signalButton = Button(phoneControl, Rect(250,10,100,50))
	.font_(Font("Artifakt Element Light",10))
	.states_([
		["", Color.black,Color.new255(100,100,100)]])
	.font_(Font("Artifakt Element Light",15));

signalButton.action_({arg me; wave = me.value;});

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
			if( ((count != 9) && (count != 11)),{a = Synth(\ring, [\freq,440+(100*me.string.asInteger)])})
		})
		.action_({
			arg me;
			playButton.value_(0);
			if( (counterNumbers < 7) && (me.string != "*") && (me.string != "#") ,
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
					signalButton.states_([["SINE", Color.black],["SAW",Color.red],["TRI",Color.new255(100,200,100)]]);
					signalButton.value_(wave);
				},
				{
					playButton.states_(["", Color.black,Color.new255(100,100,100)]);
					signalButton.states_(["", Color.black,Color.new255(100,100,100)]);
				}
			);
		});
});//End of buttonArray.do.action

playButton.action_({
		arg me;
		//Setup of variables //
		var displayKnobs, displayButtons, knobMatrix, buttonsWave, numKnob = 1, myWave;
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
				//Setup of the wave to generate//
				myWave = wave;

				//Setup of the additive Window //
				additiveWindow = Window.new("Additive Synthesis",Rect(1000,200,500,70*numKnob + 50))
				.alwaysOnTop_(true)
				.background_(Color.new255(50,50,50))
				.front;

				//Setup of the display that contains the knobs //
				displayKnobs = CompositeView.new(additiveWindow,Rect(0,0,350,70*numKnob + 50)).background_(Color.black);
				funPrintKnobText.value(displayKnobs);
				displayKnobs.decorator = FlowLayout(displayKnobs.bounds, margin:10@40,gap: 20@10);
				knobMatrix = Array.fill2D(numKnob,5, {EZKnob(displayKnobs,50@60)});

				//Setup of the display that contains the buttons for start and stop sound//
				displayButtons = CompositeView.new(additiveWindow,
					Rect(displayKnobs.bounds.width,0,120,70*numKnob + 50)).background_(Color.black);
				displayButtons.decorator = FlowLayout(displayButtons.bounds, margin:10@40,gap: 10@20);
				buttonsWave = Array.fill(numKnob,{Button(displayButtons, 100@50)});

				//Setup of knobs
				knobMatrix.do({
				arg me,count;
					for(0,4){
						arg i;
						me.at(i,count).enabled_(false);
					}
				});

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
						knobMatrix.do({
								arg me,count;
								if(count==index,
									{
									for(0,4){arg i;me.at(i,count).enabled_(true);};
										me.at(0,count).set(
											spec:ControlSpec(f.value(count,number[count])-100, f.value(count,number[count])+100,
												\lin,10,f.value(count,number[count])),
											initVal:f.value(count,number[count]));
										me.at(1).set(spec:ControlSpec(0.1,1,\lin,0.05,(1/number.size)),initVal:1/number.size);
										me.at(2).set(spec:ControlSpec(0,20000,\lin,10,20000),initVal:20000);
										me.at(3).set(spec:ControlSpec(0,10,\lin,0.1,1),initVal:1);
										me.at(4).set(spec:ControlSpec(1,20,\lin,1,1),initVal:1);
								});
							});

						case
						{state.value == 1}
					{

						case
						{myWave == 0}{
							notesArray[index] = Synth(\addSin,[
								\fund,f.value(index,number[index]),
								\ampHz, 1,
								\maxPartial, 1,
								\width, number[index],
								\totalAmp, 1/number.size,
								\vel, 1,
								\fc, 20000
						]);
						}
						{myWave == 1}{
							notesArray[index] = Synth(\addSaw,[
								\fund,f.value(index,number[index]),
								\ampHz, 1,
								\maxPartial, 1,
								\width, number[index],
								\totalAmp, 1/number.size,
								\vel, 1,
								\fc, 20000
						]);
						}
						{myWave ==2}{
							notesArray[index] = Synth(\addTri,[
								\fund,f.value(index,number[index]),
								\ampHz, 1,
								\maxPartial, 1,
								\width, number[index],
								\totalAmp, 1/number.size,
								\vel, 1,
								\fc, 20000
						]);
						};

					}

						{state.value == 0}
						//Stop the sound
						{
							notesArray[index].free;
							//Start to setting value
							knobMatrix.do({
								arg me,count;
								if(count==index,
									{
										for(0,4){arg i;me.at(i,count).enabled_(false);}
								});
							});

						}
					}
				});

				knobMatrix.do({
					arg me, count;
					//Frequency range//

					me.at(0,count).action_({arg me;
						notesArray[count].set(\fund, me.value;)});

					//Amplitude//

					me.at(1,count).action_({arg me;notesArray[count].set(\totalAmp, me.value;)});

					me.at(2,count).action_({arg me;notesArray[count].set(\fc, me.value;)});

					me.at(3,count).action_({arg me;notesArray[count].set(\ampHz, me.value;)});

					me.at(4,count).action_({arg me;notesArray[count].set(\maxPartial, me.value;)});

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


