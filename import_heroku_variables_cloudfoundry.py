import os
import argparse
import pdb


class CopyVariablesHerokuCloudFront:
    """
    Description of this class:
    This utility will import environmental config variables from heroku,
    set them up in CF and then restart the CF server to apply all changes
    CF == CloudFoundry, the foundation on which GDS PaaS is built upon

    The equivalent command line would be something like:
    heroku config -s --app <STAGING-HEROKU-APP> >> <LOCAL-FILE>
    for each line in <LOCAL-FILE>
    cf set-env <STAGING-CF-APP> <KEY> <VALUE>
    cf restage <STAGING-CF-APP>
    """
    def __init__(self):
        print("importing variables from heroku to cloudfront")

    def parse_args(self):
        parser = argparse.ArgumentParser(description='you need to provide staging heroku app source environment and CF target environment')
        parser.add_argument('--source', dest='source_heroku_app',
                            required=True, help='A required parameter for heroku source app')
        parser.add_argument('--destination', dest='destination_gds_paas_app',
                            required=True, help='A required parameter for heroku destination app')

        heroku_variables = self.read_heroku_variables(parser.parse_args().source_heroku_app)

        self.set_cloudfront_variables(heroku_variables,parser.parse_args().destination_gds_paas_app)

    def read_heroku_variables(self, source_heroku_app):
        return os.popen('heroku config -s --app ' + source_heroku_app).read()


    def set_cloudfront_variables(self, input_variables, destination_gds_paas_app):
        for line in input_variables.split('\n'):
            line_tokens = line.split("=")
            if line_tokens[0] and line_tokens[1]:
                key = line_tokens[0]
                value = line_tokens[1].replace("'", "")
                self._set_cloudfront_variable(key, value, destination_gds_paas_app)

        print("done setting all variables, restarting GDS PaaS server..")
        os.system("cf restage " + destination_gds_paas_app)

    # private method to set a single variable in GDS PaaS
    def _set_cloudfront_variable(self, key, value, destination_gds_paas_app):
        str = "cf set-env " + destination_gds_paas_app + " " + key + " " + value
        print("calling system command:" + str)
        os.system(str)

def main():
    CopyVariablesHerokuCloudFront().parse_args()

if __name__ == '__main__':
    main()
