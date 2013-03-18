module BraintreeRails
  class Addresses < SimpleDelegator
    include Association

    def initialize(customer)
      @customer = customer
      super(customer.raw_object.addresses)
    end

    def default_options
      {:customer_id => @customer.id}
    end
  end
end
