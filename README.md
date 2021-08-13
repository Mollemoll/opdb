![License](https://img.shields.io/badge/Licence-MIT-informational)
[![GitHub release](https://img.shields.io/github/release/Mollemoll/opdb.svg)](https://github.com/Mollemoll/opdb/releases)
![Build](https://github.com/Mollemoll/opdb/actions/workflows/main.yml/badge.svg)

# Opdb

This gem is a simple API wrapper for the [Open Pinball Database API](https://opdb.org/api) for ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'opdb'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install opdb

## Usage

By initializing a Opdb::Client without a api_token you will gain access to the public endpoints like Opdb typeahead_search and changelog.

```ruby
opdb_client = Opdb::Client.new

opdb_client.typeahead_search(q: "Metallica")

opdb_client.changelog
```

To access the full Open Pinball Database you will have to sign up for an account at their webpage [https://opdb.org/api](https://opdb.org/api) and initialize the client with your api_token:

```ruby
opdb_client = Opdb::Client.new(api_token: "your-valid-token") //Remember to put your token in an env variable/secrets

opdb_client.search_machines(q: "Metallica (PRO LED)")

opdb_client.get_machine_info(opdb_id: "GRBE4-MQK1Z-A9Yn1")

opdb_client.get_machine_info_by_ipdb_id(ipdb_id: 6179)

opdb_client.export_machines //Note: This endpoint is rate limited and you will only be able to request the export once per hour.

opdb_client.export_machine_groups
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mollemoll/opdb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
