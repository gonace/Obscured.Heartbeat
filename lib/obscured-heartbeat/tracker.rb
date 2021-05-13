# frozen_string_literal: true

require 'active_support/concern'

module Obscured
  module Heartbeat
    module Tracker
      extend ActiveSupport::Concern

      class Record
        include Obscured::Heartbeat::Record
      end

      # Adds heartbeat to the x_heartbeat collection for document. This is
      # only called on manually.
      #
      # @example Add heartbeat.
      #   document.add_heartbeat
      #
      # @return [ document ]
      def add_heartbeat(event)
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.make!(event.merge(proprietor: { "#{self.class.name.demodulize.downcase}_id".to_sym => id }))
        end
      end

      # Get an heartbeat from the x_heartbeat collection for document. This is
      # only called on manually.
      #
      # @example Get heartbeat.
      #   document.get_heartbeat(id)
      #
      # @return [ document ]
      def get_heartbeat(id)
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.find(id)
        end
      end

      # Get heartbeats from the x_heartbeat collection for document by proprietor. This is
      # only called on manually.
      #
      # @example Get heartbeats.
      #   document.get_heartbeats
      #   document.heartbeats
      #
      # @return [ documents ]
      def get_heartbeats
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.by(proprietor: { "#{self.class.name.demodulize.downcase}_id".to_sym => id })
        end
      end
      alias heartbeats get_heartbeats

      # Find heartbeats from the x_heartbeat collection for document. This is
      # only called on manually.
      #
      # @example Get heartbeats.
      #   document.find_heartbeats(params, options)
      #
      # @return [ documents ]
      def find_heartbeats(params, options)
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.by({ proprietor: { "#{self.class.name.demodulize.downcase}_id".to_sym => id } }.merge(params), options)
        end
      end

      # Search heartbeats from the x_heartbeat collection for document. This is
      # only called on manually.
      #
      # @example Get heartbeats.
      #   document.search_heartbeats(text, options)
      #
      # @return [ documents ]
      def search_heartbeats(text, options)
        limit = options[:limit].blank? ? nil : options[:limit].to_i
        skip = options[:skip].blank? ? nil : options[:skip].to_i
        order = options[:order].blank? ? :created_at.desc : options[:order]

        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          criteria = m.full_text_search(text)
          criteria = criteria.order_by(order) if order
          criteria = criteria.limit(limit).skip(skip)

          docs = criteria.to_a
          docs
        end
      end

      # Edit an heartbeat from the x_heartbeat collection by id. This is
      # only called on manually.
      #
      # @example Get heartbeat.
      #   document.edit_heartbeat(id, params)
      #
      # @return [ document ]
      def edit_heartbeat(id, params = {})
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          hb = m.where(id: id).first
          hb.hostname = params[:hostname] if params[:hostname]
          hb.save
          hb
        end
      end

      # Delete an heartbeat from the x_heartbeat collection by id. This is
      # only called on manually.
      #
      # @example Get heartbeat.
      #   document.delete_heartbeat(id)
      #
      # @return [ document ]
      def delete_heartbeat(id)
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.where(id: id).delete
        end
      end

      # Clear heartbeats from the x_heartbeat collection for document. This is
      # only called on manually.
      #
      # @example Get heartbeats.
      #   document.clear_heartbeats
      #
      # @return [ documents ]
      def clear_heartbeats
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.where(proprietor: { "#{self.class.name.demodulize.downcase}_id".to_sym => id }).delete
        end
      end
    end
  end
end
