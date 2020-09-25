FUNCTION main {
	//DoAscent().
	    //DoCountdown().
	//doSafeStage().
	//stageDeltaV().
	//UNTIL APOAPSIS > 100100 {
    //    DoAutoStage().
    //}
	//DoShutdown().
	//circularize().
    
	STAGE.
	global TGT is VESSEL("Kerbal X-JB").
	doTransfer().
	doHoverslam().
	WAIT UNTIL FALSE.
}
	
FUNCTION warp {
    print "Warping to next maneuver...".
    global n is nextnode.
    local node_time is time:seconds + n:eta. 
    kuniverse:timewarp:warpto(node_time - 60).
}	
FUNCTION circularize {
	PRINT "Circularization is being figured out!".
	local circ is list(0).
	set circ to improveConv(circ, eccentScore@).
	ExeMan(list(TIME:SECONDS + ETA:APOAPSIS, 0, 0, circ[0])).
	
}
FUNCTION notPast {
	PARAMETER originalFunc.
	local replacementFunc is {
		PARAMETER data.
		IF data[0] < TIME:SECONDS + 15 {
			RETURN 2^64.	
		}
		ELSE {
			RETURN originalFunc(data).
		}
	}.
	RETURN replacementFunc@.
}

FUNCTION doTransfer {
	
	local startPoint is ternarySearch(
		angleToMun@,
		TIME:SECONDS + 30,
		TIME:SECONDS + 30 + ORBIT:PERIOD,
		1
	).
	
	
	PRINT "Transfer is being figured out!".
	local transfer is list(startPoint, 0, 0, 0).
	set transfer to improveConv(transfer, notPast(munTransferScore@)).
	ExeMan(transfer).
	WAIT UNTIL BODY = TGT. 
	
	
}
FUNCTION ternarySearch {
	PARAMETER f, left, right, absolutePrecision.
    UNTIL FALSE {
        IF abs(right - left) < absolutePrecision {
            return (left + right) / 2.
		}
        local leftThird is left + (right - left) / 3.
        local rightThird is right - (right - left) / 3.

        IF f(leftThird) < f(rightThird) {
            set left to leftThird.
		}
        ELSE {
			set right to rightThird.
		}
	}
}

FUNCTION angleToMun {
	PARAMETER t.
	RETURN VECTORANGLE(
		KERBIN:POSITION - POSITIONAT(SHIP, t),
		KERBIN:POSITION - POSITIONAT(TGT, t)
	).//TGT
}

FUNCTION munTransferScore {
	PARAMETER data.
	local mnv is node(data[0], data[1], data[2], data[3]). 
	addMan(mnv).
	local result is 0.
	if mnv:ORBIT:HASNEXTPATCH {
		set result to mnv:ORBIT:NEXTPATCH:PERIAPSIS.
	}
	ELSE {
		set result to distanceToMunAtApoapsis(mnv).
	}
	remMnv(mnv).
	RETURN result.	
}

FUNCTION distanceToMunAtApoapsis {
	PARAMETER mnv.
	local apoapsisTime is ternarySearch(
	altitudeAt@,
	TIME:SECONDS + mnv:ETA,
	TIME:SECONDS + mnv:ETA + (mnv:ORBIT:PERIOD / 2),
	1
	).
	return (POSITIONAT(SHIP, apoapsisTime) - POSITIONAT(TGT, apoapsisTime)):MAG.//Mun, apoapsisTime)):MAG.
}

FUNCTION altitudeAt {
	PARAMETER t.
	RETURN KERBIN:ALTITUDEOF(POSITIONAT(SHIP, t)).
}

FUNCTION eccentScore {
	PARAMETER data.
	local mnv is node(TIME:SECONDS + ETA:APOAPSIS, 0, 0, data[0]).
	addMan(mnv).
	local result is mnv:ORBIT:ECCENTRICITY. // 0 is good
	remMnv(mnv).
	RETURN result.
}


FUNCTION improveConv {
	PARAMETER data, scoreFunction.
	FOR stepSize in list(100, 10, 1, 0.1) {
		UNTIL FALSE {
			set oldScore to scoreFunction(data).
			set data to improve(data, stepSize, scoreFunction).
			if oldScore <= scoreFunction(data) {
				BREAK.
			}
		}
	}
	RETURN data.
}


FUNCTION improve {
	PARAMETER data, stepSize, scoreFunction.
	local scoregoal is scoreFunction(data).
	local bestcandidate is data.
	local candidates is list().
	local index is 0.
	until index >= data:length {
		local incCand is data:copy().
		local decCand is data:copy().
		set incCand[index] to incCand[index] + stepSize.
		set decCand[index] to decCand[index] - stepSize.
		candidates:add(incCand).
		candidates:add(decCand).
		set index to index + 1.
	}
	for candidate in candidates {
		local candidatescore is scoreFunction(candidate).
		if candidatescore < scoregoal {
			set scoregoal to candidatescore.
			set bestcandidate to candidate.
		}
	}
	return bestcandidate.
}


FUNCTION ExeMan {
	PARAMETER mlist.
	local mnv is node(mlist[0], mlist[1], mlist[2], mlist[3]).
	addMan(mnv).
	burncheck(mnv).
	local starttime is calcStartTime(mnv).

    print "Warping to next maneuver...". //jb
    kuniverse:timewarp:warpto(starttime - 65). //jb

	WAIT UNTIL TIME:SECONDS > starttime - 60.
	lockSteering(mnv).
	PRINT starttime.
	WAIT UNTIL TIME:SECONDS > starttime.
	LOCK THROTTLE TO thrott(mnv).
	PRINT "Executing Maneuver Node.".
	UNTIL mnv:DELTAV:MAG < 0.1 {
		WAIT 0.1.
		DoAutoStage().
	}
	LOCK THROTTLE TO 0.
	remMnv(mnv).
	PRINT "MANEUVER COMPLETED!".
}

FUNCTION thrott {
	PARAMETER mnv.
	local maxAcc to MAXTHRUST / SHIP:MASS.
	set maxAcc to MAX(0.001, maxAcc).
	//Print "Throttle :" + MIN(mnv:DELTAV:MAG / maxAcc, 1).
	RETURN MIN(mnv:DELTAV:MAG / maxAcc, 1).
}

FUNCTION addMan {
	PARAMETER mnv.
	ADD mnv.
}

FUNCTION calcStartTime {
	PARAMETER mnv.
	local t is burnTime(mnv:DELTAV:MAG / 2).
	RETURN TIME:SECONDS + mnv:ETA - t.
}

FUNCTION burnTime {
	
    print "CALCULATING BURN TIME!!!".

    PARAMETER dV.
	local g0 is 9.80665.
	local isp is 0.

    list engines in myEngines.
	for en in myEngines {
        print "evaluating engine:" + en + ", en:isp:" + en:isp + ", en:avalableThrust:" + en:availableThrust + ", ship:availableThrust:" + ship:availableThrust.
		if (en:isp > 0 and en:availableThrust > 0 and ship:availableThrust > 0) {//not en:flameout and 
			set isp to isp + (en:isp * (en:availableThrust / ship:availableThrust)).
        }
    }
    print "ship mass = " + ship:mass + ", isp = " + isp.
    local mf is ship:mass / constant():e^(dV / (isp * g0)).
    local fuelFlow is ship:availableThrust / (isp * g0).
    local t is (ship:mass - mf) / fuelFlow.
    PRINT "Burntime :" + t.
    return t.
}

FUNCTION lockSteering {
	PARAMETER mnv.
	LOCK STEERING TO mnv:BURNVECTOR.
	PRINT "STEERING LOCKED TO MANEUVER VECTOR.".
}

FUNCTION remMnv {
	PARAMETER mnv.
	UNLOCK STEERING.
	REMOVE mnv.
}

FUNCTION DoAscent{
	LOCK THROTTLE TO 1.0.
	LOCK targetpitch TO 81.5934 - 0.00146703 * ALT:RADAR.
	SET targetdirection TO 90.
	LOCK STEERING TO HEADING(targetdirection, targetpitch).
}
FUNCTION DoCountdown {
	CLEARSCREEN.
	PRINT "Counting Down...".
	SET countdown TO 3.
	UNTIL countdown = 0 {
		PRINT "..." + countdown.
		WAIT 1.
		SET countdown TO countdown - 1.
		CLEARSCREEN.
	}
}
FUNCTION DoShutdown {
	LOCK THROTTLE TO 0.
	LOCK STEERING TO PROGRADE.
}
	
FUNCTION burnCheck {
	PARAMETER mnv.
	local SdV is stageDeltaV().
	PRINT "Maneuver DeltaV Required: " + mnv:DELTAV:MAG.
	IF SdV < mnv:DELTAV:MAG {
		doSafeStage().
		}
}
	
FUNCTION stageDeltaV {
	set shipresources to stage:resources.
	list engines in shipeng.
	for res in shipresources {
		
		if res:name = "liquidfuel" {
			set stagedrymass to ship:mass - (res:amount * .005) * (20/9).
			break.
			}
	}
	for eng in shipeng {
		if eng:ignition and stage:number = eng:stage {
			local SdV is (CONSTANT:g0 * (eng:isp *(ln(ship:mass / stagedrymass)))).
			Print "DeltaV Remaining in Stage: " + SdV.
			return SdV.
			}
		}
	}
	
	
FUNCTION DoAutoStage {
	IF not(defined oldthrust) {
		DECLARE global oldthrust TO SHIP:AVAILABLETHRUST.
	}
	IF SHIP:AVAILABLETHRUST < (oldthrust - 10) {
		UNTIL FALSE {
			
			doSafeStage(). WAIT 1.
			stageDeltaV().
			IF SHIP:AVAILABLETHRUST > 0 {
				BREAK.
			}
		}
		DECLARE global oldthrust TO SHIP:AVAILABLETHRUST.
	}
}

FUNCTION doSafeStage {
	WAIT UNTIL stage:ready.
	STAGE.
}

FUNCTION doHoverslam {

	LOCK STEERING TO srfRetrograde.
	LOCK pct to stoppingDistance() / distToGrnd().
	WAIT UNTIL pct > 1.
	LOCK THROTTLE to pct.
	WHEN distToGrnd() > 500 THEN { GEAR ON. }
	WAIT UNTIL SHIP:VERTICALSPEED > 0.
	LOCK THROTTLE TO 0.
	UNLOCK STEERING.
	
}

FUNCTION distToGrnd {
	RETURN ALTITUDE - BODY:GEOPOSITIONOF(SHIP:POSITION):TERRAINHEIGHT - 4.7.
}

FUNCTION stoppingDistance {
	local grav is CONSTANT():g * (BODY:MASS / BODY:RADIUS^2).
	local maxDeceleration is (SHIP:AVAILABLETHRUST / SHIP:MASS) - grav.
	RETURN SHIP:VERTICALSPEED^2 / (2 * maxDeceleration).
	
}

main().


