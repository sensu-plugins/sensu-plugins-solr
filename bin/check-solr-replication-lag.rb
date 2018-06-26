#!/usr/bin/env ruby
#
# Push Apache Solr stats into graphite
# ===
#
# TODO: Flags to narrow down needed stats only
#
# Copyright 2013 Kyle Burckhard <kyle@marketfish.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'

class SolrCheckReplication < Sensu::Plugin::Check::CLI
  option :host,
         short:       '-h HOST',
         long:        '--host HOST',
         description: 'Solr Host to connect to',
         required:    true

  option :port,
         short:        '-p PORT',
         long:         '--port PORT',
         description:  'Solr Port to connect to',
         proc:         proc(&:to_i),
         required:     true

  option :core,
         description: 'Solr Core to check',
         short: '-d CORE',
         long: '--core CORE',
         required:     true

  option :warning,
         description: 'Warning if greater than X seconds',
         short: '-w SECONDS',
         proc: proc(&:to_i),
         default: 1200

  option :critical,
         description: 'Critical if greater than X seconds',
         short: '-c SECONDS',
         proc: proc(&:to_i),
         default: 3600

  def get_url_json(url)
    r = RestClient::Resource.new(url, timeout: 45)
    JSON.parse(r.get)
  rescue Errno::ECONNREFUSED
    warning 'Connection refused'
  rescue RestClient::RequestTimeout
    warning 'Connection timed out'
  rescue RestClient::ResourceNotFound
    warning "404 resource not found - #{url}"
  rescue => e
    warning "RestClient exception: #{e.class} -> #{e.message}"
  end

  def run
    data = get_url_json "http://#{config[:host]}:#{config[:port]}/solr/#{config[:core]}/replication?command=details&wt=json"
    if data['details']['isSlave']
      lag = (data['details']['slave']['masterDetails']['indexVersion'] - data['details']['indexVersion']) / 1000
      if lag >= config[:critical]
        critical "Replication lag exceeds #{config[:critical]} seconds (#{lag})"
      elsif lag >= config[:warning]
        warning "Replication lag exceeds #{config[:warning]} seconds (#{lag})"
      else
        ok "Replication lag is ok (#{lag})"
      end
    else
      ok 'this is not a slave host'
    end
  end
end
