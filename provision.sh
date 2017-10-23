#! /bin/bash

wget -q https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb &&
sudo dpkg -i erlang-solutions_1.0_all.deb &&
sudo apt-get update &&
sudo apt-get install -y esl-erlang=1:19.3.6 elixir=1.4.5-1

wget -q https://bintray.com/artifact/download/erlio/vernemq/deb/jessie/vernemq_1.2.0-1_amd64.deb &&
sudo dpkg -i vernemq_1.2.0-1_amd64.deb &&
sudo apt-get install -y mosquitto-clients
