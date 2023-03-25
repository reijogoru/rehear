// CroneEngine_Rehear
Engine_Rehear : CroneEngine {

    var synthSampler;
    var oscs;
    var osfun;
    var buffer;
    var c;
    var position;
    var rate;
 
    // don't change this
    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

   
alloc {


SynthDef("Rehear", {
			arg out = 0,
			buffer,
			amp, pan,
			rate = 1,
	    slew=4;
   
    var lpf_freq = rate.abs.linlin(1, 3, 20000, 5000); // make fast forward less grating on ears
    var sig;
    
    rate=Lag.kr(rate,slew);
    sig = VDiskIn.ar(2,buffer,rate,loop:0,sendID:14);
    LPF.ar(sig, lpf_freq);
		Out.ar(out,sig);
		}).add;
		
synthSampler =  Synth("Rehear",target:context.server);

this.addCommand("buf", "s", { arg msg;
   buffer.free;
synthSampler.free;
synthSampler =  Synth("Rehear",target:context.server);




c = SoundFile(msg[1].asString).info; 
    
    buffer =	Buffer.cueSoundFile(context.server,msg[1],0,2,bufferSize: 65536);
    synthSampler.set(\buffer,buffer);
   
   
		});
		

context.server.sync;


        
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
        
 
OSCFunc({ arg msg;
    var sendID = msg[1];
    var index = msg[3];
     //msg.postln;
      position = (index % c.numFrames / c.sampleRate);
     
    
     if (index / c.sampleRate >= c.duration) {
                
                 NetAddr("127.0.0.1", 10111).sendMsg("position",0,"duration",c.duration);
                 synthSampler.free;}
                
          
         
     {
    NetAddr("127.0.0.1", 10111).sendMsg("position",position,"duration",c.duration);}
     
},'/diskin');  





}
free {synthSampler.free;
 buffer.free;
 
}
}
