#!/usr/bin/python3
import time
import argparse
import board
import busio
import digitalio
import adafruit_bme280
import adafruit_tsl2591

def get_bme_data(bme):
	return "{:.2f}\t{:.2f}\t{:.2f}\t{:.1f}\t{:.2f}".format(bme.humidity,bme.temperature,bme.pressure,bme.altitude,bme.sea_level_pressure)
def get_tsl_data(tsl):
	return "{:.2f}\t{}\t{}".format(tsl.lux,tsl.visible,tsl.infrared)
def dayseconds():
	Now = time.localtime()
	return Now.tm_hour*60*60 + Now.tm_min*60 + Now.tm_sec
def file_name(Prefix=""):
	Start = time.localtime()
	return Prefix+"airdata_{}-{}-{}.dat".format(Start.tm_year,Start.tm_mon,Start.tm_mday)


Parser = argparse.ArgumentParser(description="DataCollection of the bme280 Sensor from adafruit. Tmeperature, Humidity, Pressure and more is shown and stored at the same time")
Parser.add_argument("--prefix",metavar="PATH",help="Prefix for the OUPUT-FILE; usually a certain folder",type=str,required=False)
Args = Parser.parse_args()



spi = busio.SPI(board.SCK, MOSI=board.MOSI, MISO=board.MISO)
i2c = busio.I2C(board.SCL, board.SDA)
cs = digitalio.DigitalInOut(board.D5)
bme280 = adafruit_bme280.Adafruit_BME280_SPI(spi, cs)
tsl2591 = adafruit_tsl2591.TSL2591(i2c)

Head = "DailySecond\tHumidity\tTemperature\tPressure\tAltitude\tSeaLevelPressure\tLux\tVisibleLight\tInfraredLevel"
Units = "#[s]\t[%]\t[°C]\t[hPa]\t[m]\t[m]\t[lx]\t[]\t[]"
Prefix = ""
Time = 0
TimeLast = 0

if Args.prefix:
	Prefix = Args.prefix
	if Prefix[-1] != "/":
		Prefix += "/"



File = open(file_name(Prefix),"w",buffering=1)
File.write("#Starting on {}\n".format(time.ctime()))
File.write(Head+"\n")
File.write(Units+"\n")
print("#Starting on {}".format(time.ctime()))
print(Head)
print(Units)

Time = dayseconds()
while TimeLast <= Time:
	Start = time.time()
	Data = repr(Time) + "\t" + get_bme_data(bme280) + "\t" + get_tsl_data(tsl2591)
	File.write("{}\n".format(Data))
	print(Data)
	Stop = time.time()
	#print and write everything; AFTERWARDS reset; sothat nothing interrupts the tally function call at loop start
	time.sleep(1-(Stop-Start))
	TimeLast = Time
	Time = dayseconds()

print("END")
