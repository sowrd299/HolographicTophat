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
        c.send(Message(
            type = "card_draw",
            cards_draw = "For Sant Cler!"
        ))
        print("Message sent!")

if __name__ == "__main__":
    main()