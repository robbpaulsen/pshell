### Arrays
# Assign multiple vaslues to a variable
$a=2,42,5,7,13
$a

# Assign range operator
$a=1..10
$a
$a.GetType()

# Storing multiple data types
$a = 24, 'Omar'
$a
$a.GetType()

# Zero length arrays
$a = @()
$a.GetType()
$a.Count

# VM's Array
$p = @(Get-VM)
$p.Count

# by range
$a=1..10
$a[1..6]
$a
$a.GetType()

# Substitute a value of the index in the array
$a=1..10
$a[3]=99
$a[-8..2]
$a
$a.GetType()

