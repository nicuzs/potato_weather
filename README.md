Potato Weather
==============

Hi there! In this project I will juggle with some AWS services and just because I couldn't find a better name for it ... here comes ... **The Potato Weather** project.

![Potato Weather](./docs/potato.svg)


This project is a very tiny little RESTful app running on AWS API Gateway and Lambda, all resources built on terraform. PotatoWeather serverless app connects behind the scenes to [OpenWeatherMap](https://openweathermap.org/current) and simply returns the current temperature and weather feel for any town in the world (city names as defined in [ISO 3166](https://www.iso.org/obp/ui/#search) ).

A good starting point for this project would be for you to take a peep at the [Makefile](./Makefile) and simply run the commands available in there.

Little to no manual intervention will be required.

 - First time you will run
    ```
   make build  # or just simply 'make'
    ```
    it will genereate a [secrets.env](./secrets.env) file in the root dir, and it will contain some placeholders for your aws and OpenWeatherMap  credentials. Because of these placeholders, this command **will initially fail**.
   - Make sure to fill your credentials by sticking to the env vars format defined in there. `TF_VAR_*=...`.
This file is of course in [gitignored](./.gitignore).
   - When it comes to OpenWeatherMap credentials, you will have to create [a free account on their platform](https://openweathermap.org/price) and then use the `https://api.openweathermap.org` + your private api key.
   - Running `make` again should be successful this time, and you should now have everything up and running.

 - In order to check up on the lambda function, just do a
    ```
   make lambda-get
    ```
   this will use aws-cli to invoke the lambda function,  and you should see something like ``{"headers": {"Content-Type": "application/json"}, "statusCode": 400, "body": "Expected to receive city_name=? as query string param!"}``

 - If you want to use the actual API endpoint, do a simple
    ```
   make api-gw-get
    ```
    which will return an actual live result for Cluj-Napoca
    ```
     % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                     Dload  Upload   Total   Spent    Left  Speed
    100   113  100   113    0     0    169      0 --:--:-- --:--:-- --:--:--   168
    {current_temperature: 26.71, status: few clouds, verbose: It's few clouds today and about 26.71\u00b0C}
    ```

 - Running the tests
   - This is the second time some manual intervention is neeeded. You will have to download and install [this thing](https://ktomk.github.io/pipelines/index.html#download-the-phar-php-archive-file)  in order to run the tests locally as defined in the [bitbucket-pipelines.yml](./bitbucket-pipelines.yml) file. Otherwise, simpy clone this repo to bitbucket, and you can run the tests hassle-free, [directly in there](https://support.atlassian.com/bitbucket-cloud/docs/get-started-with-bitbucket-pipelines/). Then run:

```
make test
```
This will also generate a gitignored [test.env](./test.env) file which you can use to put various environment variables, only for the purpose of running the tests.
 - Cleanup
```
make clean
```


```
      _____                    _____                    _____                            _____                    _____                    _____
     /\    \                  /\    \                  /\    \                          /\    \                  /\    \                  /\    \
    /::\    \                /::\____\                /::\    \                        /::\    \                /::\____\                /::\    \
    \:::\    \              /:::/    /               /::::\    \                      /::::\    \              /::::|   |               /::::\    \
     \:::\    \            /:::/    /               /::::::\    \                    /::::::\    \            /:::::|   |              /::::::\    \
      \:::\    \          /:::/    /               /:::/\:::\    \                  /:::/\:::\    \          /::::::|   |             /:::/\:::\    \
       \:::\    \        /:::/____/               /:::/__\:::\    \                /:::/__\:::\    \        /:::/|::|   |            /:::/  \:::\    \
       /::::\    \      /::::\    \              /::::\   \:::\    \              /::::\   \:::\    \      /:::/ |::|   |           /:::/    \:::\    \
      /::::::\    \    /::::::\    \   _____    /::::::\   \:::\    \            /::::::\   \:::\    \    /:::/  |::|   | _____    /:::/    / \:::\    \
     /:::/\:::\    \  /:::/\:::\    \ /\    \  /:::/\:::\   \:::\    \          /:::/\:::\   \:::\    \  /:::/   |::|   |/\    \  /:::/    /   \:::\ ___\
    /:::/  \:::\____\/:::/  \:::\    /::\____\/:::/__\:::\   \:::\____\        /:::/__\:::\   \:::\____\/:: /    |::|   /::\____\/:::/____/     \:::|    |
   /:::/    \::/    /\::/    \:::\  /:::/    /\:::\   \:::\   \::/    /        \:::\   \:::\   \::/    /\::/    /|::|  /:::/    /\:::\    \     /:::|____|
  /:::/    / \/____/  \/____/ \:::\/:::/    /  \:::\   \:::\   \/____/          \:::\   \:::\   \/____/  \/____/ |::| /:::/    /  \:::\    \   /:::/    /
 /:::/    /                    \::::::/    /    \:::\   \:::\    \               \:::\   \:::\    \              |::|/:::/    /    \:::\    \ /:::/    /
/:::/    /                      \::::/    /      \:::\   \:::\____\               \:::\   \:::\____\             |::::::/    /      \:::\    /:::/    /
\::/    /                       /:::/    /        \:::\   \::/    /                \:::\   \::/    /             |:::::/    /        \:::\  /:::/    /
 \/____/                       /:::/    /          \:::\   \/____/                  \:::\   \/____/              |::::/    /          \:::\/:::/    /
                              /:::/    /            \:::\    \                       \:::\    \                  /:::/    /            \::::::/    /
                             /:::/    /              \:::\____\                       \:::\____\                /:::/    /              \::::/    /
                             \::/    /                \::/    /                        \::/    /                \::/    /                \::/____/
                              \/____/                  \/____/                          \/____/                  \/____/                  ~~

```
