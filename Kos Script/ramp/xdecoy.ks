run once lib_ui.

FROM {local x is 35.} UNTIL x = 0 STEP {set x to x-1.} DO {
  print "ctl intructions received".
  print "mission ensuing:".  
  print "countdown: T-" + x.
  wait 1.
  clearScreen.
}
LIST TARGETS IN targetList.
local TgtAppears is false.
until TgtAppears = true {
    FOR tgt IN targetList {
        //print "Name = " + tgt:NAME.
        if (tgt:NAME = "protector") { 
            set target to tgt.
            set TgtAppears to true.
            uiBanner("decoy", "Target set").
        }
    }
    wait 10.
}

run once lib_staging.
stagingCheck().

RCS on.
SAS on.

//all decoy wants to do is lure the protector in and run away...
local lock dist to (target:position - ship:position):mag.
FROM {local xx is 23.} UNTIL xx = 0 STEP {set xx to xx-1.} DO {
    wait 5.
    if dist < 20 {
        uiBanner("decoy", "Enemy@ " + dist + " Moving...").
        SET SHIP:CONTROL:FORE TO 1.
        WAIT 2.
        SET SHIP:CONTROL:FORE to 0.0.
    }
}

RCS off.
uiBanner("decoy", "Done. Waiting further instruction").
SET SHIP:CONTROL:NEUTRALIZE to True.
