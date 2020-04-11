# This script invokes continuous web request to an address specified in command line argument
# Purpose: to generate some traffic in VPC flow low

$url=$args[0]
while($true)
{
    Invoke-WebRequest $url -TimeoutSec 10
    Sleep 1
}
