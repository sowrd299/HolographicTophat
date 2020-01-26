import java.util.Map;

/*
This class is largely a translationg of the message class
from the server
*/
class Message{

    public static final String root_name = "msg";

    HashMap<String, String> data;

    Message(){
        data = new HashMap<String, String>();
    }

    void put(String k, String v){
        data.put(k,v);
    }

    String to_string(){

        XML root = new XML(root_name);
        for(Map.Entry e : data.entrySet()){
            XML node = new XML((String)e.getKey());
            node.setContent((String)e.getValue());
            root.addChild(node);
        }
        return root.format(-1);

    }

    String get(String k){
        return data.get(k);
    }
  
}

Message msg_from_string(String s){
    XML root = parseXML(s);
    Message msg = new Message();
    for(XML e : root.getChildren()){
        msg.put(e.getName(), e.getContent());
    }
    return msg;
}