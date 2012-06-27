source :rubygems

# bundler requires these gems in all environments
gem "rails", "~> 3.1.3"
gem "nokogiri", "~> 1.5.0"
gem "haml", "~> 3.1.3"
gem "typhoeus", "0.3.2"
gem "yajl-ruby", "~> 1.0.0", :require => "yajl"
gem "capistrano-ext", "~> 1.2.1"
gem "capistrano", "~> 2.9.0"
gem "rpm_contrib", "~> 2.1.7"
gem "newrelic_rpm", "~> 3.3.1"
gem "savon", "~> 0.9.7"
gem "jruby-openssl", :platforms => :jruby
gem "omniauth", "1.0"
gem "omniauth-google-oauth2", "~> 0.1.8"
gem "oink", "~> 0.9.3"

gem "daemons", "~> 1.1.8", :groups => [:development, :test]
gem "tunnels", "~> 1.2.2", :groups => [:development, :test]

group :assets do
  gem "sass-rails", "~> 3.1.5"
end

group :compression do
  gem "uglifier", "~> 1.1.0"
  gem "therubyracer", "~> 0.9.9"
end

group :test do
  # bundler requires these gems while running tests
  gem "parallel_tests", "~> 0.6.7"
  gem "rspec-rails", "~> 2.7.0"
  gem "capybara", "~> 1.1.1"
  gem "cucumber", "1.1.2"
  gem "cucumber-rails",  "1.2.0" #
  gem "fuubar-cucumber", "0.0.15"
  gem "selenium-webdriver", "~> 2.21.2"
end

group :development do
  gem 'quiet_assets', "~> 1.0.1"
end
