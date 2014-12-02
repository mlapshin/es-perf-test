#!/bin/env/ruby

require 'rubygems'
require 'bundler/setup'

require 'elasticsearch'
require 'patron'
require 'benchmark'
require 'json'

$client = Elasticsearch::Client.new log: false

def insert_patients
  file = File.open('/home/devel/fhir-patients.sql')
  bulk = []
  file.each_line do |line|
    json = JSON.parse(line)

    patient_id = json['identifier']
      .find { |identifier| identifier['label'] == 'MEDAPPID' }['value']

    print "#{patient_id} "

    bulk << {
      create: {
        _index: 'test',
        _id: patient_id,
        _type: 'patient',
        data: json
      }
    }

    if bulk.size >= 2000
      $client.bulk(body: bulk)
      puts "\n"
      bulk = []
    end
  end
end

def insert_observations
  file = File.open('/home/devel/fhir-observations.sql')
  bulk = []
  file.each_line do |line|
    json = JSON.parse(line)
    patient_id = json['subject']['reference'].split('/')[2]

    bulk << {
      create: {
        _index: 'test',
        _parent: patient_id,
        _type: 'observation',
        data: json
      }
    }

    if bulk.size >= 2000
      $client.bulk(body: bulk)
      bulk = []
    end
  end
end

Benchmark.bm do |x|
  x.report { insert_patients }
  x.report { insert_observations }
end
