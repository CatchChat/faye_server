FROM ruby:2.3.1

ENV WORKDIR /var/www
WORKDIR $WORKDIR
ADD . $WORKDIR
RUN bundle install --without development test --deployment
RUN mkdir -p tmp/pids
EXPOSE 8000
CMD bundle exec thin start -w 30 -l log/thin.log --max-conns 16384 --max-persistent-conns 16384 -e $RACK_ENV -p 8000 --threaded -c $WORKDIR --tag faye
