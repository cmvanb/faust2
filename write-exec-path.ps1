[Byte[]] $contents = [System.Text.Encoding]::UTF8.getBytes((Get-Item -Path ".\" -Verbose).FullName)
[System.IO.File]::WriteAllBytes("./exec.path", $contents)
