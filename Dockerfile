FROM ruby:3.2.2

# Install dependencies
RUN apt-get update && apt-get install -y \
    nodejs \
    yarn \
    postgresql-client \
    wget \
    fontconfig \
    libfreetype6 \
    libjpeg62-turbo \
    libpng16-16 \
    libx11-6 \
    libxcb1 \
    libxext6 \
    libxrender1 \
    xfonts-75dpi \
    xfonts-base \
    libjpeg62-turbo


RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install
COPY . .

# RUN rake assets:precompile

# Expose the port
EXPOSE 3001

# Start the server
CMD ["rails", "server", "-b", "0.0.0.0"]