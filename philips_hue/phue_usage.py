from phue import Bridge
from time import sleep
from datetime import datetime
from rgbxy import Converter


# replace these values with your settings
HUE_IP = "192.168.1.52"
BULB_NAME = "Office color bulb"

# schedule time, in this example is the actual time +/- 2 minutes in a sequence
actual_time = datetime.now()
SCHEDULE1 = {"start": (actual_time.hour, actual_time.minute - 2), "stop": (actual_time.hour, actual_time.minute + 2)}
SCHEDULE2 = {"start": (actual_time.hour, actual_time.minute + 3), "stop": (actual_time.hour, actual_time.minute + 5)}


class ColorsXY:
    _converter = Converter()
    RED = _converter.rgb_to_xy(255, 20, 20)
    GREEN = _converter.rgb_to_xy(20, 255, 20)
    BLUE = _converter.rgb_to_xy(20, 20, 255)
    COLD_WHITE = [0.3129, 0.3288]
    WARM_WHITE = [0.5177, 0.4141]


class Schedule:
    """Object used to check the time and set the corresponding light parameters"""
    def __init__(self, start, stop, days=None):
        """
        Constructor
        :param start: tuple, start schedule (hour, minute) i.e. (15, 30) for 3:30 PM
        :param stop: tuple, stop schedule (hour, minute) i.e. (15, 30) for 3:30 PM
        :param days: set of strings or None, valid days for the schedule i.e. {"Monday", "Wednesday"}
                     if None, it defaults to every day
        """
        self._start_time = (start[0], start[1])
        self._stop_time = (stop[0], stop[1])
        if days is None:
            days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
        self._days = set([day.capitalize() for day in days])
        self._is_active = False

    def is_time(self):
        """
        Check if now is the scheduled time
        :return: bool
        """
        now = datetime.now()
        start = datetime(now.year, now.month, now.day, self._start_time[0], self._start_time[1], 0)
        stop = datetime(now.year, now.month, now.day, self._stop_time[0], self._stop_time[1], 0)

        # check if today should be considered in the schedule
        if now.strftime("%A") not in self._days:
            self._is_active = False
            return False

        if start <= now < stop:
            if not self._is_active:
                self._is_active = True
                return True
            else:
                return False
        else:
            self._is_active = False
            return False


def apply_schedule(light, schedule, on, brightness=None, transition=None, colortemp=None, xy_color=None):
    """
    If is the scheduled time, it will apply the parameters to the given light.
    :param light: phue.Light, the light you want to set
    :param schedule: Schedule, the schedule to use
    :param on: bool, True or False
    :param brightness: int, 0-254
    :param transition: int, in **deciseconds**, time for this transition to take place
    :param colortemp: int, 154-500
    :param xy_color: list, if the lamp is RGB you can specify here the color space in xy
    :return: None
    """
    if schedule.is_time():
        if transition is not None:
            light.transition = transition
        if colortemp is not None:
            light.colortemp = colortemp
        if xy_color is not None:
            light.xy = xy_color
        if brightness is not None:
            light.brightness = brightness
        light.on = on


test = Schedule(start=SCHEDULE1["start"], stop=SCHEDULE1["stop"])
test2 = Schedule(start=SCHEDULE2["start"], stop=SCHEDULE2["stop"], days={"Saturday", "Sunday"})

hue_bridge = Bridge(HUE_IP)

# Get the bridge state (This returns the full dictionary that you can explore)
# state = hue_bridge.get_api()

light_names = hue_bridge.get_light_objects('name')
office_light = light_names[BULB_NAME]

for i in range(6):
    print(f"First {i*60} seconds have passed...")
    apply_schedule(office_light, test, on=True, transition=600, brightness=128, xy_color=ColorsXY.BLUE)
    apply_schedule(office_light, test2, on=False, transition=300)
    sleep(60)
