#install the gems
bundle check || bundle install
#run the server
bundle exec puma -C config/puma.rb
