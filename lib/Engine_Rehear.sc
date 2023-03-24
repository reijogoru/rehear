// CroneEngine_Rehear
Engine_Rehear : CroneEngine {

    var synthSampler;
    var oscs;
    var osfun;

    // don't change this
    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

   
alloc {
    
     SynthDef("Rehear", {
			arg out = 0,
			freq, sub_div, noise_level,
			cutoff, resonance,
			attack, release,
			bufnum,
			amp, pan,
			rate = 1,
	    pos = 0,
      trig = 1,
      slew=4;
   
    var lpf_freq = rate.abs.linlin(1, 3, 20000, 5000); // make fast forward less grating on ears
    var sig, playhead, isPlaying;
    rate=Lag.kr(rate,slew);
    #sig, playhead, isPlaying = SuperPlayBufX.arDetails(2, bufnum, rate, trig, start: pos, loop: 0);
    SendReply.ar(Impulse.ar(10), '/playhead', playhead.components); // send both components of playhead
    LPF.ar(sig, lpf_freq);
		Out.ar(out,sig);
		}).add;
	context.server.sync;	




		
 synthSampler =  Synth("Rehear",target:context.server);


  OSCdef(\playhead, { |msg|
 ("Playhead: %       BufDur: %".format(
    SuperPair(*msg[3..4]).asFloat,
 ~buf.duration.asFloat)
 );
 NetAddr("127.0.0.1", 10111).sendMsg("position",SuperPair(*msg[3..4]).asFloat, "duration",~buf.duration.asFloat);
}, '/playhead');




this.addCommand("buf","s", { arg msg;
                Buffer.freeAll;
                Buffer.read(context.server,msg[1],action:{
                arg buffer;
                ~buf = buffer;
               synthSampler.set(\bufnum,buffer);
               
               
            });
        });
	

        
this.addCommand("rate","f", { arg msg;
            synthSampler.set(
                \rate,msg[1],
            );
        });
        
this.addCommand("slew","f", { arg msg;
            synthSampler.set(
                \slew,msg[1],
            );
        });
        
        

}

free {synthSampler.free}

}