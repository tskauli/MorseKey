/*

         >>> ULTRA-COMPACT MORSE KEY <<<

    Torbjørn Skauli, LA4ZCA (tskauli@gmail.com)

                  v1.0, July 2018


DESCRIPTION

This is a compact morse key which offers precise movement with adjustable force and travel, all in a very simple 3D-printed design. There is a choice of different knob shape options (according to parameter "knobtype" in the code). The key is lightweight and needs attachment to a steady surface for good ergonomy. Holes for attachment screws are provided, or an adhesive can be used.

The design is parametric so that dimensions can be varied to suit different tastes. It is also easy to adjust the code to accommodate printer tolerances or other screw dimensions.

Spring force is adjusted by moving the spring closer or further away from the hinge. Stroke length is adjusted by the end stop screw accessible from the top.


ASSEMBLY

Materials:
-two printed parts, base and arm
-five M3 screws, 1x16 to 18mm, 2x8 to 10mm and 2x5mm length for the default design
-cable, 3-4 mm in diameter for the default design, with plug as needed

First, prepare the 3D-printed parts by removing support material under the arm and in the ends of the cable holes. Also remove any protuding edges and bumps by gently filing the surfaces. In particular, ensure that the arm has a loose fit between the side walls of the base, and that the oversized hole in the middle of the arm, for the end stop screw, is fully open.

Route the cable through the base in a 90-degree bend, which acts as a strain relief: First, route the cable into the well underneath the knob by making a loose bend outside the "window" in the side wall, then compress the bend and pull out excess cable to make a sharp bend inside the base. From the wire well, route the two conductors to the top and bottom contact screws on the base and the loose arm. Clamp the bare wire ends under their respective screws. Screws are self-threaded into the plastic. Preferably use screws with length close to the maximum calculated by the code and printed as ECHO statements. Some force is needed to enter screws into their holes.

Mount the arm onto the base with two screws at the back. Then put the spring in place in the slot underneath the arm. Choose a spring which is a bit too short, and make an initial adjustment of spring force by pulling the spring to permanently increase its length. Set the length so that the force is approximately as desired when the spring is in the middle of the slot.

Finally, enter the end stop screw from the top. For a firm end stop, first place an M4 washer in the bottom of the recess on the top of the arm and glue it in place. The arm should move freely without friction in the hinge, side walls or end stop screw.


TODO

-tapered opening for easy entry of screws into self-threading holes?
-recess head/nut of back mounting screw?
-simplify definition of grip-style knob
-dovetail attachment to other 3D-printed part as base?
-print sliding spring holder for easier adjustment
-ideally, add checks in code for relations between parameters

*/

//***************** parameters for overall shape
wxbase=25;      // width of base, mm
lybase=60;      // total length of base
hzarm=6;        // thickness of moving arm
dknob=30;       // outer diameter of knob
hzaxis=18;      // z, y pos of axis rel to back top of base
yaxis=5;        // y (forward) coordinate of axis rel. to back end
ysidewallrel=4; // length of sidewalls rel to yaxis
knobtype=3;     // 1=disk shape, 2=grip shape, 0=cylinder shape, for faster debug

//***************** parameters for rendering
cacc=8;         // accuracy of circles, multiplier for $fn. Use cacc=1 for dev/debug, =2-4 for final.
preview=1;      // =1 to preview assembly, =0 for print layout, =-1 for base only, =-2 for top only

//**************** parameters for knob
rfinger=10;     // radius of finger rest surface,sets knob height together with topangle
topangle=30;    // overhang angle at top of knob (before Minkowski smoothing)
bottangle=20;   // start angle at bottom of knob
rsmooth=0.8;    // radius of Minkowski smoothing of knob grip
redge=2.5;      // radius of disk knob edge

//**************** parameters for non-printed parts
dscrew=3;       // screw dia, also scales screw head height
dmounthole=4;   // diameter of mounting holes
darmrecess=9.5; // diameter of screw recess in arm, room for M4 washer
dcable=4;       // cable diameter
dspring=8;      // spring diameter, also sets screw ridge width
hspring=12;     // height of spring recess, max

//**************** internal or less significant parameters
stroke=1;       // default stroke length, for height estim.
wallt=5.5;        // thick and thin wall
wallmin=2;
gap=0.1;        // gap for loose fit
threaddepth=0.1;// diameter reduction for screws to self-thread into the plastic
tol=0.01;       // general tolerance

// computed quantities, common
hzscrhead=2/3*dscrew;                   // screw head height
diascrh=2.2*dscrew;                     // screw head diameter
hzbase=hzaxis-hzarm/2-2*hzscrhead-stroke;// height of base, set by hzaxis
wxarm=wxbase-2*wallt;                   // width of arm
echo(wxarm=wxarm);
wxouter=wxbase;                         // outer width of hinge and end stop
wxinner=wxarm+2*gap;                    // sideways space for arm
yknob=lybase-wxbase/2;                  // y pos of knob center
yendstop=lybase-wxbase/2-dknob/2-1*dscrew;// pos of upper end stop screw
hzscrew=hzbase;                         // height of screw hole top
lyspringch=yendstop-yaxis-dscrew-darmrecess/2;     // length and startpos. of spring trench
pyspringch=yaxis+dscrew;
wellystart=yendstop+diascrh/2;          // y start and width of wire well
wellywidth=yknob-yendstop-diascrh;

// Calculate screw lengths
echo("Max contact screw length bottom=",hzbase);
echo("Max contact screw length top=",hzarm-0.5);
echo("Max length of hinge screws=",wxbase/2-hzscrhead);
echo("Max end stop screw length=",hzaxis+hzarm/2-hzscrhead);
echo("Screw lengths exclude screw head.");

// computed quantities for grip knob
rknob0=dknob/2-rsmooth; // radius of knob before smoothing
rtorus=rknob0+0.3*rfinger;
rtop=rtorus-rfinger*(cos(topangle)); // radius of knob top before smoothing
rdimple=rfinger*1.3; // radius of top dimple
hknob0=hzarm+rfinger*(cos(bottangle)+sin(topangle)); // height of knob before smoothing
hztopcen=hknob0+rfinger*(1-sqrt(1-pow(rtop/rfinger,2))); // height of dimpling sphere center

// computed quantities for disk knob
rjoin=dknob/2-redge*(1-1/sqrt(2)); // radius and height where cone joins torus
hzjoin=hzarm-redge*(1+1/sqrt(2));
rbot=rjoin-hzjoin; // bottom radius, for 45-degree overhang, no support material needed

module teardropHole(lh,rh){ // Hole with 45-degree teardrop shape
    rotate([90,0,0])
    rotate([0,0,45])
    union(){
        cylinder(h=lh,r1=rh,r2=rh,$fn=8*cacc);
        cube([rh,rh,lh]);
    };
};


module base_add(){ // parts of base that add to shape
    // base plate
    translate([-wxbase/2,0,0])
    cube([wxbase,lybase-wxbase/2,hzbase]);
    
    // base rounded end
    translate([0,yknob,0])
    cylinder(d=wxbase,h=hzbase,$fn=12*cacc);        
    
    // outer shape of hinge, top flush with top of arm
    translate([-wxouter/2,0,0])
    cube([wxouter,yaxis*ysidewallrel,hzaxis+hzarm/2]);
};
module base_sub(){  // parts of base that cut away from shape

        // arm hinge inner
        translate([-wxinner/2,0,hzbase])
        cube([wxinner,yaxis*ysidewallrel,hzaxis+hzarm/2]);

        // hinge hole
        translate([wxbase/2,yaxis,hzaxis])
        rotate([0,0,-90])
        teardropHole(lh=wxbase,rh=dscrew/2);

        // screw head recess 1
        translate([wxbase/2+tol,yaxis,hzaxis])
        rotate([0,0,-90])
        teardropHole(lh=hzscrhead,rh=diascrh/2+gap);

        // screw head recess 2
        translate([-(wxbase/2+tol),yaxis,hzaxis])
        rotate([0,0,90])
        teardropHole(lh=hzscrhead,rh=diascrh/2+gap);

        // trench for spring
        translate([-dspring/2,pyspringch,(hzaxis+hzarm/2-wallmin)-hspring])
        cube([dspring,lyspringch,hzaxis*2]);
        
        // End stop screw hole (tight fit)
        translate([0,yendstop,0])
        cylinder(d=dscrew-threaddepth,h=hzbase+hzscrew,$fn=8*cacc);
        
        // Contact screw hole (tight fit)
        translate([0,yknob,0])
        cylinder(d=dscrew-threaddepth,h=hzbase+hzscrew,$fn=8*cacc);
 
        // wire well
        translate([-(wxbase-2*wallt)/2,wellystart,wallmin])
        cube([wxbase-2*wallt,wellywidth,hzbase]);

        // Mounting hole 1, in wire well
        translate([0,wellystart+wellywidth/2,0])
        cylinder(d=dmounthole+gap,h=hzbase+hzscrew,$fn=8*cacc);
 
        // Mounting hole 2, under rotation axis
        translate([0,yaxis,0])
        cylinder(d=dmounthole+gap,h=hzbase+hzscrew,$fn=8*cacc);
 
        //cable holes
        translate([wxbase/2-dcable/4,yendstop,dcable/2+wallmin]){
            // cable hole 1
            rotate([0,0,-45])
            teardropHole(lh=wxbase*2,rh=dcable/2);
            // cable hole 2
            rotate([0,0,-45-90])
            teardropHole(lh=wxbase/sqrt(2),rh=dcable/2);
            //cable access opening
            cube([dcable,2*dcable,dcable],center=true);
            };

};
module base(){ // complete base part
    difference(){
        base_add();
        base_sub();
    };
};

module knob_grip(){ // grip-shaped knob (XX NEEDS REVISION - use rotated polygon shape?)
    union(){
//    minkowski(){
        difference(){
            // cylinder to be carved from
            translate([0,yknob,0])
            cylinder(d=dknob,h=hknob0,$fn=20*cacc);
            // torus to form sidewall shape
            translate([0,yknob,hzarm+rfinger*cos(bottangle)])
            rotate_extrude(convexity=10,$fn=10*cacc)
            translate([rtorus, 0, 0])
            circle(r=rfinger, $fn=10*cacc);

            // sphere to form top dimple
            translate([0,yknob,hztopcen])
            sphere(r=rfinger,$fn=10*cacc);
        };
        sphere(r=rsmooth,$fn=8*cacc);
    };
    // smoothing, if enabled
//    translate([0,yknob,0])
//    cylinder(d=dknob,h=hzarm/2,$fn=20*cacc);
//};
};
module knob_disk(){ // Disk-shaped knob, works well
    
    echo("diameter of knob bottom:",rbot*2);
    
    // torus-shaped main part
    translate([0,yknob,hzarm-redge]){
        minkowski(){
            // base cylinder
            cylinder(d=dknob-2*redge,h=tol,$fn=12*cacc);
            
            // rounding sphere
            sphere(r=redge-tol/2,$fn=8*cacc);
        };
    };
        
    // conical bottom to limit sidewall overhang to max 45 degrees
    translate([0,yknob,0])
    cylinder(r2=rjoin,r1=rbot,h=hzjoin,$fn=12*cacc);
};
module knob_cyl(){ // simple cylinder-shaped knob for faster debug and test
    translate([0,yknob,0])
    cylinder(d=dknob,h=hzarm,$fn=12*cacc);
};
module knob_fingerrest(){ // preferred knob shape: disk with dimpled top
    shape=[[14.2678,4.64142], [14.7112,5.24278], [14.9572,5.94834], [14.9836,6.69506], [14.7882,7.41625], [14.3884,8.04748], [14.2678,8.17695], [13.691,8.65461], [13.0352,9.01637], [12.3236,9.24957], [11.5809,9.34602], [10.8333,9.30234], [10.1069,9.12007], [9.8615,9.02418], [9.16798,8.73871], [8.46621,8.47418], [7.75682,8.23082], [7.04045,8.00884], [6.31775,7.80845], [5.58936,7.62983], [4.85594,7.47314], [4.11815,7.33852], [3.37665,7.22609], [2.63212,7.13595], [1.88521,7.06819], [1.13661,7.02286], [0.386988,7.], [0,7.], [0,0.], [9.62635,0.] ];
    translate([0,yknob,0])
    rotate_extrude(convexity = 10,$fn=12*cacc)
    polygon(shape);
};
module arm(){ // keyer arm, additive and subtractive elements
    difference(){
        
        //additive elements
        union(){
            // arm
            translate([-wxarm/2,0,0])
            cube([wxarm,yknob,hzarm]);
            
            //knob
            if (knobtype==1){knob_disk();};
            if (knobtype==2){knob_grip();};
            if (knobtype==3){knob_fingerrest();};
            if (knobtype==0){knob_cyl ();};
            
        };
        
        // trench for spring
        translate([-dspring/2,pyspringch,0])
        cube([dspring,lyspringch,hzarm-wallmin]);
        
        // hinge hole
        translate([wxbase/2,yaxis,hzarm/2])
        rotate([0,0,-90])
        teardropHole(lh=wxbase,rh=(dscrew-threaddepth)/2);        
                
        // end stop screw hole (loose fit)
        translate([0,yendstop,0])
        cylinder(d=dscrew*1.2,h=hzarm,$fn=8*cacc);

        // end stop screw head recess
        translate([0,yendstop,hzarm-hzscrhead-stroke])
        cylinder(d=darmrecess,h=hzarm,$fn=8*cacc);
        
        // Contact screw hole (tight fit) FIX: shortened hole to 0.5 mm less than hzarm
        translate([0,yknob,0])
        cylinder(d=dscrew-threaddepth,h=hzarm-0.5,$fn=8*cacc);
        translate([0,yknob,hzarm-0.5])
        cylinder(d1=dscrew-threaddepth,d2=0,h=dscrew/2,$fn=8*cacc);

    };
};
module build_all(){ // Call modules to generate shape
if (preview==1){
    base();
    translate([0,0,hzaxis-hzarm/2])  // preview layout
    arm();}
else if (preview==-1){
    base();}
else if (preview==-2){
    arm();}
else {
    base();
    translate([max(wxbase,dknob)*1.1,0,0]) // print layout
    arm();};
};
build_all();
