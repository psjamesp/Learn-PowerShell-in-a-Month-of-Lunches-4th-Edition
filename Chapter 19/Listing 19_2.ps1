$filePath = '/usr/bin/'    
get-childitem -path $filepath | get-filehash |
Sort-Object hash | Select-Object -first 10