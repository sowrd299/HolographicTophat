class StarFieldBG{
  
    float[][] star_coords;
    float[] pan_step;

    int num_layers;
    float layer_range;

    int[] sizes;

    StarFieldBG(){

        // setup stars
        star_coords = new float[10000][2];
        num_layers = 100;
        layer_range = 0.025;
        pan_step = new float[]{0.15 - layer_range, -0.15 + layer_range};
        sizes = new int[]{10, 1000, 2000, 3000};

        for(int i = 0; i < star_coords.length; i++) {
            star_coords[i][0] = random(0,width);
            star_coords[i][1] = random(0,height);
        }

    }

    private float get_pan_step(float pan_step, int i){
        return pan_step + ((pan_step < 0 ? -1 : 1) * (layer_range/num_layers) * (i%num_layers));
    }

    private int get_color_val(int i, int val_range){
        return (255-val_range) + (i % val_range);
    }

    void draw(){

        int size_index = 0;
        // wipe the screen
        background(5,10,25);
        // draw some stars
        for(int i = 0; i < 1000; i++){
            stroke(get_color_val(i, 44), get_color_val(i+7, 40), get_color_val(i+13, 36));
            strokeWeight(random(0.9, sizes.length + 1 - size_index));
            point(int(star_coords[i][0]), int(star_coords[i][1]));

            // implement pan camera (positive panning only)
            star_coords[i][0] += get_pan_step(pan_step[0], i);
            if(star_coords[i][0] > width){
                star_coords[i][0] = 0;
            }

            star_coords[i][1] += get_pan_step(pan_step[1], i);
            if(star_coords[i][1] > height){
                star_coords[i][1] = 0;
            }
            if(star_coords[i][1] < 0){
                star_coords[i][1] = height;
            }

            // decrememnt size as move down array
            if(size_index < sizes.length && i > sizes[size_index]){
                size_index++;
            }
        }

    }

}
