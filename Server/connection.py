import socket
from message import Message
from threading import Thread


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
        msg = self.recieve_msg()
        if msg:
            return Message.from_str(msg)
        else:
            return None

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
    con_class = Connection

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
        return self.con_class(client_socket)



'''
THE LOGIN SYSTEM
'''


'''
A connection that is persistent for one user
    accross multiple sessions
'''
class LoggedInConnection(Connection):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.user_id = ""

    def get_id(self):
        return self.user_id 

    def is_logged_in(self):
        return self.get_id()

    '''
    Logs in a given client
    '''
    # TODO: enforce ID uniqueness
    def login(self, unique = True):

        # send
        self.send(Message(
            type = "please_login"
        ))

        # recieve
        msg = None
        while not msg:
            msg = self.recieve()

        # process
        if msg.get("type") == "login":
            self.user_id = msg.get("user_id")
        else:
            raise RuntimeError("Unexpected Message Type")


'''
A version of ServerAcceptConnection that asyncronously
    logs in clients as they connect
'''
class ServerLoginConnection(ServerAcceptConnection):

    con_class = LoggedInConnection

    def __init__(self):
        super().__init__()

    '''
    Takes a callable to call on  a newly logged in client
    If not provided, will return login the client in the main thread
    '''
    def accept_client(self, thread_target=None):
        con = super().accept_client()

        if thread_target:

            def func(): # the thread callback function
                con.login()
                thread_target(con)

            Thread(target=func, args=tuple()).start()
            return None

        else:
            con.login()        
            return con