from xml.etree import ElementTree

'''
A class for managing messages from client to server
'''
class Message():

    root_name = "msg"

    '''
    Takes a dictionary of data entries for the message.
    Takes in the form of kewword argumeents.
    MUST include "type"
    '''
    def __init__(self, **kwargs):

        self.data = kwargs

    def to_bytes(self, encoding="utf-8"):

        root = ElementTree.Element(self.root_name)
        for k,v in self.data.items():
            se = ElementTree.SubElement(root,k)
            se.text = v
        
        return ElementTree.tostring(root)

    def __str__(self):
        return self.to_bytes().decode("utf-8")

    '''
    Constructs a message from the given string.
    '''
    @staticmethod
    def from_str(s):

        root = ElementTree.fromstring(s)
        data = dict()
        for child in root:
            data[child.tag] = child.text
        
        return Message(**data)

    '''
    Returns the value of the given field.
    '''
    def get(self, key):
        return self.data[key]