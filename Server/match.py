import random

from message import Message
from collections import defaultdict

'''
a class to represent an ongoing session of gameplay
'''
class Match():

    def __init__(self, player_ids):

        # PLAYERS
        self.player_ids = player_ids # all the player id's available for clients to use
        self.lockedin_ids = set() # id's of players currently locked in

        # CLIENTS
        self.connected_clients = set() # all of the client objects currently connected

        # OUTGOING MESSAGES
        self.collected_args = dict() # gameplay data collected from clients to be redistributed
        self.turn = 0 # the current turn
        self.seed_manager = SeedManager() # manages giving players random seeds
        self.old_messages = list() # useful for doing rewinds

    '''
    returns the number of the collected clients
    '''
    def get_connected_count(self):
        return len(self.connected_clients)

    '''
    returns if everyone who has a player ID is locked in
    '''
    def all_locked_in(self):
        return all(c in self.lockedin_ids for c in self.player_ids)

    '''
    sends an identical message to all connected clients
    '''
    def send_to_all(self, msg):
        for client in self.connected_clients:
            client.send(msg)
        print("Message sent to all clients!")
        self.old_messages.append(msg)

    '''
    sends all old messages to a given client

    marks all but the latest message as "rewind" messages
    rewind message should update the client gamestate, but not display to the user
    rewind messages should not be responded to by the client
    '''
    def send_old_messages(self, client):
        for msg in self.old_messages:

            if msg != self.old_messages[-1]:
                msg.set("rewind","true")

            client.send(msg)
            

    '''
    sends a welcome message to the given client,
        to establish all player id's
    '''
    def send_welcome_message(self, con, player_id):
        con.send(Message( 
            type = "setup",
            you_are = player_id,
            all_players = ",".join(c for c in self.player_ids),
            rand_seed = self.seed_manager[player_id],
            turn = 0 #str(self.get_turn()) # tell the client where to start the turn count
        ))

    '''
    to be called after things change in the gamestate
    manages progressing the gamestate
    '''
    def update(self):

        print("...{0}/{1} clients locked in".format(len(self.lockedin_ids), len(self.player_ids)))
        # handle the end of the turn
        if self.all_locked_in():

            # forward all cards played
            self.send_to_all(Message(
                type="card_play",
                **self.collected_args
            ))
            
            # cleanup
            self.lockedin_ids = set()
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
        self.send_old_messages(con)
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
                        print("...{0} is locking in...".format(player_id))
                        self.lockedin_ids.add(player_id)

                self.update()

        # handle a disconnect
        except RuntimeError as e:
            print("Client {0} disconnected cleanly!".format(player_id))
        finally:
            self.connected_clients.remove(con)


'''
A 'class' for assigning random seeds to players
'''
class SeedManager(defaultdict):

    MAX_SEED = 2**15

    def __init__(self):
        super().__init__( (lambda : random.randrange(self.MAX_SEED)) )
