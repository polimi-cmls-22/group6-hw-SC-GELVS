/*
***************************************************************************************************************************************************************

--Company: Politecnico di Milano
--Course name: Computer Music - Languages and Systems
--Module name: Homework 1
--Assignement: #1
--Project name: Fourier's phone: Additive Synthesis Demo (GUI)
--Group ID: 6
--Group nickname: GELVS
--Engineers:
            Del Moro Samuele
            Di Clerico Letizia
            Negroni Viola
            Perego Gabriele
            Roncuzzi Enrico
--Description:
If Fourier had lived in the 90s, how would he have reacted to a mobile phone full of ringtones?
In this project we created an instrument (with the appearance of an old mobile phone) that generates ringtones through additive synthesis, generating a series of signals that can be played individually or simultaneously, and which can be modulated by changing some of their parameters.
A visual feedback of the resulting sound is given by both a frequency analyzer and a stethoscope.

***************************************************************************************************************************************************************
*/

/*Start the server*/
s.waitForBoot({

/*Setup of  variables */
var mainWindow, additiveWindow, phone, phoneScreen, phoneKeyboard,phoneControl, buttonArray, playButton, cancelButton;
var funPrintText, funPrintKnobText, funNote, egg;
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
		arg ampHz=10, fund=440, maxPartial=4, totalAmp=0.5, vel = 1;
		var amp,sig,freq;
		amp = SinOsc.kr(freq:ampHz,phase:0,mul:0.12) * totalAmp;
		freq = LFNoise0.kr(vel).exprange(fund, fund * maxPartial).round(fund);
		sig = SinOsc.ar(freq,0,amp);
		Out.ar(0, sig);
		Out.ar(1, sig);
	}).add;

//SynthDef for generate LFSaw wave
SynthDef.new(\addSaw, {
		arg ampHz=10, fund=440, maxPartial=4, totalAmp=0.5, vel = 1;
		var amp,sig,freq;
		amp = SinOsc.kr(ampHz,0,0.12) * totalAmp;
		freq = LFNoise0.kr(vel).exprange(fund, fund * maxPartial).round(fund);
		sig = LFSaw.ar(freq,0, amp);
		Out.ar(0, sig);
		Out.ar(1, sig);
	}).add;

//SynthDef for generate  LFTri wave
SynthDef.new(\addTri, {
		arg ampHz=10, fund=440, maxPartial=4,totalAmp=0.5,vel = 1;
		var amp, sig,freq;
		amp = SinOsc.kr(ampHz,0,0.12) * totalAmp;
		freq = LFNoise0.kr(vel).exprange(fund, fund * maxPartial).round(fund);
	    sig = LFTri.ar(freq,0,amp);
		Out.ar(0, sig);
		Out.ar(1, sig);
	}).add;

/*Setup of Functions*/

//Function for print E-Eggs
egg = {
		arg a;
		case
		{a == ["3","3","1","0"]}{
		w = Window.new("EGG",Rect(900,700,200,100),false).alwaysOnTop_(true).background_(Color.black).front;
			TextView(w,Rect(0,0,200,100)).string_("NOKIA EASTER EGG FOUND xD").editable_(false)
			.font_(Font("Artifakt Element Light",20)).background_(Color.cyan).front;
		}
		{a == ["1","3","5","6","8","*","#"]}{
		w = Window.new("EGG",Rect(900,600,200,100),false).alwaysOnTop_(true).background_(Color.black).front;
		TextView(w,Rect(0,0,200,100)).string_("C MAJOR SCALE EASTER EGG FOUND xD").editable_(false)
			.font_(Font("Artifakt Element Light",20)).background_(Color.green).front;
		}
		{a == ["*","#","1","3","5","6","8"]}{
		w = Window.new("EGG",Rect(900,500,200,100),false).alwaysOnTop_(true).background_(Color.black).front;
		TextView(w,Rect(0,0,200,100)).string_("A MINOR SCALE EASTER EGG FOUND xD").editable_(false)
			.font_(Font("Artifakt Element Light",20)).background_(Color.yellow).front;
		}
		{a == ["1","8","2","*","5","#","7"]}{
		w = Window.new("EGG",Rect(900,400,200,100),false).alwaysOnTop_(true).background_(Color.black).front;
		TextView(w,Rect(0,0,200,100)).string_("CIRCLE OF FIFTHS EASTER EGG FOUND xD").editable_(false)
			.font_(Font("Artifakt Element Light",20)).background_(Color.new255(255,100,100)).front;
		}
		{}{};
	};

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
		TextView(viewPrint,Rect(0,0,600,35))
		.string_("Detune       Amp       Speed       AmpHz       Range      Octave")
		.editable_(false)
		.font_(Font("Artifakt Element Light",15))
		.front;
	};


/*Initialization of window components*/

//Main Window//
mainWindow = Window.new("Fourier's phone - Additive Synthesis",Rect(Window.screenBounds.width/2 - 750,Window.screenBounds.height/2 -300,500,700))
	.alwaysOnTop_(true)
	.background_(Color.black)
	.front;

/*Setup of the plots*/
s.freqscope.window.setTopLeftBounds(Rect(900,10), menuSpacer: 45);
s.scope.window.setTopLeftBounds(Rect(900,400,604,328), menuSpacer: 45);

/*CLOSE ALL AND STOP ALL*/
mainWindow.onClose = {
		//Server.freeAll;
		Server.killAll;
		Window.closeAll;
		"Bye Bye!".postln
};

CmdPeriod.doOnce({mainWindow.close});

/*Phone*/
phone = CompositeView.new(mainWindow,Rect(10,10,mainWindow.bounds.width - 20,mainWindow.bounds.height - 20))
	.background_(Color.grey);
	StaticText.new(phone,Rect(70,0,500,100)).string_("FOURIER'S PHONE 3310").font_(Font("Artifakt Element Light",30));

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
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
playButton.action_({
		arg me;
		/*Setup of variables */
		var displayKnobs,displayButtons,knobMatrix,buttonsWave,displayWaves,buttonsSignals,displayFreq,buttonsFreq;
		var numKnob = 1, myWave=0;
		var notesArray = Array.newClear(number.size);

		if((me.value == 1) && (number.size > 0),
			{
				/*Make the phone invisible*/
				mainWindow.visible_(false);

				/*E-Egg controller*/
				egg.value(h.value(number));

				/*Setup of the number of knobs (they depend by the size of the phone number)*/
				numKnob = number.size;

				/*Setup of the additive Window */
				additiveWindow = Window.new("Additive Synthesis",Rect(10,500-(50*numKnob),810,70*numKnob + 50))
				.alwaysOnTop_(true)
				.background_(Color.new255(50,50,50))
				.front;

				/*Setup of the display that contains the knobs */
				displayKnobs = CompositeView.new(additiveWindow,Rect(0,0,450,70*numKnob + 50)).background_(Color.black);
				funPrintKnobText.value(displayKnobs);
				displayKnobs.decorator = FlowLayout(displayKnobs.bounds, margin:10@40,gap: 20@10);
				knobMatrix = Array.fill2D(numKnob,6, {EZKnob(displayKnobs,50@60)});

				/*Setup of the display that contains the buttons for start and stop sound*/

				//Display of buttons that start and stop the signals
				displayButtons = CompositeView.new(additiveWindow,
					Rect(displayKnobs.bounds.width,0,120,70*numKnob + 50)).background_(Color.black);
				displayButtons.decorator = FlowLayout(displayButtons.bounds, margin:10@40,gap: 10@20);
				TextView(additiveWindow,Rect(450,0,120,35)).string_("NOTES").editable_(false).font_(Font("Artifakt Element Light",15)).background_(Color.cyan).front;
				buttonsWave = Array.fill(numKnob,{Button(displayButtons, 100@50)});

				//Display of buttons that change the type of waves (SinOsc, LFSaw, LFTri)
				displayWaves = CompositeView.new(additiveWindow,
					Rect(displayKnobs.bounds.width+displayButtons.bounds.width,0,120,70*numKnob + 50)).background_(Color.grey);
				displayWaves.decorator = FlowLayout(displayWaves.bounds, margin:10@40,gap: 10@20);
				TextView(additiveWindow,Rect(570,0,120,35)).string_("WAVES").editable_(false).font_(Font("Artifakt Element Light",15)).background_(Color.yellow).front;
				buttonsSignals = Array.fill(numKnob,{Button(displayWaves, 100@50)});

				//Display that shows the intervals of frequencies
				displayFreq = CompositeView.new(additiveWindow,
					Rect(displayKnobs.bounds.width+displayButtons.bounds.width+displayWaves.bounds.width,0,120,70*numKnob + 50)).background_(Color.black);
				TextView(additiveWindow,Rect(690,0,120,35)).string_("MAIN FREQUENCY").editable_(false).font_(Font("Artifakt Element Light",12)).background_(Color.green).front;
				displayFreq.decorator = FlowLayout(displayFreq.bounds, margin:10@40,gap: 10@20);
				buttonsFreq = Array.fill(numKnob,{StaticText(displayFreq, 100@50)});

				/*Setup of buttons that change the type of signals*/
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

						/*Frequency-detune*/
						me.at(0,count).set(spec:ControlSpec(-50,50,\lin,1),initVal:0);

						/*Amplitude*/
						me.at(1).set(spec:ControlSpec(0,1,\lin,0.1),initVal:0.5);

						/*Speed*/
						me.at(2).set(spec:ControlSpec(1,10,\lin,1),initVal:1);

						/*AmpHz-modulation*/
						me.at(3).set(spec:ControlSpec(0,10,\lin,0.1),initVal:1);

						/*Range of octaves*/
						me.at(4).set(spec:ControlSpec(1,4,\lin,1),initVal:1);

						/*Octave invetvals*/
						me.at(5,count).set(spec:ControlSpec(-2,2,\lin,1),initVal:0);

					};

					me.at(0,count).action_({
						arg io;
						u = (f.value(number[count]-1)*pow(2,me.at(5,count).value)) + io.value;
						buttonsFreq[count].string_(u.asStringPrec(3)).stringColor_(Color.white).font_(Font("Artifakt Element Light",20));
						});
					me.at(5,count).action_({arg io;
						u = (f.value(number[count]-1)*pow(2,io.value)) + me.at(0,count).value;
						buttonsFreq[count].string_(u.asStringPrec(3)).stringColor_(Color.white).font_(Font("Artifakt Element Light",20));
					});

				});
				/*Print the frequency intervals*/
				buttonsFreq.do({
					arg me,count;
					u = f.value(number[count]-1);
					me.string_(u.asStringPrec(3)).stringColor_(Color.white).font_(Font("Artifakt Element Light",20));
					});

				/*Definition of the states of the start and stop buttons*/
				buttonsWave.do({
					arg me, index;
					me.states_([[e.value(number[index]).asString, Color.black],[e.value(number[index]).asString, Color.black, Color.green]]);
					me.font = Font("Artifakt Element Light",20);
				});

				/*Definition of the action of the start and stop buttons*/
				buttonsWave.do({
					arg me, index;
					me.action = {
						arg state;

						case
						//Button ON
						{(state.value == 1)}
						{
						//Generate the signals
							buttonsSignals[index].enabled_(false);
							knobMatrix.do({
								arg knob,count;
								if(count == index,
									{
										case
										{buttonsSignals[index].value == 0}
										{
											notesArray[index] = Synth(\addSin,[
											\fund,f.value(number[count]-1)*pow(2,knob.at(5,count).value) + knob.at(0,count).value,
											\totalAmp,knob.at(1,count).value,
											\vel, knob.at(2,count).value,
											\ampHz,knob.at(3,count).value,
											\maxPartial,knob.at(4,count).value]);
											//Update the range of octaves
											u = f.value(number[count]-1)*pow(2,knob.at(5,count).value) + knob.at(0,count).value;
											buttonsFreq[index].string_(u.asStringPrec(3)).stringColor_(Color.white)
											.font_(Font("Artifakt Element Light",20));
										}
										{buttonsSignals[index].value == 1}
										{

											notesArray[index] = Synth(\addSaw,[
											\fund,f.value(number[count]-1)*pow(2,knob.at(5,count).value) + knob.at(0,count).value,
											\totalAmp,knob.at(1,count).value,
											\vel, knob.at(2,count).value,
											\ampHz,knob.at(3,count).value,
											\maxPartial,knob.at(4,count).value]);
											//Update the range of octaves
											u = f.value(number[count]-1)*pow(2,knob.at(5,count).value) + knob.at(0,count).value;
											buttonsFreq[index].string_(u.asStringPrec(3)).stringColor_(Color.white)
											.font_(Font("Artifakt Element Light",20));
										}
										{buttonsSignals[index].value == 2}
										{

											notesArray[index] = Synth(\addTri,[
											\fund,f.value(number[count]-1)*pow(2,knob.at(5,count).value) + knob.at(0,count).value,
											\totalAmp,knob.at(1,count).value,
											\vel, knob.at(2,count).value,
											\ampHz,knob.at(3,count).value,
											\maxPartial,knob.at(4,count).value]);
											//Update the range of octaves
											u = f.value(number[count]-1)*pow(2,knob.at(5,count).value) + knob.at(0,count).value;
											buttonsFreq[index].string_(u.asStringPrec(3)).stringColor_(Color.white)
											.font_(Font("Artifakt Element Light",20));
										};
								});
							});

							knobMatrix.do({
							arg me, count;

								/*Update frequency-detune*/
								me.at(0,count).action_({
									arg io;
									notesArray[count].set(\fund,(f.value(number[count]-1)*pow(2,me.at(5,count).value)) + io.value);
									u = (f.value(number[count]-1)*pow(2,me.at(5,count).value)) + io.value;
									buttonsFreq[count].string_(u.asStringPrec(3)).stringColor_(Color.white).font_(Font("Artifakt Element Light",20));
								});

								/*Update amplitude*/
								me.at(1,count).action_({arg me;notesArray[count].set(\totalAmp, me.value);});

								/*Update speed of ringtone*/
								me.at(2,count).action_({arg me;notesArray[count].set(\vel, me.value);});

								/*Update ampHz-modulation*/
								me.at(3,count).action_({arg me;notesArray[count].set(\ampHz, me.value);});

								/*Update range of octaves*/
								me.at(4,count).action_({arg me;notesArray[count].set(\maxPartial, me.value;)});

								/*Update Octave invetvals*/
								me.at(5,count).action_({
									arg io;
									notesArray[count].set(\fund,f.value(number[count]-1)*pow(2,io.value));
									u = (f.value(number[count]-1)*pow(2,io.value)) + me.at(0,count).value;
								    buttonsFreq[count].string_(u.asStringPrec(3)).stringColor_(Color.white).font_(Font("Artifakt Element Light",20));
								});
							});
						}
                        //Button OFF
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

		},{});
});//End of playButton.action
	//----------------------------------------------------------------------------------------------------------------------------------------------------------//
"Additive Synthesis Demo Starts".postln;

});
//End of the code


