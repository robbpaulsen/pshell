# Assign Value to A and check the type
$a = 12
$a.GetType()

# Assign Value to b and check the type
$b = "12"
$b.GetType()

# Assign Value to c and check the type
$c = $a + $b
$c
$c.GetType()
$a.GetType()
$b.GetType()

# Assign Value to d and check the type
$d = $b + $a
$d
$d.GetType
$b.GetType
$c.GetType

# Assign Value to e and check the type
$e = "Omar"
$f = $a + $e
$f
$f.GetType
$a.GetType
$f.GetType

# Assign Value to g and check the type
$g = $e + $a
$g
$e.GetType
$a.GetType
$g.GetType

# strings
# Expandable Strings " "
"Tha value of $a is $a"

# Literal Strings ' '
'Tha value of $a is $a'

# Escape character `
"Tha value of `$a is $a"