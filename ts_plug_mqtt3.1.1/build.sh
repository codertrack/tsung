#!/usr/bin/env bash

#rm -f ./../include/mqtt4.hrl
#
#rm -f ./../include/mqtt4.hrl
#rm -f ./../include/ts_mqtt4.hrl
#rm -f ./../src/lib/mqtt4_frame.erl
#rm -f ./../src/tsung_controller/ts_config_mqtt4.erl
#rm -f ./../src/tsung/ts_mqtt4.erl
#rm -f ./../tsung-1.0.dtd
#
#
#cp ./mqtt4.hrl ./../include/mqtt4.hrl
#cp ./ts_mqtt4.hrl ././../include/ts_mqtt4.hrl
#cp ./mqtt4_frame.erl ./../src/lib/mqtt4_frame.erl
#cp ./ts_config_mqtt4.erl ./../src/tsung_controller/ts_config_mqtt4.erl
#cp ./ts_mqtt4.erl ./../src/tsung/ts_mqtt4.erl
#cp ./tsung-1.0.dtd ./../tsung-1.0.dtd


##进入上级目录

cd ../
sudo ./configure

sudo make uninstall

sudo make install




