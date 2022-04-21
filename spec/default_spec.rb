require 'yaml'

describe 'compiled component password-generator' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/default.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/default/password-generator.compiled.yaml") }
  
  context "Resource" do

    
    context "PasswordSSMSecureParameter" do
      let(:resource) { template["Resources"]["PasswordSSMSecureParameter"] }

      it "is of type Custom::SSMSecureParameter" do
          expect(resource["Type"]).to eq("Custom::SSMSecureParameter")
      end
      
      it "to have property ServiceToken" do
          expect(resource["Properties"]["ServiceToken"]).to eq({"Fn::GetAtt"=>["SSMSecureParameterCR", "Arn"]})
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq({"Fn::Sub"=>"/${Identifier}/${EnvironmentName}/${PathSuffix}"})
      end
      
      it "to have property Description" do
          expect(resource["Properties"]["Description"]).to eq({"Fn::Sub"=>"Secret parameter for ${EnvironmentName} ${Identifier}"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-${Identifier}"}}, {"Key"=>"Environment", "Value"=>{"Fn::Sub"=>"${EnvironmentName}"}}, {"Key"=>"EnvironmentType", "Value"=>{"Fn::Sub"=>"${EnvironmentType}"}}])
      end
      
    end
    
    context "LambdaRoleSSMParameterCustomResource" do
      let(:resource) { template["Resources"]["LambdaRoleSSMParameterCustomResource"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>"lambda.amazonaws.com"}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq("/")
      end
      
      it "to have property Policies" do
          expect(resource["Properties"]["Policies"]).to eq([{"PolicyName"=>"cloudwatch-logs", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams", "logs:DescribeLogGroups"], "Resource"=>["arn:aws:logs:*:*:*"]}]}}, {"PolicyName"=>"ssm", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["ssm:AddTagsToResource", "ssm:DeleteParameter", "ssm:PutParameter", "ssm:GetParameters"], "Resource"=>"*"}]}}])
      end
      
    end
    
    context "SSMSecureParameterCR" do
      let(:resource) { template["Resources"]["SSMSecureParameterCR"] }

      it "is of type AWS::Lambda::Function" do
          expect(resource["Type"]).to eq("AWS::Lambda::Function")
      end
      
      it "to have property Code" do
          expect(resource["Properties"]["Code"]["S3Bucket"]).to eq("")
          expect(resource["Properties"]["Code"]["S3Key"]).to start_with("/latest/SSMSecureParameterCR.password-generator.latest.")
      end
      
      it "to have property Environment" do
          expect(resource["Properties"]["Environment"]).to eq({"Variables"=>{}})
      end
      
      it "to have property Handler" do
          expect(resource["Properties"]["Handler"]).to eq("handler.lambda_handler")
      end
      
      it "to have property MemorySize" do
          expect(resource["Properties"]["MemorySize"]).to eq(128)
      end
      
      it "to have property Role" do
          expect(resource["Properties"]["Role"]).to eq({"Fn::GetAtt"=>["LambdaRoleSSMParameterCustomResource", "Arn"]})
      end
      
      it "to have property Runtime" do
          expect(resource["Properties"]["Runtime"]).to eq("python3.7")
      end
      
      it "to have property Timeout" do
          expect(resource["Properties"]["Timeout"]).to eq(5)
      end
      
    end

    context 'Resource SSMSecureParameterCRVersion' do
    
        let(:resource) { template["Resources"].select {|r| r.start_with?("SSMSecureParameterCRVersion") }.keys.first }
        let(:properties) { template["Resources"][resource]["Properties"] }
    
        it 'has property FunctionName' do
          expect(properties["FunctionName"]).to eq({"Ref"=>"SSMSecureParameterCR"})
        end
    
        it 'has property CodeSha256' do
          expect(properties["CodeSha256"]).to a_kind_of(String)
        end
    
      end
    
  end

end