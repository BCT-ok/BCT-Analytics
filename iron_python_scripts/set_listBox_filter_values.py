'''
This code shows how to set docuemnt property values to a list box filter using ironpython. 
Example code set a docuemnt property value to a list box filter, but the values can be passed any other method as well.
'''
from Spotfire.Dxp.Application import Filters as filters

#get reference to filter
myFilterPanel = Document.ActivePageReference.FilterPanel
myFilter = myFilterPanel.TableGroups[0].GetFilter("ColumnName")
listboxFilter = myFilter.FilterReference.As[filters.ListBoxFilter]()

#read values
values=Document.Properties['myDocumentPropertyName']

#set values
if values is None:
	listboxFilter.IncludeAllValues=True
else:
	#create a list/set for setting listbox filter
	setSelection=set()
	setSelection.add(values)
	listboxFilter.IncludeAllValues=False
	listboxFilter.SetSelection(setSelection)
