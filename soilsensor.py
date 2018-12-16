#!/usr/bin/python3
import argparse
import time
import pigpio

def dayseconds():
	Now = time.localtime()
	return Now.tm_hour*60*60 + Now.tm_min*60 + Now.tm_sec
def file_name(Prefix=""):
	Start = time.localtime()
	print(Prefix)
	return Prefix+"soildata-py_{}-{}-{}.dat".format(Start.tm_year,Start.tm_mon,Start.tm_mday)


Parser = argparse.ArgumentParser(description="DataCollection of the bme280 Sensor from adafruit. Tmeperature, Humidity, Pressure and more is shown and stored at the same time.")
Parser.add_argument("--prefix",metavar="PATH",help="Prefix for the OUPUT-FILE; usually a certain folder.",type=str,required=False)
Parser.add_argument("-p",metavar="N",help="Set Pulse to N µs, default p = 20µs.", default=[20], type=int,nargs=1,required=False)
Parser.add_argument("-s",metavar="N",help="Set sample rate to N deciseconds [10^-1 s]; default s = 10.",default=[10],type=int,nargs=1,required=False)
Parser.add_argument("-g",metavar="N",help="Listen to GPIO-Pin(s) N, where soil humidity sensors are connected.",nargs="+",type=int,required=True)
Args = Parser.parse_args()


Sensors = Args.g #Read from GPIO XX
Head = "DailySecond\t"+"\t".join("GPIO_"+str(Gpio) for Gpio in Sensors)
Units = "#[s]\t"+"\t".join("[Hz]" for Gpio in Sensors)
Prefix = ""
PulseMS = 10
PulseDelay = 20
PinMask = 0
Time = 0
TimeLast = 0
if Args.prefix:
	Prefix = Args.prefix
	if Prefix[-1] != "/":
		Prefix += "/"
if Args.p:
	PulseDelay = Args.p[0]
if Args.s:
	PulseMS = Args.s[0]
for Pin in Sensors:
	PinMask |= 1<<Pin


PI = pigpio.pi()
PI.wave_clear()
for Gpio in Sensors:
    PI.set_mode(Gpio,pigpio.INPUT)
PulseGpio = [pigpio.pulse(PinMask,0,PulseDelay),pigpio.pulse(0,PinMask,PulseDelay)]
PI.wave_add_generic(PulseGpio)
WaveID = PI.wave_create()
#next function can have 3 parameter; third is user-defined callback function; if not defined, just count edges: CallBacks[X].tally() or .reset_tally()
CallBacks = [PI.callback(Gpio, pigpio.RISING_EDGE) for Gpio in Sensors]

File = open(file_name(Prefix),"w",buffering=1)
File.write("#Starting on {}\n".format(time.ctime()))
File.write(Head+"\n")
File.write(Units+"\n")
print("#Starting on {}".format(time.ctime()))
print(Head)
print(Units)

for Call in CallBacks:
	Call.reset_tally()
time.sleep(0.1*PulseMS)
Time = dayseconds()
while TimeLast <= Time:
	Time = dayseconds()
	Data = repr(Time) + "\t" + "\t".join(str(Call.tally()) for Call in CallBacks)
	File.write("{}\n".format(Data))
	print(Data)
	#print and write everything; AFTERWARDS reset; sothat nothing interrupts the tally function call at loop start
	for Call in CallBacks:
		Call.reset_tally()
	time.sleep(0.1*PulseMS)
	TimeLast = Time
	Time = dayseconds()
	
PI.wave_delete(WaveID)
PI.stop()
i2c.deinit()
File.close()
print("END")
