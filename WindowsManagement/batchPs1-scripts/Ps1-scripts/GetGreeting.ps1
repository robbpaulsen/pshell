function Get-Greeting {
    param (
        $name = "omar"
    )
    return "Hello, $name!"
}
Get-Greeting