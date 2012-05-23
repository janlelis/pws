require_relative '../lib/pws/format'

describe PWS::Format do
  describe '.read' do
    before(:all) do
      @correct          = "12345678\x01\x00\x00data"
      @unknown_format   = "12345678\xfd\x00\x00data"
      @wrong_identifier = "012345678\x01\x00\x00data"
      @too_short1       = "12345678\x01"
      @too_short2       = "12345678"
      @legacy           = "data"
    end
    
    before(:each) do
      @options = {
        key: 'value',
      }
    end
    
    it 'delegates to the proper (current) format reader if data is in correct format' do
      PWS::Format[[1,0]].should_receive(:read).with('data', @options)
      PWS::Format.read(@correct, @options)
    end
    
    it 'takes a format option that allows specifying input format' do
      PWS::Format[[0,9]].should_receive(:read).with('data', @options)
      PWS::Format.read(@legacy, @options.merge(format: 0.9))
    end
    
    it 'cannot read legacy files without specifying input format' do
      proc{
        PWS::Format.read(@legacy, @options)
      }.should raise_error(PWS::NoAccess)
    end
    
    it 'cannot read unknown formats and reports that' do
      proc{
        PWS::Format.read(@unknown_format)
      }.should raise_error(
        PWS::NoAccess,
        "Input format <253.0> is not supported",
      )
    end
    
    it "won't read, if identifier is unknown and reports that" do
      proc{ PWS::Format.read(@wrong_identifier) }.should raise_error(
        PWS::NoAccess,
        'Password file not valid',
      )
    end
    
    it 'cannot read if given data is too short' do
      proc{ PWS::Format.read(@too_short1) }.should raise_error(
        PWS::NoAccess,
        'Password file not valid',
      )
      proc{ PWS::Format.read(@too_short2) }.should raise_error(
        PWS::NoAccess,
        'Password file not valid',
      )
    end
  end
  
  describe '.write' do
    before(:each) do
      @data = { "some" => { password: 'data_to_be_written' } }
    end
    
    it 'delegates to the proper format writer, determined by options[:format], passing the data, deleting the format from the options hash' do
      PWS::Format[[1,0]].should_receive(:write).with(@data, {})
      PWS::Format.write(@data, { format: 1.0 })
    end
    
    it 'uses the current PWS::VERSION file format if no other one is given' do
      PWS::Format[PWS::Format.normalize_format(PWS::VERSION)].should_receive(:write).with(@data, {})
      PWS::Format.write(@data, {})
    end
    
    it 'writes the identifier and version header' do
      PWS::Format.write(
        @data, { format: 1.0, password: '123' }
      )[0...11].should == "12345678\x01\x00\x00"
    end
  end
  
  describe '.normalize_format' do
    it 'returns Symbol                  when Symbol given (unchanged)' do
      PWS::Format.normalize_format(:buffy).should == :buffy
    end
    
    it 'returns Array(Integer, Integer) when Array(Integer, Integer) given' do
      PWS::Format.normalize_format([42,1]).should == [42,1]
    end
    
    it 'returns Array(Integer, Integer) when Array(Integer, Integer, Integer) given' do
      PWS::Format.normalize_format([42,1,9]).should == [42,1]
    end
    
    it 'returns Array(Integer, 0)       when Array(Integer) given' do
      PWS::Format.normalize_format([42]).should == [42,0]
    end
    
    it 'returns Array(Integer, 0)       when only one integer is given' do
      PWS::Format.normalize_format(42).should == [42,0]
    end
    
    it 'returns Array(Integer, Integer) when Array(String, String) given (to_i gets called)' do
      PWS::Format.normalize_format(["42e", "1<"]).should == [42,1]
    end
    
    it 'returns Array(Integer, Integer) when String given (split by .)' do
      PWS::Format.normalize_format("42e.1<.9").should == [42,1]
    end
    
    it 'returns Array(Integer, 0)       when String given (split by ., but leads to only one element)' do
      PWS::Format.normalize_format("42e,1<,9").should == [42,0]
    end
    
    it 'returns Array(Integer, Integer) when Fload given (to_s, then split by .)' do
      PWS::Format.normalize_format(42.1).should == [42,1]
    end
    
    it 'returns nil when nil given' do
      PWS::Format.normalize_format(nil).should == nil
    end
    
    it 'raises an ArgumentError on other stuff' do
      proc{
        PWS::Format.normalize_format([])
      }.should raise_error(ArgumentError, "Invalid format given")
      
      proc{
        PWS::Format.normalize_format(/re/)
      }.should raise_error(ArgumentError, "Invalid format given")
    end
  end
  
  describe '.[]' do
    before(:all) do
      %w(V42_0 V42_1 V42_2 Buffy).each{ |v| PWS::Format.const_set(v, v) }
    end
    
    it 'returns the proper format constant (Array given)' do
      PWS::Format.should_receive(:require_relative).with('format/42.1')
      PWS::Format[[42,1]].should == 'V42_1'
    end
    
    it 'returns the proper format constant (Symbol given)' do
      PWS::Format.should_receive(:require_relative).with('format/buffy')
      PWS::Format[:buffy].should == 'Buffy'
    end

    it 'really works for 1.0' do
      PWS::Format[[1,0]].should == PWS::Format::V1_0
    end

    it 'raises an ArgumentError when called with an invalid Array' do
      proc{
        PWS::Format[[1,"String"]]
      }.should raise_error(ArgumentError)
    end
    
    it 'raises an ArgumentError when called with something other than an Array or Symbol' do
      proc{
        PWS::Format["String"]
      }.should raise_error(ArgumentError)
    end
    
    it 'raises an LoadError when format cannot be found' do
      proc{
        PWS::Format[[0, 5]]
      }.should raise_error(LoadError)
    end
  end#[]
end
