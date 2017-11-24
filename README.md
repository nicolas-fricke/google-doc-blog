# Google Doc Blog

Simple web-app using [`article_json`](https://github.com/Devex/article_json) to turn a Google Drive folder into your personal blog Edit

## Prerequisites

* You need a running `ruby` installation >= version 2.3
* Make sure to have the `bundler` gem installed
 
## Usage

1. Run `bundle install` to install all required dependencies
1. Run `bundle exec ruby bin/setup.rb` and follow the instructions to set up your environment
1. Execute `bundle exec rackup -p 4567 config.ru` to start the server
1. You should be able to open the webapp via `http://localhost:4567` in your browser 

## Running the tests

Execute `bundle exec rspec` to run the entire test suite.

## Built With

* [`article_json`](https://github.com/Devex/article_json) - The gem parsing Google documents into HTML / AMP / FBIA
* [`google-drive-ruby`](https://github.com/gimite/google-drive-ruby) - Google Drive connector
* [Sinatra](http://github.com/sinatra/sinatra) - Web framework

## Authors

Please check out the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE.md](LICENSE.md) file for details
