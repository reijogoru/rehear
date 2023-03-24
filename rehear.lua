-- REHEAR.  ((d[-_-]b))
-- 
-- K1 load audio file
--
-- K2 fastforward or rewind
--
-- enc3 select ff, pause or rw
-- 
-- K3 mark a position
--
-- marked positions will be saved 
-- in "/home/we/dust/code/
-- rehear/markers.txt"
--




engine.name = 'Rehaar'
fileselect = require 'fileselect'

g = grid.connect()
m = midi.connect()

rate = 1
enc_pos = 1
position = 0
position_time = 0
duration = 0
duration_time = 0
formatted_time = ""
selecting = false

UI=require 'ui'

loaded_files=0
Needs_Restart=false

Engine_Exists=(util.file_exists('/home/we/.local/share/SuperCollider/Extensions/SuperBinaryOpUGen.so') or util.file_exists('/home/we/.local/share/SuperCollider/Extensions/SuperBufRd.so') or util.file_exists('/home/we/.local/share/SuperCollider/Extensions/SuperPoll.so'))

-- Initialize global variable to store the file path
file_path_t = "/home/we/dust/code/rehear/markers.txt"


function init()
    Needs_Restart=false
  if not Engine_Exists then
    clock.run(function()
      if not Engine_Exists then
        Needs_Restart=true
        Restart_Message=UI.Message.new{"installing Extensions ..."}
        redraw()
        clock.sleep(1)
        os.execute("cp /home/we/dust/code/rehear/lib/SuperBinaryOpUGen.so /home/we/.local/share/SuperCollider/Extensions/")
        os.execute("cp /home/we/dust/code/rehear/lib/SuperBufRd.so /home/we/.local/share/SuperCollider/Extensions/")
        os.execute("cp /home/we/dust/code/rehear/lib/SuperPoll.so /home/we/.local/share/SuperCollider/Extensions/")
      end
     Restart_Message=UI.Message.new{"please restart norns."}
    redraw()
      clock.sleep(1)
      do return end
    end)
    do return end
  end
  
  
  screen_redraw_clock = clock.run(
function()
      while true do
        clock.sleep(1/30) -- 30 fps
      
           update_positions()
         update_duration()
         
         
        end
      end
    )
 
  engine.buf("")
  
  params:add_number("rateslew","rateslew",0,5,1)
params:set_action("rateslew", function(x) engine.slew(x) end)
  
  
end



-- Check if the file exists and create it if it doesn't
if not util.file_exists(file_path_t) then
  local file = io.open(file_path_t, "w")
  file:close()
end


-- Define function to append a number to the file
function append_number_to_file(number)
  local total_seconds = math.floor(number)
  local minutes = math.floor(total_seconds / 60)
  local seconds = total_seconds % 60
  formatted_time = string.format("%d:%02d", minutes, seconds)
  local file = io.open(file_path_t, "a")
  file:write(formatted_time .. "\n")
  file:close()
end


function append_filename_to_file(filename)
  local file = io.open(file_path_t, "a")
  file:write("\n" .. filename .. "\n")
  file:close()
end







function osc_in(path, args, from)
  position = args[1]
  duration = args[3]

end

osc.event = osc_in

function load_file(file)
  selecting = false
  if file ~= "cancel" then
    engine.buf(file)
    redraw()
    append_filename_to_file(file)
    formatted_time = ""
    position = 0
    duration = 0
  end
end



function update_positions()
  local total_seconds = math.floor(position)
  local minutes = math.floor(total_seconds / 60)
  local seconds = total_seconds % 60
   position_time = string.format("%d:%02d", minutes, seconds)
  if selecting == false then 
  redraw() end
end

function update_duration()
  local total_seconds = math.floor(duration)
  local minutes = math.floor(total_seconds / 60)
  local seconds = total_seconds % 60
   duration_time = string.format("%d:%02d", minutes, seconds)
  if selecting == false then 
  redraw() end
end



function key(n,z)
  if n==1 and z==1 then
    selecting = true
    fileselect.enter(_path.dust,load_file)
    
  elseif n==2 and z==1 then
    
    rate(15)
    
  
    elseif n == 2 and z == 0 then
    rate(1)
  elseif n==3 and z==1 then
    append_number_to_file(position)
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
  screen.aa (1)
  screen.font_size(8)
  screen.move(125,12)
  screen.text_right(position_time .. " | " .. duration_time)
  
  screen.move(118,10)
   --screen.text_right("Pos: " .. position_time)
   screen.move(10,20)
   screen.move(10,32)
  screen.font_size(16)
  screen.text("d(-_-)b")


  screen.move(125,60)
  screen.font_size(8)
  if enc_pos == 1 then
  screen.text_right(">>")
  elseif enc_pos == 0 then
     screen.text_right("=")
  else
     screen.text_right("<<")
  end
   
  
   screen.move(2,59)
   screen.text("Last Marker: " .. formatted_time)
  
  screen.update()
end