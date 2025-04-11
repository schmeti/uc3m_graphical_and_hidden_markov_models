#
# Graphical models basics
#
rm(list=ls())
#
# Many graphics libraries are available from BiocManager.
#
if (!require("BiocManager", quietly = TRUE)){install.packages("BiocManager")}
#
# Graphics libraries from BiocManager.
#
BiocManager::install("graph")
BiocManager::install("RBGL")
BiocManager::install("Matrix")
BiocManager::install("Rgraphviz")
#
# Other graphics packages.
#
if (!require("gRbase"))
  install.packages("gRbase")
if (!require("igraph"))
  install.packages("igraph")
if (!require("bnlearn")){
  install.packages("bnlearn")
}
#
# UNDIRECTED GRAPHS
#
# Creating an undirected graph. 
#
# We can do this in igraph by specifying the connected edges.
#
iug1 <- igraph::graph(c("A","B", "A","C", "B","C", "C","D"), directed = FALSE)
plot(iug1)
#
# igraph also allows us to plot "illegal" graphs.
#
illegal.graph <- igraph::graph(c("A","A", "A","C", "B","C", "C","D", "C","D"), 
                   directed = FALSE)
plot(illegal.graph)
#
# igraph is inefficient for graphs with lots of edges. In gRbase, an undirected
# graph is constructed by defining the maximal cliques.
#
ug1 <- gRbase::ug(~ A:B:C, ~ C:D)
plot(ug1)
ug1
ug1 <- gRbase::ug(~ A:B:C+C:D) 
plot(ug1)
ug1 <- gRbase::ug(~ A*B*C+C*D) 
plot(ug1)
ug1 <- gRbase::ug(c("A","B","C"), c("C","D")) 
plot(ug1)
#
# We can also convert a gRbase graph to igraph format.
#
iug1 <- as(ug1, "igraph")
plot(iug1)
#
# How would you draw the complete graph of A,B,C,D?
# How would you represent independence between D and (A,B,C) where A,B,C are all
# dependent?
#
#
# Add and quit edges in a graph.
#
ug1 <- gRbase::addEdge("A", "D", ug1)
plot(ug1)
ug1 <- gRbase::removeEdge("A", "D", ug1)
plot(ug1)
legal.graph <- igraph::delete_edges(illegal.graph, igraph::get.edge.ids(illegal.graph, 
                                                          c("A","A", "C","D")))
plot(legal.graph)
illegal.graph <- igraph::add_edges(legal.graph, c("A","A", "C","D"))
plot(illegal.graph)
#
# Checking whether a given subgraph is complete.
#
gRbase::querygraph(ug1, op = "is.complete", set = c("A","C"))
gRbase::querygraph(ug1, op = "is.complete", set = c("B","D"))
#
# Finding cliques: we can do this with the graph in igraph format.
#
igraph::cliques(iug1)
#
# Finding maximal cliques.  This can be done with igraph.
#
igraph::max_cliques(iug1)
#
# Finding neighbours.
#
igraph::neighbors(iug1,"B")
#
# Checking for separation.  This is done using gRbase.
#
gRbase::separates("A","D", c("B","C"), ug1)
gRbase::separates("A","C", c("B","D"), ug1)
#
# DIRECTED ACYCLIC GRAPHS
#
# Creating a directed acyclic graph.
#
dag1 <- gRbase::dag(~ A+B*A+C*B+D*B+E*C*D+F*E)
dag1
plot(dag1)
#
# Finding parents and children.
#
gRbase::querygraph(dag1, op = "pa", set = "E")
gRbase::querygraph(dag1, op = "ch",set = "B")
#
# Finding ancestors.
#
gRbase::querygraph(dag1,op = "ancestralSet", set = "C") 
#
# Finding descendants.
#
indic <- -1
descendents <- gRbase::querygraph(dag1, op = "ch", set = "C")
while (indic < 0){
  dnew <- gRbase::querygraph(dag1, op = "ch", set = descendents)
  dnew <- unique(c(descendents, dnew))
  if (length(dnew) == length(descendents)){
    indic <- 1
  }else{
      descendents <- dnew
  }
}
descendents
#
# Checking for d-separation.  Do this using bnlearn.
#
bndag1 <- bnlearn::as.bn(dag1)
bnlearn::dsep(bndag1, "A", "E", c("C","D"))
bnlearn::dsep(bndag1, "A", "D", c("C","E"))



