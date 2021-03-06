# frozen_string_literal: true

module Api
  module Admin
    class BasicOrderCycleSerializer < ActiveModel::Serializer
      include OrderCyclesHelper

      attributes :id, :name, :status, :orders_open_at, :orders_close_at

      has_many :suppliers, serializer: Api::Admin::IdNameSerializer
      has_many :distributors, serializer: Api::Admin::IdNameSerializer

      def status
        order_cycle_status_class object
      end

      def orders_open_at
        object.orders_open_at&.strftime("%F %T %z")
      end

      def orders_close_at
        object.orders_close_at&.strftime("%F %T %z")
      end
    end
  end
end
