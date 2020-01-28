/**
A class for displaying alerts to the user
*/
class AlertMenu extends Menu{

    String text;
    ButtonHandler when_finished;
    Button bg;
    Button finished_button;
    int margin;

    AlertMenu(String text, color holo_color, ButtonHandler when_finished){
        super(null, holo_color);
        this.text = text;
        this.when_finished = when_finished;
        this.margin = 16;
    }

    void init(){

        Rect area = new Rect(8, height/4, width-2*margin, height/2);

        bg = new BackgroundButton(area, text, holo_color, null, height/36, 5, 128, 32);

        finished_button = new TicketButton(
            area.get_section(0.33, 0.8, 0.33, 0.15),
            "Ja",
            holo_color,
            when_finished,
            5, 32
        );

    }

    Button[] get_buttons(){
        return new Button[]{bg, finished_button};
    }

}