FROM ruby:2.3.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /r_c_marvel
WORKDIR /r_c_marvel
ADD Gemfile /r_c_marvel/Gemfile
ADD Gemfile.lock /r_c_marvel/Gemfile.lock
RUN bundle install
ADD . /r_c_marvel
