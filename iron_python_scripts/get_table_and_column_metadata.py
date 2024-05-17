'''
  This script gives the data type of the columns for given tables. 
  Simlar code can be used to get other metadata related to table and column.
'''

from Spotfire.Dxp.Data.DataOperations import DataOperation

## If you want detials for limited tables, you can create this list of table, else loop through all tables
table_names = [
    "table1", "table2", "table3"
    ]

for tbl in Document.Data.Tables:
  ## in case you want to run the script for all tables, remove if condition
	if tbl.Name in table_names:
		for col in tbl.Columns:
			print (tbl.Name ,col.Name,  col.DataType.Name)

