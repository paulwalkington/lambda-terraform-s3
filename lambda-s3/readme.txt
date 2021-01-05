--install dependencies

You need to install extra dependencies like "requests"
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

zip all the dependencies from you PIP virtual env

$ cd YOUR-NAME-SPACE/lib/python3.8/site-packages
e.g.
$ cd simple-lambda/lib/python3.8/site-packages/

$ zip -r9 ${OLDPWD}/lambda_function_payload.zip .

-zip up python code and add to zip file
$ cd $OLDPWD
$ zip -g lambda_function_payload.zip lambda_function.py