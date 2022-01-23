#!/bin/sh
echo 'gem: --no-document' >> ~/.gemrc
gem install bundler
gem install dependabot-omnibus
