require "spec_helper"

describe SDClient do

  let(:subject) do
    SDClient.new("billy@gmail.com","123456")
  end

  context "creating new client" do
    it "has a username" do
      expect(subject.username).to eq("billy@gmail.com")
    end

    it "returns the sha1 password" do
      expect(subject.password).to eq("7c4a8d09ca3762af61e59520943dc26494f8941b")
    end
  end

  context "authentication to the remote machine" do
    it "authenticates to the service" do
      token_response = <<-RESPONSE
{
    "code": 0,
    "message": "OK",
    "serverID": "AWS-SD-web.1",
    "datetime": "2016-08-23T13:55:25Z",
    "token": "f3fca79989cafe7dead71beefedc812b"
}
RESPONSE
      stub_request(:post, "http://json.schedulesdirect.org/20141201/token").
        with(:body => "{\"username\":\"billy@gmail.com\",\"password\":\"7c4a8d09ca3762af61e59520943dc26494f8941b\"}").to_return(:status => 200, :body => token_response, :headers => {})

      subject.authenticate

      expect(subject.token).to_not be nil
    end

    it "fails to authenticate due to offline" do

    service_offline = <<-RESPONSE
{
    "response": "SERVICE_OFFLINE",
    "code": 3000,
    "serverID": "20141201.web.1",
    "message": "Server offline for maintenance.",
    "datetime": "2015-04-23T00:03:32Z",
    "token": "CAFEDEADBEEFCAFEDEADBEEFCAFEDEADBEEFCAFE"
}
RESPONSE
      stub_request(:post, "http://json.schedulesdirect.org/20141201/token").
        with(:body => "{\"username\":\"billy@gmail.com\",\"password\":\"7c4a8d09ca3762af61e59520943dc26494f8941b\"}").to_return(:status => 200, :body => service_offline, :headers => {})
      expect { subject.authenticate }.to raise_error(SDClient::ServiceOffline, "Opps Upstream service offline, please try again in 30 minutes.")
    end
  end


end
