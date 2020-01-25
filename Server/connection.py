import socket
from message import Message


'''
A superclass for socket connections.
'''
class Connection():

    terminator = "</{0}>".format(Message.root_name)
    encoding = "utf-8"
    port = 5006

    def __init__(self, sock = None):

        self.socket = sock or socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.in_buffer = ""

    def connect(self, host):
        self.socket.connect((host, self.port))

    '''
    Sends the given string allong the connection.
    Assumes the message does not contain the terminator sequence.
    '''
    def send(self, msg : Message):
        total_msg = msg.to_bytes(self.encoding)
        total_sent = 0
        while total_sent < len(total_msg):
            sent = self.socket.send(total_msg[total_sent:])
            if sent == 0:
                raise RuntimeError("socket connection broken (found on send)")
            total_sent += sent

    '''
    Gets raw data from the steam.
    '''
    def recieve_data(self):
        chunk = self.socket.recv(2048)
        if chunk == b'':
            raise RuntimeError("socket connection broken (found on recieve)")
        self.in_buffer += chunk.decode(self.encoding)

    '''
    Gets the next message out the recieved data.
    If there isn't one yet, returns None.
    '''
    def recieve_msg(self):
        try:
            i = self.in_buffer.index(self.terminator) + len(self.terminator)
            r = self.in_buffer[:i]
            self.in_buffer = self.in_buffer[i:]
            return r
        except ValueError as e:
            return None

    '''
    Returns the next mesage from the stream.
    Returns None is there isn't one.
    This is what one should use from recieve most often.
    '''
    def recieve(self):
        self.recieve_data()
        return Message.from_str(self.recieve_msg())

    '''
    Closes the connection.
    '''
    def close(self):
        self.socket.close()

'''
A class for connecting the server to accept connections with.
'''
class ServerAcceptConnection(Connection):

    max_clients = 2

    def __init__(self):

        super().__init__()
        self.socket.bind(('', self.port))
        self.socket.listen(self.max_clients)

    '''
    Accepts and manages a client. Returns after a client has connected.
    Returns the socket connection to that server.
    '''
    def accept_client(self):

        (client_socket, client_addr) = self.socket.accept()
        return Connection(client_socket)