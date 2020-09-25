run once lib_ui.

wait 25.

LIST TARGETS IN targetList.
local TgtAppears is false.
until TgtAppears = true {
    FOR tgt IN targetList {
        //print "Name = " + tgt:NAME.
        if (tgt:NAME = "goal") { 
            set target to tgt.
            set TgtAppears to true.
            uiBanner("docker", "Target set").
        }
    }
    wait 10.
}

//the docker's job is to dock the "goal" satellite while the decoy distracts the protector
local lock dist to (target:position - ship:position):mag.
local docked is false.
until docked = true {
    wait 5.
    clearScreen.
    if dist < 200 {
        uiBanner("docker", "Target distance: " + dist).
        run once lib_staging.
        stagingCheck().
        runoncepath("lib_ui").
        runoncepath("lib_util").
        run xapproach.
        wait until target:position:mag < 150.
        run match.
        uiBanner("docker", "Docking target").
        run xdock. 
    }
    set docked to true.
}

RCS off.
SAS on.
uiBanner("docker", "Done. Waiting further instruction").
