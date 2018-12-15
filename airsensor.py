#!/usr/bin/python3
import time
import argparse
import board
import busio
import adafruit_bme280

def get_i2c_data(bme):
	return "{:.2f}\t{:.1f}\t{:.2f}\t{:.1f}\t{:.2f}".format(bme.humidity,bme.temperature,bme.pressure,bme.altitude,bme.sea_level_pressure)
def dayseconds():
	Now = time.localtime()
	return Now.tm_hour*60*60 + Now.tm_min*60 + Now.tm_sec
def file_name(Prefix=""):
	Start = time.localtime()
	return Prefix+"airdata_{}-{}-{}--{}-{}.dat".format(Start.tm_year,Start.tm_mon,Start.tm_mday,Start.tm_hour,Start.tm_min)


Parser = argparse.ArgumentParser(description="DataCollection of the bme280 Sensor from adafruit. Tmeperature, Humidity, Pressure and more is shown and stored at the same time")
Parser.add_argument("--prefix",metavar="PATH",help="Prefix for the OUPUT-FILE; usually a certain folder",type=str,required=False)
Args = Parser.parse_args()



i2c = busio.I2C(board.SCL, board.SDA)
bme280 = adafruit_bme280.Adafruit_BME280_I2C(i2c)
#bme280.sea_level_pressure = 1019.75

Head = "DailySecond\tHumidity\tTemperature\tPressure\tAltitude\tSeaLevelPressure"
Units = "#[s]\t[%]\t[°C]\t[hPa]\t[m]"
Prefix = ""
Time = 0

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

while Time < 86000:
	Time = dayseconds()
	Data = repr(Time) + "\t" + get_i2c_data(bme280)
	File.write("{}\n".format(Data))
	print(Data)
	#print and write everything; AFTERWARDS reset; sothat nothing interrupts the tally function call at loop start
	time.sleep(0.7)

print("END")
