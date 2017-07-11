import os
import argparse

class CopyVariablesHerokuCloudFront(object):
    """
    heroku config -s --app <STAGING-HEROKU-APP> >> <LOCAL-FILE>
    """
    def __init__(self, filename, targetCfApp):
        print("importing variables from heroku to cloudfront")

    def parse_args():
        parser = argparse.ArgumentParser(description='you need to provide staging heroku app source environment and CF target environment')
        
    def readFile(self, filename):
        file = open(filename, 'rw')

        for line in file:
            line_tokens = line.split("=")
            key = line_tokens[0]
            value = line_tokens[1].replace("'", "")
            str = "cf set-env <STAGING-CF-APP> " + key + " " + value
            print("calling system command:" + str)
            os.system(str)
        print("done setting all variables, restarting server..")
        os.system("cf restage <STAGING-CF-APP>")

def main():
    args = parse_args()
    copyVariables = CopyVariablesHerokuCloudFront(args.required_param)
    copyVariables.readFile()

if __name__ == '__main__':
    main()
