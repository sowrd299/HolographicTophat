from connection import ServerLoginConnection, ServerAcceptConnection
from message import Message
from threading import Thread
from match import Match

import sys

'''
A class for managing clients waiting to join a match
'''
class MatchMakingQueue():

    def __init__(self, match_size, client_ids):
        self.clients = [] # the queue of clients
        self.match_size = match_size # the number to players to add to a match
        self.client_ids = client_ids # player id's specifically
        self.client_ind = 0 # index of the current client

        self.player_assignments = dict() # { user_id : (player_id, match) }

    '''
    Adds a client to the queue
    If the user is already in a match, will just re-add them to that match
    '''
    def join(self, client):

        # rejoin a game
        user_id = client.get_id()
        if(user_id in self.player_assignments):
            player_id, match = self.player_assignments[user_id] 
            match.manage_client(client, player_id)

        # if couldn't queue for a new game
        else:
            self.enqueue(client)


    '''
    Adds a client to the queue. Forces joining a new game
    '''
    def enqueue(self, client):
        self.clients.append(client)
        # send the wait message
        client.send(Message(type="wait"))

    '''
    Actually adds a given client to a given match
    '''
    def _add_to_match(self, match, client):

        player_id = self.client_ids[self.client_ind]

        # start the thread for that client in that match
        Thread(target=match.manage_client, args=(client, player_id)).start()
        #match.manage_client(client, self.client_ids[self.client_ind])

        # record the assignment
        self.player_assignments[client.get_id()] = (player_id, match)

        # increments the ID system
        # TODO: improve the client ind system for multiple ongoing matches
        self.client_ind += 1
        self.client_ind %= len(self.client_ids)

    '''
    Tries to begin a new match from clients in the queue
    Match will have the specified number of players, or the default if none given
    returns (the match, clients in it), (None, []) if it fails
    '''
    def make_match(self, size=-1):

        if size < 0:
            size = self.match_size

        if len(self.clients) < size:
            return (None, [])

        match = Match(self.client_ids)
        clients = []
        while match.get_connected_count() < size:
            client = self.clients.pop(0)
            self._add_to_match(match, self.clients.pop(0))
            clients.append(client)

        return (match, clients)

'''
A version of the match making queue that doesn't wait for everyone to join
    to start the game.
Instead, it add players to the game as they join
'''
class RollingMatchMakingQueue(MatchMakingQueue):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.match = Match(self.client_ids)

    def enqueue(self, client):
        self._add_to_match(self.match, client)

    def make_match(self, _=None):
        return self.match


def main(match_maker_class, match_size):

    # list of all id's that can be assigned to clients
    client_ids = [
        "Cler",
        "Sayngos",
        "Micu",
        "Jarli"
    ]

    con = ServerLoginConnection()
    match_maker = match_maker_class(match_size, client_ids)

    def make_match(c):
        print("A client connected!")
        match_maker.join(c)
        match_maker.make_match()

    print("Listening...")
    while True:
        c = con.accept_client(make_match)
        if c != None:
            make_match(c)
        else:
            print("Some thing happened. A client may be logging in!")


# setup modes the server can opperate in

ROLLING_MODE = "rolling"
WAIT_MODE = "wait"
DEFAULT_MODE = ROLLING_MODE
DEFAULT_SIZE = 4

modes = {
    ROLLING_MODE : RollingMatchMakingQueue,
    WAIT_MODE : MatchMakingQueue
}

if __name__ == "__main__":
    mode = modes[sys.argv[1].lower() if len(sys.argv) > 1 else DEFAULT_MODE]
    size = int(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_SIZE
    print("Running in mode: {0}, with game size: {1}".format(mode,size))
    main(mode, size)