# frozen_string_literal: true

require 'mongoid'
require 'mongoid_search'

module Mongoid
  module Heartbeat
    module Record
      extend ActiveSupport::Concern

      included do
        include Mongoid::Document
        include Mongoid::Search
        include Mongoid::Timestamps

        field :distribution, type: Hash
        field :hostname, type: String
        field :ip_address, type: String
        field :uptime, type: Integer
        field :proprietor, type: Hash

        index({ hostname: 1 }, background: true)
        index({ _keywords: 1 }, background: true)

        search_in :id, :hostname, :ip_address, proprietor: %i[host_id gateway_id]
      end

      module ClassMethods
        def make(params = {})
          raise ArgumentError, 'distribution missing' if params[:distribution].blank?
          raise ArgumentError, 'hostname missing' if params[:hostname].blank?
          raise ArgumentError, 'ip_address missing' if params[:ip_address].blank?
          raise ArgumentError, 'uptime missing' if params[:uptime].blank?
          raise ArgumentError, 'proprietor missing' if params[:proprietor].blank?

          doc = new
          doc.distribution = params[:distribution]
          doc.hostname = params[:hostname]
          doc.ip_address = params[:ip_address]
          doc.uptime = params[:uptime]
          doc.proprietor = params[:proprietor]
          doc
        end

        def make!(params = {})
          doc = make(params)
          doc.save!
          doc
        end

        def by(params = {}, options = {})
          limit = options[:limit].blank? ? nil : options[:limit].to_i
          skip = options[:skip].blank? ? nil : options[:skip].to_i
          order = options[:order].blank? ? :created_at.desc : options[:order]
          only = options[:only].blank? ? %i[id distrubuton hostname ip_address uptime created_at updated_at proprietor] : options[:only]

          query = {}
          query[:hostname] = params[:hostname] if params[:hostname]
          params[:proprietor]&.map { |k, v| query.merge!("proprietor.#{k}" => v) }

          criterion = where(query).only(only).limit(limit).skip(skip)
          criterion = criterion.order_by(order) if order

          docs = criterion.to_a
          docs
        end
      end
    end
  end
end
