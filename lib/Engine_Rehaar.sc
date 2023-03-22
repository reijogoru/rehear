// CroneEngine_Rehaar
Engine_Rehaar : CroneEngine {

    var synthSampler;
    var bufnum = "/home/we/dust/audio/tape/0000.wav";
    var oscs;
    
    // don't change this
    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

   
    alloc {
    ~buf = Buffer.read(context.server.sync, bufnum, action: { "OK, loaded!".postln });
       
    SynthDef("Rehaar", {
			arg out = 0,
			freq, sub_div, noise_level,
			cutoff, resonance,
			attack, release,
			
			amp, pan,
			rate = 1,
	    pos = 0,
      trig = 1;
   
    var lpf_freq = rate.abs.linlin(1, 3, 20000, 5000); // make fast forward less grating on ears
    var sig, playhead, isPlaying;
    #sig, playhead, isPlaying = SuperPlayBufX.arDetails(2, ~buf, rate, trig, start: pos);
    SendReply.ar(Impulse.ar(10), '/playhead', playhead.components); // send both components of playhead
    LPF.ar(sig, lpf_freq);

		

			Out.ar(out,sig);

		}).add;
		
		
		OSCdef(\playhead, { |msg|
    ("Playhead: %       BufDur: %".format(
        SuperPair(*msg[3..4]).asFloat.asTimeString,
        ~buf.duration.asTimeString)
    ).postln;
}, '/playhead');

oscs.put("duration",OSCFunc({ |msg| NetAddr("127.0.0.1", 10111).sendMsg("progress",msg[3],msg[3]); }, '/duration'));

 context.server.sync;

synthSampler =  Synth("Rehaar",target:context.server);

       

this.addCommand("bufnum", "s", { arg msg;
	bufnum = msg[1];
});
		
		this.addCommand("rate","f", { arg msg;
            synthSampler.set(
                \rate,msg[1],
            );
        });
        
  this.addCommand("trig","f", { arg msg;
            synthSampler.set(
                \trig,msg[1],
            );
        });


}

free {
       
       synthSampler.free
    }

}