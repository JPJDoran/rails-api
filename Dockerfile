# Use official Ruby base image (includes Ruby and Linux tools)
FROM ruby:3.2

# Install required Linux packages
# -qq = quiet output (cleaner logs)
# build-essential = compilers for native gems
# libpq-dev = PostgreSQL client headers for pg gem
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# Set the working directory inside the container
WORKDIR /app

# Install bundler (manages Ruby gem dependencies)
RUN gem install bundler

# Copy Gemfile and Gemfile.lock first (for Docker layer caching)
COPY Gemfile Gemfile.lock ./

# Install Ruby gems (Rails, pg, etc.)
RUN bundle install

# Copy the rest of your application code into the container
COPY . .

# Expose port 3000 (default for Rails development server)
EXPOSE 3000

# Start the Rails server, binding to all IPs so it's accessible outside the container
CMD ["rails", "server", "-b", "0.0.0.0"]