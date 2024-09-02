# gummy-osd
Use gummy to control screen brightness/temp on Cinnamon DE (with OSD notification)

 This script allows you to adjust brightness, backlight, and temperature settings using the gummy daemon, 
 and it also displays an on-screen display (OSD) notification.

 # requires gummy: https://codeberg.org/fusco/gummy
 
 Usage:
 ``./gummy-osd.sh <mode> <direction>``
 
 Parameters:
 - ``<mode>``: Specifies the setting to adjust. Available modes:
   - brightness: Adjusts the screen brightness.
   - backlight: Adjusts the screen backlight.
   - temperature: Adjusts the screen color temperature.
 
 - ``<direction>``: Specifies the adjustment direction. Available directions:
   - up: Increases the setting value.
   - down: Decreases the setting value.
   - reset: Resets the setting to its default value.
 
 Examples:
 - Increase Brightness: ``./gummy-osd.sh brightness up``
 - Decrease Backlight: ``./gummy-osd.sh backlight down``
 - Reset Temperature to Default: ``./gummy-osd.sh temperature reset``
