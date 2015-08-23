#http://scruss.com/blog/2014/01/07/processing-2-1-oracle-java-raspberry-pi-serial-arduino-%E2%98%BA/

# expand file system with sudo raspi-config

# upgrade to latest everything:
sudo apt-get update
sudo apt-get upgrade
sudo rpi-update

# add to audio
sudo usermod -a -G audio pi

# find usb sound card with alsamixer and then store it with:
# replace 1 with
# sudo alsactl store 1
# test recording with
# arecord -D plughw:1 --duration=10 -f cd -vv ~/rectest.wav

# add teensy udev rulels
wget http://www.pjrc.com/teensy/49-teensy.rules
sudo mv 49-teensy.rules /etc/udev/rules.d/


sudo apt-get install oracle-java7-jdk
wget http://download.processing.org/processing-2.2.1-linux32.tgz
tar xzf processing-2.2.1-linux32.tgz

rm -rf ~/processing-2.2.1/java
#do not use jdk 8; tried it and it doesnt work
ln -s /usr/lib/jvm/jdk-7-oracle-arm-vfp-hflt/  ~/processing-2.2.1/java

git clone https://github.com/uvgroovy/SextantLEDs.git

# fake x server for processing
sudo apt-get install xvfb
# start it 
Xvfb :1 -screen 0 1152x900x8 -fbdir /tmp &
export DISPLAY=localhost:1.0

# libraries
mkdir -p sketchbook/libraries/
cp -r  SextantLEDs/Processing_P5/libs/* sketchbook/libraries/

# not needed for processing2
# pushd sketchbook/libraries/
# git clone https://github.com/ddf/Minim.git minim
# popd

# test processing
~/processing-2.2.1/processing-java  --sketch=/home/pi/SextantLEDs/Processing_P5/crude_fft/  --output=/tmp/output --force --run

