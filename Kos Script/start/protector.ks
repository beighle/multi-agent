//core:doaction("Open Terminal", true).
//set the telnet port
SET CONFIG:TPORT TO 5410. 
// Restart telnet server:
SET CONFIG:TELNET TO FALSE.
WAIT 0.5. // important to give kOS a moment to notice and kill the old server.
SET CONFIG:TELNET TO TRUE.
print "welcome to spaceX! Type: run xprotector.".