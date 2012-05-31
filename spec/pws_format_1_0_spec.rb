# coding: utf-8

require_relative '../lib/pws/format/0.9'
require_relative '../lib/pws/format/1.0'

describe PWS::Format::V1_0 do

  describe '.read' do
    before(:all) do
      @password = 'password'
      @correct                    = File.read('spec/fixtures/1.0/correct')
      @correct_1000000_iterations = File.read('spec/fixtures/1.0/correct_1000000_iterations')
      @v0_9                       = File.read('spec/fixtures/0.9/correct')
      @invalid_iv                 = File.read('spec/fixtures/1.0/invalid_iv')
      @invalid_iterations         = File.read('spec/fixtures/1.0/invalid_iterations')
      @invalid_salt               = File.read('spec/fixtures/1.0/invalid_salt')
      @invalid_data               = File.read('spec/fixtures/1.0/invalid_data')
      @invalid_hmac               = File.read('spec/fixtures/1.0/invalid_hmac')
    end
    
    it "calls V1_0.decrypt and V1_0.unmarshal" do
      PWS::Format::V1_0.should_receive(:decrypt)
      PWS::Format::V1_0.should_receive(:unmarshal)
      PWS::Format.read(@correct, format: 1.0, password: @password)
    end
    
    it 'works correctly for a valid file' do
      proc{
        @data = PWS::Format.read(@correct, format: 1.0, password: @password)
      }.should_not raise_error
      @data.should be_a Hash
      @data['github'][:password].should == '123456'
    end
    
    it 'works correctly for a valid file with many iterations' do
      proc{
        @data = PWS::Format.read(@correct_1000000_iterations, format: 1.0, password: @password)
      }.should_not raise_error
      @data.should be_a Hash
      @data['github'][:password].should == '123456'
    end
    
    it 'cannot read 0.9 safes' do
      proc{
        PWS::Format.read(@v0_9, format: 1.0, password: @password)
      }.should raise_error(PWS::NoAccess)
    end
    
    it 'cannot read files with wrong password' do
      proc{
        PWS::Format.read(@correct, format: 1.0, password: '12345678')
      }.should raise_error(PWS::NoAccess)
    end
    
    it 'cannot read files with invalid iv' do
      proc{
        PWS::Format.read(@invalid_iv, format: 1.0, password: @password)
      }.should raise_error(PWS::NoAccess)
    end

    it 'cannot read files with invalid salt' do
      proc{
        PWS::Format.read(@invalid_salt, format: 1.0, password: @password)
      }.should raise_error(PWS::NoAccess)
    end
    
    it 'cannot read files with invalid hmac' do
      proc{
        PWS::Format.read(@invalid_hmac, format: 1.0, password: @password)
      }.should raise_error(PWS::NoAccess)
    end
    
    it 'cannot read files with invalid data' do
      proc{
        PWS::Format.read(@invalid_data, format: 1.0, password: @password)
      }.should raise_error(PWS::NoAccess)
    end
  end
  
  describe '.write' do
    before(:all) do
      @data = {
        'github' => { password: '123456', timestamp: Time.now.to_i },
        '⌨'.unpack('a*')[0] => { password: '⌨'.unpack('a*')[0], timestamp: Time.now.to_i },
        'twittör'.unpack('a*')[0]  => { password: 'twittör'.unpack('a*')[0], timestamp: Time.now.to_i },
      }
      @password = 'password'
    end
    
    it "calls V1_0.marshal and V1_0.encrypt" do
      PWS::Format::V1_0.should_receive(:marshal)
      PWS::Format::V1_0.should_receive(:encrypt)
      PWS::Format.write(@data, format: 1.0, password: @password)
    end
    
    it 'stores the iteration count in the password file' do
      iter = 500
      res = PWS::Format.write(@data, format: 1.0, password: @password, iterations: iter)
      res.unpack('A91 N')[1].should == 500
    end
    
    it 'cannot create password files with more than 10_000_000 iterations' do
      proc{ 
        PWS::Format.write(@data, format: 1.0, password: @password, iterations: 10_000_001)
      }.should raise_error(ArgumentError, 'Invalid iteration count given')
    end
    
    it 'cannot create password files with less than 2 iterations' do
      proc{ 
        PWS::Format.write(@data, format: 1.0, password: @password, iterations: 1)
      }.should raise_error(ArgumentError, 'Invalid iteration count given')
    end
    
    it 'always uses different salt' do
      res1  = PWS::Format.write(@data, format: 1.0, password: @password, iterations: 5)
      salt1 = res1.unpack('A11 A64')[1]
      res2  = PWS::Format.write(@data, format: 1.0, password: @password, iterations: 5)
      salt2 = res2.unpack('A11 A64')[1]
      salt1.should_not == salt2
    end
    
    it 'always uses different iv' do
      res1  = PWS::Format.write(@data, format: 1.0, password: @password, iterations: 5)
      iv1   = res1.unpack('A75 A16')[1]
      res2  = PWS::Format.write(@data, format: 1.0, password: @password, iterations: 5)
      iv2   = res2.unpack('A75 A16')[1]
      iv1.should_not == iv2
    end
    
    it 'creates files with size > 200_000 bytes' do
      PWS::Format.write(
        @data, format: 1.0, password: @password
      ).unpack('A*')[0].size.should > 200_000
    end
    
    it 'keeps the same data when reading own output' do
      res      = PWS::Format.write(@data, format: 1.0, password: @password, iterations: 10_0)
      new_data = PWS::Format.read(res,    format: 1.0, password: @password)
      @data.should == new_data
    end
    
    describe 'stress' do
      it 'no errors on 400 write-reads (1/2)' do
        300.times{
          res      = PWS::Format.write(@data, format: 1.0, password: @password, iterations: 2)
          new_data = PWS::Format.read(res,    format: 1.0, password: @password)
          @data.should == new_data
        }
      end
      
      it 'no errors on 400 write-reads (2/2)' do
        300.times{
          res      = PWS::Format.write(@data, format: 1.0, password: @password, iterations: 2)
          new_data = PWS::Format.read(res,    format: 1.0, password: @password)
          @data.should == new_data
        }
      end
      
      it 'no errors on 400 write-reads, getting more and more data' do
        data = @data.dup
        300.times{
          data[SecureRandom.random_bytes(SecureRandom.random_number(1000))] = {
            password: SecureRandom.random_bytes(SecureRandom.random_number(1000)),
            timestamp: SecureRandom.random_number(Time.now.to_i),
          }
          res      = PWS::Format.write(data, format: 1.0, password: @password, iterations: 2)
          new_data = PWS::Format.read(res,    format: 1.0, password: @password)
          data.should == new_data
        }
      end
    end
  end
  
  describe 'misc' do
    it 'generates the same kdf, no matter which implementation' do
      password = "12345678"
      salt     = SecureRandom.random_bytes(64)
      iterations = SecureRandom.random_number(10_000)
      PWS::Format::V1_0.kdf_ruby(password, salt, iterations).should ==
        PWS::Format::V1_0.kdf_openssl(password, salt, iterations)
    end
  end
end
