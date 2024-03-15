CloudFormation do

  ssm_path = external_parameters.fetch(:ssm_path)
  Resource("PasswordSSMSecureParameter") {
    Type "Custom::SSMSecureParameter"
    Property('ServiceToken', FnGetAtt('SSMSecureParameterCR', 'Arn'))
    Property('Path', ssm_path)
    Property('Description', FnSub("Secret parameter for ${EnvironmentName} ${Identifier}"))
    Property('Tags',[
      { Key: 'Name', Value: FnSub("${EnvironmentName}-${Identifier}")},
      { Key: 'Environment', Value: FnSub("${EnvironmentName}")},
      { Key: 'EnvironmentType', Value: FnSub("${EnvironmentType}")}
    ])
  }

end
