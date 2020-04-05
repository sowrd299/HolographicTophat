/**
A class for moving around an existing menu on the screen
Linearly scales and translates the menu
*/
// TODO: make this time and not frame based?
class TransformingMenu extends Menu{

    private Menu menu;
    Rect initial;
    Rect last;

    float frame;
    float frames;

    TransformingMenu(Menu menu, Rect initial, Rect last, int frames){
        super();
        this.menu = menu;
        this.initial = initial;
        this.last = last;

        this.frame = -1;
        this.frames = float(frames);
    }

    /**
    Changes the final destination for the transformation
    Does not change the current position or the time remaining
    */
    void set_last_rect(Rect r){
        last = r;
        initial = menu.get_rect();
        frames = frames - frame;
        frame = 0;
    }

    // NOTE: ignore init passthrough because init will be called in draw

    boolean click(int x, int y){
        return this.menu.click(x,y);
    }

    void draw(){
        inc_frame();
        menu.set_rect(initial.interpolate(last, frame/frames));
        menu.init(); // TODO: this really slows everything down
        menu.draw();
    }

    void inc_frame(){
        if(frame < frames){
            frame++;
        }
    }

    boolean is_finished(){
        return frame == frames;
    }
    
}


/**
A class for moving two menus around on the screen
Will wind up setting the rect of the new menu to the current rect of the old menu
If given a transition menu, will premempt that transition and take over all of its transformations
*/
class TransitionMenu extends Menu {

    private ArrayList<TransformingMenu> menus;

    private Menu next_menu;

    TransitionMenu(Menu prev_menu, Menu next_menu, Rect exit_to, Rect enter_from, int frames, MenuSwitcher switcher){
        super(switcher, 0);

        menus = new ArrayList<TransformingMenu>();

        if(prev_menu instanceof TransitionMenu){
            for(TransformingMenu m : ((TransitionMenu)prev_menu).get_menus()){
                m.set_last_rect(exit_to);
                menus.add(m);
            }
        }else{
            menus.add(new TransformingMenu(prev_menu, prev_menu.get_rect(), exit_to, frames));
        }

        menus.add(new TransformingMenu(next_menu, enter_from, prev_menu.get_rect(), frames));

        this.next_menu = next_menu;
    }
    
    protected ArrayList<TransformingMenu> get_menus(){
        return menus;
    }

    void draw(){
        boolean finished = true;
        for(TransformingMenu m : menus){
            m.draw();
            finished = finished && m.is_finished();
        }

        if(finished){
            switcher.switch_menu_notransition(next_menu);
        }
    }

}