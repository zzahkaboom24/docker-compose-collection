# Requires PowerShell 7+. Install with: winget install Microsoft.PowerShell
# Replace "path\to\file" with location to storescu.exe, in my case "C:\Users\zzahkaboom24\Software\dcmtk-3.7.0\bin\storescu.exe"
$storescu = "path\to\file"
$files = Get-ChildItem -Recurse -Filter "*.dcm" "path\to\folder"
$total = $files.Count
$counter = [System.Collections.Concurrent.ConcurrentBag[int]]::new()

# Change 32 to any number to control how many threads run simultaneously
$threads = 32

$chunks = $files | Group-Object { [math]::Floor([array]::IndexOf($files, $_) / ($total / $threads)) }
$chunks | ForEach-Object -Parallel {
    foreach ($file in $_.Group.FullName) {
        & $using:storescu -aec OHIF 192.168.178.2 4242 $file 2>&1 | Out-Null
        $c = $using:counter
        $c.Add(1)
        $done = $c.Count
        $percent = [math]::Round(($done / $using:total) * 100, 1)
        Write-Host "[$done/$using:total] $percent% - $($file | Split-Path -Leaf)"
    }
} -ThrottleLimit $threads
