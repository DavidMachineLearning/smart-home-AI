# smart-home-AI
Create your own AI smart home!

# content:
- jetson_configuration (configure the jetson nano)
- philips_hue (setup and examples on how to use the Philips Hue bridge via Python)

To learn more please visit my [website](https://davidforino-aisolutions.com/lesson-1-control-zigbee-devices-with-philips-hue-and-python/)!

## Usage:

- The jetson_configuration.sh script works only for jetpack 4.4.1, so make sure you use that version on your nano.
- Dowload this repo and change permissions to jetson_configuration.sh file by typing "sudo chmod +x jetson_configuration.sh".
- Run the script and give your user password, ./jetson_configuration.sh -p youruserpassword
- If you want to start the jupyter lab at start up type, ./jetson_configuration.sh -p youruserpassword -s yes

##### This script will build all necessary wheel files and this takes time, so be prepared to wait several hours!
