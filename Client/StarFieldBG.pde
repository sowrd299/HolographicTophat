class StarFieldBG{
  
    int[][] star_coords;
    int[] pan_step;

    StarFieldBG(){

        // setup stars
        star_coords = new int[1000][2];
        pan_step = new int[]{1,-1};
        for(int i = 0; i < star_coords.length; i++) {
            star_coords[i][0] = (int)random(0,width);
            star_coords[i][1] = (int)random(0,height);
        }

    }

    void draw(){

        // wipe the screen
        background(5,10,25);
        // draw some stars
        stroke(255,255,230);
        for(int i = 0; i < 1000; i++){
            strokeWeight(random(1,4));
            point(star_coords[i][0], star_coords[i][1]);
            // implement pan camera (positive panning only)
            star_coords[i][0] += pan_step[0];
            if(star_coords[i][0] > width){
                star_coords[i][0] = 0;
            }

            star_coords[i][1] += pan_step[1];
            if(star_coords[i][1] > height){
                star_coords[i][1] = 0;
            }
            if(star_coords[i][1] < 0){
                star_coords[i][1] = height;
            }
        }

    }

}
