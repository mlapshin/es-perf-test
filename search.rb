#!/bin/env/ruby

require 'rubygems'
require 'bundler/setup'

require 'elasticsearch'
require 'patron'
require 'benchmark'
require 'json'

client = Elasticsearch::Client.new log: false

q1 = {
  filter: {
    and: [
          {
            term: {
              'name.coding.code' => 'glu'
            }
          },
          {
            range: {
              issued: {
                gte: '2013',
                lte: '2014'
              }
            }
          }
         ]
  }
}

Benchmark.bm do |x|
  x.report { client.search(index: 'test', type: 'observation', body: q1) }
end
