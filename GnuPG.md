# Overview and Quickstart
GnuPG (aka 'gpg') is an open source program for PGP encrypting, decrypting, and signing files. After installing, it is executed from the command line (assuming the PATH variable is updated, or you are in the correct directory). If an existing keyring is not specified, GPG will create empty ones for you.
Starting with version 2.1 the secret keys are only maintained by gpg-agent (see https://gnupg.org/faq/whats-new-in-2.1.html). Public keys are stored in the new pubring.kbx file, while the old version (and some 3rd party apps) use the pubring.pkr/secring.skr format. Operations requiring public keys can accept either format keyring, while secret key operations require the keys to be imported first.

# Configuration
To read configuration settings from a specific file, set the environment variable GNUPGHOME to the path of the configuration folder; the default configuration file path is ~/.gnupg  
The configuration file name is gpg.conf  
In the config file, to not create a default keyring, enter

	no-default-keyring
	
To use a specific keyring, enter

	keyring C:\PGPKeys\pubring.pkr

To define a primary keyring (where imported keys go), enter

	primary-keyring C:\PGPKeys\pubring.pkr

## Key Types & Codes
pub – Public key  
uid – User Id for the key  
sub – Subkey (e.g. https://security.stackexchange.com/q/43590/78812)  
ssb – Secret subkey  

## Generate Keys
Generate new public & private key pair

	gpg --full-generate-key
 
# Keys (detached management)
Explicit home folder (~/.gnupg if no path defined in $env:GNUPGHOME)

	gpg –-homedir "C:\pathTo\keys\" <other ops>

Add (public) keyring for consideration & exclude installed keyrings

	gpg --no-default-keyring --keyring "C:\pathTo\keys.kbx" <other ops>

View info for a key (?)

	gpg –-dry-run --import "C:\pathTo\key.asc"

View public keys on a keyring

	gpg –-keyring "C:\path\file.pkr" -k

View secret keys on a keyring (v2 with new, Keybox format)

	gpg –-homedir "C:\path" -K

View secret keys on a keyring (v2 with old, skr format)



Perform GPG operations with an external keyring

	gpg --no-default-k--eyring --keyring "C:\path\file.pkr"

Bypass the home directory (assuming c:\temp doesn't have a keys file)

	gpg --no-default-keyring --homedir c:\temp --keyring "C:\path\file.pkr"

Import keys to a specific keyring (v2 uses Keybox format)

	gpg --homedir "C:\path\" --import "C:\pathTo\foreignKey.asc"


# Keys (on the keyring)
List public keys
	gpg -k
List private keys
	gpg -K
List key fingerprints (public)
	gpg --fingerprint
Get a key's long ID
	gpg --list-keys --with-colon 0xA1B62738
Import a private key (imports public portion if embedded) 
	gpg --import "C:\pathTo\privateKey.asc"
Export public keys (single if User Name is provided)
	gpg --export –a –o "C:\path\output.asc" "User Name"
Export private keys (single if User Name is provided)
	gpg –-export-secret-keys –a –o "C:\path\output.asc" "User Name"

# Encrypting
Encrypt a file
	gpg –e --recipient john@client.com –o out.pgp in.docx
Encrypt a file, formatted in ASCII (aka ASCII armored)
	gpg –e -a --recipient john@client.com –o out.asc in.docx
Encrypt a file with a signature
	gpg –e --recipient john@client.com –s  –o out.pgp in.docx

# Signing
Create a signed file
	gpg –s in.docx –o out.sig
Create a detached signature
	gpg --detach-sig in.docx –o out.sig
Verify a signature (if file is encrypted, won't decrypt)
	gpg --verify in.sig
Verify a detached signature
	gpg --verify in.sig in.docx
Clearsign a document
	gpg --clearsign in.txt

# Decrypting
Decryption verifies a signature (if it is available)
Decrypt a file 
	gpg –d in.pgp
	gpg –o out.zip –d in.zip.gpg
Decrypt a file without being prompted for the password
	gpg –d --batch --passphrase mypassw0rd in.pgp
Decryption, no interaction, password stored in a file
	gpg -d -q --batch --passphrase-fd 0 in.pgp < C:\password.txt

