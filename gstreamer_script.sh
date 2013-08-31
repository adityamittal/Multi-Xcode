#!/bin/bash
#Needs to be root for now. Ideally would be better to make it a sudo thing....

apt-get install bison
apt-get install flex
apt-get install libsoup2.4-dev
apt-get install libglib2.0-dev
 
# Right Now..!!! Please Set the Paths... Self Explanatory...!! 

SETUP_HOME=/home/aditya/work/
SETUP_DIR=multi_xcode
SETUP_EXT=$SETUP_HOME/$SETUP_DIR/external-dependencies/
SETUP_GST_DEV=gstreamer-dev
SETUP_GST_BUILD=gstreamer-build

mkdir $SETUP_HOME
cd $SETUP_HOME
mkdir $SETUP_DIR
cd $SETUP_DIR

mkdir $SETUP_EXT

mkdir $SETUP_GST_DEV
mkdir $SETUP_GST_BUILD 

cd $SETUP_GST_DEV
echo "Building the Gstreamer Core Code"
wget "http://gstreamer.freedesktop.org/src/gstreamer/gstreamer-0.10.35.tar.gz"
tar zxvf gstreamer-0.10.35.tar.gz
cd gstreamer-0.10.35

./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
make
make install

cd $SETUP_EXT
echo $PWD

export PKG_CONFIG_PATH=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD/lib/pkgconfig/

echo "Building the Ogg Code"
wget "http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.gz"
tar zxvf libogg-1.3.1.tar.gz
cd libogg-1.3.1
./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
make
make install

cd $SETUP_EXT
echo "Building the Vorbis Code"
wget "http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.3.tar.gz"
tar zxvf libvorbis-1.3.3.tar.gz
cd libvorbis-1.3.3

./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
make
make install

cd $SETUP_EXT
echo "Building the Theora Code"
wget "http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2"
tar jxf libtheora-1.1.1.tar.bz2 
cd libtheora-1.1.1

./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
make
make install

cd $SETUP_HOME/$SETUP_DIR/$SETUP_GST_DEV/ 
wget "http://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-0.10.35.tar.gz"
tar zxvf gst-plugins-base-0.10.35.tar.gz
cd gst-plugins-base-0.10.35

./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
make
make install

export PKG_CONFIG_PATH=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD/lib/pkgconfig/:/usr/lib/pkgconfig/

echo "Building the Gstreamer FFMpeg Code from Source"

cd $SETUP_HOME/$SETUP_DIR/$SETUP_GST_DEV/
wget "http://gstreamer.freedesktop.org/src/gst-ffmpeg/gst-ffmpeg-0.10.11.tar.gz"
tar zxvf gst-ffmpeg-0.10.11.tar.gz
cd gst-ffmpeg-0.10.11

./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
make
make install

apt-get install libxv-dev

cd $SETUP_EXT
echo "Building the DV Codec Code"
wget "http://sourceforge.net/projects/libdv/files/libdv/1.0.0/libdv-1.0.0.tar.gz" 
tar zxvf libdv-1.0.0.tar.gz
cd libdv-1.0.0

./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
make
make install

apt-get install g++
cd $SETUP_HOME/$SETUP_DIR/$SETUP_GST_DEV/  
wget "http://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-0.10.30.tar.gz"
tar zxvf gst-plugins-good-0.10.30.tar.gz
cd gst-plugins-good-0.10.30

./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
make
make install

cd $SETUP_EXT
echo "Building the Faac Codec Code.. There is a error in building the FAAC Code..Need to comment Line 126 in mpeg4ip.h"
wget "http://sourceforge.net/projects/faac/files/faac-src/faac-1.28/faac-1.28.tar.gz" 
tar zxvf faac-1.28.tar.gz
cd faac-1.28

./configure 
make
make install

cd $SETUP_EXT
echo "Building the FAAD Codec Code"
wget "http://sourceforge.net/projects/faac/files/faad2-src/faad2-2.7/faad2-2.7.tar.gz" 
tar zxvf faad2-2.7.tar.gz
cd faad2-2.7

./configure 
make
make install

cd $SETUP_HOME/$SETUP_DIR/$SETUP_GST_DEV/
wget "http://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-0.10.22.tar.gz"
tar zxvf gst-plugins-bad-0.10.22.tar.gz
cd gst-plugins-bad-0.10.22

./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
make
make install


cd $SETUP_EXT
wget "http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz"
tar zxvf yasm-1.2.0.tar.gz
cd yasm-1.2.0

./configure 
make
make install

#cd $SETUP_EXT
#echo "Building the x264 Code"
#git clone git://git.videolan.org/x264.git
#cd x264

#./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
#make
#make install

#There seems to be lot of issues in building x264 from Code.. Using the Dev Package...Works Well..!!!
sudo apt-get install libx264-dev

cd $SETUP_HOME/$SETUP_DIR/$SETUP_GST_DEV/
wget "http://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-0.10.18.tar.gz"
tar zxvf gst-plugins-ugly-0.10.18.tar.gz
cd gst-plugins-ugly-0.10.18

./configure --prefix=$SETUP_HOME/$SETUP_DIR/$SETUP_GST_BUILD
make
make install


