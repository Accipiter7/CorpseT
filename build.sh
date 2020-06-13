#!/usr/bin/env bash

git clone --depth 1 https://github.com/Accipiter7/CorpseT -b thine-wip /root/build/thine 

IMG=/root/build/thine/out/arch/arm64/boot/Image.gz-dtb
TCV=$("/root/build/pclang/bin/clang" --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')

export PATH=/root/build/pclang/bin:${PATH}

function sendInfo() 
{
 curl -s -X POST https://api.telegram.org/bot"${BID}"/sendMessage -d chat_id="${GID}" -d "parse_mode=HTML" -d text="$(
  for POST in "${@}"; do
   echo "${POST}"
    done
     )" 
}

function sendLog() 
{
 curl -F chat_id="${GID}" -F document=@/build.log https://api.telegram.org/bot"${BID}"/sendDocument
}

function sendZip()
{
 ZIP=$(echo /root/build/ak3/*.zip)
 curl -F chat_id="${GID}" -F document="@${ZIP}"  https://api.telegram.org/bot"${BID}"/sendDocument
}

function zipit()
{
 cp "${IMG}" /root/build/ak3
 make -C /root/build/ak3 -j8
}
function bythygrace() 
{
 sendInfo "<b>Commit: </b><code>$(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1)</code>" \
          "<b>Compile Time: </b><code>$((DIFF/1000000000)) Seconds</code>" \
          "<b>Toolchain:</b><code>${TCV}</code>" \
          "<b>ByThyGrace</b>"
 sendLog
}

function tryagain() 
{
 sendInfo "<b>Commit:</b><code>$(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1)</code>" \
          "<b>Help me Dear God! </b>" \
          "<b>Total Time Elapsed: </b><code>$((DIFF/1000000000)) Seconds</code>"
 sendLog
 exit 1;
 }

function compile() 
{
		cd /root/build/thine || exit
	    START=$(date +"%s%N")
	    make mido_defconfig &> /build.log
		make -j16 &>> /build.log \
			CC=clang \
			CROSS_COMPILE=aarch64-linux-gnu- \
			CROSS_COMPILE_ARM32=arm-linux-gnueabi-
		

if ! [ -a "$IMG" ] ; 
then																		
   END=$(date +"%s%N")
   DIFF=$((END - START))
   tryagain 

fi
  END=$(date +"%s%N")
  DIFF=$((END - START))
  bythygrace
  zipit
  sendZip
}

compile
