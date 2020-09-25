import telnetlib
import time


def attach_to_vessel_cpu(tnx, vessel):
    tnx.read_until(b'>')
    tnx.write(b'1\n')
    time.sleep(.2)
    tnx.write(b'1\n')
    time.sleep(.2)


def send_cmd(tnx, cmd):
    tnx.write(cmd)
    time.sleep(.2)


def startup_expect(tnx, token):
    # read xTerm garbage up until readable data begins
    x = tnx.read_until(b'T+').decode('cp437')
    # print(x)
    # read everything up to cmd entry
    token = token + "."
    x = tnx.read_until(bytes(token, 'cp437')).decode('cp437')
    # print(x)


def startup_mission(vessel, telnet_port):
    tn = telnetlib.Telnet("127.0.0.1", telnet_port)
    attach_to_vessel_cpu(tn, vessel)
    startup_expect(tn, vessel)
    cmd = "run x" + vessel + ".\n"
    send_cmd(tn, bytes(cmd, 'cp437'))
    return tn


# startup everyone's 1st mission
tn_y = startup_mission("decoy", 5411)
print("decoy mission has started")
tn_p = startup_mission("protector", 5410)
print("protector mission has started")
tn_d = startup_mission("docker", 5412)
print("docker mission has started")



time.sleep(15)
tn_p.close()
tn_y.close()
tn_d.close()
