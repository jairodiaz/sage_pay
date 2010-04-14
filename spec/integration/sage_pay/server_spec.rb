require 'spec_helper'

if run_integration_specs?
  describe SagePay::Server, "integration specs" do
    describe ".payment" do
      before(:each) do
        SagePay::Server.default_registration_options = {
          :mode => :simulator,
          :vendor => "rubaidh",
          :notification_url => "http://test.host/notification"
        }

        @payment = SagePay::Server.payment(
          :description => "Demo payment",
          :amount => 12.34,
          :currency => "GBP",
          :billing_address => address_factory
        )
      end

      after(:each) do
        SagePay::Server.default_registration_options = {}
      end

      it "should successfully register the payment with SagePay" do
        @payment.register!.should_not be_nil
      end

      it "should be a valid registered payment" do
        registration = @payment.register!
        registration.should be_ok
      end

      it "should have a next URL" do
        registration = @payment.register!
        registration.next_url.should_not be_nil
      end

      it "should allow us to follow the next URL and the response should be successful" do
        registration = @payment.register!
        uri = URI.parse(registration.next_url)
        request = Net::HTTP::Get.new(uri.request_uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        http.start { |http|
          http.request(request)
        }
      end

      it "should allow us to retrieve signature verification details" do
        @payment.register!
        sig_details = @payment.signature_verification_details

        sig_details.should_not                be_nil
        sig_details.security_key.should_not   be_nil
        sig_details.vendor.should_not         be_nil
      end
    end
  end
end