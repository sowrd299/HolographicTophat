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

# list of all id's that can be assigned to clients
client_ids = [
    "Cler",
    "Sayngos",
    "Micu",
    "Jarli"
]

def main():

    con = ServerAcceptConnection()
    client_ind = 0 # index of the current client
    print("Listening...")
    while True:
        c = con.accept_client()
        print("A client connected!")
        c.send(Message( # a welcome message, to establish all player id's
            type = "setup",
            you_are = client_ids[client_ind],
            other_players = ",".join(c for c in client_ids if not c == client_ids[client_ind])
        ))
        client_ind += 1
        Thread(target=manage_client, args=(c,)).start()

if __name__ == "__main__":
    main()