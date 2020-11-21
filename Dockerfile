FROM ruby:2.7.1

WORKDIR /code
COPY . /code
RUN bundle install

EXPOSE 5000

CMD ["thin", "start", "-p",  "5000",  "--ssl",  "--ssl-key-file",  "./ssl/server.key",  "--ssl-cert-file", "./ssl/server.crt"]