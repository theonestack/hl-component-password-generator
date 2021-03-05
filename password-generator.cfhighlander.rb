CfhighlanderTemplate do
  Name 'password-generator'
  Description "password-generator - #{component_version}"

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
    ComponentParam 'SSMParameterPath'
    ComponentParam 'Identifier'
  end

  LambdaFunctions 'ssm_custom_resources'

end
