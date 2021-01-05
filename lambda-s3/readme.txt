--install dependencies

If you need to install extra dependencies like "requests"
You can use PIP to create a virtual environment and install them there

$ python3 -m venv YOUR-NAME-SPACE
e.g.
$ python3 -m venv simple-lambda

$ source YOUR-NAME-SPACE/bin/activate
e.g.
$ source simple-lambda/bin/activate

$ pip install PACKAGES-YOU-NEED
e.g.
$ pip install requests

--zip up lambda code

$ zip lambda_function.zip lambda_function.py

(you only need to do this if your using extra dependencies)
zip all the dependencies from you PIP virtual env

$ cd YOUR-NAME-SPACE/lib/python3.8/site-packages
e.g.
$ cd simple-lambda/lib/python3.8/site-packages/

$ zip -r9 ${OLDPWD}/lambda_function.zip .

-zip up python code and add to zip file
$ cd $OLDPWD
$ zip -g lambda_function.zip lambda_function.py

-----manually upload the lambda function using awscli
-update existing code (can be used if just the code has been updated)

$ zip -u lambda_function.zip lambda_function.py

---creating the function in AWS

--create new role for lambda

$ aws iam create-role --role-name lambda-ex --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'

$ aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole


--create new lambda function

$ aws lambda create-function --function-name paul-function \
--zip-file fileb://function.zip --handler simple-lambda.lambda_handler --runtime python3.8 \
--role arn:aws:iam::455073406672:role/lambda-ex

--update lambda function


$ aws lambda update-function-code --function-name paul-function --zip-file fileb://function.zip