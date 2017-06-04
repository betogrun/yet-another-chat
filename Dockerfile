FROM ruby:2.4-slim
RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential nodejs libpq-dev
ENV INSTALL_PATH /yet-another-chat
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH
#copy Gemfile to container
COPY Gemfile ./
#set path for gems
ENV BUNDLE_PATH /box
COPY . .
