[![CircleCI](https://circleci.com/gh/uktrade/export-opportunities.svg?style=svg)](https://circleci.com/gh/uktrade/export-opportunities)
[![Dependency Status](https://gemnasium.com/badges/github.com/uktrade/export-opportunities.svg)](https://gemnasium.com/github.com/uktrade/export-opportunities)

# DIT Exporting is GREAT

*NOTE* The name of the organisation has changed from UKTI to DIT. In all
user-facing pages this change has been made, but some existing entities like
databases may continue to be called ukti.

We aim to follow [GDS service standards](https://www.gov.uk/service-manual/service-standard) and [GDS design principles](https://www.gov.uk/design-principles).


## Installation

* Copy the application configuration
```bash
$ cp config/application.example.yml config/application.yml
```
* Have an instance of redis-server running and configured in your `application.yml`

* Have an instance of elasticsearch running (can be default localhost:9200) and configured in your `application.yml`

## Running tests

Install [PhantomJS](http://phantomjs.org/), then run tests with `bundle exec rspec`

## Style checking

Run style checks with `bundle exec rubocop`. This checks code against the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide), with a couple of customisations.

Configure your editor's syntax checker to flag up rubocop rules.

## Concepts

### Users / Editors

* There was originally a model called `User` which stored details of people who could access the admin site. This has been renamed to `Editor`, so `User` can be instead used for end-users who subscribe and apply for opportunities.

* Editors can be one of three roles: Uploader, Publisher or Administrator:

  * **Uploaders** can add new opportunities and edit ones they created
  * **Publishers** can additionally publish opportunities so they appear on the site.
  * **Administrators** can also manage editor accounts.

### License

MIT licensed. See the bundled LICENSE file for more details.
  
## Deployment
  
* You can deploy the project on Heroku with minimum effort as long as you setup environmental variables like you would do in localhost.

## Contribution
You are welcome to contribute, please get in touch with [Alex Giamas](mailto:alexandros.giamas@digital.trade.gov.uk) or [Mateusz Lapsa Malawski](mailto:mateusz.lapsa-malawski@digital.trade.gov.uk).
