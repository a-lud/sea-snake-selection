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
revigo.data <- rbind(c("GO:0000791","euchromatin",0.010653613149339828,0.7688485798924821,0.06390304,"euchromatin"),
c("GO:0000776","kinetochore",0.1845170553581813,0.7156773601382059,0.60346895,"euchromatin"),
c("GO:0000785","chromatin",0.7112100834284024,0.7043185146095501,0.69398821,"euchromatin"),
c("GO:0001725","stress fiber",0.008826294389097074,0.7684033251410118,0.23468637,"euchromatin"),
c("GO:0005940","septin ring",0.005937828256554021,0.7230904579069968,0.38131798,"euchromatin"),
c("GO:0015630","microtubule cytoskeleton",1.1931625332997238,0.6806716121929034,0.52823551,"euchromatin"),
c("GO:0030018","Z disc",0.032451189136302655,0.7569214061599073,0.25247207,"euchromatin"),
c("GO:0035267","NuA4 histone acetyltransferase complex",0.04246504917671053,0.6866571373617403,0.58077026,"euchromatin"),
c("GO:0072686","mitotic spindle",0.05422961083856692,0.7367992920246652,0.60849884,"euchromatin"),
c("GO:0005575","cellular_component",100,1,-0,"cellular_component"),
c("GO:0005622","intracellular anatomical structure",40.30417387187009,0.9998697823185846,9.415E-05,"intracellular anatomical structure"),
c("GO:0016020","membrane",61.75528715720534,0.9998603777207427,0.00035445,"membrane"),
c("GO:0016528","sarcoplasm",0.03973364817869568,0.8760956449889946,3.229E-05,"sarcoplasm"),
c("GO:0000139","Golgi membrane",0.7859156246097315,0.6880726777232633,0.69471244,"sarcoplasm"),
c("GO:0001401","SAM complex",0.012538394763678268,0.6982750646112051,0.51215281,"sarcoplasm"),
c("GO:0001650","fibrillar center",0.02419569243122271,0.6899813156239573,0.44412707,"sarcoplasm"),
c("GO:0005634","nucleus",12.299943073465876,0.6993897190587208,0.44261416,"sarcoplasm"),
c("GO:0005654","nucleoplasm",1.1935686041353335,0.6604531310689378,0.59010438,"sarcoplasm"),
c("GO:0005737","cytoplasm",24.89336809708311,0.8411096940824171,0.19795228,"sarcoplasm"),
c("GO:0005739","mitochondrion",2.7162231428197097,0.7302572712132142,0.27141176,"sarcoplasm"),
c("GO:0005759","mitochondrial matrix",0.3371000872669211,0.6583483510977989,0.69563777,"sarcoplasm"),
c("GO:0005763","mitochondrial small ribosomal subunit",0.026268186035607047,0.5919589421715098,0.65280264,"sarcoplasm"),
c("GO:0005794","Golgi apparatus",1.6851786443516696,0.7124928501173944,0.32819506,"sarcoplasm"),
c("GO:0005795","Golgi stack",0.12172164840241773,0.7556424931780061,0.54134043,"sarcoplasm"),
c("GO:0005801","cis-Golgi network",0.029738942422986366,0.776693975690173,0.4780674,"sarcoplasm"),
c("GO:0005829","cytosol",1.6735941329659796,0.8354069716118188,0.17522289,"sarcoplasm"),
c("GO:0015030","Cajal body",0.013258595868344174,0.7373307040463806,0.42890356,"sarcoplasm"),
c("GO:0016363","nuclear matrix",0.018035674472165378,0.7433765120859543,0.13169003,"sarcoplasm"),
c("GO:0031965","nuclear membrane",0.16679551115507232,0.7000031871893662,0.55672959,"sarcoplasm"),
c("GO:0044284","mitochondrial crista junction",0.0026394604314617554,0.7689744909573983,0.1136891,"sarcoplasm"),
c("GO:0061617","MICOS complex",0.029647001856433274,0.6841944941537176,0.62458208,"sarcoplasm"),
c("GO:0099128","mitochondrial iron-sulfur cluster assembly complex",0.0006933851060879212,0.7586772334768362,0.40600766,"sarcoplasm"),
c("GO:0140275","MIB complex",5.363199715597181E-05,0.7678583761162738,0.36449824,"sarcoplasm"),
c("GO:0030425","dendrite",0.11241266603891692,0.9364024160162623,3.687E-05,"dendrite"),
c("GO:0005930","axoneme",0.06935383403655097,0.658932177969238,0.69550853,"dendrite"),
c("GO:0097227","sperm annulus",0.0007278628185453317,0.8166918451002335,0.51338196,"dendrite"),
c("GO:0097546","ciliary base",0.00881863267521765,0.7919282031801794,0.59279236,"dendrite"),
c("GO:0097730","non-motile cilium",0.02625669346478791,0.778931357853852,0.63580773,"dendrite"),
c("GO:0030496","midbody",0.05904499801178525,0.9999362654409596,0,"midbody"),
c("GO:0032153","cell division site",0.13904861434073632,0.9999319457338859,3.518E-05,"cell division site"),
c("GO:0032991","protein-containing complex",14.83437673106848,1,-0,"protein-containing complex"),
c("GO:0042383","sarcolemma",0.04298604572051141,0.9504085539348698,3.246E-05,"sarcolemma"),
c("GO:0005614","interstitial matrix",0.0019843838947709567,0.9385222159832479,0.53458064,"sarcolemma"),
c("GO:0005886","plasma membrane",14.240532611702042,0.9280366274600579,0.39023759,"sarcolemma"),
c("GO:0005901","caveola",0.03927394534593021,0.9398214222951581,0.62510288,"sarcolemma"),
c("GO:0031012","extracellular matrix",0.2118846973354858,0.9303601659461913,0.22742583,"sarcolemma"),
c("GO:0032154","cleavage furrow",0.02311539077422385,0.9413650388738249,0.20732689,"sarcolemma"),
c("GO:0042995","cell projection",1.3209599208085252,0.9999168870024369,4.52E-05,"cell projection"),
c("GO:0043083","synaptic cleft",0.0027390627118942744,0.9788038613326496,2.748E-05,"synaptic cleft"),
c("GO:0005615","extracellular space",0.6728478820341237,0.9749257545113111,0.43890746,"synaptic cleft"),
c("GO:0005798","Golgi-associated vesicle",0.1327391929610302,0.7780664656953518,0.55616684,"synaptic cleft"),
c("GO:0070062","extracellular exosome",0.020564040052375474,0.800511772231652,0.50449339,"synaptic cleft"),
c("GO:0045202","synapse",0.5985560734022837,0.966693455489511,5.219E-05,"synapse"),
c("GO:0048786","presynaptic active zone",0.010576996010545583,0.9687403984059753,0.64124533,"synapse"),
c("GO:0060076","excitatory synapse",0.0058229025483626535,0.9694181534049324,0.61550489,"synapse"),
c("GO:1990904","ribonucleoprotein complex",4.374160563473086,0.8654354004222681,-0,"ribonucleoprotein complex"),
c("GO:0000346","transcription export complex",0.010902618850421125,0.7450126126261546,0.34525489,"ribonucleoprotein complex"),
c("GO:0005681","spliceosomal complex",0.3788487661959054,0.6603231189360522,0.50700372,"ribonucleoprotein complex"),
c("GO:0005732","sno(s)RNA-containing ribonucleoprotein complex",0.0742918086318401,0.8665490775141006,0.32770265,"ribonucleoprotein complex"),
c("GO:0031428","box C/D RNP complex",0.022950663925816222,0.8751202807183159,0.38404408,"ribonucleoprotein complex"),
c("GO:0032040","small-subunit processome",0.09726162684235487,0.8644298831275637,0.42326362,"ribonucleoprotein complex"),
c("GO:0034709","methylosome",0.005485787137667973,0.8107855979398195,0.2511781,"ribonucleoprotein complex"),
c("GO:0044530","supraspliceosomal complex",0.00038691655091093943,0.765464304949853,0.25445417,"ribonucleoprotein complex"),
c("GO:0070761","pre-snoRNP complex",0.001574482202221744,0.8912254491848556,0.22908062,"ribonucleoprotein complex"),
c("GO:0071013","catalytic step 2 spliceosome",0.03887936708113985,0.695723683812716,0.55500963,"ribonucleoprotein complex"),
c("GO:1990229","iron-sulfur cluster assembly complex",0.0011032867986371343,0.848532011862463,0.22347913,"ribonucleoprotein complex"));

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

