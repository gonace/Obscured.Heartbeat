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
gem 'Obscured.Heartbeat, :git => 'git@github.com:gonace/Obscured.Heartbeat.git', :branch => 'master'
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
#### Usage
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
heartbeat = account.add_heartbeat({ ... })

#returns array of heartbeats for document (proprietor)
host.get_heartbeat
host.heartbeats

#returns heartbeat by id
host.get_heartbeat(heartbeat.id.to_s)

#returns array of heartbeats by predefined params, supports pagination
host.find_heartbeats({ type: nil, producer: nil }, { limit: 20, skip: 0, order: :created_at.desc, only: [:id, :type, :message, :producer, :created_at, :updated_at, :proprietor] })

#retuns array of heartbeats
host.search_heartbeats("domain.tld", { type: :comment, limit: 20, skip: 0, order: :created_at.desc })
```