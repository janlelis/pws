require_relative '../lib/pws/runner'

describe PWS::Runner do
  describe '.parse_cli_arguments' do
    it 'returns an array of this format: [Symbol, Array, Hash]' do
      ret = PWS::Runner.parse_cli_arguments(%w"-dev get redmine")
      ret.should be_a Array
      ret.size.should == 3
      ret[0].should be_a Symbol # action
      ret[1].should be_a Array  # arguments
      ret[2].should be_a Hash   # options
    end
    
    describe 'action' do
      it 'returns the first undashed argument as action symbol' do
        ret = PWS::Runner.parse_cli_arguments(%w"get -dev redmine")
        ret[0].should == :get
        
        ret = PWS::Runner.parse_cli_arguments(%w"-dev get redmine")
        ret[0].should == :get
        
        ret = PWS::Runner.parse_cli_arguments(%w"--option value get redmine")
        ret[0].should == :get
      end
      
      it 'returns :show if no action is given' do
        ret = PWS::Runner.parse_cli_arguments(%w"-dev")
        ret[0].should == :show
        
        ret = PWS::Runner.parse_cli_arguments(%w"--option value")
        ret[0].should == :show
        
        ret = PWS::Runner.parse_cli_arguments(%w"")
        ret[0].should == :show
      end
    end
    
    describe 'options' do
      it 'treats double dash arguments as options that take a value' do
        ret = PWS::Runner.parse_cli_arguments(%w"get -dev redmine --seconds 3")
        ret[2][:seconds].should == '3'
        
        ret = PWS::Runner.parse_cli_arguments(%w"get -dev --seconds 3 redmine")
        ret[2][:seconds].should == '3'
        
        ret = PWS::Runner.parse_cli_arguments(%w"get --seconds 3 -dev redmine")
        ret[2][:seconds].should == '3'
        
        ret = PWS::Runner.parse_cli_arguments(%w"--seconds 3 get -dev redmine --length 5")
        ret[2][:seconds].should == '3'
        ret[2][:length].should == '5'
      end
      
      describe 'special options' do
        it 'behaves differently for the special options help and version' do
          ret = PWS::Runner.parse_cli_arguments(%w"get --seconds 3 --help get -dev redmine")
          ret[0].should == :help
          
          ret = PWS::Runner.parse_cli_arguments(%w"--version")
          ret[0].should == :version
        end
      end
    end
    
    describe 'namespace' do
      it 'treats single dash arguments as namespace option' do
        ret = PWS::Runner.parse_cli_arguments(%w"-dev")
        ret[2][:namespace].should == 'dev'
        
        ret = PWS::Runner.parse_cli_arguments(%w"get redmine")
        ret[2][:namespace].should == nil
        
        ret = PWS::Runner.parse_cli_arguments(%w"-dev --option value")
        ret[2][:namespace].should == 'dev'
      end
      
      it 'takes the last namespace if multiple are given' do
        ret = PWS::Runner.parse_cli_arguments(%w"-dev -better-dev")
        ret[2][:namespace].should == 'better-dev'
      end
      
      it 'namespace can also be set as usual option' do
        ret = PWS::Runner.parse_cli_arguments(%w"--namespace dev")
        ret[2][:namespace].should == 'dev'
      end
    end
    
    describe 'arguments' do
      it 'returns all input argument as arguments that are no action, namespace or option' do
        ret = PWS::Runner.parse_cli_arguments(%w"get -dev redmine --seconds 3 vs chili")
        ret[1].should == %w'redmine vs chili'
      end
    end
  end
end

