# Copyright © 2022. TIBCO Software Inc.  Licensed under TIBCO BSD-style license.
# Author: Andrew Berridge, Gaia Paolini, February 2022

from Spotfire.Dxp.Application.Filters import *
from Spotfire.Dxp.Data import *
import Spotfire.Dxp.Application.Filters as filters
from System.Collections.Generic import List
from System import Array

myPanel = Document.ActivePageReference.FilterPanel
myFilter = myPanel.TableGroups[0].GetFilter("MyH")
chFilter = myFilter.FilterReference.As[filters.CheckBoxHierarchyFilter]()

# Uncheck all nodes
#chFilter.UncheckAllNodes()
# now set exact checks
#chFilter.Check(DistinctDataValue('MGM'),DistinctDataValue('Action'))
#chFilter.Check(DistinctDataValue('MGM'),DistinctDataValue('Horror'))

#chFilter.CheckAllNodes()
# you could append the values to this global variable while
# recursing through the hierarchy
checkedValues=[] 

#how many levels? 
print (chFilter.Hierarchy.Levels.Count)

# recursive function to traverse the tree of nodes
# takes a root node and calls itself on all its children
def traverse(node, path = ''):
	if (path == ''):
		path += str(node.FormattedValue)
	else:
		path += ">" + str(node.FormattedValue)
	
	
	pathArray = path.Split(">")
	distinctValues = Array[DistinctDataValue]([DistinctDataValue(x) for x in pathArray])
	isChecked = chFilter.IsChecked(distinctValues)
	
	# No point in going any further if not checked:
	if isChecked:
		print str(isChecked) + ":" + path
		if node.Children.Count == 0:
			print "This node is a leaf with no children!"
		for child in node.Children:			
			traverse(child, path)

rootLevel = chFilter.Hierarchy.Levels.RootLevel
found,nodes = rootLevel.TryGetNodes(100)
for node in nodes:
	traverse(node)
