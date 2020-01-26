from connection import ServerAcceptConnection
from message import Message

def main():

    con = ServerAcceptConnection()
    print("Listening...")
    while True:
        c = con.accept_client()
        print("A client connected!")
        msg = None
        while not msg:
            msg = c.recieve()
        print("Recieved message: ",msg)

if __name__ == "__main__":
    main()