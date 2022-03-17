/* GELVS - SuperCollider */
s.waitForBoot({
	/*Global variables */
	var mainWindow, phone, phoneScreen, phoneKeyboard,phoneControl, buttonArray, playButton, jingleButton;

	Window.closeAll;
	GUI.current;

	/*Setup of SyntDef*/

	/*Setup of Routine*/

	/*Initialization of window components*/

	//Main Window//
	mainWindow = Window.new("Fourier's phone - Additive Synthesis",Rect(Window.screenBounds.width/2 - 750,Window.screenBounds.height/2 -300,500,700);)
	.alwaysOnTop_(true)
	.background_(Color.black)
	.front;
	//CLOSE ALL AND STOP ALL
	mainWindow.onClose = {s.freeAll; "Bye Bye!".postln};
	CmdPeriod.doOnce({mainWindow.close});

	//Phone//
	phone = CompositeView.new(mainWindow,Rect(10,10,mainWindow.bounds.width - 20,mainWindow.bounds.height - 20))
	.background_(Color.grey);
	StaticText.new(phone,Rect(phone.bounds.width/4,0,300,100))
	.string_("NOCHIA 2022")
	.font_(Font("Artifakt Element Light",40));

	phoneScreen = CompositeView.new(phone,Rect(40,80,400,250))
	.background_(Color.cyan);

	phoneControl = CompositeView.new(phone,Rect(40,300,400,70))
	.background_(Color.new255(50,50,50));

	playButton = Button(phoneControl, Rect(40,10,100,50))
	.font_(Font("Artifakt Element Light",10))
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

	phoneKeyboard = CompositeView.new(phone,Rect(40,370,400,250)).background_(Color.black);
	phoneKeyboard.decorator = FlowLayout(phoneKeyboard.bounds, margin: 40@20, gap: 5@5 );

	buttonArray = Array.fill(12, {Button(phoneKeyboard, 100@50)});

	buttonArray.do({
		arg me, count;
		me.states = [
			[(count+1).asString, Color.black],
			[(count+1).asString, Color.black]
		];
		if(count == 9, {me.states = [["*"]]});
		if(count == 10, {me.states = [["0"]]});
		if(count == 11, {me.states = [["#"]]});
		me.font_(Font("Artifakt Element Light",20));
		});
	buttonArray.do({
		arg me;
		me.mouseDownAction_({
			a = {EnvGen.kr(Env.new([1,0.7,0.8,0],[0.1,0.1,0.2,0.1]), doneAction: 2) * LFPulse.ar(600*(me.string.asInteger),0,mul:0.3)}.play;})
		.action_({ arg me;
			a.release(0.2);

			me.string.asInteger.postln;

            });

	});

"Additive Synthesis Demo Starts".postln;
});


