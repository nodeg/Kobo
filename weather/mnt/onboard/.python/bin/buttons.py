from struct import unpack


format = "iihhi"
button = open("/dev/input/event0")


while 1:
    event = button.read(16)
    t1, t2, type, code, value = unpack(format, event)

        
    if code == 59:
        print("HOME")     
    elif code == 60:
        print("MENU")
    elif code == 61:
        print("SHOP")
    elif code == 62:
        print("BACK")

