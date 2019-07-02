[![Vulnerabilities](https://snyk.io/test/github/gonace/obscured.heartbeat/badge.svg)](https://snyk.io/test/github/gonace/obscured.heartbeat)
[![Build Status](https://travis-ci.org/gonace/Obscured.Heartbeat.svg?branch=master)](https://travis-ci.org/gonace/Obscured.Heartbeat)
[![Test Coverage](https://codeclimate.com/github/gonace/Obscured.Heartbeat/badges/coverage.svg)](https://codeclimate.com/github/gonace/Obscured.Heartbeat)
[![Code Climate](https://codeclimate.com/github/gonace/Obscured.Heartbeat/badges/gpa.svg)](https://codeclimate.com/github/gonace/Obscured.Heartbeat)

# Obscured::Heartbeat
## Introduction
Obscured Heartbeat adds heartbeat to a separate collection for an entity (Document), the naming of the class (Mongoid Document) is used for naming the heartbeat collection, so if the class is named "Host" the collection name will end up being "host_heartbeat".

## Installation
### Requirements
- activesupport
- mongoid
- mongoid_search

##### Add this line to your application's Gemfile
```ruby
gem 'obscured-heartbeat', :git => 'https://github.com/gonace/Obscured.Heartbeat.git', :branch => 'master'
```

##### Execute
```
$ bundle
```

### Usage
#### Base
Use this in files where you create non-default log collections.
```ruby
require 'obscured-heartbeat'
```


### Example
#### Document
```ruby
require 'obscured-heartbeat'

module Obscured
  class Host
    include Mongoid::Document
    include Mongoid::Timestamps
    include Obscured::Heartbeat::Tracker
    
    field :name, type: String
    field :hostname, type: String
  end
end


host = Obscured::Host.create(:name => "John Doe", :hostname => "domain.tld")
heartbeat = host.add_heartbeat(distribution: { name: 'Ubuntu', release: '19.04', codename: 'disco', description: 'Ubuntu 19.04' }, hostname: 'host.domain.tld', ip_address: '10.0.1.1', uptime: Time.now.to_i)

#returns array of heartbeats for document (proprietor)
host.get_heartbeat
host.heartbeats

#returns heartbeat by id
host.get_heartbeat(heartbeat.id.to_s)

#returns array of heartbeats by predefined params, supports pagination
host.find_heartbeats({ hostname: "domain.tld" }, { limit: 20, skip: 0, order: :created_at.desc, only: [:id, :distrubuton, :hostname, :ip_address, :uptime, :created_at, :updated_at, :proprietor] })

#retuns array of heartbeats
host.search_heartbeats("domain.tld", { limit: 20, skip: 0, order: :created_at.desc })
```

#### Service
```ruby
module Obscured
  class HostHeartbeatService
    include Mongoid::Timeline::Service::Base
  end
end

module Obscured
  class PackageSynchronizer
    def initialize(host)
      @host = host
      @service = Obscured::HostHeartbeatService.new
    end

    def last_heartbeat
      @host.by(proprietor: { host_id: host.id }).last
    end
  end
end
```