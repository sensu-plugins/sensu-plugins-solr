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
  option :core_url,
         short: '-u URL',
         long: '--url URL',
         description: 'Solr Core Url',
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

  option :core_missing_ok,
         short: '-x',
         long: '--core-missing-ok',
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
    uri = "#{config[:core_url]}/replication?command=details&wt=json"
    data = get_url_json(uri, config[:core_missing_ok])
    details = data['details']
    if details['isSlave'] == 'true'
      slave_details = details['slave']
      lag = (DateTime.parse(slave_details['currentDate']).to_time - DateTime.parse(slave_details['indexReplicatedAt']).to_time).to_i
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
