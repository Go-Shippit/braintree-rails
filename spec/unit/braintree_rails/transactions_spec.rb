require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Transactions do

  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
    stub_braintree_request(:get, '/payment_methods/credit_card/credit_card_id', :body => fixture('credit_card.xml'))
  end

  describe '#initialize' do
    it 'should load an array of Braintree::Transaction' do
      stub_braintree_request(:post, '/transactions/advanced_search_ids', :body => fixture('transaction_ids.xml'))
      stub_braintree_request(:post, '/transactions/advanced_search', :body => fixture('transactions.xml'))

      braintree_transactions = Braintree::Transaction.search do |search|
        search.customer_id.is 'customer_id'
        search.payment_method_token.is 'credit_card_id'
      end

      transactions = BraintreeRails::Transactions.new(BraintreeRails::Customer.new('customer_id'))

      expect(transactions.map(&:id).sort).to eq(braintree_transactions.map(&:id).sort)
    end

    it 'should load all transactions' do
      stub_braintree_request(:post, '/transactions/advanced_search_ids', :body => fixture('transaction_ids.xml'))
      stub_braintree_request(:post, '/transactions/advanced_search', :body => fixture('transactions.xml'))

      braintree_transactions = Braintree::Transaction.search
      transactions = BraintreeRails::Transactions.new(nil)
      expect(transactions.map(&:id).sort).to eq(braintree_transactions.map(&:id).sort)
    end
  end

  describe '#build' do
    it 'should use default options' do
      stub_braintree_request(:post, '/transactions/advanced_search_ids', :body => fixture('transaction_ids.xml'))
      stub_braintree_request(:post, '/transactions/advanced_search', :body => fixture('transactions.xml'))
      customer = BraintreeRails::Customer.new('customer_id')
      transactions = BraintreeRails::Transactions.new(customer)
      transaction = transactions.build
      expect(transaction.customer).to eq(customer)
      expect(transaction.credit_card).to eq(customer.credit_cards.find(&:default?))
    end

    it 'has no default options when loading all' do
      transactions = BraintreeRails::Transactions.new(nil)
      transaction = transactions.build
      expect(transaction.attributes.except(:type).values.compact).to be_empty
    end

    it 'should be able to override default values' do
      transactions = BraintreeRails::Transactions.new(BraintreeRails::Customer.new('customer_id'))
      customer = BraintreeRails::Customer.new(:first_name => 'Braintree')
      transaction = transactions.build(:customer => customer)
      expect(transaction.customer).to eq(customer)
    end
  end

  describe '#lazy_loading' do
    it 'should not load if not necessary' do
      expect {BraintreeRails::Transactions.new(BraintreeRails::Customer.new('customer_id'))}.not_to raise_error()
    end

    it 'load from Braintree when needed' do
      transactions = BraintreeRails::Transactions.new(BraintreeRails::Customer.new('customer_id'))
      stub_braintree_request(:post, '/transactions/advanced_search_ids', :body => fixture('transaction_ids.xml'))
      stub_braintree_request(:post, '/transactions/advanced_search', :body => fixture('transactions.xml'))

      expect(transactions.find('transactionid')).to_not be_blank
    end
  end
end