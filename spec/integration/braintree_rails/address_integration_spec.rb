require File.expand_path(File.join(File.dirname(__FILE__), '../integration_spec_helper'))

describe 'Address Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should be able to add address' do
    customer = BraintreeRails::Customer.create!(customer_hash)
    attributes = address_hash()
    customer.addresses.create!(attributes)
    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_address = braintree_customer.addresses.first

    attributes.each do |key, value|
      expect(braintree_address.send(key)).to eq(value)
    end
  end

  it 'should be able to update existing address' do
    customer = BraintreeRails::Customer.create!(customer_hash)
    address = customer.addresses.create(address_hash)
    address.update_attributes(:first_name => 'Foo')

    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_address = braintree_customer.addresses.first
    expect(braintree_address.first_name).to eq('Foo')

    address.last_name = 'Bar'
    address.save!

    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_address = braintree_customer.addresses.first
    expect(braintree_address.last_name).to eq('Bar')
  end

  it 'should be able to destroy existing address' do
    customer = BraintreeRails::Customer.create!(customer_hash)
    address = customer.addresses.create!(address_hash)
    address.destroy
    expect { Braintree::Address.find(customer.id, address.id) }.to raise_error(Braintree::NotFoundError)
    expect(address).to_not be_persisted
    expect(address).to be_frozen

    address = customer.addresses.create!(address_hash)
    BraintreeRails::Address.delete(customer.id, address.id)
    expect { Braintree::Address.find(customer.id, address.id) }.to raise_error(Braintree::NotFoundError)
  end
end