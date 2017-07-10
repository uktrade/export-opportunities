import os

class CopyVariablesHerokuCloudFront(object):
    """
    heroku config -s --app <STAGING-HEROKU-APP> >> <LOCAL-FILE>
    """
    def __init__(self):
        print("importing variables from heroku to cloudfront")

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
    copyVariables = CopyVariablesHerokuCloudFront()
    copyVariables.readFile(<LOCAL-FILE>)

if __name__ == '__main__':
    main()
