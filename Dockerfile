FROM ruby:latest

# Create and switch to a user called app
RUN useradd --create-home --shell /bin/bash blog

WORKDIR /home/blog

# copy gemfile separately to cache step before more frequent code changes :)
COPY Gemfile Gemfile.lock /home/blog/
RUN bundle install

ADD . /home/blog
RUN chown --recursive blog:blog /home/blog

USER blog

EXPOSE 4567

ENTRYPOINT ["bundle","exec"]
