$http = New-Object System.Net.HttpListener
$http.Prefixes.Add("http://localhost:8080/")
$http.Start()
Write-Host "Server running on http://localhost:8080/"

try {
    while ($http.IsListening) {
        $context = $http.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $rawPath = $request.Url.LocalPath
        if ($rawPath -eq "/" -or [string]::IsNullOrEmpty($rawPath)) {
            $rawPath = "/index.html"
        }
        
        $relPath = $rawPath.TrimStart('/')
        $filePath = Join-Path -Path $PSScriptRoot -ChildPath $relPath
        
        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            if ($filePath.EndsWith(".html")) { $response.ContentType = "text/html; charset=utf-8" }
            elseif ($filePath.EndsWith(".js")) { $response.ContentType = "application/javascript" }
            elseif ($filePath.EndsWith(".css")) { $response.ContentType = "text/css" }
            elseif ($filePath.EndsWith(".svg")) { $response.ContentType = "image/svg+xml" }
            
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        $response.Close()
    }
} finally {
    $http.Stop()
}
