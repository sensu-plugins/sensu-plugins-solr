#!/usr/bin/env ruby
#
# Check how behind replication is.
# ===
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'
require 'date'

class SolrCheckReplication < Sensu::Plugin::Check::CLI
  option :host,
         short: '-h HOST',
         long: '--host HOST',
         description: 'Solr Host to connect to',
         required: true

  option :port,
         short: '-p PORT',
         long: '--port PORT',
         description: 'Solr Port to connect to',
         proc: proc(&:to_i),
         required: true

  option :core,
         description: 'Solr Core to check',
         short: '-d CORE',
         long: '--core CORE',
         required: true

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

  option :unknown_core,
         short: '-u',
         long: '--unknown-core',
         description: 'Allow core to be missing (consider ok)',
         boolean: true,
         default: false

  def get_url_json(url, notfoundok)
    r = RestClient::Resource.new(url, timeout: 45)
    JSON.parse(r.get)
  rescue Errno::ECONNREFUSED
    warning 'Connection refused'
  rescue RestClient::RequestTimeout
    warning 'Connection timed out'
  rescue RestClient::ResourceNotFound
    if notfoundok
      ok "404 resource not found - #{url}"
    else
      warning "404 resource not found - #{url}"
    end
  rescue => e
    warning "RestClient exception: #{e.class} -> #{e.message}"
  end

  def run
    data = get_url_json("http://#{config[:host]}:#{config[:port]}/solr/#{config[:core]}/replication?command=details&wt=json", config[:unknown_core])
    details = data['details']
    if details['isSlave'] == 'true'
      slave_details = details['slave']
      lag = Integer(DateTime.parse(slave_details['currentDate']).to_time - DateTime.parse(slave_details['indexReplicatedAt']).to_time)
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
