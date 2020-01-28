/**
A class for displaying alerts to the user
*/
class AlertMenu extends Menu{

    ButtonHandler when_finished;
    Box bg;
    Button finished_button;
    int margin;

    AlertMenu(color holo_color, ButtonHandler when_finished){
        super(null, holo_color);
        this.when_finished = when_finished;
        this.margin = 16;
    }

    void init(){

        Rect area = new Rect(8, height/4, width-2*margin, height/2);

        bg = new DeskBox(area, holo_color, 5, 128, 32);

        finished_button = new Button(
            area.get_section(0.33, 0.8, 0.33, 0.15),
            "Ja",
            holo_color,
            when_finished,
            5, 32
        );

    }

    Button[] get_buttons(){
        return new Button[]{finished_button};
    }

    void draw(){
        bg.draw();
        super.draw();
    }

}