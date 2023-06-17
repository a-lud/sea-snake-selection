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

revigo.names <- c("term_ID","description","frequency","value","uniqueness","dispensability","representative");
revigo.data <- rbind(c("GO:0006796","phosphate-containing compound metabolic process",13.135671182135214,2.096387901395786,0.9566515201595629,0.0869499,"phosphate-containing compound metabolic process"),
c("GO:0008104","protein localization",3.0453359938674045,3.4059014807393955,0.9352803803979195,-0,"protein localization"),
c("GO:0016570","histone modification",0.5007315881434488,1.7720937319712153,0.9437108367641016,-0,"histone modification"),
c("GO:0043414","macromolecule methylation",1.4817448007413312,1.3562754731786788,0.9177522616107208,0.40592449,"histone modification"),
c("GO:0044265","cellular macromolecule catabolic process",1.4797835721040555,1.419052825876876,0.9365763872004018,0.12253661,"histone modification"),
c("GO:0050911","detection of chemical stimulus involved in sensory perception of smell",0.3963842522913882,9.104565314890612,0.8635038280980272,0,"detection of chemical stimulus involved in sensory perception of smell"),
c("GO:0002250","adaptive immune response",0.060402517911751566,4.099158840603654,0.8845548123174944,0.25407288,"detection of chemical stimulus involved in sensory perception of smell"),
c("GO:0006974","cellular response to DNA damage stimulus",2.553180625866618,2.0564809456852835,0.852660635483656,0.4792186,"detection of chemical stimulus involved in sensory perception of smell"),
c("GO:0007186","G protein-coupled receptor signaling pathway",1.579324235736624,3.4205233483257897,0.7047429264691235,0.3397478,"detection of chemical stimulus involved in sensory perception of smell"),
c("GO:0051128","regulation of cellular component organization",0.7906610148267887,2.538637739760558,0.820519785280853,-0,"regulation of cellular component organization"),
c("GO:0010605","negative regulation of macromolecule metabolic process",1.509371531596241,2.3410152280845424,0.6904969304965465,0.2602523,"regulation of cellular component organization"),
c("GO:0010608","post-transcriptional regulation of gene expression",1.4904440131883652,1.8902578789281497,0.7508970246117883,0.42830151,"regulation of cellular component organization"),
c("GO:0030162","regulation of proteolysis",0.2767293607195755,1.5454423855671187,0.7648415169946406,0.35678077,"regulation of cellular component organization"),
c("GO:0031331","positive regulation of cellular catabolic process",0.14664671620685882,1.5911564039135073,0.7260114517230299,0.33144187,"regulation of cellular component organization"),
c("GO:0050790","regulation of catalytic activity",0.6853995469827777,1.656719250113905,0.8335217610310832,0.23148419,"regulation of cellular component organization"),
c("GO:2000112","regulation of cellular macromolecule biosynthetic process",1.458974603850929,1.5437899022554498,0.7451784088796672,0.42721611,"regulation of cellular component organization"),
c("GO:0070925","organelle assembly",0.6294646414244132,2.209866560904262,0.9574436996409246,0.00944951,"organelle assembly"),
c("GO:0099116","tRNA 5'-end processing",0.07523804911202382,1.357001843139495,0.9561507796886016,0.09330831,"tRNA 5'-end processing"),
c("GO:1901576","organic substance biosynthetic process",27.020538351942346,2.212524875372608,0.934376827600649,0.06492575,"organic substance biosynthetic process"));

stuff <- data.frame(revigo.data);
names(stuff) <- revigo.names;

stuff$value <- as.numeric( as.character(stuff$value) );
stuff$frequency <- as.numeric( as.character(stuff$frequency) );
stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) );
stuff$dispensability <- as.numeric( as.character(stuff$dispensability) );

# by default, outputs to a PDF file
pdf( file="revigo_treemap.pdf", width=16, height=9 ) # width and height are in inches

# check the tmPlot command documentation for all possible parameters - there are a lot more
treemap(
  stuff,
  index = c("representative","description"),
  vSize = "value",
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

