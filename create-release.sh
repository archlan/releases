#!/usr/bin/env bash

## Copyright (C) 2020-2021 Aditya Shakya <adi1090x@gmail.com>
## Modified by @Lanhild for ArchLan
## Everyone is permitted to copy and distribute copies of this file under GNU-GPL3

## Create new release and upload release assets

DIR=`pwd`
RFILE="$DIR/rnotes"
RELEASE=`find $DIR -type f -name "archlan-*.iso" -printf "%f\n"`
VER=`echo $RELEASE | cut -d'-' -f2 | cut -d'.' -f 1,2`
TAG="v${VER:2}"
KEY="5F765E0E531F5B53"

# Check if hub is installed or not
check_hub() {
	if [[ ! -x `which hub` ]]; then
		echo -e "\n[*] 'hub' is not installed, exiting...\n"
		exit 1
	fi
}

# Create a release notes file
create_notes() {
	echo -e "\n[*] Creating release notes file..."
	if [[ ! -f "$RFILE" ]]; then
		touch "$RFILE"
	fi
	
	cat > "$RFILE" <<- _EOF_
		`date +"%B %Y : ArchLan %Y.%m"`
				
		### ${RELEASE}

		- Verify the **\`sha256sum\`**
		\`\`\`
		\$ sha256sum -c ${RELEASE}.sha256sum
		\`\`\`

		- Verify the **\`GPG Signature\`**
		\`\`\`
		\$ gpg --recv-keys ${KEY}

		\$ gpg --verify ${RELEASE}.sig
		\`\`\`

		### Release notes: 

		[**\`All release notes\`**](https://archlan.github.io/documentation/news)		
	_EOF_
	
	echo -e "\n[*] Opening release notes file to edit changelogs..."
	if [[ -x "/usr/bin/vim" ]]; then
		vim "$RFILE"
	else
		nvim "$RFILE"
	fi	
}
	
# Create New release
create_tag() {
	echo -e "\n[*] Creating a new release tag : ${TAG}"
	hub release create -oc -F "$RFILE" ${TAG}
}

# Edit tag and upload assets
edit_tag() {
	assets=(`ls -r $DIR/files`)
	cd "$DIR/files"
	for _asset in "${assets[@]}"; do
		echo -e "\n[*] Uploading : ${_asset}"
		hub release edit -a ${_asset} -m "" ${TAG}
	done
	cd "$DIR"
}

# Clean-up
clean_repo() {
	echo -e "\n[*] Cleaning up...\n"
	rm -rf "$RFILE"
}

## Main
check_hub
create_notes
create_tag
edit_tag
clean_repo
