from connection import ServerAcceptConnection
from message import Message
from threading import Thread

'''
a class to represent an ongoing session of gameplay
'''
class Match():

    def __init__(self):
        self.connected_clients = set() # id's of clients currently connected
        self.lockedin_clients = set() # id's of clients currently locked in
        self.collected_args = dict() # gameplay data collected from clients to be redistributed
        self.turn = 0 # the current turn

    '''
    returns if everyone is locked in
    '''
    def all_locked_in(self):
        return all(c in self.lockedin_clients for c in self.connected_clients)

    '''
    sends a message to all connected clients
    '''
    def send_to_all(self, msg):
        for client in self.connected_clients:
            client.send(msg)
        print("Message sent to all clients!")

    '''
    to be called after things change in the gamestate
    manages progressing the gamestate
    '''
    def update(self):

        print("...{0}/{1} clients locked in".format(len(self.lockedin_clients), len(self.connected_clients)))
        # handle the end of the turn
        if self.all_locked_in():

            # forward all cards played
            self.send_to_all(Message(
                type="card_play",
                **self.collected_args
            ))
            
            # cleanup
            self.lockedin_clients = set()
            self.collected_args = dict()
            self.turn += 1

    def get_turn(self):
        return self.turn

    '''
    a loop that manages a single client playing this game
    '''
    def manage_client(self, con, player_id):

        # setup
        self.connected_clients.add(con)

        try:
            while True:

                # recieve a message
                msg = None
                while not msg:
                    msg = con.recieve()
                print("Recieved message from {0}: {1}".format(player_id,msg))

                # handle card play messages for the current turn
                if msg.get("type") == "card_play" and int(msg.get("turn")) == self.turn:

                    print("...is card play message")

                    # compile card plays
                    for k in msg.regex_get_keys("{0}_to_".format(player_id)):
                        self.collected_args[k] = msg.get(k)

                    # update lockins
                    if msg.get("lockin") == "true":
                        self.lockedin_clients.add(con)

                self.update()

        # handle a disconnect
        except RuntimeError as e:
            print("Client {0} disconnected!".format(player_id))
        finally:
            self.connected_clients.remove(con)


# list of all id's that can be assigned to clients
client_ids = [
    "Cler",
    "Sayngos",
    "Micu",
    "Jarli"
]

def main():

    con = ServerAcceptConnection()
    match = Match()
    client_ind = 0 # index of the current client
    print("Listening...")
    while True:
        c = con.accept_client()
        print("A client connected!")
        # a welcome message, to establish all player id's
        c.send(Message( 
            type = "setup",
            you_are = client_ids[client_ind],
            other_players = ",".join(c for c in client_ids if not c == client_ids[client_ind]),
            turn = str(match.get_turn()) # tell the client where to start the turn count
        ))
        # start the thread
        Thread(target=match.manage_client, args=(c,client_ids[client_ind])).start()
        # increments the ID system
        client_ind += 1
        client_ind %= len(client_ids)

if __name__ == "__main__":
    main()