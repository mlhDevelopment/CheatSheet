# Networking

## nmap

### Full scan
    nmap -v -A server

### Scan a single port
    nmap -Pn -p 80 server

### Scan a UDP port
    nmap -Pn -sU -p 19132 server

### Host info (windows)
    nmap -sU --script nbstat.nse -p137 server
    nmap --script smb-os-discovery.nse -p445 server

## Curl

### Basic request
    curl -k -s -f -w "%{http_code}" https://server/endpoint -o C:\etc\tmp.junk
- -k: Allow insecure connections (don't verify certificate)
- -s: Silent mode
- -v: Verbose mode
- -f: Fail silently on HTTP errors
- -w <format>: Console output with custom format
  - http_code: HTTP response code
- -o <file>: Output to file
- -A <ua>: User Agent
- -x <proxy>: Use a proxy server
- -I: Request header only
- -H <header>: Include header in request

### Post data
    curl.exe 'http://server/endpoint' --data-ascii '{"data": 42}' -H 'Content-Type: application/json'

### Monitor website
    while($true) { $(curl -k -s -f -w "%{http_code}`n" https://server/endpoint -o C:\tmp.junk); sleep 3 }

### Custom user agent (e.g. dye trace)
    curl -s -A "Mozilla/5.0 (mlhDevelopment)" "http://server/endpoint"

### Use a proxy (e.g. Fiddler)
    curl.exe 'http://server/endpoint' -x 127.0.0.1:8888

## OpenSSL

### Basic client connect
    openssl s_client -connect server:443

### Retrieve certificates
    openssl s_client -showcerts -servername server -connect server:443
- `showcerts` for chain
- `servername` for SNI

### Verify certificates
    openssl s_client -verify_return_error -servername server -connect server:443
- WIP (`verify_return_error` error on top SSL sites)

## Time & Date

### Display a chart of clock drift compared to a server
    w32tm /stripchart /dataonly /computer:pool.ntp.org

### Show time sync server
    w32tm /query /status

### Force a resync
    w32tm /resync /rediscover

### Set to use an explicit pool
    w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"

### Set to use domain heirarchy
    w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"

# Websites & Hosting

## IIS running ASP.NET Core

### Pass environment variable to Kestrel
    <aspNetCore>
        <environmentVariables>
            <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="DevLocal" />
        </environmentVariables>
    </aspNetCore>

## Azure DevOps

### Run a pipeline
    az pipelines run --project myproj --name mypipeline --branch ifnotmain

## Azure Hosting

### Install all Azure modules
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

### Install individual modules
    Install-Module Az.Websites
    Install-Module Az.Monitor
    Install-Module Az.Network

### Login
    Connect-AzAccount

### Find a website
    Get-AzWebApp | ? { $_.name -like '*test*' -and $_.name -like '*app*' } | select Name,id | fl

### Use az to tail a web log
    az webapp log tail --ids resourceid
    
