-- REHEAR
-- 
--
-- press K1 to open a file





engine.name = 'Rehaar'
fileselect = require 'fileselect'

g = grid.connect()
m = midi.connect()

rate = 1
enc_pos = 1

UI=require 'ui'

loaded_files=0
Needs_Restart=false

Engine_Exists=(util.file_exists('/home/we/.local/share/SuperCollider/Extensions/SuperBinaryOpUGen.so') or util.file_exists('/home/we/.local/share/SuperCollider/Extensions/SuperBufRd.so') or util.file_exists('/home/we/.local/share/SuperCollider/Extensions/SuperPoll.so'))


function init()
    Needs_Restart=false
  if not Engine_Exists then
    clock.run(function()
      if not Engine_Exists then
        Needs_Restart=true
        Restart_Message=UI.Message.new{"installing Extensions ..."}
        redraw()
        clock.sleep(1)
        os.execute("cp /home/we/dust/code/rehaar/lib/SuperBinaryOpUGen.so /home/we/.local/share/SuperCollider/Extensions/")
        os.execute("cp /home/we/dust/code/rehaar/lib/SuperBufRd.so /home/we/.local/share/SuperCollider/Extensions/")
        os.execute("cp /home/we/dust/code/rehaar/lib/SuperPoll.so /home/we/.local/share/SuperCollider/Extensions/")
      end
     Restart_Message=UI.Message.new{"please restart norns."}
    redraw()
      clock.sleep(1)
      do return end
    end)
    do return end
  end
  
  engine.buf("/home/we/dust/audio/tape/0000.wav")
end


function load_file(file)
  
  if file ~= "cancel" then
    engine.buf(file)
    --reset()
    
  end
end


function key(n,z)
  if n==1 and z==1 then
    selecting = true
    fileselect.enter(_path.dust,load_file)
  elseif n==2 and z==1 then
    
    rate(20)
    elseif n == 2 and z == 0 then
    rate(1)
  elseif n==3 and z==1 then
    append_number_to_file(position*length)
  end
end




function rate(rate)
  for i=1,2 do
      engine.rate(rate*enc_pos)
    end
  redraw()
  end

function enc(n,d)
  if n == 3 then
    enc_pos = util.clamp(enc_pos + d,-1,1)
    rate(1)
    redraw()
    
  end
end



function redraw()
  screen.clear()
  screen.level(15)
  if Needs_Restart then
    screen.clear()
    screen.level(15)
    Restart_Message:redraw()
    screen.update()
    return
  end
  screen.move(118,62)
  if enc_pos == 1 then
  screen.text_right("-> ")
  elseif enc_pos == 0 then
     screen.text_right("-")
  else
     screen.text_right("<-")
     end
  screen.update()
end