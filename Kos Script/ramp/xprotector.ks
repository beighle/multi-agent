run once lib_ui.

wait 30.

LIST TARGETS IN targetList.
local ThreatAppears is false.
until ThreatAppears = true {
    FOR tgt IN targetList {
        //print "Name = " + tgt:NAME.
        if (tgt:NAME = "decoy") {
            set target to tgt.
            set ThreatAppears to true.
            uiBanner("protector", "Tracking Threat.").
            //LOG "protector: I'm tracking you!" to TXLog.
        }
    }
}

local lock dist to (target:position - ship:position):mag.
//print "distance to tgt = " + dist.
wait 5.
clearScreen.
if dist < 400 {
    uiBanner("protector","Threat too close. Engaged.").
    run once lib_staging.
    stagingCheck().
    runoncepath("lib_ui").
    runoncepath("lib_util").
    run approach.
    //uiBanner("protector", "Approach to 150m").
    wait until target:position:mag < 150.
    run match.
    run xpursue.
}
else {
    uiBanner("protector", "Mission is hosed. Quitting").
}

RCS off.
SAS on.
uiBanner("protector", "Done. Waiting further instruction").

