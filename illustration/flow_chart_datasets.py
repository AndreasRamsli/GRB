from graphviz import Digraph

# Create a new directed graph
grb_flowchart = Digraph("GRB_Detection_and_Data_Sources", format="png")

# Add nodes for the central circle (GRB Detection) and data sources
grb_flowchart.node("A", "GRB Detection and Location")
grb_flowchart.node("B", "IPN")
grb_flowchart.node("C", "GRBweb")
grb_flowchart.node("D", "GCN Archive")
grb_flowchart.node("E", "ASIM Data")
grb_flowchart.node("F", "Konus-WIND Data")
grb_flowchart.node("G", "Fermi/GBM Data")

# Connect each data source node to the central GRB detection node
grb_flowchart.edges(["AB", "AC", "AD", "AE", "AF", "AG"])

# Save and render the flowchart
grb_flowchart.render("grb_flowchart", view=True)
