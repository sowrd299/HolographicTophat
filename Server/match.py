from message import Message

'''
a class to represent an ongoing session of gameplay
'''
class Match():

    def __init__(self, client_ids):
        self.connected_clients = set() # id's of clients currently connected
        self.lockedin_clients = set() # id's of clients currently locked in
        self.collected_args = dict() # gameplay data collected from clients to be redistributed
        self.client_ids = client_ids # all the id's of all the clients
        self.turn = 0 # the current turn

    '''
    returns the number of the collected clients
    '''
    def get_connected_count(self):
        return len(self.connected_clients)

    '''
    returns if everyone is locked in
    '''
    def all_locked_in(self):
        return all(c in self.lockedin_clients for c in self.connected_clients)

    '''
    sends an identical message to all connected clients
    '''
    def send_to_all(self, msg):
        for client in self.connected_clients:
            client.send(msg)
        print("Message sent to all clients!")

    '''
    sends a welcome message to the given client,
        to establish all player id's
    '''
    def send_welcome_message(self, con, player_id):
        con.send(Message( 
            type = "setup",
            you_are = player_id,
            other_players = ",".join(c for c in self.client_ids if not c == player_id), # TODO: don't reference the global here
            turn = str(self.get_turn()) # tell the client where to start the turn count
        ))

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
        self.send_welcome_message(con, player_id)
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
                    for k in msg.regex_get_keys("{0}_".format(player_id)):
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
