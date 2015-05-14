## Sensu-Plugins-solr

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-solr.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-solr)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-solr.svg)](http://badge.fury.io/rb/sensu-plugins-solr)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-solr/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-solr)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-solr/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-solr)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-solr.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-solr)
[ ![Codeship Status for sensu-plugins/sensu-plugins-solr](https://codeship.com/projects/b42f3150-dc04-0132-8e5a-1e3fe125131b/status?branch=master)](https://codeship.com/projects/79861)

## Functionality

## Files
 * bin/metrics-solr-graphite
 * metrics-solr-v1.4graphite
 * bin/metrics-solr4-graphite
 *

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-solr -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-solr`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-solr' do
  options('--prerelease')
  version '0.0.1'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-solr' do
  options('--prerelease')
  version '0.0.1'
end
```

## Notes
