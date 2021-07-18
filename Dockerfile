FROM ruby:2.7.2-slim
RUN apt-get update -qq && apt-get install -y build-essential libcurl4-openssl-dev libxml2-dev libsqlite3-dev libpq-dev nodejs sqlite3 npm && \ 
    npm install -g yarn && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /myapp
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY package.json yarn.lock ./
RUN yarn install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Configure the main process to run when running the image
EXPOSE 3000
COPY . .
# RUN bin/webpack

ENV RAILS_ENV development
CMD ["rails", "server", "-b", "0.0.0.0"]