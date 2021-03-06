# frozen_string_literal: true

module OpenFoodNetwork
  class CustomersReport
    attr_reader :params

    def initialize(user, params = {}, compile_table = false)
      @params = params
      @user = user
      @compile_table = compile_table
    end

    def header
      if is_mailing_list?
        [I18n.t(:report_header_email),
         I18n.t(:report_header_first_name),
         I18n.t(:report_header_last_name),
         I18n.t(:report_header_suburb)]
      else
        [I18n.t(:report_header_first_name),
         I18n.t(:report_header_last_name),
         I18n.t(:report_header_billing_address),
         I18n.t(:report_header_email),
         I18n.t(:report_header_phone),
         I18n.t(:report_header_hub),
         I18n.t(:report_header_hub_address),
         I18n.t(:report_header_shipping_method)]
      end
    end

    def table
      return [] unless @compile_table

      orders.map do |order|
        if is_mailing_list?
          [order.email,
           order.billing_address.firstname,
           order.billing_address.lastname,
           order.billing_address.city]
        else
          ba = order.billing_address
          da = order.distributor&.address
          [ba.firstname,
           ba.lastname,
           [ba.address1, ba.address2, ba.city].join(" "),
           order.email,
           ba.phone,
           order.distributor&.name,
           [da&.address1, da&.address2, da&.city].join(" "),
           order.shipping_method&.name]
        end
      end
    end

    def orders
      filter Spree::Order.managed_by(@user).distributed_by_user(@user).complete.not_state(:canceled)
    end

    def filter(orders)
      filter_to_supplier filter_to_distributor filter_to_order_cycle orders
    end

    def filter_to_supplier(orders)
      if params[:supplier_id].to_i > 0
        orders.select do |order|
          order.line_items.includes(:product)
            .where("spree_products.supplier_id = ?", params[:supplier_id].to_i)
            .references(:product)
            .count
            .positive?
        end
      else
        orders
      end
    end

    def filter_to_distributor(orders)
      if params[:distributor_id].to_i > 0
        orders.where(distributor_id: params[:distributor_id])
      else
        orders
      end
    end

    def filter_to_order_cycle(orders)
      if params[:order_cycle_id].to_i > 0
        orders.where(order_cycle_id: params[:order_cycle_id])
      else
        orders
      end
    end

    private

    def is_mailing_list?
      params[:report_type] == "mailing_list"
    end
  end
end
