require_relative '../lib/pws/format/0.9'

describe PWS::Format::V0_9 do
  describe '.read' do
    before(:all) do
      @password    = 'password'
      @correct     = File.read('spec/fixtures/0.9/correct')
      # @v1_0        = File.read('spec/fixtures/1.0/correct')
#      @wrongly_marshalled = File.read('spec/fixtures/0.9/wrongly_marshalled')
      @invalid_iv         = File.read('spec/fixtures/0.9/invalid_iv')
      @wrongly_encrypted  = File.read('spec/fixtures/0.9/wrongly_encrypted')
    end
    
    it 'works correctly for a valid file' do
      proc{
        @data = PWS::Format::V0_9.read(@correct, password: @password)
      }.should_not raise_error
      @data.should be_a Hash
      @data['github'].should == '123456'
    end
    
#    it 'cannot read 1.0 safes' do
#      proc{ PWS::Format::V0_9.read(@v1_0) }.should raise_error(PWS::NoAccess)
#    end
    
#    it 'cannot read broken marshalled files' do
#      proc{ PWS::Format::V0_9.read(@wrongly_marshalled) }.should raise_error(PWS::NoAccess)
#    end
#    
    it 'cannot read files with invalid iv' do
      proc{ PWS::Format::V0_9.read(@invalid_iv) }.should raise_error(PWS::NoAccess)
    end

    it 'cannot read broken encrypted files' do
      proc{ PWS::Format::V0_9.read(@wrongly_encrypted) }.should raise_error(PWS::NoAccess)
    end
  end
end
