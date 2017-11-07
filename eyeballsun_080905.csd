<csinstruments>
; first feedback attempt
; by Captain Mikee
; Sep 4, 2008

sr = 44100
kr = 441
ksmps = 100
nchnls = 2

gaSend1	init	0
gaSend2	init	0
gaSend3	init  0
gaSend4	init  0
gaSend5	init  0
gaSend6	init  0


; *******************************************************************************
; Instrument 1 - Delay Line

		instr 1

iDelayTime	=  p4

aSig		delay gaSend1, iDelayTime
aSig 		= gaSend1 + aSig

;				imeth=2 tanh method	ilimit
aSig		clip 	aSig,	2,				10000

		outs1	aSig

kRMS		rms aSig
		outvalue "k1RMS", kRMS / 10000

; clear sends for next cycle

gaSend1	= 0

; feedback mix levels
kMix1		invalue "Send 1 - 4"
kMix2		invalue "Send 1 - 5"
kMix3		invalue "Send 1 - 6"

gaSend4 = gaSend4 + ( kMix1 * aSig )
gaSend5 = gaSend5 + ( kMix2 * aSig )
gaSend6 = gaSend6 + ( kMix3 * aSig )

		endin

; *******************************************************************************
; Instrument 2 - Delay Line

		instr 2

iDelayTime	=  p4

aSig		delay gaSend2, iDelayTime
aSig 		= gaSend2 + aSig

;				imeth=2 tanh method	ilimit
aSig		clip 	aSig,	2,				10000

aSig = aSig * 0.707

		outs	aSig, aSig

kRMS		rms aSig 
		outvalue "k2RMS", kRMS / 10000

; clear sends for next cycle

gaSend2	= 0

; feedback mix levels
kMix1		invalue "Send 2 - 4"
kMix2		invalue "Send 2 - 5"
kMix3		invalue "Send 2 - 6"

gaSend4 = gaSend4 + ( kMix1 * aSig )
gaSend5 = gaSend5 + ( kMix2 * aSig )
gaSend6 = gaSend6 + ( kMix3 * aSig )

		endin

; *******************************************************************************
; Instrument 3 - Delay Line

		instr 3

iDelayTime	=  p4

aSig		delay gaSend3, iDelayTime
aSig 		= gaSend3 + aSig

;				imeth=2 tanh method	ilimit
aSig		clip 	aSig,	2,				10000

		outs2	aSig

kRMS		rms aSig 
		outvalue "k3RMS", kRMS / 10000

; clear sends for next cycle

gaSend3	= 0

; feedback mix levels
kMix1		invalue "Send 3 - 4"
kMix2		invalue "Send 3 - 5"
kMix3		invalue "Send 3 - 6"

gaSend4 = gaSend4 + ( kMix1 * aSig )
gaSend5 = gaSend5 + ( kMix2 * aSig )
gaSend6 = gaSend6 + ( kMix3 * aSig )

		endin

; *******************************************************************************
; Instrument 4 - Bandpass filter with light tremelo

		instr 4

iMinFreq		= p4
iMaxFreq		= p5
iCenterFreq		= ( iMinFreq + iMaxFreq ) / 2
iBandwidth		= ( iMaxFreq - iMinFreq ) / 2

aSig		tone gaSend4, iMaxFreq
aSig		atone	aSig, iMinFreq

; Tremelo

kIntensity	rms gaSend6
kTremeloRate = 0.5 + kIntensity / 1500

;			amp	cps	method=0 sine
kTremelo	lfo	0.1,	7.5023,	5
aSig = aSig * ( kTremelo + 0.9 )

;				imeth=2 tanh method	ilimit
aSig		clip 	aSig,	2,				10000

kRMS		rms aSig 
		outvalue "k4RMS", kRMS / 10000

; clear sends for next cycle

gaSend4	= 0

; feedback mix levels
kMix1		invalue "Send 4 - 1"
kMix2		invalue "Send 4 - 2"
kMix3		invalue "Send 4 - 3"

gaSend1 = gaSend1 + ( kMix1 * aSig )
gaSend2 = gaSend2 + ( kMix2 * aSig )
gaSend3 = gaSend3 + ( kMix3 * aSig )

		endin

; *******************************************************************************
; Instrument 5 - Bandpass filter with tremelo

		instr 5

iMinFreq		= p4
iMaxFreq		= p5
iCenterFreq		= ( iMinFreq + iMaxFreq ) / 2
iBandwidth		= ( iMaxFreq - iMinFreq ) / 2

aSig		reson gaSend5, iCenterFreq, iBandwidth

; Tremelo

kIntensity	rms gaSend6
kTremeloRate = 0.5 + kIntensity / 900

;			amp	cps	method=0 sine
kTremelo	lfo	0.9,	kTremeloRate,	5
aSig = aSig * ( kTremelo + 0.1 )

;				imeth=2 tanh method	ilimit
aSig		clip 	aSig,	2,				10000

kRMS		rms aSig 
		outvalue "k5RMS", kRMS / 10000

; clear sends for next cycle

gaSend5	= 0

; feedback mix levels
kMix1		invalue "Send 5 - 1"
kMix2		invalue "Send 5 - 2"
kMix3		invalue "Send 5 - 3"

gaSend1 = gaSend1 + ( kMix1 * aSig )
gaSend2 = gaSend2 + ( kMix2 * aSig )
gaSend3 = gaSend3 + ( kMix3 * aSig )

		endin

; *******************************************************************************
; Instrument 6 - Bandpass filter with tremelo

		instr 6

iMinFreq		= p4
iMaxFreq		= p5
iCenterFreq		= ( iMinFreq + iMaxFreq ) / 2
iBandwidth		= ( iMaxFreq - iMinFreq ) / 2

aSig		reson gaSend6, iCenterFreq, iBandwidth

; Tremelo

kIntensity	rms gaSend6
kTremeloRate = 0.5 + kIntensity / 450

;			amp	cps	method=0 sine
kTremelo	lfo	1,	kTremeloRate,	0
aSig = aSig * kTremelo

;				imeth=2 tanh method	ilimit
aSig		clip 	aSig,	2,				10000

kRMS		rms aSig 
		outvalue "k6RMS", kRMS / 10000

; clear sends for next cycle

gaSend6	= 0

; feedback mix levels
kMix1		invalue "Send 6 - 1"
kMix2		invalue "Send 6 - 2"
kMix3		invalue "Send 6 - 3"

gaSend1 = gaSend1 + ( kMix1 * aSig )
gaSend2 = gaSend2 + ( kMix2 * aSig )
gaSend3 = gaSend3 + ( kMix3 * aSig )

		endin

; *******************************************************************************
; Instrument 100 - Background Hiss

		instr 100

kLevel	=  p4

aSig		pinkish kLevel

gaSend1 = gaSend1 + aSig
gaSend2 = gaSend2 + aSig
gaSend3 = gaSend3 + aSig

		endin
</csinstruments>
<csscore>
f1 0 512 10 1


;instr	start	dur	delay time

i1		0 	3600 	0.02				; 50 hz
i2		0 	3600 	0.015874010519682		; up a major 3rd
i3		0 	3600 	0.0125992104989487	; up another major 3rd

/*
i1		0 	3600 	0.01				; 100 hz
i2		0 	3600 	0.00840896415253715	; up a minor third
i3		0 	3600 	0.00667419927085017	; up an equal tempered 5th
*/

/*
i1		0 	3600 	0.01				; 100 hz
i2		0 	3600 	0.00749153538438341	; up an equal tempered 4th
i3		0 	3600 	0.00561231024154687	; and another one
*/

/*
i1		0 	3600 	0.01				; 100 hz
i2		0 	3600 	0.00618033988749897	; / the golden mean	
i3		0 	3600 	0.00381966011250108	; again	
*/

;instr	start	dur	min freq	max freq
i4		0 	3600 	20		500		
i5		0	3600	1000		10000		
i6		0	3600	5000		20000		

i100	0 3600 1
</csscore>

</csoundsynthesizer>
<macoptions>
Version: 3
Render: Real+File
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 325 45 1012 747
CurrentView: io
IOViewEdit: Off
Options: -b128 -A -o/Users/mike/devel/csound/work/feedback5.aif -s -m167 -R --midi-velocity-amp=4 --midi-key-cps=5 
</macoptions>
<macgui>
ioView background {60108, 65535, 63132}
ioSlider {272, 17} {34, 249} 0.000000 1.000000 0.000000 Send 2 - 4
ioSlider {320, 15} {34, 249} 0.000000 1.000000 0.000000 Send 2 - 5
ioSlider {99, 18} {34, 249} 0.000000 1.000000 0.000000 Send 1 - 5
ioSlider {48, 18} {34, 249} 0.000000 1.000000 0.000000 Send 1 - 4
ioMeter {6, 17} {34, 249} {3867, 33805, 2995} "k1RMS" 0.000039 "k1RMS" 0.000039 fill 1 0 notrack
ioMeter {230, 17} {34, 249} {15056, 41515, 31992} "k2RMS" 0.000042 "k2RMS" 0.000042 fill 1 0 notrack
ioSlider {538, 15} {34, 249} 0.000000 1.000000 0.082500 Send 3 - 5
ioSlider {485, 15} {34, 249} 0.000000 1.000000 0.000000 Send 3 - 4
ioMeter {443, 15} {34, 249} {23572, 65535, 52153} "k3RMS" 0.000031 "k3RMS" 0.000031 fill 1 0 notrack
ioSlider {589, 15} {34, 249} 0.000000 1.000000 0.871500 Send 3 - 6
ioSlider {366, 16} {34, 249} 0.000000 1.000000 0.000000 Send 2 - 6
ioSlider {148, 17} {34, 249} 0.000000 1.000000 0.348600 Send 1 - 6
ioSlider {588, 314} {34, 249} 0.000000 1.000000 0.000000 Send 6 - 3
ioSlider {537, 314} {34, 249} 0.000000 1.000000 1.000000 Send 6 - 2
ioSlider {484, 314} {34, 249} 0.000000 1.000000 0.000000 Send 6 - 1
ioMeter {442, 314} {34, 249} {31971, 56933, 65535} "k6RMS" 0.000018 "k6RMS" 0.000018 fill 1 0 notrack
ioSlider {271, 316} {34, 249} 0.000000 1.000000 1.000000 Send 5 - 1
ioSlider {319, 314} {34, 249} 0.000000 1.000000 0.000000 Send 5 - 2
ioSlider {98, 317} {34, 249} 0.000000 1.000000 0.000000 Send 4 - 2
ioMeter {229, 316} {34, 249} {30161, 36731, 44481} "k5RMS" 0.000006 "k5RMS" 0.000006 fill 1 0 notrack
ioSlider {365, 315} {34, 249} 0.000000 1.000000 0.000000 Send 5 - 3
ioSlider {147, 316} {34, 249} 0.000000 1.000000 1.000000 Send 4 - 3
ioSlider {47, 317} {34, 249} 0.000000 1.000000 0.000000 Send 4 - 1
ioMeter {5, 316} {34, 249} {21881, 24531, 42405} "k4RMS" 0.000000 "k4RMS" 0.000000 fill 1 0 notrack
ioText {35, 273} {101, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Comb 1
ioText {267, 269} {101, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Comb 2
ioText {489, 268} {101, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Comb 3
ioText {25, 570} {101, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Low EQ
ioText {275, 566} {101, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Mid EQ
ioText {497, 565} {101, 33} label 0.000000 0.001000 "" center "Lucida Grande" 10 {0, 0, 0} {65535, 65535, 65535} nobackground noborder High EQ
</macgui>
