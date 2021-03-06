import java.net.*;
import java.io.*;

class Connection{

    static final int port = 5006;

    public static final String terminator = "</"+Message.root_name+">";

    private DataOutputStream out;
    private InputStreamReader in;

    private boolean connected;

    private String in_buffer;

    private Socket soc;

    Connection(){
        in_buffer = "";
        connected = false;
    }

    boolean is_connected(){
        return connected;
    }

    // connects to the given server
    // returns the success state
    boolean connect(String server_ip){
        // setup tcp
        System.out.println("Connecting...");
        try{
            soc = new Socket(server_ip, port);
            System.out.println("Connected!");

            //setup steams
            out = new DataOutputStream(soc.getOutputStream());
            in = new InputStreamReader(soc.getInputStream());

            connected = true;
            return true;

        }catch(UnknownHostException e){
            System.out.println("UnkownHostException");
        }catch(IOException e){
            System.out.println("IOException");
        }
        return false;
    }

    boolean send(Message msg){
        String data = msg.to_string();
        try{
            out.get_w()riteBytes(data);
            return true;
        }catch(IOException e){
            System.out.println("IOException on Send");
            connected = false;
            return false;
        }
    }

    void recieve_data(){
        try{
            while(in.ready()){
                int c = in.read();
                if(c < 0){ break; }
                in_buffer += (char)c;
            }
        }catch(IOException e){
            connected = false;
            System.out.println("IOException on Recieve");
        }
    }

    Message recieve_msg(){
        int i = in_buffer.indexOf(terminator);
        if(i > 0){
            int j = i + terminator.length();
            String r = in_buffer.substring(0,j);
            in_buffer = in_buffer.substring(j);
            return msg_from_string(r);
        }
        return null;
    }

    Message recieve(){
        recieve_data();
        return recieve_msg();
    }

}
