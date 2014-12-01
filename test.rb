#!/bin/env/ruby

require 'rubygems'
require 'bundler/setup'

require 'elasticsearch'
require 'patron'
require 'benchmark'
require 'json'

def mkdoc(n)
  @obs ||= JSON.parse(File.read("observation.json"))
  obs = @obs.dup
  obs["valueQuantity"]["value"] = 36 + rand() * 10
  obs
end

client = Elasticsearch::Client.new log: false

Benchmark.bm do |x|
  x.report("insert 500000 docs") {
    docs = (1..500000).map { |i| mkdoc(i) }

    docs.each_slice(2000) do |slice|
      bdy = slice.map { |d|
        {create: {_index: 'test', _type: 'observation', data: d } }
      }

      client.bulk body: bdy
    end
  }

  x.report("search by value") {
    client.search type: 'observation', q: "valueQuantity.value:36"
  }
end
