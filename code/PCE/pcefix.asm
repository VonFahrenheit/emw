header
sa1rom

	org $048259
		dl read3($01808C+$01)


print "Fahrenheit's constant for this ROM is: $", hex(read3($01808C+$01)), "."