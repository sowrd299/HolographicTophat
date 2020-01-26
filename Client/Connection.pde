import java.net.*;
import java.io.*;

class Connection{

    static final int port = 5006;

    DataOutputStream out;

    Socket soc;
  
    // connects to the given server
    boolean connect(String server_ip){
        // setup tcp
        System.out.println("Connecting...");
        try{
            soc = new Socket(server_ip, port);
            System.out.println("Connected!");

            //setup steams
            out = new DataOutputStream(soc.getOutputStream());

            return true;

        }catch(UnknownHostException e){
            System.out.println("UnkownHostException");
        }catch(IOException e){
            System.out.println("IOException");
        }
        return false;
    }

    // send
    void send(Message msg){
        String data = msg.to_string();
        try{
            out.writeBytes(data + 'n');
        }catch(IOException e){
            System.out.println("IOException on Send");
        }
    }

}
