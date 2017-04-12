[![CircleCI](https://circleci.com/gh/uktrade/export-opportunities.svg?style=svg&circle-token=520908ff27611bb49c52f39e47eae77db6133718)](https://circleci.com/gh/uktrade/export-opportunities)

[![Dependency Status](https://gemnasium.com/badges/github.com/uktrade/export-opportunities.svg)](https://gemnasium.com/github.com/uktrade/export-opportunities)

# DIT Exporting is GREAT

*NOTE* The name of the organisation has changed from UKTI to DIT. In all
user-facing pages this change has been made, but some existing entities like
databases will continue to be called ukti.


## Installation

* Copy the application configuration
```bash
$ cp config/application.example.yml config/application.yml
```
* Have an instance of redis-server running and configured in your `application.yml`

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
