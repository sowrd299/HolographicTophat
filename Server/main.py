from connection import ServerAcceptConnection
from message import Message
from threading import Thread

def manage_client(con):

    while True:

        # recieve a message
        msg = None
        while not msg:
            msg = con.recieve()
        print("Recieved message: ",msg)

        # respond
        con.send(Message(
            type = "card_draw",
            cards_draw = "For Sant Cler!"
        ))
        print("Message sent!")


def main():

    con = ServerAcceptConnection()
    print("Listening...")
    while True:
        c = con.accept_client()
        print("A client connected!")
        Thread(target=manage_client, args=(c,)).start()

if __name__ == "__main__":
    main()