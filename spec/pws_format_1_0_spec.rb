require_relative '../lib/pws/format/1.0'

describe PWS::Format::V1_0 do

  describe '.read' do
    before(:all) do
      @correct
      @v0_9
      @wrongly_marshalled
      @wrongly_encrypted
      @invalid_iv
      # ...
    end
    
    it 'works correctly for a valid file' do
      pending
    end
    
    it 'also works with the newer pws header' do
      pending
    end
    
    it 'cannot read 1.0 safes' do
      pending
    end
    
    it 'cannot read broken marshalled files' do
      pending
    end
    
    it 'cannot read broken encrypted files' do
      pending
    end
  end
  
#  describe '.write' do
#    before(:all) do
#      @data = {}
#      @settings = {}
#    end
#    
#    it 'creates the password file' do
#      
#    end
#    
#    
#    describe 'stress' do
#      it '1000 write-read iterations' do
#        
#      end
#    end
#  end
  

end
