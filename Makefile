SHELL := /bin/bash
.PHONY: build clean test lambda-get api-gw-get bump
.DEFAULT_GOAL := build

ifndef part
override part = minor
endif

$(shell if [ ! -f secrets.env ]; then echo -e "TF_VAR_aws_region=add-something-here\nTF_VAR_aws_profile=add-something-here\nTF_VAR_owm_base_url=add-something-here\nTF_VAR_owm_appid=add-something-here" > secrets.env; fi)
include secrets.env
export


build:
	terraform apply

clean:
	terraform destroy

# you have to install pipelines
# (https://ktomk.github.io/pipelines/index.html#download-the-phar-php-archive-file )
# so you can run and debug the tests locally as it would be run by bitbucket in the pipeline
test:
	$(shell if [ ! -f test.env ]; then echo -e "OWM_BASE_URL=https://add-something-here.com\nOWM_APP_ID=add-something-here" > test.env; fi)
	pipelines --pipeline  pull-requests/** --env-file test.env

lambda-get:
	aws lambda invoke --region=${TF_VAR_aws_region} --function-name=$(shell terraform output -raw function_name) dev/null/response.json
	@echo "+----------------------------------------------+"
	cat dev/null/response.json

api-gw-get:
	@echo $(shell curl "$(shell terraform output -raw base_url)/potato-cities?city_name=cluj-napoca")

# run it as `make part=patch bump` if you want to bump another part than the default minor
bump:
	bumpversion $(part)
	@git --no-pager diff
	@echo "+----------------------------------------------+"
	@echo "|    Bumpversion succeeded. Files changed ↑    |"
	@echo "+----------------------------------------------+"
