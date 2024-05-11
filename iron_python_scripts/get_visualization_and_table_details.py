'''
  This script provides you the the details about what tables are used in the given page and visualization, 
  which can also be used to back trace use of a given table in different pages and visualization.
'''

from Spotfire.Dxp.Application.Visuals import VisualContent
from Spotfire.Dxp.Application.Visuals import *
from Spotfire.Dxp.Application.Visuals.Maps import *

tableRows = ""
for page in Document.Pages:
  for vis in page.Visuals:
		visType = vis.TypeId.Name
		#print(type(vis.As[VisualContent]()))
		if visType not in ['Spotfire.HtmlTextArea', 'Spotfire.WebMapChart']:
			row = page.Title+ '>>' + vis.Title + '>>' + visType + ">>" + vis.As[VisualContent]().Data.DataTableReference.Name
			tableRows= tableRows + row + "/n"
		elif visType == 'Spotfire.WebMapChart':
			vis = vis.As[VisualContent]()
			for layer in vis.Layers:
				#print layer.Title
				#print layer.GetType().Name == MapChartDataLayer
				if layer.GetType().Name == "MapChartDataLayer"  and layer.As[MarkerLayerVisualization]():
					#print layer.As[MarkerLayerVisualization]().Data.DataTableReference.Name
					row = page.Title+ '>>' + vis.Title + '>>' + visType + ">>" + layer.As[MarkerLayerVisualization]().Data.DataTableReference.Name
				elif layer.GetType().Name == "MapChartDataLayer"  and layer.As[FeatureLayerVisualization]():
					#print layer.As[FeatureLayerVisualization]().Data.DataTableReference.Name
					row = page.Title+ '>>' + vis.Title + '>>' + visType + ">>" + layer.As[FeatureLayerVisualization]().Data.DataTableReference.Name
			tableRows= tableRows + row + "/n"
tableRows = tableRows[:-2]		
print(tableRows)
Document.Properties["TableAndVisRelation"]=tableRows
