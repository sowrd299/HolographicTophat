/**
A class to render a very not fancy box
 */
class Box {

    protected Rect r;
    protected color c;
    protected int stroke_weight;
    protected int corner_size;

    Box(Rect rect, color c, int stroke_weight, int corner_size){
        this.r= rect;
        this.c = c;
        this.stroke_weight = stroke_weight;
        this.corner_size = corner_size;
    }

    void setup_draw() { 
        // set the pallet
        stroke(c, 200);
        fill(c, 150);
        strokeWeight(stroke_weight);
    }

    void draw() {
        setup_draw();
        rect(r.get_x(),r.get_y(),r.get_w(),r.get_h());
    }

}

/**
A box to render a bookmark shape
(with the tongues on the left hand side)
*/
class TabBox extends Box{

    TabBox(Rect rect, color c, int stroke_weight, int corner_size){
        super(rect, c, stroke_weight, corner_size);
    }

    void draw(){
        setup_draw();

        beginShape();

        vertex(r.get_x(), r.get_y()+corner_size);
        vertex(r.get_x() + r.get_w(), r.get_y());
        vertex(r.get_x() + r.get_w(), r.get_y() + r.get_h());
        vertex(r.get_x(), r.get_y()+r.get_h()-corner_size);
        vertex(r.get_x()+corner_size, r.get_y()+r.get_h()/2);

        endShape();
    }

}


/**
A class to render a fancy box
 */
class TicketBox extends Box{

    TicketBox(Rect rect, color c, int stroke_weight, int corner_size){
        super(rect, c, stroke_weight, corner_size);
    }

    void draw(){

        setup_draw();

        // do the background rectangle
        strokeWeight(max(stroke_weight-1,0));
        rect(r.get_x() + corner_size/2, r.get_y() + corner_size/2, r.get_w() - corner_size, r.get_h() - corner_size);

        // the main box
        strokeWeight(stroke_weight);
        int x1 = r.get_x() + corner_size;
        int x2 = r.get_x() + r.get_w() - corner_size;
        int x3 = r.get_x() + r.get_w();
        int y1 = r.get_y() + corner_size;
        int y2 = r.get_y() + r.get_h() - corner_size;
        int y3 = r.get_y() + r.get_h();
        beginShape();
        vertex(x1, r.get_y());

        // top right corner
        vertex(x2, r.get_y());
        bezierVertex(x2, y1, x3, y1, x3, y1);

        // bottom right corner
        vertex(x3,y2);
        bezierVertex(x2, y2, x2, y3, x2, y3);

        // bottom left corner
        vertex(x1,y3);
        bezierVertex(x1, y2, r.get_x(), y2, r.get_x(), y2);

        // top left corner
        vertex(r.get_x(),y1);
        bezierVertex(x1, y1, x1, r.get_y(), x1, r.get_y());

        endShape();
    
    }

}

/**
A class that represents a less fancy, but still fancy, box
*/
class DeskBox extends Box{

    int margin;

    DeskBox(Rect rect, color c, int stroke_weight, int corner_size, int margin){
        super(rect, c, stroke_weight, corner_size);
        this.margin = margin;
    }

    /**
    Draws the tab decal for each corner
    */
    void draw_corner(int x, int y, int x_dir, int y_dir) {

        beginShape();

        int x1 = x + (x_dir * corner_size);
        int y3 = y + (y_dir * corner_size);

        // the outside edges
        vertex(x1, y);
        vertex(x,y);
        vertex(x, y3);

        // the curves
        int x_cp1 = x + (x_dir * margin/2);
        int x4 = x + (x_dir * margin);
        int y4 = y + (y_dir * margin);
        bezierVertex(x_cp1, y3, x_cp1, y3, x4, y4);

        int y_cp2 = y + (y_dir * margin/2);
        bezierVertex(x1, y_cp2, x1, y_cp2, x1, y);

        endShape();

    }

    void draw() {

        setup_draw();
        fill(c, 75);

        super.draw();

        draw_corner(r.get_x(), r.get_y(), 1, 1);
        draw_corner(r.get_x()+r.get_w(), r.get_y(), -1, 1);
        draw_corner(r.get_x()+r.get_w(), r.get_y()+r.get_h(), -1, -1);
        draw_corner(r.get_x(), r.get_y()+r.get_h(), 1, -1);

    }

}


class ShieldBox extends Box {

    ShieldBox(Rect rect, color c, int stroke_weight, int corner_size){
        super(rect, c, stroke_weight, corner_size);
    }

    void draw() {

        setup_draw();

        beginShape();

        vertex(r.get_x() + r.get_w()/2, r.get_y());
        bezierVertex(r.get_x() + r.get_w()/2 + corner_size, r.get_y() + corner_size/4, r.get_x() + r.get_w() - corner_size, r.get_y() + corner_size/2, r.get_x() + r.get_w(), r.get_y() + corner_size/2);
        bezierVertex(r.get_x() + r.get_w(), r.get_y() + r.get_h() - corner_size/2, r.get_x() + r.get_w() - corner_size, r.get_y() + r.get_h() - corner_size/2, r.get_x() + r.get_w()/2, r.get_y() + r.get_h());
        bezierVertex(r.get_x() + corner_size, r.get_y() + r.get_h() - corner_size/2, r.get_x(), r.get_y() + r.get_h() - corner_size/2, r.get_x(), r.get_y() + corner_size/2);
        bezierVertex(r.get_x() + corner_size, r.get_y() + corner_size/2, r.get_x() + r.get_w()/2 - corner_size, r.get_y() + corner_size/4, r.get_x() + r.get_w()/2, r.get_y());

        endShape();

    }

}