//Medidas
//hole_names          = [    1,     2,     3,      4,      5,      6,      7,      8, ouvidos, ouvidos, fim ];
holes_center_from_top = [58.05, 66.25, 90.05, 115.60, 141.65, 165.00, 189.65, 216.45, 238.85, 257.90, 317.00];
holes_diam_vertical   = [ 1.50,  2.70,  3.50,  4.40 ,   4.30,   8.00,   7.50,   5.50,   5.50,   8.00,  20,00];
holes_diam_horizontal = [ 1.50,  2.70,  3.70,  4.50 ,   4.60,   8.35,   7.50,   5.50,   5.50,   8.00,  20.00];
//holes_cone_outer_diam = [ 12.0, 12.30, 13.40, 14.60 ,  16.80,  17.20,  18.20,  19.30,  19.90,  22.00,  48.40];
holes_cone_outer_diam = [ 12.0, 12.30, 13.40, 14.60 ,  16.80,  17.20,  18.20,  19.30,  19.90,  22.00,  28];
hole_angle =            [180.0,   0.0,   0.0,   0.0 ,    0.0,    0.0,    0.0,   20.0,  180.0,   -90.0,   0.0];

lenght_from_espigo    = [0.00, 17.15, 23.45, 32.8, 46.4, 61.45, 73.65, 85.1, 98, 110.9, 123.4, 134.25, 144.1, 153.0, 157, 175.1, 184, 198.7 , 227, 241.25, 261.5, 266.3, 290.0, 317];
inner_diam            = [6.50,  4.00,  4.25,  4.5,  5.0,  5.5 ,  6.0 ,  6.5,  7,   7.5,   8.0,   8.5 ,   9.0,   9.5,  10,  10.5,  11,  11.75,  13,  14.00,  15.0,  15.5,  17.5,  20];

//Espigo
espigo_diam_exterior            = 15.30;
espigo_altura                   = 23.20;
espigo_cone_invertido_altura    = 17.15;
espigo_cone_invertido_diam_sup  =  6.50;
espigo_cone_invertido_diam_inf  =  4.00;
diam_apos_espigo                = 30.00;

diam_anilha = 48.40;
altura_anilha = 5.00;

//curve resolution
$fn=50;

//cilindro
module espigo_outside(){
  translate([0,0,-espigo_altura/2])
  cylinder(espigo_altura, espigo_diam_exterior/2, espigo_diam_exterior/2, center=true);
}


//esfera esticada na dimensao Z e cortada em dois
module encaixe_espigo(){
  translate([0,0,-espigo_altura])  
  difference(){
  scale([0.3,0.3,0.6])
    sphere(100.0/2, center=true);
  translate([0,0,15])  
    cube([30,30,30], center=true);
  }
}

//segmento exterior
module outer_segment(i){
 if(i==0){
  oheight=10;
  top_rad = holes_cone_outer_diam[i]/2 -0.2;
  bottom_rad = holes_cone_outer_diam[i]/2;

  translate([0,0,-(holes_center_from_top[i]-oheight/2)]){
    cylinder(oheight , bottom_rad, top_rad, center=true);
  }

 }
 if(i!=0){
   oheight = holes_center_from_top[i]-holes_center_from_top[i-1];  
   top_rad = holes_cone_outer_diam[i-1]/2;
   bottom_rad = holes_cone_outer_diam[i]/2;

  translate([0,0,-(holes_center_from_top[i]-oheight/2)]){
    cylinder(oheight , bottom_rad, top_rad, center=true);
  }
 }
}

//criar todos os segmentos
module cone_exterior(){
  union(){
    for (i=[0:len(holes_cone_outer_diam)-1]){ outer_segment(i); }
  }
}

//segmento interior (para remover)
module inner_segment(i){
 height = lenght_from_espigo[i]-lenght_from_espigo[i-1];  
 top_rad = inner_diam[i-1]/2;
 bottom_rad = inner_diam[i]/2;

 translate([0,0,-(lenght_from_espigo[i]-height/2)]){
      cylinder(height , bottom_rad, top_rad, center=true);
 }
}

//criar todos os segmentos interiores
module cone_interior(){
  union(){
    for (i=[1:len(inner_diam)-1]){ inner_segment(i); }
  }
}

//buraco
module hole(i, mult=1){
  rotate([0,0, hole_angle[i]]) //rodar buraco eixo z de acordo com tabela
    translate( [((2-mult)*holes_cone_outer_diam[i])/2, 0, -holes_center_from_top[i]])
      scale([1, holes_diam_horizontal[i]/20 , holes_diam_vertical[i]/20])
        rotate([0,90,0])
          cylinder(mult*holes_cone_outer_diam[i], 10, 10, center=true); 
} 


//todos os buracos
module holes(){
  for(i=[0:len(hole_angle)-3]){
    hole(i);
  }
  hole(len(hole_angle)-2, 2);//multiplicar por 5 nos ouvidos inferiores para causar o atravessamento completo
}

module anilha(){
  translate([0,0,-holes_center_from_top[len(holes_center_from_top)-1]])
    cylinder(altura_anilha, diam_anilha/2, diam_anilha/2);
}


//Montagem
module assemble(){
  translate([0,0,lenght_from_espigo[len(lenght_from_espigo)-1]]){
    difference(){
      union(){
        espigo_outside();
        encaixe_espigo();
        cone_exterior();
        anilha();
      }
      union(){
        holes();
        cone_interior();
      }
    }
  }
}


module inserts(height, diam, insert_side=5){
  
  translate([0, diam/2-1, height])  
  rotate([0,45,0])
    cube([insert_side, 2, insert_side], center=true);

  translate([0, -diam/2+1, height])  
  rotate([0,45,0])
    cube([insert_side, 2, insert_side], center=true);

  translate([diam/2-1, 0, height])  
  rotate([0,45,90])
    cube([insert_side, 2, insert_side], center=true);

  translate([-diam/2+1, 0, height])  
  rotate([0,45, 90])
    cube([insert_side, 2, insert_side], center=true);


}

module cut_side1(height, diam){
  intersection(){
    assemble();
    union(){
      rotate([0,0,45]){
        translate([0,0,height/2])
          cube([100,100,height], center=true);
        inserts(height, diam);
      }
    }
  }
}

module cut_side2(height, diam){
  translate([0,0,-height])
  intersection(){
    difference(){
      assemble();
      rotate([0,0,45]){
        inserts(height, diam);
      }
    }
    translate([0,0, 250 + height])
      cube([200,200,500], center=true);

  }
}


//max z height printer = 250
total_height=holes_center_from_top[len(holes_center_from_top)-1];

ind= len(holes_center_from_top)-3;
cut_height= holes_center_from_top[ind];
cut_diam= holes_cone_outer_diam[ind];
//cut_side1(total_height-cut_height,cut_diam);
cut_side2(317-cut_height,cut_diam);

//assemble();
