from connection import ServerAcceptConnection
from message import Message
from threading import Thread
from match import Match

'''
A class for managing clients waiting to join a match
'''
class MatchMakingQueue():

    def __init__(self, match_size, client_ids):
        self.clients = [] # the queue of clients
        self.match_size = match_size
        self.client_ids = client_ids
        self.client_ind = 0 # index of the current client

    '''
    Adds a client to the queue
    '''
    def enqueue(self, client):
        self.clients.append(client)
        # send the wait message
        client.send(Message(type="wait"))

    '''
    Actually adds a given client to a given match
    '''
    def _add_to_match(self, match, client):
        # start the thread for that client in that match
        Thread(target=match.manage_client, args=(c,self.client_ids[self.client_ind])).start()
        # increments the ID system
        # TODO: improve the client ind system for multiple ongoing matches
        self.client_ind += 1
        self.client_ind %= len(client_ids)

    '''
    Tries to begin a new match from clients in the queue
    Match will have the specified number of players, or the default if none given
    returns the match, None if it fails
    '''
    def make_match(self, size=-1):

        if size < 0:
            size = self.match_size

        if len(self.clients) < size:
            return None

        match = Match(self.client_ids)
        while match.get_connected_count() < size:
            self._add_to_match(match, self.clients.pop(0))

        return match


# list of all id's that can be assigned to clients
client_ids = [
    "Cler",
    "Sayngos",
    "Micu",
    "Jarli"
]

def main():

    con = ServerAcceptConnection()
    match_maker = MatchMakingQueue(4, client_ids)
    print("Listening...")
    while True:
        c = con.accept_client()
        print("A client connected!")
        match_maker.enqueue(c)
        match_maker.make_match()

if __name__ == "__main__":
    main()