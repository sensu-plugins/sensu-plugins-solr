# frozen_string_literal: true

#
# check-solr-replication-lag_spec
#
# DESCRIPTION:
#   Tests for check-solr-replication-lag.rb
#
# OUTPUT:
#
# PLATFORMS:
#
# DEPENDENCIES:
#
# USAGE:
#   bundle install
#   rake spec
#
# NOTES:
#

require_relative '../spec_helper.rb'
require_relative '../../bin/check-solr-replication-lag.rb'
require 'json'

describe SolrCheckReplication do
  let(:config) { %w(-d core0 -h 127.0.0.1 -p 8983) }
  let(:check) { described_class.new(config) }

  describe '#run' do
    before do
      expect(check).to receive(:get_url_json).with('http://127.0.0.1:8983/solr/core0/replication?command=details&wt=json', false).and_return(response)
    end

    context 'slave server' do
      let(:response) do
        slave_state = { indexReplicatedAt: 'Thu Jul 05 11:00:00 UTC 2018', currentDate: 'Thu Jul 05 11:30:00 UTC 2018' }
        JSON.parse(JSON.generate(details: { isSlave: 'true', slave: slave_state, indexVersion: 0 }))
      end

      context 'returns ok' do
        let(:config) { %w(-d core0 -h 127.0.0.1 -p 8983 -w 1900 -c 3600) }
        it 'exists properly' do
          expect(check.run).to eq('OK: Replication lag is ok (1800)')
        end
      end
      context 'returns warning' do
        let(:config) { %w(-d core0 -h 127.0.0.1 -p 8983 -w 10 -c 3600) }
        it 'exists properly' do
          expect(check.run).to eq('WARNING: Replication lag exceeds 10 seconds (1800)')
        end
      end
      context 'returns critical' do
        let(:config) { %w(-d core0 -h 127.0.0.1 -p 8983 -w 1 -c 1700) }
        it 'exists properly' do
          expect(check.run).to eq('CRITICAL: Replication lag exceeds 1700 seconds (1800)')
        end
      end
    end

    context 'master server' do
      let(:response) do
        JSON.parse(JSON.generate(details: { isSlave: 'false', isMaster: 'true' }))
      end
      context 'a default config' do
        it 'exists properly' do
          expect(check.run).to eq('OK: this is not a slave host')
        end
      end
    end
  end
end
