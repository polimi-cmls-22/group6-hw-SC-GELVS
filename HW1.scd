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
            Di Clerico Letizia
            Negroni Viola
            Del Moro Samuele
--Description:
If Fourier had lived in the 90s, how would he have reacted to a cell phone full of ringtones ?
In this assignement we created a demo prototype of additive synthesis in the form of a mobile phone able to generate
a series of components, that can be modulated and modified in real time, for create a ringtone jingle.
Each button of the phone represents a musical note and you can enter from 1 up to 7 numbers to create a bank of, up to 7,signals.
In the phase in which the signals are generated, it is possible to start them individually, or simultaneously,
and modularly: frequency, amplitude, cutoff, ampHz and jingle time.

*************************************************************************************************************************************
*/

/*Start the server*/
s.waitForBoot({

/*Setup of  variables */
var mainWindow, additiveWindow, phone, phoneScreen, phoneKeyboard,phoneControl, buttonArray, playButton, cancelButton;
var funPrintText, funPrintKnobText, funNote;
var space = 0, counterNumbers = 0, wave=0, fundamentalNote = 523.20;
var number = Array.new(10);

Window.closeAll;
GUI.current;

/*Setup of SyntDef*/

//SynthDef for play sound out of the buttons
SynthDef(\ring, {
	arg freq = 440, amp = 0.1;
	var env, snd;
	snd = EnvGen.kr(Env.new([1,0.7,0.8,0],[0.1,0.1,0.2,0.1]), doneAction: 2) * LFPulse.ar(freq,0,mul:0.3);
	Out.ar(0, snd*0.5);
	Out.ar(1, snd*0.5);
	}).add;

//SynthDef for generate SinOsc wave
SynthDef.new(\addSin, {
		arg ampHz=10, fund=440, maxPartial=4, totalAmp=0.5, vel = 1, fc = 20000, rq = 0.25;
		var amp,sig,freq;
		amp = SinOsc.kr(ampHz,0,0.12) * totalAmp;
		freq = LFNoise0.kr(vel).exprange(fund, fund * maxPartial).round(fund);
		sig = SinOsc.ar(freq,0, amp);
		sig = RLPF.ar(sig, fc, rq);
		Out.ar(0, sig);
		Out.ar(1, sig);
	}).add;

//SynthDef for generate  LFSaw wave
SynthDef.new(\addSaw, {
		arg ampHz=10, fund=440, maxPartial=4, totalAmp=0.5, vel = 1, fc = 20000, rq = 0.25;
		var amp,sig,freq;
		amp = SinOsc.kr(ampHz,0,0.12) * totalAmp;
		freq = LFNoise0.kr(vel).exprange(fund, fund * maxPartial).round(fund);
		sig = LFSaw.ar(freq,0, amp);
		sig = RLPF.ar(sig, fc, rq);
		Out.ar(0, sig);
		Out.ar(1, sig);
	}).add;

//SynthDef for generate  LFTri wave
SynthDef.new(\addTri, {
		arg ampHz=10, fund=440, maxPartial=4,totalAmp=0.5,vel = 1, fc = 20000, rq = 0.25;
		var amp, sig,freq;
		amp = SinOsc.kr(ampHz,0,0.12) * totalAmp;
		freq = LFNoise0.kr(vel).exprange(fund, fund * maxPartial).round(fund);
	    sig = LFTri.ar(freq,0,amp);
		sig = RLPF.ar(sig, fc, rq);
		Out.ar(0, sig);
		Out.ar(1, sig);
	}).add;

/*Setup of Functions*/

//Function that convert the number pressed to a musical note string
e = {
		arg num;
		var note = "";
		case
		{num ==1}{note = "C"}
	    {num==2}{note = "C#"}
		{num==3}{note = "D"}
		{num==4}{note = "D#"}
		{num==5}{note = "E"}
		{num==6}{note = "F"}
		{num==7}{note = "F#"}
		{num==8}{note = "G"}
		{num==9}{note = "G#"}
		{num==10}{note = "A"}
		{num==11}{note = "A#"}
		{num==12}{note = "B"};
	    o = note;
};

//Function that given the number of the phone generate the corresponding musical note frequency
f = {
		arg val;
		o  = fundamentalNote*pow(2,val/12);
};
//Function that given an input array of numbers generate the corresponding array of musical notes string
g = {
		arg arrayInput;
	    var arrayOutput = List.new(arrayInput.size);
		for(0,arrayInput.size,{
		arg i;
		case
		{arrayInput[i]==1}{arrayOutput.add("C")}
		{arrayInput[i]==2}{arrayOutput.add("C#")}
		{arrayInput[i]==3}{arrayOutput.add("D")}
		{arrayInput[i]==4}{arrayOutput.add("D#")}
		{arrayInput[i]==5}{arrayOutput.add("E")}
		{arrayInput[i]==6}{arrayOutput.add("F")}
		{arrayInput[i]==7}{arrayOutput.add("F#")}
		{arrayInput[i]==8}{arrayOutput.add("G")}
		{arrayInput[i]==9}{arrayOutput.add("G#")}
		{arrayInput[i]==10}{arrayOutput.add("A")}
		{arrayInput[i]==11}{arrayOutput.add("A#")}
		{arrayInput[i]==12}{arrayOutput.add("B")}
		});
	    o = arrayOutput.asArray;
};
//Function that given an input array of numbers generate the corresponding array phone numbers string
h = {
		arg arrayInput;
	    var arrayOutput = List.new(arrayInput.size);
		for(0,arrayInput.size,{
		arg i;
		case
		{arrayInput[i]==1}{arrayOutput.add("1")}
		{arrayInput[i]==2}{arrayOutput.add("2")}
		{arrayInput[i]==3}{arrayOutput.add("3")}
		{arrayInput[i]==4}{arrayOutput.add("4")}
		{arrayInput[i]==5}{arrayOutput.add("5")}
		{arrayInput[i]==6}{arrayOutput.add("6")}
		{arrayInput[i]==7}{arrayOutput.add("7")}
		{arrayInput[i]==8}{arrayOutput.add("8")}
		{arrayInput[i]==9}{arrayOutput.add("9")}
		{arrayInput[i]==10}{arrayOutput.add("*")}
		{arrayInput[i]==11}{arrayOutput.add("0")}
		{arrayInput[i]==12}{arrayOutput.add("#")}
		});
	    o = arrayOutput.asArray;
};

//Function that prints the phone number on the screen
funPrintText = {
		arg arrayNumber,viewPrint;
		var stringNumber, phoneNumber;
		stringNumber = g.value(arrayNumber);
		phoneNumber = h.value(arrayNumber);

		TextView(viewPrint,Rect(0,30,viewPrint.bounds.width, 70))
		.string_(phoneNumber.asString)
		.editable_(false)
		.font_(Font("Artifakt Element Light",40))
		.background_(Color.cyan)
		.front;

		TextView(viewPrint,Rect(0,100,viewPrint.bounds.width, 60))
		.string_(stringNumber.asString)
		.editable_(false)
		.font_(Font("Artifakt Element Light",25))
		.background_(Color.cyan)
		.front;
	};

//Function that prints the name of the variable parameters of the waves
funPrintKnobText = {
		arg viewPrint;
		TextView(viewPrint,Rect(0,0,400,30))
		.string_("Freq           Amp        Speed     AmpHz      Range")
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
		//Server.killAll;
		"Bye Bye!".postln
};

CmdPeriod.doOnce({mainWindow.close});

/*Phone*/
phone = CompositeView.new(mainWindow,Rect(10,10,mainWindow.bounds.width - 20,mainWindow.bounds.height - 20))
	.background_(Color.grey);
	StaticText.new(phone,Rect(70,0,500,100)).string_("FOURIER'S PHONE 2022").font_(Font("Artifakt Element Light",30));

/*Phone screen*/
phoneScreen = CompositeView.new(phone,Rect(40,80,400,200)).background_(Color.cyan);
StaticText.new(phoneScreen,Rect(0,0,400,40)).string_("NUMBER ENTERED").font_(Font("Artifakt Element Light",20))
	.background_(Color.new255(200,200,200));
StaticText.new(phoneScreen,Rect(0,160,400,40)).string_("NOTES ENTERED").font_(Font("Artifakt Element Light",20))
	.background_(Color.new255(200,200,200));

/*INITIALIZATION OF THE PHONE NUMBER LINE*/
funPrintText.value(number,phoneScreen);


/*Setup of the view of the phone*/
phoneControl = CompositeView.new(phone,Rect(40,300,400,70)).background_(Color.new255(50,50,50));
phoneKeyboard = CompositeView.new(phone,Rect(40,370,400,250)).background_(Color.black);
phoneKeyboard.decorator = FlowLayout(phoneKeyboard.bounds, margin: 40@20, gap: 5@5 );

/*Setup of the buttons of the phone*/
playButton = Button(phoneControl, Rect(40,10,100,50)).font_(Font("Artifakt Element Light",10))
	.states_([
		["", Color.black,Color.new255(100,100,100)]])
	.font_(Font("Artifakt Element Light",15));

cancelButton = Button(phoneControl, Rect(250,10,100,50))
	.font_(Font("Artifakt Element Light",10))
	.states_([
		["", Color.black,Color.new255(100,100,100)]])
	.font_(Font("Artifakt Element Light",15));

cancelButton.action_({
		if(counterNumbers > 0,{
			counterNumbers = counterNumbers-1;
			number.removeAt(counterNumbers);
			funPrintText.value(number,phoneScreen);
		});
		if( (number.size == 0),
			{
			playButton.states_([["", Color.black,Color.new255(100,100,100)]]);
			cancelButton.states_([["", Color.black,Color.new255(100,100,100)]]);
			}
		);
	});

buttonArray = Array.fill(12, {Button(phoneKeyboard, 100@50)});

buttonArray.do({
		arg me, count;
		me.states = [[(count+1).asString, Color.black],[(count+1).asString, Color.black]];
		if(count == 9, {me.states_([["*"]])});
		if(count == 10, {me.states = [["0"]]});
		if(count == 11, {me.states = [["#"]]});
		me.font_(Font("Artifakt Element Light",20));
});

/* Setup Actions of Buttons */

buttonArray.do({
		arg me, count;
		me.mouseDownAction_({a = Synth(\ring, [\freq,f.value(count+1)])})
		.action_({
			arg me;
			playButton.value_(0);
			if(counterNumbers < 7,{
				number.add(count+1);
				funPrintText.value(number,phoneScreen);
				counterNumbers = counterNumbers+1;
			});
			if(number.size > 0,
				{
					playButton.states_([["PLAY", Color.black,Color.green],["PLAY", Color.black,Color.red]]);
					cancelButton.states_([["CANCEL", Color.black, Color.new255(255,100,100)]]);
				}
			);

		});
});

playButton.action_({
		arg me;
		/*Setup of variables */
		var displayKnobs,displayButtons,knobMatrix,buttonsWave,displayWaves,buttonsSignals,displayFreq,buttonsFreq;
		var numKnob = 1, myWave=0;
		var notesArray = Array.newClear(number.size);

		/*Setup of the plots*/
		s.freqscope;
		s.scope;

		if((me.value == 1) && (number.size > 0),
			{
				/*Make the phone invisible*/
				mainWindow.visible_(false);

				/*Setup of the number of knobs (they depend by the size of the phone number)*/
				numKnob = number.size;

				/*Setup of the additive Window */
				additiveWindow = Window.new("Additive Synthesis",Rect(600,200,810,70*numKnob + 50))
				.alwaysOnTop_(true)
				.background_(Color.new255(50,50,50))
				.front;

				/*Setup of the display that contains the knobs */
				displayKnobs = CompositeView.new(additiveWindow,Rect(0,0,450,70*numKnob + 50)).background_(Color.black);
				funPrintKnobText.value(displayKnobs);
				displayKnobs.decorator = FlowLayout(displayKnobs.bounds, margin:10@40,gap: 20@10);
				knobMatrix = Array.fill2D(numKnob,6, {EZKnob(displayKnobs,50@60)});

				/*Setup of the display that contains the buttons for start and stop sound*/
				displayButtons = CompositeView.new(additiveWindow,
					Rect(displayKnobs.bounds.width,0,120,70*numKnob + 50)).background_(Color.black);
				displayButtons.decorator = FlowLayout(displayButtons.bounds, margin:10@40,gap: 10@20);
				buttonsWave = Array.fill(numKnob,{Button(displayButtons, 100@50)});

				displayWaves = CompositeView.new(additiveWindow,
					Rect(displayKnobs.bounds.width+displayButtons.bounds.width,0,120,70*numKnob + 50)).background_(Color.grey);
				displayWaves.decorator = FlowLayout(displayWaves.bounds, margin:10@40,gap: 10@20);
				buttonsSignals = Array.fill(numKnob,{Button(displayWaves, 100@50)});

				displayFreq = CompositeView.new(additiveWindow,
					Rect(displayKnobs.bounds.width+displayButtons.bounds.width+displayWaves.bounds.width,0,120,70*numKnob + 50)).background_(Color.black);
				displayFreq.decorator = FlowLayout(displayFreq.bounds, margin:10@40,gap: 10@20);
				buttonsFreq = Array.fill(numKnob,{Button(displayFreq, 100@50)});


				buttonsSignals.do({
					arg me;
					me.states = [
						["SINE",Color.black,Color.new255(255,100,100)],
						["SAW",Color.black,Color.new255(100,255,100)],
						["TRI",Color.black,Color.new255(100,100,255)]
				]});

				/*Initialization of knobs */
				knobMatrix.do({
				arg me,count;
					for(0,5){
						arg i;
						/*Frequency*/
						me.at(0,count).set(spec:ControlSpec(-100,100,\lin,1,0),initVal:0);
						me.at(0,count).value = 0;
						/*Amplitude*/
						me.at(1).set(spec:ControlSpec(0,1,\lin,0.1,1),initVal:0.5);
						me.at(1,count).value = 0.5;
						/*Speed*/
						me.at(2).set(spec:ControlSpec(1,10,\lin,1,1),initVal:1);
						me.at(2,count).value = 1;
						/*AmpHz*/
						me.at(3).set(spec:ControlSpec(0,10,\lin,0.1,1),initVal:1);
						me.at(3,count).value = 1;
						/*maxPartial*/
						me.at(4).set(spec:ControlSpec(1,10,\lin,1,1),initVal:1);
						me.at(4,count).value = 1;
						/*Octave*/
						me.at(5,count).set(spec:ControlSpec(-2,2,\lin,1,0),initVal:0);
						me.at(5,count).value = 0;
					}
				});
				buttonsFreq.do({
					arg me,count;
					u = f.value(number[count]-1);
					me.states = [[u.asStringPrec(3),Color.black]]});

				//Definition of the states of the start and stop buttons
				buttonsWave.do({
					arg me, index;
					me.states = [[e.value(number[index]).asString, Color.black],[e.value(number[index]).asString, Color.black, Color.green]];
				});

				//Definition of the action of the start and stop buttons
				buttonsWave.do({
					arg me, index;
					me.action = {
						arg state;

						case
						//If the button is pressed: start to play
						{(state.value == 1)}
						{
						//Generate SinOsc
							buttonsSignals[index].enabled_(false);
							knobMatrix.do({
								arg knob,count;
								if(count == index,
									{
										case
										{buttonsSignals[index].value == 0}
										{
											//notesArray[index].free;
											notesArray[index] = Synth(\addSin,[
											\fund,f.value(number[count]-1)*pow(2,knob.at(5,count).value) + knob.at(0,count).value,
											\totalAmp,knob.at(1,count).value,
											\vel, knob.at(2,count).value,
											\ampHz,knob.at(3,count).value,
											\maxPartial,knob.at(4,count).value]);
											u = f.value(number[count]-1)*pow(2,knob.at(5,count).value) + knob.at(0,count).value;
											u.postln;
											buttonsFreq[index].states = [[u.asString,Color.black]];
										}
										{buttonsSignals[index].value == 1}
										{
											//notesArray[index].free;
											notesArray[index] = Synth(\addSaw,[
											\fund,f.value(number[count]-1)*pow(2,knob.at(5,count).value) + knob.at(0,count).value,
											\totalAmp,knob.at(1,count).value,
											\vel, knob.at(2,count).value,
											\ampHz,knob.at(3,count).value,
											\maxPartial,knob.at(4,count).value]);
										}
										{buttonsSignals[index].value == 2}
										{
											//notesArray[index].free;
											notesArray[index] = Synth(\addTri,[
											\fund,f.value(number[count]-1)*pow(2,knob.at(5,count).value) + knob.at(0,count).value,
											\totalAmp,knob.at(1,count).value,
											\vel, knob.at(2,count).value,
											\ampHz,knob.at(3,count).value,
											\maxPartial,knob.at(4,count).value]);
										};
								});
							});
							//Control the signal values only if the buttons are on
							knobMatrix.do({
								arg me, count;
								//Frequency range//
								me.at(0,count).action_({arg io;notesArray[count].set(
									\fund,(f.value(number[count]-1)*pow(2,me.at(5,count).value)) + io.value);

								u = (f.value(number[count]-1)*pow(2,me.at(5,count).value)) + io.value;
								buttonsFreq[count].states = [[u.asStringPrec(3),Color.black]];
								});

								//Amplitude//
								me.at(1,count).action_({arg me;notesArray[count].set(\totalAmp, me.value;)});

								//Speed of the ringtone//
								me.at(2,count).action_({arg me;notesArray[count].set(\vel, me.value;)});

								//Value of ampHz//
								me.at(3,count).action_({arg me;notesArray[count].set(\ampHz, me.value;)});

								//Value of the range of the tones//
								me.at(4,count).action_({arg me;notesArray[count].set(\maxPartial, me.value;)});

								me.at(5,count).action_({
									arg io;
									notesArray[count].set(\fund,f.value(number[count]-1)*pow(2,io.value));

									u = (f.value(number[count]-1)*pow(2,io.value)) + me.at(0,count).value;
								    buttonsFreq[count].states = [[u.asStringPrec(3),Color.black]];
								});

							});
						}
                        //Button off
						{state.value == 0}
						//Stop the sound
						{
							notesArray[index].free;
					        buttonsSignals[index].enabled_(true);

						}
					}
				});

				/*Back to the phone*/
				additiveWindow.onClose = {
				s.freeAll;//Stop the sound
				mainWindow.visible_(true);
				playButton.value_(0);
				"Goodbye!!".postln
				};

		},{/*else*/});
});//End of playButton.action

"Additive Synthesis Demo Starts".postln;

});
//End of the code


