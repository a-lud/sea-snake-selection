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
revigo.data <- rbind(c("GO:0005622","intracellular anatomical structure",40.30417387187009,0.9997804619468694,0.00022436,"intracellular anatomical structure"),
c("GO:0005829","cytosol",1.6735941329659796,0.81826391140239,6.395E-05,"cytosol"),
c("GO:0005634","nucleus",12.299943073465876,0.5003923641068392,0.67197631,"cytosol"),
c("GO:0005737","cytoplasm",24.89336809708311,0.7748691535933283,0.19795228,"cytosol"),
c("GO:0005739","mitochondrion",2.7162231428197097,0.5858060856575866,0.37244178,"cytosol"),
c("GO:0005774","vacuolar membrane",0.3920077597838171,0.5802388784240071,0.6165566,"cytosol"),
c("GO:0031090","organelle membrane",4.796175425665669,0.5861764349581644,0.33892201,"cytosol"),
c("GO:0031410","cytoplasmic vesicle",1.3570963943208312,0.5829304334947197,0.2489647,"cytosol"),
c("GO:0031982","vesicle",1.4080621150467634,0.643875256005283,0.28895232,"cytosol"),
c("GO:0043227","membrane-bounded organelle",20.921144874581575,0.5615282139540256,0.47704514,"cytosol"),
c("GO:0043228","non-membrane-bounded organelle",9.559941801621372,0.6129515843068466,0.39407892,"cytosol"),
c("GO:0043229","intracellular organelle",26.90076394949092,0.5136999293760324,0.64856585,"cytosol"),
c("GO:0043231","intracellular membrane-bounded organelle",20.46505837076719,0.4641266560939096,0.59228248,"cytosol"),
c("GO:0043232","intracellular non-membrane-bounded organelle",9.181215622847537,0.5695932515678908,0.34397701,"cytosol"),
c("GO:0098588","bounding membrane of organelle",2.152727072129673,0.5742390970127849,0.35984755,"cytosol"),
c("GO:0012505","endomembrane system",4.686256647494504,0.9998598604926859,7.382E-05,"endomembrane system"),
c("GO:0031974","membrane-enclosed lumen",2.6854766850215794,0.9998718085829473,0,"membrane-enclosed lumen"),
c("GO:0032991","protein-containing complex",14.83437673106848,1,-0,"protein-containing complex"),
c("GO:0043226","organelle",27.573029541270206,0.999799962924399,0.00011335,"organelle"),
c("GO:0110165","cellular anatomical entity",98.43624036635251,1,-0,"cellular anatomical entity"),
c("GO:1990904","ribonucleoprotein complex",4.374160563473086,0.9492593487131649,-0,"ribonucleoprotein complex"),
c("GO:0030677","ribonuclease P complex",0.04961342822621364,0.9612287685626598,0.302688,"ribonucleoprotein complex"),
c("GO:0031981","nuclear lumen",2.1374036443708238,0.47685430022036407,0.4800794,"ribonucleoprotein complex"),
c("GO:0140513","nuclear protein-containing complex",2.213174163781393,0.5430838691426836,0.46832957,"ribonucleoprotein complex"));

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

