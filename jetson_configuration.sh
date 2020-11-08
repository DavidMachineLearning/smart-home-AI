#!/bin/bash

set -e
cd ~

password=""
start_jupyter="no"

# exit message if something is not as expected
exit_msg() {
  echo
  echo "Usage: $0 [ -p password ] [ -s yes/no ]" 1>&2
  echo
  echo "if -s is yes, jupyter lab will run at startup. Default is no."
  exit 1
}

# check arguments
while getopts ":p:s:" option; do
  case "${option}" in
    p)
      password=${OPTARG}
      ;;
    s)
      start_jupyter=${OPTARG}
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit_msg
      ;;
    *)
      echo "Argument -${OPTARG} is not recognized.\n"
      exit_msg
      ;;
  esac
done

# make sure a password is given
if [ "$password" = "" ]; then
  echo "A Password is required!"; exit_msg;
fi

# make sure the value passed to STRAT_JUPYTER is yes or no
if [ "$start_jupyter" != "yes" ] && [ "$start_jupyter" != "no" ]; then
  echo "Argument -s can be only yes or no."; exit_msg;
fi

# update and remove unnecessary libraries
echo $password | sudo -S apt update
echo $password | sudo -S apt remove --purge libreoffice* -y
echo $password | sudo -S apt autoremove -y
echo $password | sudo -S apt install htop -y
echo $password | sudo -S apt install netdiscover -y
echo $password | sudo -S apt install idle3 -y

# install necessary dependencies
echo $password | sudo -S apt-get install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev libopenblas-base
echo $password | sudo -S apt-get install -y libatlas-base-dev gfortran libfreetype6-dev build-essential libopenmpi-dev
echo $password | sudo -S apt install -y python3-pip python3-dev python3-smbus cmake
echo $password | sudo -S pip3 install -U pip testresources setuptools==49.6.0
echo $password | sudo -S pip3 install flask
echo $password | sudo -S pip3 install -U numpy==1.18.3
echo $password | sudo -S pip3 install -U jetson-stats
echo $password | sudo -S pip3 install pillow==7.1.2
echo $password | sudo -S pip3 install matplotlib==3.2.1
echo $password | sudo -S pip3 install pandas==1.0.3
echo $password | sudo -S pip3 install scipy==1.4.1
echo $password | sudo -S pip3 install cython
echo $password | sudo -S pip3 install scikit-learn==0.22.0
echo $password | sudo -S pip3 install seaborn==0.10.1
echo $password | sudo -S pip3 install -U future==0.18.2 mock==3.0.5 h5py==2.10.0 keras_preprocessing==1.1.1 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11 grpcio
echo $password | sudo -S pip3 install -U absl-py py-cpuinfo psutil portpicker six mock requests astor termcolor protobuf  wrapt google-pasta
echo $password | sudo -S apt-get install -y virtualenv

# install jupyter lab
echo $password | sudo -S apt install -y nodejs npm
echo $password | sudo -S pip3 install -U jupyter jupyterlab
jupyter lab --generate-config

# install mqtt client to comunicate with other IOT devices
pip3 install -U paho-mqtt

# install phue library for interacting with Philips Hue
pip3 install -U phue
pip3 install -U rgbxy

# set jupyter password
python3 -c "from notebook.auth.security import set_password; set_password('$password', '$HOME/.jupyter/jupyter_notebook_config.json')"

# install tensorflow and pytorch
pip3 install -U --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 tensorflow==2.3.1+nv20.10
wget https://nvidia.box.com/shared/static/wa34qwrwtk9njtyarwt5nvo6imenfy26.whl -O torch-1.7.0-cp36-cp36m-linux_aarch64.whl
pip3 install -U torch-1.7.0-cp36-cp36m-linux_aarch64.whl
pip install -U torchvision
rm torch-1.7.0-cp36-cp36m-linux_aarch64.whl

# check the amount of ram in the Jetson to determine if you need to change the GUI
totalram=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)

if (($totalram \> 4000000))
then
  # reduce ram usage by changing GUI
  echo $password | sudo -S apt remove --purge ubuntu-desktop -y
  echo $password | sudo -S apt remove --purge gdm3 -y
fi

# start jupyter lab at sturtup
if [ "$start_jupyter" == "yes" ]; then
  jetsonip=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(192.([0-9]*\.){2}[0-9]*).*/\2/p'`
  echo $password | sudo -S bash -c "echo \"[Desktop Entry]\" >> /etc/xdg/autostart/jupyterlab.desktop"
  echo $password | sudo -S bash -c "echo \"Name=jupyterlab\" >> /etc/xdg/autostart/jupyterlab.desktop"
  echo $password | sudo -S bash -c "echo \"Exec=jupyter lab --ip=$jetsonip --no-browser --allow-root\" >> /etc/xdg/autostart/jupyterlab.desktop"
fi

# reboot the system
echo $password | sudo -S reboot
