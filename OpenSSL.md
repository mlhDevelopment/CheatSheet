# Overview

## Definitions

- PEM – Most common format, extensions include .crt, .cer, .key, .pem; can have multiple certificates and/or keys in a single file, but more common to have a single entity per file
- DER – Binary version of PEM format, extensions include .der, .cer; typically used with Java applications
- PKCS12 – Format used by Windows certificate store, extensions include .p12, .pfx; can combine certificates, chain certificates, and keys into a single file; is password protected
- PKCS7 – Format used by Windows and Tomcat, extensions include .p7b, .p7c; can combine certificates and chain certificates, but cannot include the key
- PKCS10 – Certification Request Standard, format certificate signing requests
- RSA – Format for public & private keys; aka PKCS1
- ECDSA - Elliptic Curve Digital Signature Algorithm, an alternative to RSA that is smaller & faster but not as widely adopted (e.g. IIS)
- CSR – Certificate Signing Request, typically done in PKSC10
- CA – Certificate Authority, an organization that signs CSRs and is typically the trusted party between all parties involved (e.g. server & client)

## Tips

OpenSSL is available as an open source implementation of SSL & TLS, and includes a library of cryptographic functions for SSL management. http://www.openssl.org/

OpenSSL has been ported to Windows and is maintained by Thomas J. Hruska, III. The packages required by this cheat sheet are the Win32 v1.x Light distribution and the VC++ 2008 redistributables (even when installed on x64 box) http://www.slproweb.com/products/Win32OpenSSL.html

Sometimes the `-inform <form>` parameter does not need to be specified if OpenSSL can detect it based on file extension

If not specified, the `-in <inputfile>` parameter defaults to input from STDIN

PKCS12 to PEM – OpenSSL puts all certificates and the private key into a single file. Manually separate the certificates & keys by opening the output file in a text editor and copy each certificate and then private key (including the BEGIN/END statements) to its own individual text file and save them, naming them appropriately (.crt, .key).

When creating CSRs & certificates, a lot of data entry is required. It is possible to pull the entered information from configuration files. See the documentation for more details.
 
# Configuration

To read configuration settings from a specific file, set the environment variable OPENSSL_CONF to the path of the configuration file

# Creation

### Create self-signed certificate & key (valid for 10 years)
	openssl req -x509 -days 3650 -newkey rsa:2048 –nodes -sha256 -keyout private.key -out public.crt

### Create new private key (RSA) and password protect it
	openssl genrsa –aes256 -out private.key

### Create new private key (EC)
	openssl ecparam -name secp384r1 -genkey -out private.key

### Create CSR (prompts for CSR data)
	openssl req -new -key private.key -out csr.csr

### Create CSR and a new private key
	openssl req -new -newkey rsa:2048 -nodes –keyout newkey.key -out csr.csr

### Create CSR from config file (see below)
	openssl req -new -key private.key -out csr.csr –config configfile.conf

### Create CA (valid for 20 years)
	openssl req -new -x509 -days 7300 -extensions v3_ca -sha256 -keyout CAprivate.key -out CApublic.crt

### Convert CSR to certificate as a CA (valid for 20 years)
	openssl x509 -req -days 7300 -in csr.csr -CA CApublic.crt -CAkey CAprivate.key -CAcreateserial -out public.crt

### Process for Creation using CA
1. Create a new private key for use with the new cert.
2. When prompted enter a password for the key (make sure you remember it for later). 
3. Prepare a CSR Config file.
4. Create a CSR from the key and config file.
5. Convert the CSR to a cert as a CA using the CSR file and the CA file.

# Reading

### Read PEM formatted file
    openssl x509 -inform pem -noout -text -in cert.crt

### Read DER formatted file
	openssl x509 -inform der -noout -text -in cert.der

### Read PKCS12 formatted file
	openssl pkcs12 -info -nodes -in cert.pfx

### Read a CSR (in PEM format)
	openssl req -in csr.csr -noout -text

### Read the issuer and subject DN (from a PEM)
	openssl x509 -inform pem -noout –issuer -subject -in cert.crt

### Read an RSA key (in PEM format; not very interesting)
	openssl rsa -inform pem -noout -text -in rsakey.key

### View a hash of a certificate (certificate in PEM format)
	openssl x509 –inform pem -noout -hash -in cert.crt

### Read a P7B (in PEM format)
	openssl pkcs7 -print_certs -in cert.p7b

# Conversion

### Convert PEM to DER (public certificate)
	openssl x509 -outform der -in cert.crt -out cert.der

### Convert PEM to DER (RSA private key)
	openssl rsa -outform der -in rsakey.key -out rsakey.der

### Convert PEM to PKCS12
	openssl pkcs12 -export -in public.crt -inkey private.key -out cert.pfx

#### ... with SHA2 signing capabilities (added to above)
	-CSP "Microsoft Enhanced RSA and AES Cryptographic Provider"

#### ... with friendly name (added to above)
	-name "Friendly, Exp 2099"

### Convert PKCS12 to PEM (exports as multiple certs in single file) 
	openssl pkcs12 -nodes -in cert.pfx -out cert.pem

### Convert DER to PEM
	openssl x509 -inform der -in cert.der -out certificate.crt

### Convert P7B to separate PEMs
	openssl pkcs7 -print_certs -in cert.p7b -out certificates.crt

### Convert P7B in DER to PEM
	openssl pkcs7 -inform der -in cert.p7b -out certificate.crt

### Convert PEMs to P7B
	openssl crl2pkcs7 -nocrl -certfile domain.crt -certfile ca-chain.crt -out domain.p7b

### Convert PKCS12 to DER
unsupported; use PKCS12 --> PEM --> DER

### Convert DER to PKCS12
unsupported; use DER --> PEM --> PKCS12

### Convert encrypted key to plain (encoded)
	openssl rsa -in rsakey.key -out unencrypted.key

### Convert RSA formatted key to PVK format
	openssl rsa -in rsakey.key -outform PVK -pvk-strong -out pvkkey.key

# CSR Config Example
    [ req ]
    default_bits = 2048
    distinguished_name = req_distinguished_name
    req_extensions = req_ext
    prompt = no
    output_password = includeIfGeneratingKey
    
    [ req_distinguished_name ]
    C = US
    ST = Full State
    L = City
    O = Internal
    OU = For Testing Only
    CN = Testing
    emailAddress = me@domain.com

    [ req_ext ]
    subjectAltName = @alt_names

    [ alt_names ]
    DNS.1  = Include_CN_Value
    DNS.2  = devlocal

To generate the CSR:

    openssl genrsa -out private.key
    openssl req -new -key private.key -out csr.csr –config configfile.conf
