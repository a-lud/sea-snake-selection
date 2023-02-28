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
revigo.data <- rbind(c("GO:0000966","RNA 5'-end processing",0.10864209415606056,0.9018150565952093,0.09613643,"RNA 5'-end processing"),
c("GO:0006396","RNA processing",4.052084515125943,0.853546716119848,0.53423551,"RNA 5'-end processing"),
c("GO:0034470","ncRNA processing",2.675338577038208,0.8547712058084903,0.58894179,"RNA 5'-end processing"),
c("GO:0034660","ncRNA metabolic process",3.7632919362289554,0.8553425795402464,0.3429036,"RNA 5'-end processing"),
c("GO:0006950","response to stress",4.85393118141787,0.9711868242372257,-0,"response to stress"),
c("GO:0006974","cellular response to DNA damage stimulus",2.553180625866618,0.9564605136987877,0.65046436,"response to stress"),
c("GO:0034976","response to endoplasmic reticulum stress",0.12389646401446282,0.967218098552793,0.3383444,"response to stress"),
c("GO:0051716","cellular response to stimulus",11.92665018193055,0.9590968821794008,0.63828901,"response to stress"),
c("GO:0006996","organelle organization",3.5258104170692315,0.956081942096273,-0,"organelle organization"),
c("GO:0044085","cellular component biogenesis",4.795792386729822,0.9552563986095935,0.67668373,"organelle organization"),
c("GO:0070925","organelle assembly",0.6294646414244132,0.96139322543373,0.56651126,"organelle organization"),
c("GO:0008152","metabolic process",65.58850504615819,1,-0,"metabolic process"),
c("GO:0009056","catabolic process",6.089661456369162,0.9632875269826275,0.04835157,"catabolic process"),
c("GO:0009058","biosynthetic process",28.21250331123538,0.9447871520534703,0.07142613,"biosynthetic process"),
c("GO:0006139","nucleobase-containing compound metabolic process",24.03953065737758,0.8353472314150009,0.62483952,"biosynthetic process"),
c("GO:0006725","cellular aromatic compound metabolic process",26.79292613417935,0.9117698457042773,0.23504502,"biosynthetic process"),
c("GO:0006793","phosphorus metabolic process",13.445758050270145,0.9268805540763227,0.1534065,"biosynthetic process"),
c("GO:0006796","phosphate-containing compound metabolic process",13.135671182135214,0.9272997279314221,0.13854474,"biosynthetic process"),
c("GO:0006807","nitrogen compound metabolic process",49.550089164434496,0.9318715709948467,0.14752788,"biosynthetic process"),
c("GO:0016070","RNA metabolic process",13.496068550990763,0.8291083952123453,0.5909548,"biosynthetic process"),
c("GO:0018130","heterocycle biosynthetic process",13.69822468586519,0.8532426329776943,0.55113538,"biosynthetic process"),
c("GO:0019438","aromatic compound biosynthetic process",13.374206446172934,0.8540619657126721,0.54716201,"biosynthetic process"),
c("GO:0034641","cellular nitrogen compound metabolic process",30.54528505178458,0.8956000506888465,0.29997373,"biosynthetic process"),
c("GO:0034654","nucleobase-containing compound biosynthetic process",11.336157480410234,0.8332763296872795,0.52120986,"biosynthetic process"),
c("GO:0043170","macromolecule metabolic process",38.67120377521221,0.9231624868663669,0.19180088,"biosynthetic process"),
c("GO:0043436","oxoacid metabolic process",8.720556598016906,0.9285807641660093,0.11511881,"biosynthetic process"),
c("GO:0044237","cellular metabolic process",52.27297257740313,0.9259479890403743,0.23063781,"biosynthetic process"),
c("GO:0044238","primary metabolic process",54.341480421137625,0.9291699961689275,0.22123429,"biosynthetic process"),
c("GO:0044249","cellular biosynthetic process",26.205471674988644,0.8652156709070395,0.68616296,"biosynthetic process"),
c("GO:0044271","cellular nitrogen compound biosynthetic process",18.828945062096654,0.8410582503461299,0.61000433,"biosynthetic process"),
c("GO:0046483","heterocycle metabolic process",26.784054067682934,0.9117786404282978,0.18628936,"biosynthetic process"),
c("GO:0071704","organic substance metabolic process",59.155721653523166,0.9265244705884108,0.25577572,"biosynthetic process"),
c("GO:0090304","nucleic acid metabolic process",18.979959667166867,0.8263490798065074,0.56410817,"biosynthetic process"),
c("GO:1901360","organic cyclic compound metabolic process",27.64011374727202,0.9314192534118515,0.11377484,"biosynthetic process"),
c("GO:1901362","organic cyclic compound biosynthetic process",14.300544593303174,0.8622856258796405,0.55842492,"biosynthetic process"),
c("GO:1901564","organonitrogen compound metabolic process",30.85322786488385,0.9082253391297519,0.2017223,"biosynthetic process"),
c("GO:1901576","organic substance biosynthetic process",27.020538351942346,0.8774863219799398,0.16529832,"biosynthetic process"),
c("GO:0009987","cellular process",80.90928742480475,1,-0,"cellular process"),
c("GO:0016570","histone modification",0.5007315881434488,0.9381438013944445,-0,"histone modification"),
c("GO:0010467","gene expression",16.693722203531454,0.9066961755509105,0.29376382,"histone modification"),
c("GO:0019538","protein metabolic process",19.1169597977714,0.8904104014560792,0.33829603,"histone modification"),
c("GO:0036211","protein modification process",8.944329461413709,0.9037431624781024,0.50056465,"histone modification"),
c("GO:0043412","macromolecule modification",11.34052536927359,0.9147531711525599,0.15592651,"histone modification"),
c("GO:0044260","cellular macromolecule metabolic process",15.643185097800322,0.8899669407169069,0.31968505,"histone modification"),
c("GO:0032501","multicellular organismal process",2.3849736911150656,1,-0,"multicellular organismal process"),
c("GO:0032502","developmental process",2.3294642724475,1,0,"developmental process"),
c("GO:0033036","macromolecule localization",3.699222918000399,0.9719783103313606,-0,"macromolecule localization"),
c("GO:0033365","protein localization to organelle",0.634723393465379,0.9524503144061696,0.3256193,"macromolecule localization"),
c("GO:0051641","cellular localization",3.742193769854739,0.9646998340147989,0.41338567,"macromolecule localization"),
c("GO:0044248","cellular catabolic process",4.056548803362995,0.921625307619151,0.03414315,"cellular catabolic process"),
c("GO:0050810","regulation of steroid biosynthetic process",0.009377332179244463,0.8096546335825655,-0,"regulation of steroid biosynthetic process"),
c("GO:0006355","regulation of DNA-templated transcription",9.928869561442351,0.6197923223012202,0.59882425,"regulation of steroid biosynthetic process"),
c("GO:0009966","regulation of signal transduction",0.9172500130720875,0.7721976485497763,0.2658838,"regulation of steroid biosynthetic process"),
c("GO:0010628","positive regulation of gene expression",0.22275900791482073,0.7158739797777016,0.63047046,"regulation of steroid biosynthetic process"),
c("GO:0010646","regulation of cell communication",0.9864082534085572,0.7869297382572701,0.27220079,"regulation of steroid biosynthetic process"),
c("GO:0019222","regulation of metabolic process",12.985497578497595,0.706761078872351,0.4063976,"regulation of steroid biosynthetic process"),
c("GO:0023051","regulation of signaling",0.9919794723849535,0.7927634204659165,0.24170876,"regulation of steroid biosynthetic process"),
c("GO:0048518","positive regulation of biological process",1.9716996037287677,0.7752572414306792,0.28518046,"regulation of steroid biosynthetic process"),
c("GO:0048519","negative regulation of biological process",2.3667974229987565,0.7700801822751545,0.30652234,"regulation of steroid biosynthetic process"),
c("GO:0048523","negative regulation of cellular process",1.8278052558467632,0.6871595302166299,0.29653132,"regulation of steroid biosynthetic process"),
c("GO:0048583","regulation of response to stimulus",1.3331568005952028,0.7855843506191486,0.2683551,"regulation of steroid biosynthetic process"),
c("GO:0050790","regulation of catalytic activity",0.6853995469827777,0.7909810336530915,0.22271973,"regulation of steroid biosynthetic process"),
c("GO:0050793","regulation of developmental process",1.1758828844673783,0.7886942982933682,0.25959592,"regulation of steroid biosynthetic process"),
c("GO:0050794","regulation of cellular process",20.367259674616214,0.683690413378923,0.64719805,"regulation of steroid biosynthetic process"),
c("GO:0051128","regulation of cellular component organization",0.7906610148267887,0.7921138888651038,0.24869653,"regulation of steroid biosynthetic process"),
c("GO:0051239","regulation of multicellular organismal process",0.537170551400761,0.8061972014747935,0.16212391,"regulation of steroid biosynthetic process"),
c("GO:0051240","positive regulation of multicellular organismal process",0.22369308460477738,0.765980421531233,0.20751555,"regulation of steroid biosynthetic process"),
c("GO:0051246","regulation of protein metabolic process",2.1160693002465862,0.701559859023971,0.30937265,"regulation of steroid biosynthetic process"),
c("GO:0065009","regulation of molecular function",0.8277348843039647,0.8027755138834397,0.23256911,"regulation of steroid biosynthetic process"),
c("GO:0050896","response to stimulus",14.587937719223396,1,-0,"response to stimulus"),
c("GO:0051179","localization",18.742358479819107,1,-0,"localization"),
c("GO:0060537","muscle tissue development",0.04901409535021611,0.8674782915886059,-0,"muscle tissue development"),
c("GO:0007507","heart development",0.09448800680433317,0.8465413115056677,0.67042036,"muscle tissue development"),
c("GO:0009888","tissue development",0.43290299434072516,0.8476690141415318,0.62715908,"muscle tissue development"),
c("GO:0035239","tube morphogenesis",0.12667210115365785,0.8520774573496516,0.5315676,"muscle tissue development"),
c("GO:0072359","circulatory system development",0.1713415764548585,0.8506662757345796,0.66386673,"muscle tissue development"),
c("GO:0065007","biological regulation",22.890652894010586,1,-0,"biological regulation"),
c("GO:0071840","cellular component organization or biogenesis",9.257238504316515,0.9905108245055197,0.01412867,"cellular component organization or biogenesis"));

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

