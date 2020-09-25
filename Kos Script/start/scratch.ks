RCS on.
SAS on.

print "Gently pushing forward for x seconds.".
SET SHIP:CONTROL:FORE TO 1.
SET now to time:seconds.
WAIT until time:seconds > now + 8.
SET SHIP:CONTROL:FORE to 0.0.

print "Gently Pushing leftward".
SET SHIP:CONTROL:STARBOARD TO -0.1.
SET now to time:seconds.
WAIT until time:seconds > now + 3.
SET SHIP:CONTROL:STARBOARD to 0.0.

SET SHIP:CONTROL:FORE TO 1.
SET now to time:seconds.
WAIT until time:seconds > now + 8.
SET SHIP:CONTROL:FORE to 0.0.

print "Gently Pushing rightward".
SET SHIP:CONTROL:STARBOARD TO 0.1.
SET now to time:seconds.
WAIT until time:seconds > now + 3.
SET SHIP:CONTROL:STARBOARD to 0.0.

//print "Starting an upward rotation.".
//SET SHIP:CONTROL:PITCH TO 0.2.
//SET now to time:seconds.
//WAIT until time:seconds > now + 0.5.
//SET SHIP:CONTROL:PITCH to 0.0.

print "Giving control back to the player now.".
SET SHIP:CONTROL:NEUTRALIZE to True.



//*******************************
print "rendez complete".

RCS on.
SAS on.

print "locking steering to target".
lock steering to target:facing.
wait 10.
local lock dist to (target:position - ship:position):mag.
local ThreatTooClose is false.
until ThreatTooClose = true {
    print "distance to tgt = " + dist.
    if dist < 20 {
        print "getting too close!".
        //SET SHIP:CONTROL:FORE TO -1.
        WAIT 3.
        SET SHIP:CONTROL:FORE to 0.0.
    }
    else {
        print "going to try to get closer!".
        //SET SHIP:CONTROL:FORE TO 1.
        WAIT 3.
        SET SHIP:CONTROL:FORE to 0.0.
    }
    wait 5.
}
//*******************************

//global TXlog is "0:/jblog.txt". //jb.
//deletepath(TXlog). //jb.

//set target to vessel("JBDocker").
//stage.
//print "Enter a command fool:".
//run rendezvous.

// We choose go to to the Mun and do the other things!
//set target to mun.

// TODO: Do the other things, not because they are easy, but because they are hard!
 //run transfer.

// TODO: nuke these after uncommenting transfer command.
//uiBanner("Mission", "Need input; see kOS console").
//print "To visit Mun, edit the craft's start file, save changes, and reboot this processor.".
