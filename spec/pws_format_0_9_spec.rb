require_relative '../lib/pws/format/0.9'
require_relative '../lib/pws/format/1.0'

describe PWS::Format::V0_9 do
  describe '.read' do
    before(:all) do
      @password    = 'password'
      @correct     = File.read('spec/fixtures/0.9/correct')
      @v1_0        = File.read('spec/fixtures/1.0/correct')
      @invalid_iv          = File.read('spec/fixtures/0.9/invalid_iv')
      @invalid_encryption  = File.read('spec/fixtures/0.9/invalid_encryption')
      @invalid_marshalling = File.read('spec/fixtures/0.9/invalid_marshalling')
      @manipulated_file    = File.read('spec/fixtures/0.9/manipulated_file')
    end
    
    it 'works correctly for a valid file' do
      proc{
        @data = PWS::Format::V0_9.read(@correct, password: @password)
      }.should_not raise_error
      @data.should be_a Hash
      @data['github'][:password].should == '123456'
    end
    
    it 'cannot read 1.0 safes' do
      proc{
        PWS::Format::V0_9.read(@v1_0, password: @password)
      }.should raise_error(PWS::NoAccess)
    end
    
    it 'cannot read files with wrong password' do
      proc{
        PWS::Format::V0_9.read(@correct, password: '12345678')
      }.should raise_error(PWS::NoAccess)
    end
    
    it 'cannot read files with invalid iv' do
      proc{
        PWS::Format::V0_9.read(@invalid_iv, password: @password)
      }.should raise_error(PWS::NoAccess)
    end

    it 'cannot read files with invalid encryption' do
      proc{
        PWS::Format::V0_9.read(@invalid_encryption, password: @password)
      }.should raise_error(PWS::NoAccess)
    end
    
    it 'cannot read files with invalid marshalling' do
      proc{
        PWS::Format::V0_9.read(@invalid_marshalling, password: @password)
      }.should raise_error(PWS::NoAccess)
    end
    
    it 'BUG: does not do integrity checks' do
      proc{
        PWS::Format::V0_9.read(@manipulated_file, password: @password)
      }.should_not raise_error
    end
  end
  
  describe '.write' do
    it 'raises a NotImplementedError' do
      proc{ 
        PWS::Format::V0_9.write('data', {})
      }.should raise_error(NotImplementedError)
    end
  end
end
