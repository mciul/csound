<csinstruments>
; blip rhythm
; Mike Ciul
; 2008 Sep 07

sr = 44100
kr = 441
ksmps = 100
nchnls = 2

gaComb1Send		init 0
gaComb2Send		init 0	
gaLowpassSend	init 0
gaAbsSend		init 0
gaDownbeatSend	init 0
ga8thsSend		init 0
ga16thsSend		init 0

gkDownbeatRMS	init 0
;TODO - make it possible to open comb gates with keystroke - local/global conflict

giBPM			init 130
giChannelLimit	init 10000
giLookahead		init 0.01
;gi0dbfs		init 32767

; *******************************************************
; Instrument 1
; L: Comb 1
;

			instr 1

iPitch		= p4
iDelayTime		= 1 / p4

aChain		delay gaComb1Send, iDelayTime

; since a non-inverting comb filter has a peak at 0 Hz, do a highpass filter
; (a leakDC would be nice, but this is similar?)

;						half-power point: half the comb fundamental
aChain		atone aChain,	(0.5/iDelayTime)

; limit signal with distortion

;				imeth=2 tanh method	ilimit
aChain		clip 	aChain,	2,	giChannelLimit
;				imeth=0 Bram de Jong method		iarg=0.75 - where clipping starts
; possible problems if input exceeds unity?
;aChain		clip	aChain,	0,	giChannelLimit,	0.25

; Try a gate.

kRMS			rms aChain
kRMS			=  kRMS / giChannelLimit
			outvalue "comb1 RMS", kRMS
iOpenThresh		= 0.01
iResetThresh	= 0.001
iCloseThresh	= 0.1
iFloor		= 0.1
iOpenTime		= 0.01
iCloseTime		= 0.75

iMix			= 0.25

kGate			init 1
kReset		init 0

if kGate 	== 0 then
	kGain = iFloor
	kPortHalfTime = iCloseTime / 10
	if kReset == 1 then
		if gkDownbeatRMS &gt; iOpenThresh then
			kGate = 1
			kReset = 0
		endif
	else
		if gkDownbeatRMS &lt; iResetThresh then
			kReset = 1
		endif
	endif
else
	kGain = 1
	kPortHalfTime = iOpenTime / 10
	if kRMS &gt; iCloseThresh then
		kGate = 0
	endif
endif

kGain			portk kGain, kPortHalfTime
			outvalue "test", kGain

aChain		= aChain * kGain

; effect sends

kToLowpass		invalue "comb1-lowpass"
kToAbs		invalue "comb1-abs"
kToDownbeat		invalue "combs-downbeat"

gaLowpassSend	= gaLowpassSend + aChain * kToLowpass
gaAbsSend		= gaAbsSend + aChain * kToAbs

; send to downbeat post-expansion

gaDownbeatSend	= gaDownbeatSend + aChain * kToDownbeat

; output audio

			outs1 aChain * iMix

; clear effects send for this instrument

gaComb1Send		= 0

			endin


; *******************************************************
; Instrument 2
; R: Comb 2 (inverting)
;

			instr 2

iPitch		= p4
iDelayTime		= 0.5 / p4 ; inverting delay has pitch an octave lower


aChain		delay gaComb2Send, iDelayTime


; limit signal with distortion

;				imeth=2 tanh method	ilimit
aChain		clip 	aChain,	2,	giChannelLimit
;				imeth=0 Bram de Jong method		iarg=0.75 - where clipping starts
; possible problems if input exceeds unity?
;aChain		clip	aChain,	0,	giChannelLimit,	0.25

; Try a gate.

kRMS			rms aChain
kRMS			=  kRMS / giChannelLimit
			outvalue "comb2 RMS", kRMS
iOpenThresh		= 0.01
iResetThresh	= 0.001
iCloseThresh	= 0.1
iFloor		= 0.1
iOpenTime		= 0.01
iCloseTime		= 0.75

iMix			= 0.25

kGate			init 1
kReset		init 0

if kGate 	== 0 then
	kGain = iFloor
	kPortHalfTime = iCloseTime / 10
	if kReset == 1 then
		if gkDownbeatRMS &gt; iOpenThresh then
			kGate = 1
			kReset = 0
		endif
	else
		if gkDownbeatRMS &lt; iResetThresh then
			kReset = 1
		endif
	endif
else
	kGain = 1
	kPortHalfTime = iOpenTime / 10
	if kRMS &gt; iCloseThresh then
		kGate = 0
	endif
endif

kGain			portk kGain, kPortHalfTime

; invert
aChain		= -1 * kGain * aChain

; effect sends

kToLowpass		invalue "comb2-lowpass"
kToLowpass		portk		kToLowpass, 0.001
kToAbs		invalue "comb2-abs"
kToAbs		portk		kToAbs, 0.001
kToDownbeat		invalue "combs-downbeat"
kToDownbeat		portk		kToDownbeat, 0.001

gaLowpassSend	= gaLowpassSend + aChain * kToLowpass
gaAbsSend		= gaAbsSend + aChain * kToAbs


; send to downbeat post-expansion

gaDownbeatSend	= gaDownbeatSend + aChain * kToDownbeat

; output audio

			outs2 aChain * iMix

; clear effects send for this instrument

gaComb2Send		= 0

			endin

; *******************************************************
; Instrument 3
; Lowpass filter
;

			instr 3

kCutoffOct		invalue "lowpass cutoff octave"
kCutoffOct		portk	kCutoffOct, 0.001

kCutoff		= cpsoct(kCutoffOct)
			outvalue "lowpass cutoff", kCutoff

kCutoff		port	kCutoff, 0.1

;					input		cutoff	Q (1-500)		
aChain		lowpass2 gaLowpassSend,	kCutoff,	2

; limit signal with distortion

;				imeth=2 tanh method	ilimit
aChain		clip 	aChain,	2,	giChannelLimit
;				imeth=0 Bram de Jong method		iarg=0.75 - where clipping starts
; possible problems if input exceeds unity?
;aChain		clip	aChain,	0,	giChannelLimit,	0.1


; no output, but record level

kRMS			rms aChain
			outvalue "lowpass RMS", kRMS / giChannelLimit

; effect sends

kToComb1		invalue "lowpass-comb1"
kToComb1		portk	kToComb1, 0.001
kToComb2		invalue "lowpass-comb2"
kToComb2		portk	kToComb2, 0.001

gaComb1Send		= gaComb1Send + aChain * kToComb1
gaComb2Send		= gaComb2Send + aChain * kToComb2

; clear effects send for this instrument

gaLowpassSend	= 0

			endin

; *******************************************************
; Instrument 4
; single-sideband amplitude modulation
; (fancy ring modulation)
;

			instr 4

kModFreq		invalue "Mod Frequency"
kModFreq		portk	kModFreq, 0.001
kModDir		invalue "Mod Dir"
kModDir		portk kModDir, 0.01

aChain		= gaAbsSend

iHiPassMin		= 10
kHiPassMax		= kModFreq

; highpass filter to prevent fold-under
kHiPassFreq		= iHiPassMin + ( kHiPassMax * abs( kModDir * -1 ) )
;				input		cutoff	res (1-100)	mode (1=hipass)
aChain		bqrez aChain, 	kHiPassFreq, 	1, 		1

aReal, aImag	hilbert aChain

; a complex pure tone with positive frequency
aModReal		oscil 1, kModFreq, 1, 0.25
aModImag		oscil 1, kModFreq, 1

aChain 		= ( aReal * aModReal + aImag * aModImag * kModDir )

;aChain		dcblock aChain

; limit signal with distortion

;				imeth=2 tanh method	ilimit
;aChain		clip 	aChain,	2,	giChannelLimit
;				imeth=0 Bram de Jong method		iarg=0.75 - where clipping starts
; possible problems if input exceeds unity?
aChain		clip	aChain,	0,	giChannelLimit,	0.9

; no output, but record level

kRMS			rms aChain
			outvalue "abs RMS", kRMS / giChannelLimit

; effect sends

kToComb1		invalue "abs-comb1"
kToComb1		portk		kToComb1, 0.001
kToComb2		invalue "abs-comb2"
kToComb2		portk		kToComb2, 0.001

gaComb1Send		= gaComb1Send + aChain * kToComb1
gaComb2Send		= gaComb2Send + aChain * kToComb2

; clear effects send for this instrument

gaAbsSend	= 0

			endin

; *******************************************************
; Instrument 5
; downbeat: delay, filter/ringmod, compander
;

			instr 5

iMeasures1		= p4	; first delay line, for audio output
iMeasures2		= p5	; second delay, RMS send to combs

iOneMeasure		= 60.0 * 4 / giBPM

iAudioDelay		= iMeasures1 * iOneMeasure
iRMSDelay	= iMeasures2 * iOneMeasure

;switching the delays so audio uses second delay
aChain		delay gaDownbeatSend, iAudioDelay
kRMS			rms gaDownbeatSend
kRMS			= kRMS / giChannelLimit
			outvalue "downbeat RMS", kRMS


;try this gate-like thing:

iMaxGain		= 1.0
iMinGain		= 0.25
iThreshold		= 0.001
iCloseHalfTime	= iOneMeasure / 16 / 10
iOpenHalfTime	= iOneMeasure * 1.0 / 10

if kRMS &gt; iThreshold then
	kGoal		= iMinGain
	kHalfTime	= iCloseHalfTime
else
	kGoal		= iMaxGain
	kHalfTime	= iOpenHalfTime
endif

kGain			portk kGoal, kHalfTime
			outvalue "downbeat gate", kGain
aGated		= aChain * kGain

; effect sends

; send RMS to combs, via a delay
kRegen		invalue "downbeat regen"
kRegen		portk	kRegen, 0.001
kToCombs		invalue "downbeat-combs"
kToCombs		portk kToCombs, 0.001

aCombsSend		delay	gaDownbeatSend, iRMSDelay
aCombsSend		= aCombsSend * kToCombs
gkDownbeatRMS	delayk kRMS, iRMSDelay - giLookahead
gaComb1Send		= gaComb1Send + aCombsSend
gaComb2Send		= gaComb2Send + aCombsSend
ga8thsSend		= ga8thsSend + aGated * 0.5
gaDownbeatSend	= aGated * kRegen ; clearing old value

; add kick drum FX to output signal

iThumpFreq		= 40
iThumpBW		= 30
iThumpModBW		= 10
iThumpBend		= 20
iClickFreq		= 13000
iClickBW		= 10000
iThumpAmp		= 0.3
iClickAmp		= 3.0
iThumpModAmp	= 0.01


iThumpHP		= iThumpBW / 2
iClickHP		= sr / 2 - iClickBW / 2
aThump		tone aChain, iThumpHP
aClick		reson aGated, iClickFreq, iClickBW

kThumpModFreq	= iThumpFreq + ( kRMS - 1 ) * iThumpBend

aThumpMod		reson aGated, kThumpModFreq, iThumpModBW

; don't forget, when ring modulating with signals not normalized to 0db, 
; you must divide by 0dbfs (giChannelLimit here).
; We don't do it with the click because the amplitude is so low.
kMix			invalue "downbeat mix"
kMix			portk	kMix, 0.001

iThumpMul		= iThumpAmp / giChannelLimit
aThump		= ( aThump * iThumpMul + iThumpModAmp ) * aThumpMod
; distortion as a limiter
;				imeth=0 Bram de Jong method		iarg=0.75 - where clipping starts
; possible problems if input exceeds unity?
aThump		clip	aThump,	0,	giChannelLimit,	0.75

aChain		= ( aThump + aClick * iClickAmp ) * kMix

; do we need a gain control on the output?

			outs aChain, aChain
			endin

; *******************************************************
; Instrument 6
; 8th notes: ping pong delay
;

			instr 6

iMeasuresL		= p4	; left delay feeds right delay
iMeasuresR		= p5  ; and back again
i8thsL		= p6	
i8thsR		= p7	

iOneMeasure		= 60.0 * 4 / giBPM
iOne8th		= iOneMeasure / 8

iLDelay		= iMeasuresL * iOneMeasure + i8thsL * iOne8th
iRDelay		= iMeasuresR * iOneMeasure + i8thsR * iOne8th

aLeft			delay ga8thsSend, iLDelay

aRight		delay aLeft, iRDelay
kRMS			rms aRight
kRMS			= kRMS / giChannelLimit
kStereoRMS		rms aLeft + aRight
kStereoRMS		= kStereoRMS / giChannelLimit
			outvalue "8ths RMS", kStereoRMS

;try this gate-like thing:

iMaxGain		= 1.0
iMinGain		= 0.5
iThreshold		= 0.01
iCloseHalfTime	= iOne8th * 3 / 8 / 10
iOpenHalfTime	= iOne8th * 6 / 10

if kRMS &gt; iThreshold then
	kGoal		= iMinGain
	kHalfTime	= iCloseHalfTime
else
	kGoal		= iMaxGain
	kHalfTime	= iOpenHalfTime
endif

kGain			portk kGoal, kHalfTime
aGated		= aRight * kGain

;effect sends

kRegen		invalue "8ths regen"
kRegen		portk	kRegen, 0.001
kToDownbeat		invalue "8ths-downbeat"
kToDownbeat		portk	kToDownbeat, 0.001

ga8thsSend		= aGated * kRegen ; clearing old value
gaDownbeatSend	= gaDownbeatSend + aGated * kToDownbeat
ga16thsSend		= ga16thsSend + aGated * 2

; add snare drum FX to output signal?

kMix			invalue "8ths mix"
kMix			portk	kMix, 0.001

			outs aLeft * kMix, aRight * kMix
			endin

; *******************************************************
; Instrument 7
; 16th notes
;

			instr 7

i16ths1		= p4	
i16ths2		= p5
i16ths3		= p6

iModFreq		= 300

iOneMeasure		= 60.0 * 4 / giBPM
iOne16th		= iOneMeasure / 16
iError		= 0.005

iDelay1		= i16ths1 * iOne16th
iDelay2		= i16ths2 * iOne16th
iDelay3		= i16ths3 * iOne16th

; try some crazy modulation
; the hilbert transform generates a complex signal from a real signal
aRe, aIm		hilbert ga16thsSend

aRe1			delay aRe, iDelay1
aIm1			delay aIm, iDelay1
aRe2			delay aRe1, iDelay2
aIm2			delay aIm1, iDelay2
aRe3			delay aRe2, iDelay2
aIm3			delay aIm1, iDelay2

; try modulating the first delay with itself, to produce double frequencies?
; we're doing multiplication of complex numbers,
; but only saving the real part of the result
aMod1			= aRe1 * aRe1
aMod2			= aRe2 * aRe2

aChain1		= ( aMod1 + aMod2 ) / giChannelLimit

; no effect for second delay
aChain2		= aRe2

; for third delay, modulate by a fixed frequency
aModCos		oscil 1, iModFreq, 1, .25
aModSin		oscil 1, iModFreq, 1

aMod1 		= aRe3 * aModCos
aMod2 		= aIm3 * aModSin

; Both sum and difference frequencies can be 
; output at once.
; this is upshift. For downshift use aMod1 - aMod2
aChain3 = aMod1 + aMod2

kRMS			rms aChain3
kRMS			= kRMS / giChannelLimit
kAllRMS		rms aChain1 + aChain2 + aChain3
			outvalue "16ths RMS", kAllRMS / giChannelLimit

;try this gate-like thing:

iMaxGain		= 1.3
iMinGain		= 0.3
iThreshold		= 0.01
iCloseHalfTime	= iOne16th * 0.5
iOpenHalfTime	= iOne16th * 0.5 / 10

if kRMS &gt; iThreshold then
	kGoal		= iMinGain
	kHalfTime	= iCloseHalfTime
else
	kGoal		= iMaxGain
	kHalfTime	= iOpenHalfTime
endif

kGain			portk kGoal, kHalfTime
aGated		= aChain3 * kGain

;effect sends

kRegen		invalue "16ths regen"
kRegen		portk	kRegen, 0.001
kTo8ths		invalue "16ths-8ths"
kTo8ths		portk	kTo8ths, 0.001

ga16thsSend		= aGated * kRegen ; clearing old value
ga8thsSend		= ga8thsSend + aGated * kTo8ths


; output
kMix			invalue "16ths mix"
kMix			portk	kMix, 0.001

			outs (aChain1 + aChain2) * kMix, (aChain1 + aChain3) * kMix
			endin

; *******************************************************
; Instrument 100
; Noise blip
;

			instr 100


iBlipDur		= p4 ; can p3 be in milliseconds?
; try using an envelope

iSampleDur		= 1 / sr
iMinBlip		= 0.00001
; this is sort of an arbitrary formula for amplitude
;iBlipAmp		= giChannelLimit * dbamp(iMinBlip) / dbamp(iBlipDur)
iBlipAmp		= giChannelLimit * 0.1

;iDecay		= ampdb(  -90/(iBlipDur * sr) )
;			prints "iBlipDur: %f sec, %d samples iDecay: %f", iBlipDur, iBlipDur * sr, iDecay

;aEnv			linseg 0, iSampleDur, iBlipAmp, iBlipDur, iBlipAmp, iSampleDur, 0, 1, 0
;				amp, 	rise time, overall dur, decay time,	rise table, steady attenuation, decay attenuation
;aEnv			envlpx iBlipAmp,	iSampleDur,	iBlipDur, iBlipDur - iSampleDur, 3, 1, 1 - iDecay

aEnv			linseg 0, iBlipDur/2, iBlipAmp, iBlipDur/2, 0, 1, 0

aChain		rand aEnv

; try an impulse

aChain		mpulse giChannelLimit, 0

; send to comb filters

;gaComb1Send		= gaComb1Send + aChain
;gaComb2Send		= gaComb2Send + aChain

; send to LPF and ABS

gaLowpassSend		= gaLowpassSend + aChain
gaAbsSend			= gaAbsSend	+ aChain
			endin

; *******************************************************
; Instrument 101
; Keyboard events
;

			instr 101
klastkey init -1
key, kkeydown sense

if key != -1 &amp;&amp; key &lt; 128 then

;			printks "key: %d down: %d", 0, key, kkeydown
;	Interesting! Although every press generates an automatic fake release,
;	an actual release generates a keypress of key + 128

	kBlipDur	invalue "blip time"

;event "scorechar", kinsnum, kdelay, kdur, [, kp4] [, kp5] [, ...]
;p3 is a fake dur, p4 is the actual time for the envelope, very short
        		event 	"i", 100, 0, kBlipDur * 0.001, kBlipDur * 0.001
; open feedback gates
;	gkComb1Gate = 1
;	gkComb2Gate = 1

	klastkey	= key	

endif

			endin

; *******************************************************
; Instrument 102
; Noise floor
;

			instr 102
aChain		rand 0.001

gaLowpassSend	= gaLowpassSend + aChain
gaAbsSend		= gaAbsSend + aChain
			endin
</csinstruments>
<csscore>
; 4096 point sine wave
f1 0 4096 10 1

; probability distribution: values 1 and -1 both have 50% probability
f2 0 2 -41 1 50 -1 50

; a rising envelope
f 3 0 129 -7 0 128 1

;			delay frequency
i1	0	8888	150			
i2	0	8888	242.70509831248	; 150 Hz * 1.61803398874989


i3	0	8888
i4	0	8888

;			audio delay (bars)	compander delay (bars) - these delays are in parallel
i5	0	8888	8				5

;			L delay (bars)		R delay (bars)		L delay (8ths)	R delay (8ths)
i6	0	8888	1				2				6			5

;			16ths delay (center)	(L)				(R)
i7	0	8888	13				13				13

i101	0	8888
i102	0	8888
</csscore>

</csoundsynthesizer>
<macoptions>
Version: 3
Render: Real+File
Ask: Yes
Functions: None
Listing: Window
WindowBounds: 127 45 1011 750
CurrentView: orc
IOViewEdit: Off
Options: -b128 -A -o/Users/mike/eyeballsun/public_html/csound/bliprhythm.aif -s -m167 -R --midi-velocity-amp=4 --midi-key-cps=5 
</macoptions>
<macgui>
ioView background {60108, 65535, 63132}
ioText {208, 22} {185, 216} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {60197, 60197, 60197} background noborder R: comb2 (inverting)
ioText {206, 241} {185, 302} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {60197, 60197, 60197} background noborder one-way ring mod
ioText {20, 240} {183, 271} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {60197, 60197, 60197} background noborder lowpass
ioText {445, 21} {320, 217} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {60197, 60197, 60197} background noborder downbeat
ioText {625, 241} {229, 215} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {60197, 60197, 60197} background noborder 16ths
ioText {404, 240} {219, 216} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {60197, 60197, 60197} background noborder 8ths
ioSlider {269, 38} {34, 167} 0.000000 2.000000 0.000000 comb2-lowpass
ioSlider {338, 37} {34, 167} 0.000000 2.000000 0.808800 comb2-abs
ioText {253, 203} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder To LP
ioText {322, 202} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder to mod
ioSlider {636, 37} {34, 167} 0.000000 1.000000 0.823500 downbeat regen
ioSlider {704, 37} {34, 167} 0.000000 1.000000 0.911700 downbeat-combs
ioText {624, 202} {62, 34} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder regen
ioText {688, 202} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder to combs
ioSlider {503, 257} {34, 167} 0.000000 1.000000 0.000000 8ths regen
ioSlider {572, 256} {34, 167} 0.000000 1.000000 0.000000 8ths-downbeat
ioText {487, 422} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder regen
ioText {556, 421} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder to downb
ioSlider {735, 258} {34, 167} 0.000000 1.000000 0.000000 16ths regen
ioSlider {804, 257} {34, 167} 0.000000 1.000000 0.000000 16ths-8ths
ioText {719, 423} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder regen
ioText {788, 422} {61, 34} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder to 8ths
ioSlider {81, 259} {34, 167} 0.000000 2.000000 1.367600 lowpass-comb1
ioSlider {150, 258} {34, 167} 0.000000 2.000000 0.602800 lowpass-comb2
ioText {65, 424} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder to comb1
ioText {134, 423} {66, 32} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder to comb2
ioSlider {273, 258} {34, 167} 0.000000 2.000000 1.352800 abs-comb1
ioSlider {342, 257} {34, 167} 0.000000 2.000000 0.147000 abs-comb2
ioText {257, 423} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder to comb1
ioText {326, 422} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder to comb2
ioSlider {207, 454} {180, 34} 1.000000 100.000000 20.265400 Mod Frequency
ioText {296, 487} {38, 24} display 20.265400 0.000010 "Mod Frequency" left "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder <double click to edit text>
ioSlider {26, 454} {175, 34} 6.000000 14.000000 6.500000 lowpass cutoff octave
ioText {165, 486} {33, 28} label 0.000000 0.001000 "LP cutoff" left "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Hz
ioText {100, 486} {61, 25} display 92.498604 0.001000 "lowpass cutoff" left "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Hz
ioMeter {218, 41} {30, 195} {44563, 53738, 65535} "comb2 RMS" 0.000000 "comb2 RMS" 0.000000 fill 1 0 mouse
ioText {19, 21} {185, 216} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {60197, 60197, 60197} background noborder L: comb1
ioSlider {80, 37} {34, 167} 0.000000 2.000000 0.750000 comb1-lowpass
ioSlider {149, 36} {34, 167} 0.000000 2.000000 1.485200 comb1-abs
ioMeter {29, 40} {30, 195} {44563, 53738, 65535} "comb1 RMS" 0.000000 "comb1 RMS" 0.000000 fill 1 0 mouse
ioText {64, 202} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder To LP
ioText {133, 201} {66, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder to mod
ioText {33, 486} {61, 29} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder cutoff
ioMeter {32, 261} {30, 195} {44563, 53738, 65535} "lowpass RMS" 0.000000 "lowpass RMS" 0.000000 fill 1 0 mouse
ioMeter {531, 37} {30, 195} {44563, 53738, 65535} "downbeat RMS" 0.000000 "downbeat RMS" 0.000000 fill 1 0 mouse
ioMeter {413, 258} {30, 195} {44563, 53738, 65535} "8ths RMS" 0.000000 "8ths RMS" 0.000000 fill 1 0 mouse
ioMeter {634, 262} {30, 195} {44563, 53738, 65535} "16ths RMS" 0.000000 "16ths RMS" 0.000000 fill 1 0 mouse
ioMeter {218, 260} {30, 195} {44563, 53738, 65535} "abs RMS" 0.000000 "abs RMS" 0.000000 fill 1 0 mouse
ioSlider {475, 39} {34, 167} 0.000000 0.500000 0.426450 combs-downbeat
ioText {453, 204} {77, 30} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder from combs
ioMeter {395, 20} {36, 216} {44563, 53738, 65535} "test" 0.100002 "test" 0.100002 fill 1 0 mouse
ioMeter {787, 20} {33, 219} {44563, 53738, 65535} "downbeat gate" 0.983457 "downbeat gate" 0.983457 fill 1 0 mouse
ioSlider {576, 36} {34, 167} 0.000000 0.500000 0.154400 downbeat mix
ioText {569, 201} {49, 34} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder mix
ioSlider {449, 257} {34, 167} 0.000000 2.000000 2.000000 8ths mix
ioText {442, 422} {49, 34} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder mix
ioSlider {674, 257} {34, 167} 0.000000 2.000000 1.838200 16ths mix
ioText {667, 422} {49, 34} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder mix
ioText {208, 485} {93, 28} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder mod frequency
ioText {364, 515} {27, 27} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder up
ioText {206, 514} {27, 27} label 0.000000 0.001000 "" left "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder dn
ioSlider {235, 510} {128, 35} -1.000000 1.000000 0.216400 Mod Dir
</macgui>
