/**
A class to handle sending gameplay related messages to the surver
Doubles as a handler for "lock-in" buttons
*/
class GameplaySender implements ButtonHandler{

  Connection con;
  PlayerUI[] opponents;
  String local_id;
  int turn;

  GameplaySender(Connection con, String local_id, PlayerUI[] opponents, int starting_turn){
    this.turn = starting_turn;
    this.con = con;
    this.opponents = opponents;
    this.local_id = local_id;
  }

  Message populate_basic_message(Message r, boolean lockin){
    r.put("turn",str(turn));
    r.put("lockin",str(lockin));
    return r;
  }

  Message populate_play_message(Message r){
    // cards played against opponents
    for(PlayerUI o : opponents){
      Card c = o.get_played_against().get();
      if(c != null) {
        r.put(local_id + "_to_" + o.get_id(),c.get_id());
      }
    }
    // the defense cards
    Card defense = local_player.get_played_against().get();
    if(defense != null){
      r.put(local_id + "_defense", defense.get_id());
    }
    // cleanup
    return r;
  }

  /**
  Sends a message to the server about cards you have played
  takes if the player is locking in their turn
  returns the success state
  */
  boolean send_play_message(boolean lockin){
    Message r = populate_play_message(new Message("card_play"));
    populate_basic_message(r, lockin);
    return con.send(r);
  }


  Message populate_job_message(Message r){
    Card job = job_position.get();
    r.put(local_id + "_job", job != null ? job.get_id() : "");
    r.put(local_id + "_continue_job", str(job == null));
    return r;
  }

  /**
  Sends a message to the server about cards you have played
  takes if the player is locking in their turn
  returns the success state
  */
  boolean send_job_message(boolean lockin){
    Message r = populate_job_message(new Message("card_play"));
    populate_basic_message(r, lockin);
    return con.send(r);
  }

  /**
  Sends a blank message to the server
  Serves only to lock in and increment the turn
  */
  boolean send_basic_message(boolean lockin){
    return con.send(populate_basic_message(new Message("card_play"), lockin));
  }

  /**
  Allows this to be used a a button handler
  */
  void on_click(){
    send_play_message(true);
  }

  /**
  Called at the start of each turn to track the turn count
  */
  void inc_turn(){
    turn++;
  }

}