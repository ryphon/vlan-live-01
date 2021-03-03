from aws_cdk import (
    aws_lambda as _lambda,
    aws_apigateway as apigw,
    core,
)


class vlansls(core.Stack):

    def __init__(self, scope: core.Construct, id: str, **kwargs) -> None:
        super().__init__(scope, id, **kwargs)

        my_lambda = _lambda.Function(
            self, 'vlan-game',
            runtime=_lambda.Runtime.PYTHON_3_7,
            code=_lambda.Code.asset('src'),
            handler='game',
        )

        apigw.LambdaRestApi(
            self, 'Endpoint',
            handler=my_lambda,
        )
