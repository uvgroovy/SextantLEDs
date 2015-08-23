# Setting an RPI for Sextant LED controller

## Initial pi setup

add the pi user to to audio group; we will need this for later

    sudo usermod -a -G audio pi


expand file system with:

    sudo raspi-config

upgrade to latest everything:

    sudo apt-get update
    sudo apt-get upgrade
    sudo rpi-update
## Optional - powered usb hub
My USB3 hub didn't seem to work with the PI; the solution is to use it in USB 1.1 mode.
do that by adding "dwc_otg.speed=1" to /boot/command.txt

# may not be needed on other hubs
see https://github.com/raspberrypi/firmware/issues/64 for more info
## Setting up mic
see: http://www.g7smy.co.uk/?p=283

find your mic's volume interface (verify that your sound card is indeed number 1)

    $ amixer --card 1 contents
    ...
    numid=8,iface=MIXER,name='Mic Capture Volume'
      ; type=INTEGER,access=rw---R--,values=1,min=0,max=16,step=0
      : values=0
      | dBminmax-min=0.00dB,max=23.81dB
    ...

The bump the volume!!!

    amixer  -c1 cset numid=8,iface=MIXER,name='Mic Capture Volume' 14

store settings

    sudo alsactl store 1

you can also do this with alsamixer instead of amixer.

Try test recording with:

    arecord -D plughw:1 --duration=10 -f cd -vv ~/rectest.wav

## add teensy udev rulels
wget http://www.pjrc.com/teensy/49-teensy.rules
sudo mv 49-teensy.rules /etc/udev/rules.d/

## setting up processing
see: http://scruss.com/blog/2014/01/07/processing-2-1-oracle-java-raspberry-pi-serial-arduino-%E2%98%BA/

Install java 7 (java 8 didn't work!)

    sudo apt-get install oracle-java7-jdk

download and extract proccessing

    wget http://download.processing.org/processing-2.2.1-linux32.tgz
    tar xzf processing-2.2.1-linux32.tgz

replace java

    rm -rf ~/processing-2.2.1/java
    ln -s /usr/lib/jvm/jdk-7-oracle-arm-vfp-hflt/  ~/processing-2.2.1/java
Replace the serial connector

    wget https://java-simple-serial-connector.googlecode.com/files/jSSC-2.6.0-Release.zip
    unzip jSSC-2.6.0-Release.zip
    mv jSSC-2.6.0-Release/jssc.jar ~/processing-2.2.1/modes/java/libraries/serial/library/
    rm -r jSSC-2.6.0-Release

### Setup fake x server for processing

    sudo apt-get install xvfb

Start it

    Xvfb :1 -screen 0 1152x900x8 -fbdir /tmp &
    export DISPLAY=localhost:1.0

if you start another terminal, you just need to export the env var again.

## Sextant code

get sextant code

    git clone https://github.com/uvgroovy/SextantLEDs.git

Copy processing libraries

    mkdir -p sketchbook/libraries/
    cp -r  SextantLEDs/Processing_P5/libs/* sketchbook/libraries/

# Done!
Everything should be setup now; plugin teensty and to the pi, and try:

    ~/processing-2.2.1/processing-java  --sketch=/home/pi/SextantLEDs/Processing_P5/crude_fft/  --output=/tmp/output --force --run
