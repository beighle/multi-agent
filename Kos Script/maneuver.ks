set runmode to 0.
set num to 0.
sas off.
lights on.
rcs on.
set tht to 0.
lock throttle to tht.
until false {
    if runmode = 0 { 
        set num to num + 1.
        clearscreen.
        print("Executing runmode 0").
        print("Maneuver number "+num).
        global n is nextnode.
        local eIsp is 0.
        local flowrate is 0.
        list engines in my_engines.
        for eng in my_engines {
            set eIsp to eIsp + eng:isp*(eng:availablethrust/ship:availablethrust).
            set flowrate to flowrate + eng:availablethrust/(eng:isp*constant:g0).
        }
        local Ve is ship:availablethrust/flowrate.
        local m0 is ship:mass.
        local dv is n:deltav:mag/2.
        local node_time is time:seconds + n:eta. 
        local middle_mass is m0*(constant:e^(-1*dv/Ve)).
        local burn_start is (m0-middle_mass)/flowrate.
        global start_time is node_time - burn_start.
        
        set runmode to 1.
    }
    if runmode = 1 {
        print("Executing runmode 1").
        if time:seconds < start_time - 1200 {
           print("Warping to "+(start_time - 1200)).
           kuniverse:timewarp:warpto(start_time - 1200).
        }
        print("Aligning ship with maneuver node").
        lock steering to n:burnvector.
        wait until vectorAngle(ship:facing:vector,n:burnvector) < 1.
        print("Ship stable, warping to burn").
        kuniverse:timewarp:warpTo(start_time - 10).

        set runmode to 2.
    }
    if runmode = 2 {
       print("Executing runmode 2").
       wait until time:seconds >= start_time.
       set tht to 1.
       
       set runmode to 3.
    }
    if runmode = 3 {
        print("Executing runmode 3").
        wait until n:deltav:mag < 5.
        set acc to availableThrust/mass.
            
            until n:deltav:mag < 0.01 {
            set tht to n:deltav:mag/(acc).
            set oldv to n:deltav:mag.
            wait 0.001.  
            if n:deltav:mag > oldv break.
        }
        set tht to 0.
        lock steering to ship:facing.
        set runmode to 4.
    }
    if runmode = 4 {
        print ("Maneuver successfully executed").
        remove n.
        if hasNode {
            print("Executing next maneuver").
            set runmode to 0.
        }
        break.
    }
    wait 0.
}
Landing script

set runmode to 0.
sas off.
lights on.
gear on.
rcs on.
set thr to 0.
lock throttle to thr.
function setSpeed {
    parameter speed.
    parameter h.
    parameter dh.
    set pid to PIDLOOP(0.55,0.1,0.01,0,1).
    set thr to 0.
    lock throttle to thr.
    set pid:setpoint to -speed.
    until ship_bound:bottomaltradar < h and ship_bound:bottomaltradar > dh {
         set thr to pid:update(time:seconds,verticalspeed).
         clearscreen.
         print(speed).
         print(verticalSpeed).
         wait 0.001.
    }
}    

until false {
    if runmode = 0 {
        print("Executing runmode 0").
        global ship_bound is ship:bounds.
        global grav is orbit:body:mu/(orbit:body:radius^2).
        local eIsp is 0.
        local flowrate is 0.
        list engines in my_engines.
        for eng in my_engines {
            set eIsp to eIsp + eng:isp*(eng:availablethrust/ship:availablethrust).
            set flowrate to flowrate + eng:availablethrust/(eng:isp*constant:g0).
        }

        set runmode to 1.
    }
    if runmode = 1 {
        print("Executing runmode 1").
        local dvel is velocityAt(ship,time:seconds+eta:periapsis):surface:mag.
        set n to node(time:seconds + eta:periapsis ,0,0,0).
        set n:prograde to -dvel.
        add n.
        run burn. //Execute the maneuver node using the maneuver program

        set runmode to 2.
    }
    if runmode = 2 {
        print("Executing runmode 2").
        local acc is ship:availablethrust/ship:mass - grav.
        lock steering to srfRetrograde.
        until false {            
              lock burn_height to (verticalSpeed^2)/(2*acc) + 15.
              if ship_bound:bottomaltradar < burn_height {
                  print("Burn height is "+burn_height).
                  break.
              }
              wait 0.
        }
        
        set runmode to 3.
    }
    if runmode = 3 {
        print("Executing runmode 3").
        lock throttle to 1.
        setSpeed(10,50,10).
        setSpeed(5,10,1).
        lock steering to up.
        setSpeed(1,0,-1).
        wait until verticalSpeed >=0.
        lock throttle to 0.
        unlock steering.
        print("The Eagle has landed.").
        wait 1.
        break.
    }
}