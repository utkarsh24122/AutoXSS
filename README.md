# AutoXSS
Reflected Cross Site Scripting Scanner

# Worlflow:
- **Subdomain Enumeration** using [reconftw](https://github.com/six2dez/reconftw) 
    ( Passive, Active, Bruteforce, DNS, Source code scraping)
-  HTTP Probing using [httpx](https://github.com/projectdiscovery/httpx)
-  **Fetching URLs** with parameters using [waybackulrs](https://github.com/tomnomnom/waybackurls), [gau](https://github.com/lc/gau) & [gospider](https://github.com/jaeles-project/gospider)
-  Scanning for Cross Site Scripting using [Dalfox](https://github.com/hahwul/dalfox)

# Install:
` wget -q https://raw.githubusercontent.com/utkarsh24122/AutoXSS/main/autoxss.sh `

Make sure you have [reconftw](https://github.com/six2dez/reconftw) and all its requirements installed.

# Usage:
` ./autoxss.sh target.tld`

<img align="centre" src="https://user-images.githubusercontent.com/54320208/175944984-a6c58301-b290-4bec-940f-2579643f91be.png" width="600" /> 
