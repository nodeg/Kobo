#!/usr/bin/python
import urllib2
import pygame, os, time

import config

from pygame.locals import *
from xml.dom.minidom import parseString
from datetime import date, datetime, timedelta
from subprocess import call

os.environ['SDL_NOMOUSE'] = '1'
print("Kobo Wifi weather forecast started.")

link2png =   {
               "wsymbol_0001_sunny.png":"36.png",
               "wsymbol_0002_sunny_intervals.png":"34.png",
               "wsymbol_0003_white_cloud.png":"26.png",
               "wsymbol_0004_black_low_cloud.png":"26.png",
               "wsymbol_0005_hazy_sun.png":"32.png",
               "wsymbol_0006_mist.png":"20.png",
               "wsymbol_0007_fog.png":"20.png",
               "wsymbol_0008_clear_sky_night.png":"31.png",
               "wsymbol_0009_light_rain_showers.png":"39.png",
               "wsymbol_0010_heavy_rain_showers.png":"39.png",
               "wsymbol_0011_light_snow_showers.png":"41.png",
               "wsymbol_0012_heavy_snow_showers.png":"41.png",
               "wsymbol_0013_sleet_showers.png":"42.png",
               "wsymbol_0014_light_hail_showers.png":"18.png",
               "wsymbol_0015_heavy_hail_showers.png":"18.png",
               "wsymbol_0016_thundery_showers.png":"37.png",
               "wsymbol_0017_cloudy_with_light_rain.png":"11.png",
               "wsymbol_0018_cloudy_with_heavy_rain.png":"12.png",
               "wsymbol_0019_cloudy_with_light_snow.png":"13.png",
               "wsymbol_0020_cloudy_with_heavy_snow.png":"16.png",
               "wsymbol_0021_cloudy_with_sleet.png":"05.png",
               "wsymbol_0022_cloudy_with_light_hail.png":"18.png",
               "wsymbol_0023_cloudy_with_heavy_hail.png":"18.png",
               "wsymbol_0024_thunderstorms.png":"04.png",
               "wsymbol_0025_light_rain_showers_night.png":"45.png",
               "wsymbol_0026_heavy_rain_showers_night.png":"45.png",
               "wsymbol_0027_light_snow_showers_night.png":"46.png",
               "wsymbol_0028_heavy_snow_showers_night.png":"46.png",
               "wsymbol_0029_sleet_showers_night.png":"05.png",
               "wsymbol_0030_light_hail_showers_night.png":"18.png",
               "wsymbol_0031_heavy_hail_showers_night.png":"18.png",
               "wsymbol_0032_thundery_showers_night.png":"47.png",
               "wsymbol_0033_cloudy_with_light_rain_night.png":"11.png",
               "wsymbol_0034_cloudy_with_heavy_rain_night.png":"12.png",
               "wsymbol_0035_cloudy_with_light_snow_night.png":"13.png",
               "wsymbol_0036_cloudy_with_heavy_snow_night.png":"16.png",
               "wsymbol_0037_cloudy_with_sleet_night.png":"42.png",
               "wsymbol_0038_cloudy_with_light_hail_night.png":"18.png",
               "wsymbol_0039_cloudy_with_heavy_hail_night.png":"18.png",
               "wsymbol_0040_thunderstorms_night.png":"47.png"
             }
               
en2de_dict = { "Monday":"Montag", "Tuesday":"Dienstag", "Wednesday":"Mittwoch", "Thursday":"Donnerstag", 
               "Friday":"Freitag", "Saturday":"Samstag", "Sunday":"Sonntag", 
               "Today":"heute", "Tomorrow":"morgen", "Current":"jetzt",
               "Last updated at":"Letzte Aktualisierung:",
               "Moderate or heavy snow in area with thunder":u"mittlerer bis starker \xf6rtlicher Schnee mit Donner",
               "Patchy light snow in area with thunder":u"leichter \xf6rtlicher Schnee mit Donner",
               "Moderate or heavy rain in area with thunder":u"mittlerer bis starker \xf6rtlicher Regen mit Donner",
               "Patchy light rain in area with thunder":u"leichter \xf6rtlicher Regen mit Donner",
               "Moderate or heavy showers of ice pellets":u"mittlerer bis starker Hagel",
               "Light showers of ice pellets":u"leichter Hagel",
               "Moderate or heavy snow showers":u"mittlere bis starke Schneeschauer",
               "Light snow showers":u"leichte Schneeschauer",
               "Moderate or heavy sleet":u"mittlere bis starke Graupelschauer",
               "Light sleet showers":u"leichte Graupelschauer",
               "Torrential rain shower":u"Sintflutartige Regenf\xe4lle!",
               "Moderate or heavy rain shower":u"mittlere bis starke Regenschauer",
               "Light rain shower":u"leichte Regenschauer",
               "Ice pellets":u"Hagel",
               "Heavy snow":u"starker Schnee",
               "Patchy heavy snow":u"teilweise starker Schnee",
               "Moderate snow":u"mittlerer Schnee",
               "Patchy moderate snow":u"teilweise mittlerer Schnee",
               "Light snow":u"leichter Schnee",
               "Patchy light snow":u"teilweise leichter Schnee",
               "Moderate or heavy sleet":u"mittlerer bis starker Schnee",
               "Light sleet":u"leichte Graupelschauer",
               "Moderate or Heavy freezing rain":u"mittlerer bis starker gefrierender Regen",
               "Light freezing rain":u"leichter gefrierender Regen",
               "Heavy rain":u"starker Regen",
               "Heavy rain at times":u"zeitweise starke Schauer",
               "Moderate rain":u"Regen",
               "Moderate rain at times":u"zeitweise Schauer",
               "Light rain":u"leichter Regen",
               "Patchy light rain":u"teilweise leichter Regen",
               "Heavy freezing drizzle":u"starker gefrierender Nieselregen",
               "Freezing drizzle":u"gefrierender Nieselregen",
               "Light drizzle":u"leichter Nieselregen",
               "Patchy light drizzle":u"teilweise leichter Nieselregen",
               "Freezing fog":u"gefrierender Nebel",
               "Fog":u"Nebel",
               "Blizzard":u"Schneesturm",
               "Blowing snow":u"Schneetreiben",
               "Thundery outbreaks in nearby":u"Gewitter in der N\xe4he",
               "Patchy freezing drizzle nearby":u"teilweise gefrierender Nieselregen in der N\xe4he",
               "Patchy sleet nearby":u"leichter Schneeregen in der N\xe4he",
               "Patchy snow nearby":u"leichter Schneefall in der N\xe4he",
               "Patchy rain nearby":u"leichter Regen in der N\xe4he",
               "Mist":u"Dunst",
               "Overcast":u"bedeckt",
               "Cloudy":u"bew\xf6lkt",
               "Partly Cloudy":u"teilweise bew\xf6lkt",
               "Clear":u"klar",
               "Sunny":u"sonnig" }

months = [ "Januar", "Februar", u"M\xe4rz", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember" ]

def trans (en):
    if lang == "de":
        return en2de_dict.get(en, en)
    else:
        return en

def index_error(error):
    print(error)
    print("Failed to fetch weather data.")
    print("Double check your location settings by running:")
    print(" cat /mnt/onboard/.apps/koboWeather/location")
    print("If the information is incorrect, re-set your location with:")
    print(" /mnt/onboard/.apps/koboWeather/set_location.sh")
    
def convert_to_raw(surface):
    print("Converting image . . .")
    from cStringIO import StringIO
    file_str = StringIO()
    for col in range(surface.get_width()-1,-1,-1):
        for row in range(surface.get_height()):
            x = surface.get_at((col, row))
            file_str.write(chr(x[1])+chr(x[0]))
    f = open("/tmp/img.raw", "wb")
    f.write(file_str.getvalue())
    f.close()
    print("Image converted.")
    
class TextRectException:
    def __init__(self, message = None):
        self.message = message
    def __str__(self):
        return self.message

def render_textrect(string, font, rect, text_color, background_color, justification = 0, line_spacing = 0):
    """Returns a surface containing the passed text string, reformatted
    to fit within the given rect, word-wrapping as necessary. The text
    will be anti-aliased.

    Takes the following arguments:

    string - the text you wish to render. \n begins a new line.
    font - a Font object
    rect - a rectstyle giving the size of the surface requested.
    text_color - a three-byte tuple of the rgb value of the
                 text color. ex (0, 0, 0) = BLACK
    background_color - a three-byte tuple of the rgb value of the surface.
    justification - 0 (default) left-justified
                    1 horizontally centered
                    2 right-justified

    Returns the following values:

    Success - a surface object with the text rendered onto it.
    Failure - raises a TextRectException if the text won't fit onto the surface.
    """

    import pygame
    
    final_lines = []

    requested_lines = string.splitlines()

    # Create a series of lines that will fit on the provided
    # rectangle.

    for requested_line in requested_lines:
        if font.size(requested_line)[0] > rect.width:
            words = requested_line.split(' ')
            # if any of our words are too long to fit, return.
            for word in words:
                if font.size(word)[0] >= rect.width:
                    raise TextRectException, "The word " + word + " is too long to fit in the rect passed."
            # Start a new line
            accumulated_line = ""
            for word in words:
                test_line = accumulated_line + word + " "
                # Build the line while the words fit.    
                if font.size(test_line)[0] < rect.width:
                    accumulated_line = test_line 
                else: 
                    final_lines.append(accumulated_line) 
                    accumulated_line = word + " " 
            final_lines.append(accumulated_line)
        else: 
            final_lines.append(requested_line) 

    # Let's try to write the text out on the surface.

    surface = pygame.Surface(rect.size) 
    surface.fill(background_color) 

    accumulated_height = 0
    for line in final_lines: 
        if accumulated_height + font.size(line)[1] >= rect.height:
            break
        if line != "":
            tempsurface = font.render(line, 1, text_color)
            if justification == 0:
                surface.blit(tempsurface, (0, accumulated_height))
            elif justification == 1:
                surface.blit(tempsurface, ((rect.width - tempsurface.get_width()) / 2, accumulated_height))
            elif justification == 2:
                surface.blit(tempsurface, (rect.width - tempsurface.get_width(), accumulated_height))
            else:
                raise TextRectException, "Invalid justification argument: " + str(justification)
        accumulated_height += font.size(line)[1] + line_spacing

    return surface.subsurface(pygame.Rect((0,0,rect.width,accumulated_height - line_spacing)))

def get_weather_data():
    
    print("Getting weather information . . .")

    try:
        location = open("location", "r")
        lat = location.readline().strip()
        lon = location.readline().strip()
        location.close()
    except IOError:
        print("\nCouldn't open location file.")
        print("Run the 'set_location.sh' script to set your location for the weather script.")
        return 1
    #print(lat, lon)
    #weather_link = 'http://graphical.weather.gov/xml/SOAP_server/ndfdSOAPclientByDay.php?whichClient=NDFDgenByDay&lat={0}&lon={1}&format=24+hourly&numDays=5&Unit=e'.format(lat, lon)
    weather_link='http://api.worldweatheronline.com/free/v1/weather.ashx?q={0},{1}&format=xml&includeLocation=yes&num_of_days=4&key=u93g2cb9gd3thnwbuxwug65y'.format(lat, lon)
    print(weather_link)
    weather_xml = urllib2.urlopen(weather_link)
    weather_data = weather_xml.read()
    weather_xml.close()

    dom = parseString(weather_data)

    values = {}
    try:
        values["temp"] = str(dom.getElementsByTagName('temp_%s' % temp_unit)[0].firstChild.nodeValue)
        values["humidity"] = str(dom.getElementsByTagName('humidity')[0].firstChild.nodeValue)
        values["wind_speed"] = str(dom.getElementsByTagName('windspeed%s' % speed_unit)[0].firstChild.nodeValue)
        values["wind_dir"] = str(dom.getElementsByTagName('winddir16Point')[0].firstChild.nodeValue)
        values["pressure"] = str(dom.getElementsByTagName('pressure')[0].firstChild.nodeValue)
        values["rain"] = str(dom.getElementsByTagName('precipMM')[1].firstChild.nodeValue)
        values["now"] = str(dom.getElementsByTagName('date')[0].firstChild.nodeValue)
        values["now"] = datetime.strptime(values["now"],"%Y-%m-%d")

        # translate en->de
        if lang == "de":
            values["wind_dir"] = values["wind_dir"].replace('E','O')

        values["area"] = dom.getElementsByTagName('areaName')[0].firstChild.nodeValue
        values["region"] = dom.getElementsByTagName('region')[0].firstChild.nodeValue
        values["country"] = dom.getElementsByTagName('country')[0].firstChild.nodeValue
    except AttributeError as error:
        print("Error getting current condition: " + str(error))

    h_temps = dom.getElementsByTagName('tempMax%s' % temp_unit)
    l_temps = dom.getElementsByTagName('tempMin%s' % temp_unit)
    highs = []
    lows = []
    for i in h_temps:
        try:
            highs.append(str(i.firstChild.nodeValue))
        except AttributeError as error:
            print("Error getting temperature highs: " + str(error))
                    
    for i in l_temps:
        try:
            lows.append(str(i.firstChild.nodeValue))
        except AttributeError as error:
            print("Error getting temperature lows: " + str(error))

              
    conditions = []
    for con in dom.getElementsByTagName('weatherDesc'):
        conditions.append(trans(str(con.firstChild.nodeValue).strip()))
        #conditions.append(u"mittlerer bis starker \xf6rtlicher Schnee mit Donner")
    #conditions[0] = u"teilweise gefrierender Nieselregen in der N\xe4he"
    #conditions[1] = u"mittlerer bis starker \xf6rtlicher Schnee mit Donner"
    #conditions[3] = u"mittlerer bis starker \xf6rtlicher Regen mit Donner"

    now = values["now"]
    day3 = now + timedelta(days=1)
    day4 = now + timedelta(days=2)
    day5 = now + timedelta(days=3)
    days = [trans("Current"), trans("Today"), trans(day3.strftime("%A")), trans(day4.strftime("%A")), trans(day5.strftime("%A"))]

    # images
    icons = dom.getElementsByTagName('weatherIconUrl')
    img_links = []
    for i in icons:
        try:
            org_link = str(i.firstChild.nodeValue)[59:]
            link = "icons/" + link2png.get(org_link, "na.png")
            #link = "icons/" + str(i.firstChild.nodeValue)[72:]
        except AttributeError as error:
            print("Error getting icon links: " + str(error))
        img_links.append(link)
       
    #print(img_links)
    #print(highs, lows)
    #print(conditions)
    #print(days)
    
    display(days, values, highs, lows, conditions, img_links)


def display(days, values, highs, lows, conditions, img_links):
    
    print("Creating image . . .")
    
    pygame.display.init()
    pygame.font.init()
    pygame.mouse.set_visible(False)

    white = (255, 255, 255)
    black = (0, 0, 0)
    gray = (125, 125, 125)

    #display = pygame.display.set_mode((600, 800))
    display = pygame.display.set_mode((800, 600), pygame.FULLSCREEN)
    screen = pygame.Surface((600, 800))
    #screen.fill((30, 40, 125))
    screen.fill(white)

    tiny_font = pygame.font.Font("Cabin-Regular.otf", 18)
    small_font = pygame.font.Font("Fabrica.otf", 22)
    font = pygame.font.Font("Forum-Regular.otf", 36)
    #font = pygame.font.Font("The Northern Block - Lintel.otf", 32)
    symbols = pygame.font.Font("Comfortaa-Regular.otf", 12)
    comfortaa = pygame.font.Font("Comfortaa-Regular.otf", 60)
    comfortaa_small = pygame.font.Font("Comfortaa-Regular.otf", 35)

    degrees = pygame.image.load("icons/%s.png" % temp_unit)
    wind_symbol = pygame.image.load("icons/Industry-Wind-turbine-icon.png")
    humidity_symbol = pygame.image.load("icons/humidity.png")
    pressure_symbol = pygame.image.load("icons/Measurement-Units-Pressure-icon.png")
    rain_symbol = pygame.image.load("icons/Weather-Rain-icon.png")

    # Dividing lines
    pygame.draw.line(screen, gray, (10, 100), (590, 100))
    pygame.draw.line(screen, gray, (10, 300), (590, 300))
    pygame.draw.line(screen, gray, (10, 500), (590, 500))
    pygame.draw.line(screen, gray, (200, 510), (200, 790))
    pygame.draw.line(screen, gray, (400, 510), (400, 790))



    # Today
    date = small_font.render(days[1], True, black, white)
    date_rect = date.get_rect()
    date_rect.topleft = 10, 310

    temps = comfortaa.render(highs[0] + "/" + lows[0], True, black, white)
    temps_rect = temps.get_rect()
    temps_rect.topleft = (50, 400)

    rain_rect = rain_symbol.get_rect()
    rain_rect.topleft = (425, 408)
    rain_val = comfortaa_small.render(values["rain"], True, black, white)
    rain_val_rect = rain_val.get_rect()
    rain_val_rect.topleft = (480, 410)
    rain_unit = symbols.render("mm", True, black, white)
    rain_unit_rect = rain_unit.get_rect()
    rain_unit_rect.topleft = rain_val_rect.topright
    rain_unit_rect.top -= 2
    rain_unit_rect.right += 3

    con_rect = pygame.Rect((date_rect.right, 300, 600 - 2 * date_rect.right, 90))
    condition = render_textrect(conditions[1], font, con_rect, black, white, 1, -10)
    con_rect.top += (con_rect.height - condition.get_height()) / 4

    image = pygame.image.load(img_links[1])
    image.set_colorkey((255, 255, 255))
    img_rect = image.get_rect()
    img_rect.center = (300, 425)

    screen.blit(condition, con_rect)
    screen.blit(temps, temps_rect)
    screen.blit(degrees, temps_rect.topright)
    screen.blit(rain_symbol, rain_rect)
    screen.blit(rain_val, rain_val_rect)
    screen.blit(rain_unit, rain_unit_rect)
    screen.blit(image, img_rect)
    screen.blit(date, date_rect)




    # Current condition
    date = small_font.render(days[0], True, black, white)
    date_rect = date.get_rect()
    date_rect.topleft = 10, 110

    area_text = font.render(values["area"], True, black, white)
    area_text_rect = area_text.get_rect()
    area_text_rect.centerx = 300
    area_text_rect.top = 15

    now = values["now"]
    if lang == "de":
        date_str = now.strftime("%e.") + months[now.month - 1] + now.strftime(" %Y, ")
    else:
        date_str = now.strftime("%B %e, %Y, ")
    country_text = tiny_font.render(date_str + values["region"] + ", " + values["country"], True, black, white)
    country_text_rect = country_text.get_rect()
    country_text_rect.centerx = 300
    country_text_rect.top = area_text_rect.bottom + 3

    temp_val = comfortaa.render(values["temp"], True, black, white)
    temp_val_rect = temp_val.get_rect()
    temp_val_rect.top = 200
    temp_val_rect.right = temps_rect.right

    wind_rect            = wind_symbol.get_rect()
    humidity_symbol_rect = humidity_symbol.get_rect()
    pressure_symbol_rect = pressure_symbol.get_rect()
    wind_rect.width      = humidity_symbol_rect.width

    wind_val = comfortaa_small.render(values["wind_speed"], True, black, white)
    wind_val_rect = wind_val.get_rect()
    wind_rect.topleft = (425, 173)
    wind_val_rect.topleft = (480, 175)
    if speed_unit == "Kmph":
        wind_unit = symbols.render("km/h", True, black, white)
    else:
        wind_unit = symbols.render("miles/h", True, black, white)
    wind_unit_rect = wind_unit.get_rect()
    wind_unit_rect.topleft = (wind_val_rect.right + 3, wind_val_rect.top - 2)
    wind_dir = symbols.render(values["wind_dir"], True, black, white)
    wind_dir_rect = wind_dir.get_rect()
    wind_dir_rect.topleft = (wind_val_rect.right + 3, wind_unit_rect.bottom)

    humidity_symbol_rect.topleft = (425, wind_rect.top + wind_val_rect.height)
    humidity_val = comfortaa_small.render(values["humidity"], True, black, white)
    humidity_val_rect = humidity_val.get_rect()
    humidity_val_rect.topleft = wind_val_rect.bottomleft
    humidity_unit = symbols.render("%", True, black, white)
    humidity_unit_rect = humidity_unit.get_rect()
    humidity_unit_rect.topleft = (humidity_val_rect.right + 3, humidity_val_rect.top - 2)

    pressure_symbol_rect.topleft = (425, humidity_symbol_rect.top + humidity_val_rect.height)
    pressure_val = comfortaa_small.render(values["pressure"], True, black, white)
    pressure_val_rect = pressure_val.get_rect()
    pressure_val_rect.topleft = humidity_val_rect.bottomleft
    pressure_unit = symbols.render("hPa", True, black, white)
    pressure_unit_rect = pressure_unit.get_rect()
    pressure_unit_rect.topleft = (pressure_val_rect.right + 3, pressure_val_rect.top - 2)

    con_rect = pygame.Rect((date_rect.right + 5, 100, 590 - 2 * date_rect.right, 90))
    condition = render_textrect(conditions[0], font, con_rect, black, white, 1, -10)
    con_rect.top += (con_rect.height - condition.get_height()) / 4




    image = pygame.image.load(img_links[0])
    image.set_colorkey((255, 255, 255))
    img_rect = image.get_rect()
    img_rect.center = (300, 225)

    screen.blit(area_text, area_text_rect)
    screen.blit(country_text, country_text_rect)
    screen.blit(condition, con_rect)
    screen.blit(degrees, temp_val_rect.topright)
    screen.blit(temp_val, temp_val_rect)
    screen.blit(wind_symbol, wind_rect)
    screen.blit(wind_val, wind_val_rect)
    screen.blit(wind_unit, wind_unit_rect)
    screen.blit(wind_dir, wind_dir_rect)
    screen.blit(humidity_symbol, humidity_symbol_rect)
    screen.blit(humidity_val, humidity_val_rect)
    screen.blit(humidity_unit, humidity_unit_rect)
    screen.blit(pressure_symbol, pressure_symbol_rect)
    screen.blit(pressure_val, pressure_val_rect)
    screen.blit(pressure_unit, pressure_unit_rect)
    screen.blit(image, img_rect)
    screen.blit(date, date_rect)


    def display_day(ofs_x, day, high_value, low_value, cond, img_link):
    
        date = small_font.render(day, True, black, white)
        date_rect = date.get_rect()
        date_rect.centerx = ofs_x
        date_rect.top = 510
    
        mid = comfortaa_small.render('/', True, black, white)
        mid_rect = mid.get_rect()
        mid_rect.center = (ofs_x, 740)
        
        high_temp = comfortaa_small.render(high_value, True, black, white)
        high_temp_rect = high_temp.get_rect()
        high_temp_rect.midright = mid_rect.midleft
        high_temp_rect.right -= 2
    
        low_temp = comfortaa_small.render(low_value, True, black, white)
        low_temp_rect = low_temp.get_rect()
        low_temp_rect.midleft = mid_rect.midright
        low_temp_rect.left += 4

        con_rect = pygame.Rect((ofs_x - 95, 525, 190, 80))
        condition = render_textrect(cond, tiny_font, con_rect, black, white, 1, -5)
        con_rect.top += (con_rect.height - condition.get_height()) / 3

        image = pygame.image.load(img_link)
        image.set_colorkey((255, 255, 255))
        img_rect = image.get_rect()
        img_rect.center = (ofs_x, 640)

        screen.blit(condition, con_rect)
        screen.blit(degrees, low_temp_rect.topright)
        screen.blit(high_temp, high_temp_rect)
        screen.blit(mid, mid_rect)
        screen.blit(low_temp, low_temp_rect)
        screen.blit(image, img_rect)
        screen.blit(date, date_rect)
    
    for i in range(0, 3):
        display_day(100+i*200, days[2+i], highs[1+i], lows[1+i], conditions[2+i], img_links[2+i]);

    if lang == "de":
        time_str = datetime.now().strftime("%k:%M")
    else:
        time_str = datetime.now().strftime("%l:%M%P")
    update_time = trans("Last updated at") + " " + time_str
    last_update = tiny_font.render(update_time, True, gray, white)
    screen.blit(last_update, (5, 775))

    # Rotate the display to portrait view (on the Kobo)
    graphic = pygame.transform.rotate(screen, 90)
    display.blit(graphic, (0, 0))
    pygame.display.update()

    # Show on desktop
    #graphic = pygame.transform.rotate(screen, 0)
    #display.blit(graphic, (0, 0))
    #pygame.display.update()

    #while (pygame.event.wait().type != KEYDOWN): pass

    #call(["./full_update"])
    convert_to_raw(screen)
    call(["/mnt/onboard/.apps/koboWeather/full_update.sh"])
    
    
#try:

# read configuration

lang = config.lang.lower()
temp_unit = config.temp_unit.upper()
if config.speed_unit.upper() == "KMPH":
    speed_unit = "Kmph"
else:
    speed_unit = "Miles"

get_weather_data()
#except IndexError as error:
    #index_error(error)
