//Nadel - MAT200B Fall 2014 final project by Matthias Wagner
//
//First add instrument to server (lines 7 - 78)
//Then add score to server (starts at line 80)
(
o = ServerOptions.new;
o.memSize = 2048000;
Server.default.options_(o);
)
(
s.boot;
)
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
(
b = Buffer.read(s, "/Users/matze/Desktop/Audio/PinMono.wav" );

SynthDef(\pin, {
	| gate = 1, randAdd=0, randTrigger=1, rRAmount=0, pitchRatio=1,
	winSize=1, pitchDisp = 0, shift = 0 |
	var amp, ampEnv, ampEnvCtrl; // volume and volume envelope of a stream
	var lpf, lpfEnv, lpfEnvCtrl; // lowpasss filter envelope of a stream
	var t, tEnv, tEnvCtrl, t0; // trigger and trigger envelope
	var pos, posEnv, posEnvCtrl; // position and position envelope
	var grDur, grDurEnv, grDurEnvCtrl; // grain duration and envelope
	var rate, rateEnv, rateEnvCtrl, randRate; // playback rate and rate envelope
	var att, attEnv, attEnvCtrl; // grain attack and grain attack envelope
	var timeDisp, tDEnv, tDEnvCtrl; // PitchShifter parameters
	var xPos, xEnv, xEnvCtrl, yPos, yEnv, yEnvCtrl; // 4 channel panning
	var ringMod;
	ampEnv = Env([1,0,0,0,0,0,0,0,0,0],[100,1,0,0,0,0,0,0,0]).asArray;
	ampEnvCtrl = \ampEnv.kr(ampEnv);
	amp = EnvGen.kr(ampEnvCtrl, gate, doneAction:2);
	lpfEnv = Env([20000,20000,0,0,0,0,0,0,0,0],[100,1,0,0,0,0,0,0,0]).asArray;
	lpfEnvCtrl = \lpfEnv.kr(lpfEnv);
	lpf = EnvGen.kr(lpfEnvCtrl, gate);
	tEnv = Env([1,10,1,0,0,0,0,0,0,0],[5,5,0,0,0,0,0,0,0]).asArray;
	tEnvCtrl = \tEnv.kr(tEnv);
	t0 = Impulse.kr(EnvGen.kr(tEnvCtrl, gate));
	t = Impulse.kr(EnvGen.kr(tEnvCtrl, gate)+(TRand.kr(-0.5*randTrigger,0.5*randTrigger, t0)));
	posEnv = Env([0.0,1,0,0,0,0,0,0,0,0], [100,1,0,0,0,0,0,0,0]).asArray;
	posEnvCtrl = \posEnv.kr(posEnv);
	pos = EnvGen.kr(posEnvCtrl, gate);
	grDurEnv = Env([0.5,0,0,0,0,0,0,0,0,0], [100,1,0,0,0,0,0,0,0]).asArray;
	grDurEnvCtrl = \grDurEnv.kr(grDurEnv);
	grDur = EnvGen.kr(grDurEnvCtrl, gate);
	attEnv = Env([0.001,0.001,0,0,0,0,0,0,0,0], [100,0,0,0,0,0,0,0,0,0]).asArray;
	attEnvCtrl = \attEnv.kr(attEnv);
	att = EnvGen.kr(attEnvCtrl, gate);
	rateEnv = Env([1,1,0,0,0,0,0,0,0,0], [100,0,0,0,0,0,0,0,0,0]).asArray;
	rateEnvCtrl = \rateEnv.kr(rateEnv);
	rate = EnvGen.kr(rateEnvCtrl, gate);
	randRate = TBrownRand.kr(-0.05,0.05,0.02,0,t);
	tDEnv = Env([0,0,0,0,0,0,0,0,0,0], [5,0,0,0,0,0,0,0,0,0]).asArray;
	tDEnvCtrl = \tDEnv.kr(tDEnv);
	timeDisp = EnvGen.kr(tDEnvCtrl, gate);
	xEnv = Env([0,0,0,0,0,0,0,0,0,0], [10,0,0,0,0,0,0,0,0]).asArray;
	xEnvCtrl = \xEnv.kr(xEnv);
	xPos = EnvGen.kr(xEnvCtrl, gate);
	yEnv = Env([0,0,0,0,0,0,0,0,0,0], [1000,0,0,0,0,0,0,0,0]).asArray;
	yEnvCtrl = \yEnv.kr(yEnv);
	yPos = EnvGen.kr(yEnvCtrl, gate);
	ringMod = SinOsc.ar(TBrownRand.kr(20, 50, 3, 0, t));

	Out.ar(0,
		Pan4.ar(
			BPeakEQ.ar(
			BPeakEQ.ar(
			BPeakEQ.ar(
			BPeakEQ.ar(
			BHiPass4.ar(
			LPF.ar(
			FreqShift.ar(
				PitchShift.ar(
						GrainBuf.ar(1, t, grDur, b, rate + (randRate*rRAmount), pos, 4, 0, -1, 512, 0.9, TBrownRand.kr(-1.5,1.5,0.7,0,t)*randAdd),
				winSize, pitchRatio, pitchDisp, timeDisp),
										shift + TBrownRand.kr(-2,2,0.27,0,t)) * (0.9+(ringMod*0.1)),
			freq:lpf),
			freq:50,rq:1),
			freq:160, rq:2, db:-6),
			freq:1300, rq:2, db:-10),
			freq:5000, rq:2,db:-8),
			freq:9500, rq:1,db:-6),
			xPos, yPos, 0.3) * amp
	)}).add;
)
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
(
// this is the score

SystemClock.sched(0, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,0,0,0],[1,40,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.5,0.9,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.2,0.2],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 1.0,
		\shift, -900,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[0,0,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(1, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[0.01,10,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20],[5,5]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3, 0.3],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\shift, 0.5,
		\xEnv, Pseq([[[-1,1,0],[10,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(3, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[3,60,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,50,18,72,5,16,10],[15,9,12,5,8,12]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1,0.3,0.005,0.2,0.05,0.5,1.5],[10,10,10,10,20,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0.7,0,0.2],[20,20,20,6]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,1.2,1.1,0.9,0.95, 1],[5,10,5,3,12]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 1.0,
		\pitchRatio, 0.9,
		\shift, -1000,
		\randAdd, 0,
		\randTrigger, 0.7,
		\xEnv, Pseq([[[1,-1,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,-1,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(10, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[0.01,20,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[1,10,4,50],[5,5,10]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.3],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\randAdd, 0,
		\randTrigger, 0.5,
		\pitchRatio, 1,
	    \xEnv, Pseq([[[-1,1,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,-1,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(15, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[10,15,2]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.19,0.19],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 0.5,
		\shift, -100,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[1,1,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
//drone1
SystemClock.sched(15, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,0],[13,40,0.1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.2,0.5,0.2],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.5,0.5,0.5],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\xEnv, Pseq([[[-1,-1,1,1,-1,1,1,-1],[15,15,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,1,1,1,1,1],[15,15,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
//drone2
SystemClock.sched(15, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,0],[13,40,0,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.2,0.15,0.2],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.8,0.8,1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\xEnv, Pseq([[[-1,1,1,-1,-1,1,1,-1],[15,15,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,-1,1,1,-1,-1,-1,1],[15,15,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
//drone3
SystemClock.sched(15, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,0],[13,40,0.1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.3,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.5,0.2,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.7,0.7,0.7],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0.01,
		\randAdd, 0,
		\randTrigger, 0,
		\xEnv, Pseq([[[1,1,-1,-1,1,-1,-1,-1],[15,15,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,1,1,-1,-1,-1,-1,1],[15,15,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
//drone4
SystemClock.sched(15, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,0],[13,40,0.1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.13, 0.02, 0.1],[10,30,20]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.5,0.2,0.14,0.2],[10,20,10,40]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.2,1.2,1.2],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\xEnv, Pseq([[[1,-1,-1,1,1,1,1,-1],[15,15,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,1,-1,-1,1,-1,-1,1],[15,15,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(25, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[15,7,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.21,0.21],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 0.5,
		\shift, -0,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[0,0,0,0,1],[10,100,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,1,1],[10,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(25, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[15,7,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.21,0.21],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 1.0,
		\shift, -0,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1000,1000,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[0,0,0,0,1],[10,100,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,-1,-1],[10,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(27, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[7,12,3]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.21,0.21],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 0.5,
		\shift, -200,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[-1,-1,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});


SystemClock.sched(45, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,0.9,0.9,0],[1,20,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.5,0.9,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.2,0.25],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 1.0,
		\shift, -900,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[1,0,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,0,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(50, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,0.9,0.9,0],[1,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1,0.1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.9,0.1],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.27,0.25],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 1.0,
		\shift, -500,
		\randAdd, 0,
		\randTrigger, 0.1,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[-1,0,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0.5,0,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(63, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,2,3,0],[0.01,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[2,10,6,20],[5,5,10]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.3],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.1,0.9,0,0.9,0.95, 1],[10,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 0,
		\randTrigger, 0.3,
		\pitchRatio, 0.2,
		\pitchDisp, 0.5,
		\timeDisp, 0.1,
		\shift, -2000,
	    \xEnv, Pseq([[[1,-1,-1,0,1],[10,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,1,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(63.1, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,2,3,0],[0.01,10,7]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[0.1,1,6,20],[5,5,10]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.3],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.1,0.9,0,0.9,0.95, 1],[10,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 0,
		\randTrigger, 0.3,
		\pitchRatio, 0.2,
		\pitchDisp, 0.5,
		\timeDisp, 0.1,
		\shift, -2000,
	    \xEnv, Pseq([[[1,-1,-1,0,1],[10,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,1,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(68, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,2,3,0],[0.01,10,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[30,50,16,30],[5,5,10]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.3],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.1,0.9,0,0.9,0.95, 1],[10,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 1,
		\randAdd, 0,
		\randTrigger, 0.3,
		\pitchRatio, 0.2,
		\pitchDisp, 0.2,
		\timeDisp, 0.3,
		\shift, 0,
	    \xEnv, Pseq([[[1,-1,-1,0,1],[10,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,-1,0],[10,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});

SystemClock.sched(76, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[0.01,20,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[5,20,16,30],[2,2,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.0,0.01,0.0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.1,0.9,1,0.9,0.95, 1],[10,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 1,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 1,
		\timeDisp, 0.3,
		\shift, -2000,
	    \xEnv, Pseq([[[1,1,-1,0,1],[10,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(76, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,25,25,0],[0.01,20,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[5,20,16,30],[2,2,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.0,0.01,0.0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.1,0.9,1,0.9,0.95, 1],[10,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 1,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1.0,
		\pitchDisp, 0.5,
		\timeDisp, 0,
		\shift, -4500,
		\lpfEnv, Pseq([[[300,300,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
	    \xEnv, Pseq([[[-1,-1,1,0,-1],[10,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(76.5, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[0.01,20,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[5,20,16,30],[2,2,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.01],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.0,0.01,0.0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.1,0.9,1,0.9,0.95, 1],[10,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 1,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 1,
		\timeDisp, 0.3,
		\shift, -3000,
	    \xEnv, Pseq([[[1,-1,-1,0,1],[12,8,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,1,-1],[12,8]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});

SystemClock.sched(76.5, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,15,1,0],[0.001,0,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,20,16,30],[2,2,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.01],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.0,0.03,0.0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,0.9,1,0.9,0.95, 1],[10,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 1,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\timeDisp, 0,
		\shift, -0,
	    \xEnv, Pseq([[[1,-1,-1,0,1],[12,8,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,1,-1],[12,8]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(77, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,15,1,0],[0.001,0,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,20,16,30],[2,2,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.01],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.0,0.03,0.0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.6,0.9,1,0.9,0.95, 1],[10,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 1,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\timeDisp, 0,
		\shift, 10,
	    \xEnv, Pseq([[[-1,-1,-1,0,1],[12,8,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,1,-1],[12,8]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(77.5, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,10,1,0],[0.001,0,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,20,16,30],[2,2,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.01],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.0,0.03,0.0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.6,0.9,1,0.9,0.95, 1],[10,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 0.5,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\timeDisp, 0,
		\shift, 10,
	    \xEnv, Pseq([[[1,-1,-1,0,1],[12,8,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,1,-1],[12,8]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(79.5, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,3,3,20,0],[0.01,11,2,0.001]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,20,50,30],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.2,0.2,0.1],[13,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[-1.1,-1.2, -1.6],[9,3,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.5,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\timeDisp, 0,
		\shift, 10,
	    \xEnv, Pseq([[[-1,0,-1,0,1],[12,2,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,0,1],[12,2]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(79.5,{
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,7,7,20,0],[0.01,11,2,0.001]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.2,0.2,0.1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,1.2],[10,2]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\xEnv, Pseq([[[-1,0,-1,1,-1,1,1,-1],[12,2,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,0,1,1,1,1,1,1],[12,2,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
//check till here -10
SystemClock.sched(90, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,4,4,0],[0.01,30,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[30,8,10],[5,17]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.01,0.1],[10,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.5,0,0.2],[5,5]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.04,0,0.03,0,0.02,0,0.01],[1,1,1,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,1],[10,2]]], 1).collect { |x| [Env(*x).asArray] },
		\lpfEnv, Pseq([[[80,10000],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 1,
		\pitchRatio, 1,
		\pitchDisp, 0.72,
		\randAdd, 0,
		\randTrigger, 0,
		\winSize, 1,
		\shift, -7000,
		\xEnv, Pseq([[[1,1,-1,-1,0,1,-1],[7,7,7,7]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,1,0,1,1,1],[7,7,7,7]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(92, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,4,4,0],[0.01,30,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[30,8,10],[5,17]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.01,0.1],[10,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.5,0,0.2],[5,5]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.04,0,0.03,0,0.02,0,0.01],[1,1,1,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[-1,-1],[10,2]]], 1).collect { |x| [Env(*x).asArray] },
		\lpfEnv, Pseq([[[80,10000],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 1,
		\pitchRatio, 1,
		\pitchDisp, 0.72,
		\randAdd, 0,
		\randTrigger, 0,
		\winSize, 0.5,
		\shift, -2500,
	    \xEnv, Pseq([[[0,0,-1,1,-1,1,1,-1],[12,10,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,1,1,1,1,1,1],[12,2,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(92, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[0.01,10,2]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,20,50,30],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0.3,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.01,0.02],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.1,1.2, 1.6],[9,3,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.5,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\shift, 0,
		\xEnv, Pseq([[[0,0,1,1,-1,1,1,-1],[12,10,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,1,1,1,1,1,1],[12,2,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});

SystemClock.sched(93, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[0.01,10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,20,50,30],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.01, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0.01,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.01,0.02],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.1,1.2, 1.6],[9,3,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.5,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 1.0,
		\winSize, 0.3,
		\shift, -5000,
	    \xEnv, Pseq([[[0,0,1,1,-1,1,1,-1],[12,10,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,1,1,1,1,1,1],[12,2,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});

SystemClock.sched(93, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[0.01,10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,20,16,28],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0.01,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.01,0.02],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.1,0.9,1.0],[7,12]]], 1).collect { |x| [Env(*x).asArray] },
		\lpfEnv, Pseq([[[12000,400,1000],[7,12]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.5,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\winSize, 0.5,
		\shift, -5000,
	    \xEnv, Pseq([[[1,0,-1,0,1],[12,2,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,0,1],[12,2]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(93.5, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[0.01,10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,20,16,28],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0.01,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.01,0.02,0.01],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.1,1.9,1.0],[7,12]]], 1).collect { |x| [Env(*x).asArray] },
		\lpfEnv, Pseq([[[600,4000,1000],[7,12]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.5,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\winSize, 0.1,
		\shift, -5000,
	    \xEnv, Pseq([[[-1,0,-1,0,1],[12,2,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,0,1],[12,2]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(97, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,3,9,0],[0.1,20,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,20,16,28],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0.01,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.1,0.2,0.5],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[-1,-1],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\lpfEnv, Pseq([[[1200,1200,1200],[7,12]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.2,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\winSize, 5.1,
		\shift, -2000,
	    \xEnv, Pseq([[[1,0,1,0,1],[12,2,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,0,-1],[12,2]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(98, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,3,9,0],[0.1,20,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,20,50,28],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0.01,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.1,0.2,0.5],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.3,0.3],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\lpfEnv, Pseq([[[1200,1200,1200],[7,12]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.2,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\winSize, 5.1,
		\shift, -100,
	    \xEnv, Pseq([[[1,0,-1,0,1],[12,2,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,0,-1],[12,2]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});

SystemClock.sched(115, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,10,10,0],[1,20,0.1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.2,0.5,0.2],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.5,0.5,0.5],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\xEnv, Pseq([[[-1,-1,1,1,-1,-1,1,1,0],[1,1,1,1,1,1,1,1]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,1,1,-1,-1,1,0],[1,1,1,1,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(115, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,10,10,0],[1,20,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.2,0.5,0.2],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.5,0.55,0.5],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
	\xEnv, Pseq([[[-1,-1,1,1,-1,-1,1,1,0],[1,1,1,1,1,1,1,1]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,1,1,-1,-1,1,0],[1,1,1,1,1,1,1,1]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(115.1, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,10,10,0],[1,20,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.2,0.5,0.2],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.5,0.55,0.5],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.155,
		\shift, -300,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\xEnv, Pseq([[[0,0],[20]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0],[20]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(115.2, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,10,10,0],[1,20,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.2,0.5,0.2],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.5,0.55,0.5],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.155,
		\shift, 200,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\xEnv, Pseq([[[0,0],[20]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0],[20]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(115, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,10,10,0],[1,20,0.1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.2,0.5,0.2],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.4,0.4,0.5],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0.05,
		\randAdd, 0,
		\randTrigger, 0,
		\xEnv, Pseq([[[1,-1,-1,1,1,-1,-1,1],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,-1,1,1,-1,-1,1,1],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(115, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,10,10,0],[1,20,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,50],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.2,0.5,0.2],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.4,0.4,0.4],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
	    \xEnv, Pseq([[[-1,-1,1,1,-1,-1,1,1,0],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,1,1,-1,-1,1,0],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(130, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[1,10,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[300,5, 30],[15, 5]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.01, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.01,0.2,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0.03,0.01],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,1,1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.9,
		\pitchDisp, 0.05,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, -6000,
	    \xEnv, Pseq([[[-1,-1,1,1,-1,-1,1,1,0],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,1,1,-1,-1,1,0],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(132, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[1,10,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[300,5, 30],[15, 5]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.01, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.01,0.2,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0.03,0.01],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,1,1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.9,
		\pitchDisp, 0.05,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, -4000,
	    \xEnv, Pseq([[[1,1,1,0,-1,-1,1,-1,0],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,0,1,-1,-1,1,0],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(136, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[1,10,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[300,5, 30],[15, 5]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.01, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.01,0.2,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0.03,0.01],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,1,1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 20,
		\pitchRatio, 0.9,
		\pitchDisp, 0.05,
		\randAdd, 0,
		\randTrigger, 0,
	 	\shift, 4000,
	    \xEnv, Pseq([[[1,1,1,0,-1,-1,1,-1,0],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,0,1,-1,-1,1,0],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(138, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[1,10,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[5,15, 25],[10, 10]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.01, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.001],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0.03,0.01],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,0.7,1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 20,
		\pitchRatio, 0.9,
		\pitchDisp, 0.2,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, -500,
	    \xEnv, Pseq([[[1,1,1,0,-1,-1,1,-1,0],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,0,1,-1,-1,1,0],[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(135, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,3,3,0],[1,16,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[5,15, 25],[10, 10]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.01, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0,0.01,0,0.05],[5,5,5,5,5]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,0.7,1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 10,
		\pitchRatio, 0.9,
		\pitchDisp, 0.2,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, -500,
	    \xEnv, Pseq([[[1,1,1,0,-1,-1,1,-1,0],[10,5,7]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,0,1,-1,-1,1,0],[7,8,7]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(135.1, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,3,3,0],[1,20,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[5,15, 25],[10, 10]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.01, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.001],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0,0.01,0,0.05],[5,5,5,5,5]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,0.7,1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\pitchRatio, 0.9,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, 1500,
	    \xEnv, Pseq([[[1,-1,1,0,-1,1,1,-1,0],[10,5,7]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1,1,1,-1,-1,1,0],[7,8,7]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(135.2, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,3,3,0],[1,20,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[5,15, 25],[10, 10]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.01, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.1,0.1,0.001],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0,0.01,0,0.05],[5,5,5,5,5]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.5,0.7,0.5],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\pitchRatio, 0.9,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, 1500,
	    \xEnv, Pseq([[[1,-1,1,1,-1,1,1,-1,0],[10,5,7]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,1,-1,1,1,-1,-1,1,0],[7,8,7]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(140, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[7,5,2]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.19,0.19],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 0.5,
		\shift, -200,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[1,1,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(150, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,3,2,0],[1,15,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[15,20,13,18],[5,7,8]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0.2,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0.005,0.01,0,0.05],[25,5,5,5,5]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.5,0.7,0.5],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 1,
		\pitchRatio, 0.5,
		\pitchDisp, 2,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, -200,
		\lpfEnv, Pseq([[[400,1500,0],[15,50]]], 1).collect { |x| [Env(*x).asArray]},
	    \xEnv, Pseq([[[1,-1,-1,1,-1,1,1,-1,0],[20,5,7,8]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,-1,1,1,1,-1,-1,1,0],[7,8,7,8,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(160, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,3,2,0],[1,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[15,20,13,18],[5,7,8]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.1, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0.2,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0.005,0.01,0,0.05],[25,5,5,5,5]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.5,0.7,0.5],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 1,
		\pitchRatio, 0.5,
		\pitchDisp, 2,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, -200,
		\lpfEnv, Pseq([[[2500,500,0],[15,50]]], 1).collect { |x| [Env(*x).asArray]},
	    \xEnv, Pseq([[[0,-1,-1,1,1,1,1,-1,0],[10,15,7,8]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,1,-1,-1,1,-1,-1,1,0],[10,3,9,8,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
// insert 2016

SystemClock.sched(160, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,50,50,0],[0.01,1,0.01]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[5,5,5,10],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.06, 0.06],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.01,0.01],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.75,0.8,0.8],[9,3,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 0.125,
		\pitchDisp, 0,
		\winSize, 0.5,
		\shift, -510,
		\lpfEnv, Pseq([[[120,120,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
	    \xEnv, Pseq([[[0,0,1,1,-1,1,1,-1],[12,10,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,1,1,1,1,1,1],[12,2,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(161, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,50,0],[0.01,1.01]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[5,5,5,10],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.06, 0.06],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.06,0.06],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[-0.75,-0.8,0.8],[9,3,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 0.125,
		\pitchDisp, 0,
		\winSize, 0.5,
		\shift, -400,
		\lpfEnv, Pseq([[[120,120,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
	    \xEnv, Pseq([[[0,0,1,1,-1,1,1,-1],[12,10,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,1,1,1,1,1,1],[12,2,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(161, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,10,10,0],[0.01,5,0.01]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,100,20,10],[5,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.06, 0.06],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.01,0.2],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[-0.75,-0.8,0.8],[4,3,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1.0,
		\pitchDisp, 0,
		\winSize, 0.5,
		\shift, -1500,
		\lpfEnv, Pseq([[[1200,1200,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
	    \xEnv, Pseq([[[0,0,1,1,-1,1,1,-1],[12,10,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,1,1,1,1,1,1],[12,2,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(163, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,15,15,0],[0.01,10.2,1.4]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[25,35,15,10],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.06, 0.06],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.02],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.0,0.9,2.0],[9,3,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 0.95,
		\pitchDisp, 0,
		\winSize, 0.5,
		\shift, -5000,
		\lpfEnv, Pseq([[[520,520,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
	    \xEnv, Pseq([[[-1,1,-0.5,1,-1,1,1,-1],[5,5,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,1,0,1,1,1,1,1],[7,3,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(165, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,20,20,0],[0.01,1.0,0.01]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[50,100,20,10],[5,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.06, 0.06],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.01,0.2],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.75,-0.8,0.8],[4,3,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 1.0,
		\pitchDisp, 0,
		\winSize, 0.5,
		\shift, -2000,
		\lpfEnv, Pseq([[[1200,1200,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
	    \xEnv, Pseq([[[0,0,1,1,-1,1,1,-1],[12,10,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,1,1,1,1,1,1],[12,2,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(167, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,25,25,0],[0.01,0.85,0.01]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[5,5,5,10],[10,12,1]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.06, 0.06],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.02,0.02],[10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.75,0.8,0.8],[9,3,1,1,1]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\pitchRatio, 0.125,
		\pitchDisp, 0,
		\winSize, 0.5,
		\shift, -200,
		\lpfEnv, Pseq([[[120,120,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
	    \xEnv, Pseq([[[0,0,1,1,-1,1,1,-1],[12,10,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,1,1,1,1,1,1],[12,2,15,12,1,3,1]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});

SystemClock.sched(170, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,2.5,2.5,0],[1,20,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.5,0.5,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.25,0.1],[30]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 0.125,
		\shift, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\lpfEnv, Pseq([[[500,500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[0,0,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
//pads
SystemClock.sched(170, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1.5,1.5,0],[1,40,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.5,0.9,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.2,0.2],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 1.0,
		\shift, -900,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[0,0,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(190, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[10,15,2]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.19,0.19],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 0.5,
		\shift, -200,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[1,1,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(195, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[7,12,3]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.21,0.21],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 0.5,
		\shift, -200,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[-1,-1,-1,0,1],[100,10,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,0],[50,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(200, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[15,7,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.21,0.21],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 0.5,
		\shift, -0,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1500,1500,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[0,0,0,0,1],[10,100,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,1,1],[10,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
SystemClock.sched(200, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[15,7,5]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[40,40],[65]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.3,0.3],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.4,0.4],[20,20]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.21,0.21],[60]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.0,
		\pitchRatio, 1.0,
		\shift, -0,
		\randAdd, 0,
		\randTrigger, 0.3,
		\lpfEnv, Pseq([[[1000,1000,0],[50,50]]], 1).collect { |x| [Env(*x).asArray]},
		\xEnv, Pseq([[[0,0,0,0,1],[10,100,10,5]]], 1).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,-1,-1],[10,0]]], 1).collect { |x| [Env(*x).asArray] }
	).trace.play;
});
//pads end
SystemClock.sched(200, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[5,10,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[300,100, 200],[15, 5]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.2],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.01,0.2,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0.01,0.01],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.5,0.5,1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0.05,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, 2000,
	    \xEnv, Pseq([[[-1,1,0],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[-1,-1,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(205, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,1,0],[5,10,1]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[300,100, 200],[15, 5]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.2],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0.01,0.2,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0.005,0.01,0.01],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.5,0.5,1],[60,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.1,
		\pitchRatio, 0.5,
		\pitchDisp, 0.05,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, 1000,
	    \xEnv, Pseq([[[1,-1,0],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,1,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});

SystemClock.sched(210, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,20,0],[5,45,2,0.001]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,15,8,20],[15, 5, 15]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0.0],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,1,0.7],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.5,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, 0,
	    \xEnv, Pseq([[[1,1,-1],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(211, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,20,0],[5,44,2,0.001]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,15,8,20],[15, 5, 15]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0.0],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.9,0.9,1.0],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.5,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, 0,
	    \xEnv, Pseq([[[1,1,1],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(212, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,20,0],[5,43,2,0.001]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,15,8,20],[15, 5, 15]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.2],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0.0],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1.2,1.2,1.3],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.5,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, 0,
	    \xEnv, Pseq([[[1,1,-1],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,1],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(218, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,20,0],[5,37,2,0.001]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,15,8,20],[15, 5, 15]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0.0],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.75,0.9,0.75],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.5,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, -30,
	    \xEnv, Pseq([[[1,1,1],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,1],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(220, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,20,0],[5,35,2,0.001]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,15,8,20],[15, 5, 15]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0.0],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.93,1.1,1.01],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.5,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, 20,
	    \xEnv, Pseq([[[1,1,0],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,-1],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(222, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,20,0],[5,33,2,0.001]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,15,8,20],[15, 5, 15]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0.0],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.63,1.1,1.01],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.9,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, -20,
	    \xEnv, Pseq([[[1,1,0],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,1],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(224, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,20,0],[5,31,2,0.001]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,15,8,20],[15, 5, 15]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0.0],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.63,1.1,1.01],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.9,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, 10,
	    \xEnv, Pseq([[[1,1,-1],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(226, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,1,3,20,0],[5,29,2,0.001]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[20,15,8,20],[15, 5, 15]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[0.2, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[0,0.1,0.0],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[0.63,1.2,1.01],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0.9,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, -10,
	    \xEnv, Pseq([[[1,1,1],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[1,-1,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});
SystemClock.sched(263, {
	Pbind(
		\type, \on,
		\instrument, \pin,
		\ampEnv, Pseq([[[0,6,6,0],[0.01,1.5,0.2]]], 1).collect { |x| [Env(*x).asArray] },
		\tEnv, Pseq([[[1,1,8,20],[15, 5, 15]]], 1).collect { |x| [Env(*x).asArray] },
		\grDurEnv, Pseq([[[1.9, 0.1],[10,0]]], 1).collect { |x| [Env(*x).asArray] },
		\tDEnv, Pseq([[[0,0,0.1],[10,10]]], 1).collect { |x| [Env(*x).asArray] },
		\posEnv, Pseq([[[1.5,0,0.0],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rateEnv, Pseq([[[1,1,1.01],[15,10]]], 1).collect { |x| [Env(*x).asArray] },
		\rRAmount, 0,
		\pitchRatio, 1,
		\pitchDisp, 0,
		\randAdd, 0,
		\randTrigger, 0,
		\shift, 0,
	    \xEnv, Pseq([[[0,0,1],[10,10]]]).collect { |x| [Env(*x).asArray] },
		\yEnv, Pseq([[[0,0,0],[10,10]]], 1).collect { |x| [Env(*x).asArray] }
		).trace.play;
});

)
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////