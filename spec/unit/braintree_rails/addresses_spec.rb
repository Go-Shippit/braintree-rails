require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Addresses do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
  end

  describe '#initialize' do
    it 'should wrap an array of Braintree::Address' do
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_addresses = braintree_customer.addresses
      addresses = BraintreeRails::Addresses.new(BraintreeRails::Customer.find('customer_id'))

      addresses.size.should == braintree_addresses.size

      braintree_addresses.each do |braintree_address|
        address = addresses.find(braintree_address.id)
        BraintreeRails::Address.attributes.each do |attribute|
          address.send(attribute).should == braintree_address.send(attribute)
        end
      end
    end
  end

  describe '#build' do
    it 'should build new Address object with customer_id and params' do
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_addresses = braintree_customer.addresses
      addresses = BraintreeRails::Addresses.new(BraintreeRails::Customer.find('customer_id'))
      address = addresses.build({:first_name => 'foo', :last_name => 'bar'})

      address.should_not be_persisted
      address.customer_id.should == braintree_customer.id
      address.first_name.should == 'foo'
      address.last_name.should == 'bar'
    end
  end
end
