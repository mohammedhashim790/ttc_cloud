import os

from functions.normaliser.index import lambda_handler


if __name__ == "__main__":
    print(os.environ.get("TEST"))
    lambda_handler(None, None)
