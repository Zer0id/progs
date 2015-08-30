local r = require('robot')
local component = require('component')
local computer = require('computer')
local gpu = component.gpu
local equip = component.inventory_controller.equip
local item = component.inventory_controller.getStackInInternalSlot
i=0
drill='IC2:itemToolDDrill'
lev=math.floor(r.level())

gpu.fill(1,1,50,16,' ')
print('starting...   level '..lev)
if lev==30 then error('maximum level reached') end

function remain()
  m1=r.level()
  r.place()
  r.swing()
  m2=r.level()
  gpu.fill(1,1,50,1,' ')
  gpu.set(1,1,tostring(math.floor((m2-math.floor(m2))*100)))
  gpu.set(3,1,'% complete')
  gpu.set(16,1,tostring(math.floor((math.floor(m1)+1-m1)/(m2-m1))))
  gpu.set(22,1,' cycles remain')
  if m2==30 then error('maximum level reached') end
  check()
end

function check()
  dur=r.durability()
  if dur==nil then wrong=true end
  equip()
  if r.count()>0 then
    if item().name~=drill then wrong=true end
  end
  equip()
  if wrong==true then missingDrill() end
  dur=r.durability()
  if dur<0.1 then recharge() end
end

function missingDrill()
  while wrong==true do
    equip()
    if r.count()>0 then
      if item().name==drill then wrong=false end
    end
    if wrong==false then gpu.fill(1,1,50,1,' ') break end
    gpu.set(1,1,'Верни бур на место!                ')
    computer.beep(400) computer.beep(500)
    os.sleep(1)
  end
  equip()
end

function recharge()
  gpu.fill(1,1,50,1,' ')
  gpu.set(1,1,'    waiting for recharge..')
  equip()
  r.turnAround()
  r.drop()
  for i1=30,0,-1 do
    gpu.set(28,1,'  ')
    gpu.set(28,1,tostring(i1))
    os.sleep(1)
  end
  r.suck()
  r.turnAround()
  equip()
  gpu.fill(1,1,50,1,' ')
end

remain()

while true do
  r.place()
  r.swing()
  i=i+1
  if math.floor(i/9) == i/9 then remain() end
  if math.floor(r.level()) > lev then
    lev=math.floor(r.level())
    print('level up!  new level: '..lev..'  '..i..' blocks replaced')
    for b=200,800,50 do computer.beep(b) end
    i=0
  end
end
