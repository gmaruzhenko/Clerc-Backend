#!/usr/bin/env bash

sudo apt-get install ruby
git clone https://github.com/gmaruzhenko/Clerc-Backend.git
cd Clerc-Backend/
sudo apt-get update
sudo apt-get install build-essential patch ruby-dev zlib1g-dev liblzma-dev
sudo gem install nokogiri -v '1.10.1' --source 'https://rubygems.org/'
sudo gem install bundler
sudo bundler install
ruby src/server.rb

# export GOOGLE_APPLICATION_CREDENTIALS="../Clerc-2040e3a661c9.json"

# now get files out of json and .env