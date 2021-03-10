CloudFormation do

  Resource("PasswordSSMSecureParameter") {
    Type "Custom::SSMSecureParameter"
    Property('ServiceToken', FnGetAtt('SSMSecureParameterCR', 'Arn'))
    Property('Path', FnSub("/${Identifier}/${EnvironmentName}/${PathSuffix}"))
    Property('Description', FnSub("Secret parameter for ${EnvironmentName} ${Identifier}"))
    Property('Tags',[
      { Key: 'Name', Value: FnSub("${EnvironmentName}-${Identifier}")},
      { Key: 'Environment', Value: FnSub("${EnvironmentName}")},
      { Key: 'EnvironmentType', Value: FnSub("${EnvironmentType}")}
    ])
  }

end
