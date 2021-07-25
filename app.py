from controller import create_app

app = create_app('dev')

if __name__ == '__main__':
    app.run(threaded=True, host="0.0.0.0")

