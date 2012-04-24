require_relative '../lib/pws/format'

describe PWS::Format do
  describe '.[]' do
    before(:all) do
      %w(V42_0 V42_1 V42_2).each{ |v|
        PWS::Format.const_set(v, v)
      }
    end
    
    context 'succesful call' do
      it 'returns the proper version constant when specifing version as Array of Integers' do
        PWS::Format[[42,1]].should == 'V42_1'
      end
      
      it 'returns the proper version constant when specifing version with Integers' do
        PWS::Format[42, 1].should == 'V42_1'
      end
      
      it 'returns the proper version constant when specifing version as Array of Strings (to_i gets called)' do
        PWS::Format[["42e", "1<"]].should == 'V42_1'
      end
      
      it 'returns the proper version constant when specifing version with Strings (to_i gets called)' do
        PWS::Format["42e", "2!"].should == 'V42_2'
      end
      
      it 'returns the proper version constant when specifing version with a single String (split by .)' do
        PWS::Format["42.2"].should == 'V42_2'
      end
      
      it 'returns the proper version constant when specifing version with a single Float' do
        PWS::Format[42.1].should == 'V42_1'
      end
      
      it 'also returns the proper version constant if only major version is given' do
        PWS::Format[42].should == 'V42_0'
      end
      
      it 'also returns the proper version constant if only major version is given (String)' do
        PWS::Format[42].should == 'V42_0'
      end
      
      it 'really works for 1.0' do
        PWS::Format[1, 0].should == PWS::Format::V1_0
      end
      
      it 'it falls back to [0.9] for backward compatibility (nil given)' do
        PWS::Format[nil].should == PWS::Format::V0_9
      end
    end
    
    context 'wrong call' do
      it 'raises ArgumentError when called with wrong argument type' do
        proc{ PWS::Format[{$$ => $$}] }.should raise_error ArgumentError, "Invalid version given"
      end
      
      it 'raises ArgumentError when called with senseless argument' do
        proc{ PWS::Format[[]] }.should raise_error ArgumentError, "Invalid version given"
      end
      
      it 'raises LoadError when version cannot be found' do
        proc{ PWS::Format[43, 1] }.should raise_error LoadError
      end
      
    end
    
    
  end
end


__END__
raise(ArgumentError, "Format version #{ version.join('.') } could not be found within the pws gem") 
