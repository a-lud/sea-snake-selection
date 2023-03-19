# A treemap R script produced by the Revigo server at http://revigo.irb.hr/
# If you found Revigo useful in your work, please cite the following reference:
# Supek F et al. "REVIGO summarizes and visualizes long lists of Gene Ontology
# terms" PLoS ONE 2011. doi:10.1371/journal.pone.0021800

# author: Anton Kratz <anton.kratz@gmail.com>, RIKEN Omics Science Center, Functional Genomics Technology Team, Japan
# created: Fri, Nov 02, 2012  7:25:52 PM
# last change: Fri, Nov 09, 2012  3:20:01 PM

# -----------------------------------------------------------------------------
# If you don't have the treemap package installed, uncomment the following line:
# install.packages( "treemap" );
library(treemap) 								# treemap package by Martijn Tennekes

# Set the working directory if necessary
# setwd("C:/Users/username/workingdir");

# --------------------------------------------------------------------------
# Here is your data from Revigo. Scroll down for plot configuration options.

revigo.names <- c("term_ID","description","frequency","uniqueness","dispensability","representative");
revigo.data <- rbind(c("GO:0005622","intracellular anatomical structure",40.30417387187009,0.9997709039972241,0.00022436,"intracellular anatomical structure"),
c("GO:0005829","cytosol",1.6735941329659796,0.834545597771892,6.395E-05,"cytosol"),
c("GO:0005737","cytoplasm",24.89336809708311,0.7718643786459374,0.19795228,"cytosol"),
c("GO:0012505","endomembrane system",4.686256647494504,0.9998562057153999,7.382E-05,"endomembrane system"),
c("GO:0031974","membrane-enclosed lumen",2.6854766850215794,0.9998688696344877,0,"membrane-enclosed lumen"),
c("GO:0031982","vesicle",1.4080621150467634,0.6581982227502585,6.255E-05,"vesicle"),
c("GO:0005634","nucleus",12.299943073465876,0.5096757237421312,0.67197631,"vesicle"),
c("GO:0005739","mitochondrion",2.7162231428197097,0.5960539541067195,0.37244178,"vesicle"),
c("GO:0031090","organelle membrane",4.796175425665669,0.600046906901302,0.33892201,"vesicle"),
c("GO:0031410","cytoplasmic vesicle",1.3570963943208312,0.5879561217192439,0.28895232,"vesicle"),
c("GO:0043227","membrane-bounded organelle",20.921144874581575,0.565748169317886,0.47704514,"vesicle"),
c("GO:0043228","non-membrane-bounded organelle",9.559941801621372,0.6187300280398375,0.39407892,"vesicle"),
c("GO:0043229","intracellular organelle",26.90076394949092,0.5128333969480695,0.64856585,"vesicle"),
c("GO:0043231","intracellular membrane-bounded organelle",20.46505837076719,0.4718389799943612,0.59228248,"vesicle"),
c("GO:0043232","intracellular non-membrane-bounded organelle",9.181215622847537,0.56940043469553,0.34397701,"vesicle"),
c("GO:0032991","protein-containing complex",14.83437673106848,1,-0,"protein-containing complex"),
c("GO:0043226","organelle",27.573029541270206,0.9997919769694065,0.00011335,"organelle"),
c("GO:0110165","cellular anatomical entity",98.43624036635251,1,-0,"cellular anatomical entity"),
c("GO:0140535","intracellular protein-containing complex",2.6624264188153304,0.944905481746662,-0,"intracellular protein-containing complex"),
c("GO:0030677","ribonuclease P complex",0.04961342822621364,0.956337968909809,0.28931168,"intracellular protein-containing complex"),
c("GO:0031981","nuclear lumen",2.1374036443708238,0.46864611569666365,0.4800794,"intracellular protein-containing complex"),
c("GO:0140513","nuclear protein-containing complex",2.213174163781393,0.5468201614054395,0.43706361,"intracellular protein-containing complex"));

stuff <- data.frame(revigo.data);
names(stuff) <- revigo.names;

stuff$frequency <- as.numeric( as.character(stuff$frequency) );
stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) );
stuff$dispensability <- as.numeric( as.character(stuff$dispensability) );

# by default, outputs to a PDF file
pdf( file="revigo_treemap.pdf", width=16, height=9 ) # width and height are in inches

# check the tmPlot command documentation for all possible parameters - there are a lot more
treemap(
  stuff,
  index = c("representative","description"),
  vSize = "uniqueness",
  type = "categorical",
  vColor = "representative",
  title = "Revigo TreeMap",
  inflate.labels = FALSE,      # set this to TRUE for space-filling group labels - good for posters
  lowerbound.cex.labels = 0,   # try to draw as many labels as possible (still, some small squares may not get a label)
  bg.labels = "#CCCCCCAA",   # define background color of group labels
								 # "#CCCCCC00" is fully transparent, "#CCCCCCAA" is semi-transparent grey, NA is opaque
  position.legend = "none"
)

dev.off()

